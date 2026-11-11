import { Router } from 'express';
import type { RowDataPacket } from 'mysql2/promise';
import { pool, rows, transaction } from '../../database.js';
import { requireAuth, requireEmployee } from '../../shared/auth.js';
import { ApiError } from '../../shared/errors.js';
import type { AuthedRequest } from '../../shared/types.js';
import { z } from 'zod';

const router = Router();
const cartInput = z.object({ items: z.array(z.object({ productId: z.number().int().positive(), variantId: z.number().int().positive(), quantity: z.number().int().min(1).max(100) }).strict()).min(1).max(100) }).strict();
const shippingInput = z.object({ pais: z.string().trim().min(1).max(50), ciudad: z.string().trim().min(1).max(80), calle: z.string().trim().min(1).max(200), postal: z.string().trim().min(1).max(15) }).strict();

const getCart = async (items: z.infer<typeof cartInput>['items'], lock = false) => {
  const unique = new Map<string, typeof items[number]>();
  for (const item of items) {
    const key = `${item.productId}:${item.variantId}`;
    const previous = unique.get(key);
    unique.set(key, { ...item, quantity: item.quantity + (previous?.quantity ?? 0) });
  }
  if ([...unique.values()].some((item) => item.quantity > 100)) throw new ApiError(400, 'INVALID_QUANTITY', 'Combined quantity cannot exceed 100 per variant');
  const results = [];
  for (const item of unique.values()) {
    const product = await rows<RowDataPacket & { id_producto: number; id_variante: number; marca: string; modelo: string; precio: number; imagen: string | null; variante_imagen: string | null; stock: number; talla: string; color: string }>(
      `SELECT p.id_producto, v.id_variante, p.marca, p.modelo, p.precio, p.imagen,
        v.imagen AS variante_imagen, v.stock, t.talla, c.color
       FROM productos p JOIN producto_variantes v ON v.fk_producto = p.id_producto
       JOIN tallas t ON t.id_talla = v.fk_talla JOIN colores c ON c.id_color = v.fk_color
       WHERE p.id_producto = ? AND v.id_variante = ? ${lock ? 'FOR UPDATE' : ''}`,
      [item.productId, item.variantId]
    );
    if (!product[0]) throw new ApiError(400, 'INVALID_VARIANT', 'A selected product variant does not exist');
    if (item.quantity > product[0].stock) throw new ApiError(409, 'INSUFFICIENT_STOCK', `Insufficient stock for ${product[0].marca} ${product[0].modelo}`, { variantId: item.variantId, available: product[0].stock });
    results.push({ ...product[0], quantity: item.quantity, subtotal: Math.round(product[0].precio * item.quantity * 100) / 100 });
  }
  return results;
};

router.post('/cart/quote', requireAuth, async (request, response) => {
  const input = cartInput.parse(request.body);
  const items = await getCart(input.items);
  response.json({ data: { items, total: Math.round(items.reduce((total, item) => total + item.subtotal, 0) * 100) / 100, itemCount: items.reduce((count, item) => count + item.quantity, 0) } });
});

router.post('/orders', requireAuth, async (request, response) => {
  const body = z.object({ ...shippingInput.shape, items: cartInput.shape.items }).strict().parse(request.body);
  const principal = (request as AuthedRequest).principal;
  if (principal.type !== 'customer') throw new ApiError(403, 'CUSTOMER_REQUIRED', 'Checkout is available to customer accounts');
  const orderId = await transaction(async (connection) => {
    const lockedItems: { item: typeof body.items[number]; variant: RowDataPacket & { id_variante: number; stock: number } }[] = [];
    const unique = new Map<string, typeof body.items[number]>();
    for (const item of body.items) {
      const key = `${item.productId}:${item.variantId}`;
      const previous = unique.get(key);
      unique.set(key, { ...item, quantity: item.quantity + (previous?.quantity ?? 0) });
    }
    for (const item of unique.values()) {
      if (item.quantity > 100) throw new ApiError(400, 'INVALID_QUANTITY', 'Combined quantity cannot exceed 100 per variant');
      const [found] = await connection.execute<RowDataPacket[]>(
        `SELECT p.id_producto, v.id_variante, p.marca, p.modelo, p.precio, v.stock
         FROM productos p JOIN producto_variantes v ON v.fk_producto = p.id_producto
         WHERE p.id_producto = ? AND v.id_variante = ? FOR UPDATE`, [item.productId, item.variantId]
      );
      const variant = found[0] as (RowDataPacket & { id_variante: number; stock: number }) | undefined;
      if (!variant) throw new ApiError(400, 'INVALID_VARIANT', 'A selected product variant does not exist');
      if (item.quantity > variant.stock) throw new ApiError(409, 'INSUFFICIENT_STOCK', 'Stock changed before checkout; review the cart');
      lockedItems.push({ item, variant });
    }
    const [stores] = await connection.execute<RowDataPacket[]>('SELECT id_tienda FROM tiendas ORDER BY id_tienda LIMIT 1');
    if (!stores[0]) throw new ApiError(503, 'STORE_UNAVAILABLE', 'No fulfillment store is configured');
    const storeId = Number((stores[0] as RowDataPacket & { id_tienda: number }).id_tienda);
    const [order] = await connection.execute<import('mysql2/promise').ResultSetHeader>(
      'INSERT INTO pedidos (fecha_entrega, pais, ciudad, calle, postal, fk_id_user, fk_tienda) VALUES (DATE_ADD(NOW(), INTERVAL 3 DAY), ?, ?, ?, ?, ?, ?)',
      [body.pais, body.ciudad, body.calle, body.postal, principal.id, storeId]
    );
    for (const { item, variant } of lockedItems) {
      const [updated] = await connection.execute<import('mysql2/promise').ResultSetHeader>('UPDATE producto_variantes SET stock = stock - ? WHERE id_variante = ? AND stock >= ?', [item.quantity, variant.id_variante, item.quantity]);
      if (updated.affectedRows !== 1) throw new ApiError(409, 'INSUFFICIENT_STOCK', 'Stock changed before checkout; review the cart');
      await connection.execute('INSERT INTO productos_pedidos (fk_variante, fk_pedido, cantidad) VALUES (?, ?, ?)', [variant.id_variante, order.insertId, item.quantity]);
    }
    return order.insertId;
  });
  response.status(201).json({ data: { id_pedido: orderId, status: 'created' } });
});

router.get('/orders', requireAuth, async (request, response) => {
  const principal = (request as AuthedRequest).principal;
  const isCustomer = principal.type === 'customer';
  const sql = `SELECT p.id_pedido, p.fecha_pedido, p.fecha_entrega, p.entregado, p.pais, p.ciudad, p.calle, p.postal,
      p.fk_id_user, c.nombre, c.apellido1, c.apellido2, c.mail,
      COALESCE(SUM(pr.precio * pp.cantidad), 0) AS total, COALESCE(SUM(pp.cantidad), 0) AS unidades
    FROM pedidos p JOIN clientes c ON c.id_user = p.fk_id_user
    LEFT JOIN productos_pedidos pp ON pp.fk_pedido = p.id_pedido
    LEFT JOIN producto_variantes v ON v.id_variante = pp.fk_variante
    LEFT JOIN productos pr ON pr.id_producto = v.fk_producto
    ${isCustomer ? 'WHERE p.fk_id_user = ?' : ''}
    GROUP BY p.id_pedido, p.fecha_pedido, p.fecha_entrega, p.entregado, p.pais, p.ciudad, p.calle, p.postal, p.fk_id_user, c.nombre, c.apellido1, c.apellido2, c.mail
    ORDER BY p.fecha_pedido DESC`;
  const orders = await rows<RowDataPacket>(sql, isCustomer ? [principal.id] : []);
  response.json({ data: orders });
});

router.get('/orders/:id', requireAuth, async (request, response) => {
  const id = z.coerce.number().int().positive().parse(request.params.id);
  const principal = (request as AuthedRequest).principal;
  const params: (string | number)[] = [id];
  let ownerCheck = '';
  if (principal.type === 'customer') { ownerCheck = 'AND p.fk_id_user = ?'; params.push(principal.id); }
  const order = await rows<RowDataPacket>(`SELECT p.id_pedido, p.fecha_pedido, p.fecha_entrega, p.entregado, p.pais, p.ciudad, p.calle, p.postal, p.fk_id_user FROM pedidos p WHERE p.id_pedido = ? ${ownerCheck} LIMIT 1`, params);
  if (!order[0]) throw new ApiError(404, 'ORDER_NOT_FOUND', 'Order not found');
  const items = await rows<RowDataPacket>(
    `SELECT pp.cantidad, pr.id_producto, pr.marca, pr.modelo, pr.precio, COALESCE(v.imagen, pr.imagen) AS imagen, v.id_variante, t.talla, c.color
     FROM productos_pedidos pp JOIN producto_variantes v ON v.id_variante = pp.fk_variante
     JOIN productos pr ON pr.id_producto = v.fk_producto JOIN tallas t ON t.id_talla = v.fk_talla JOIN colores c ON c.id_color = v.fk_color
     WHERE pp.fk_pedido = ? ORDER BY pr.marca, pr.modelo`, [id]
  );
  response.json({ data: { ...order[0], items, total: items.reduce((sum, item) => sum + Number(item.precio) * Number(item.cantidad), 0) } });
});

router.patch('/orders/:id/status', requireEmployee, async (request, response) => {
  const id = z.coerce.number().int().positive().parse(request.params.id);
  const input = z.object({ entregado: z.boolean() }).strict().parse(request.body);
  const [result] = await pool.execute<import('mysql2/promise').ResultSetHeader>('UPDATE pedidos SET entregado = ? WHERE id_pedido = ?', [input.entregado, id]);
  if (!result.affectedRows) throw new ApiError(404, 'ORDER_NOT_FOUND', 'Order not found');
  response.json({ data: { id_pedido: id, entregado: input.entregado } });
});

export default router;
