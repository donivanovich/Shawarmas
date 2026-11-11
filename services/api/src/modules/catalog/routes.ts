import { Router } from 'express';
import { z } from 'zod';
import type { RowDataPacket } from 'mysql2/promise';
import { pool, rows, transaction } from '../../database.js';
import { requireEmployee, requireManager } from '../../shared/auth.js';
import { ApiError } from '../../shared/errors.js';

const router = Router();
const idParam = z.coerce.number().int().positive();

router.get('/categories', async (_request, response) => {
  const data = await rows<RowDataPacket & { id_categoria: number; categoria: string; total: number }>('SELECT c.id_categoria, c.categoria, COUNT(p.id_producto) AS total FROM categorias c LEFT JOIN productos p ON p.fk_categoria = c.id_categoria GROUP BY c.id_categoria, c.categoria ORDER BY c.id_categoria LIMIT 100');
  response.json({ data });
});

router.get('/colors', async (_request, response) => {
  const data = await rows<RowDataPacket & { id_color: number; color: string; imagen: string }>('SELECT id_color, color, imagen FROM colores ORDER BY color');
  response.json({ data });
});

router.get('/sizes', async (_request, response) => {
  const data = await rows<RowDataPacket & { id_talla: number; talla: string }>('SELECT id_talla, talla FROM tallas ORDER BY talla');
  response.json({ data });
});

router.get('/brands', async (_request, response) => {
  const data = await rows<RowDataPacket & { marca: string }>('SELECT DISTINCT marca FROM productos ORDER BY marca');
  response.json({ data });
});

router.get('/products', async (request, response) => {
  const query = z.object({
    q: z.string().trim().max(100).optional(), brand: z.string().trim().max(50).optional(), category: z.coerce.number().int().positive().optional(),
    color: z.coerce.number().int().positive().optional(), minPrice: z.coerce.number().min(0).optional(),
    maxPrice: z.coerce.number().min(0).optional(), sort: z.enum(['newest', 'price_asc', 'price_desc', 'name', 'shuffle']).default('newest'),
    seed: z.coerce.number().int().min(0).max(4294967295).default(0),
    page: z.coerce.number().int().min(1).default(1), pageSize: z.coerce.number().int().min(1).max(100).default(24)
  }).parse(request.query);
  if (query.minPrice !== undefined && query.maxPrice !== undefined && query.minPrice > query.maxPrice) throw new ApiError(400, 'INVALID_PRICE_RANGE', 'minPrice cannot exceed maxPrice');
  const where: string[] = [];
  const values: (string | number | null)[] = [];
  if (query.q) { where.push('(p.marca LIKE ? OR p.modelo LIKE ? OR COALESCE(p.descripcion, \'\') LIKE ?)'); values.push(`%${query.q}%`, `%${query.q}%`, `%${query.q}%`); }
  if (query.brand) { where.push('p.marca = ?'); values.push(query.brand); }
  if (query.category) { where.push('p.fk_categoria = ?'); values.push(query.category); }
  if (query.color) { where.push('co.id_color = ?'); values.push(query.color); }
  if (query.minPrice !== undefined) { where.push('p.precio >= ?'); values.push(query.minPrice); }
  if (query.maxPrice !== undefined) { where.push('p.precio <= ?'); values.push(query.maxPrice); }
  const orderBy = { newest: 'p.id_producto DESC', price_asc: 'p.precio ASC, p.id_producto DESC', price_desc: 'p.precio DESC, p.id_producto DESC', name: 'p.modelo ASC, p.marca ASC', shuffle: 'RAND(?)' }[query.sort];
  const orderValues = query.sort === 'shuffle' ? [query.seed] : [];
  const predicate = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const [products, totals] = await Promise.all([
    rows<RowDataPacket>(`SELECT p.id_producto, p.marca, p.modelo, p.precio, COALESCE(MAX(v.imagen), p.imagen) AS imagen, p.descripcion, c.id_categoria, c.categoria,
        co.id_color, co.color, COALESCE(SUM(v.stock), 0) AS stock, COUNT(DISTINCT v.id_variante) AS variantes
      FROM productos p INNER JOIN categorias c ON c.id_categoria = p.fk_categoria
      LEFT JOIN producto_variantes v ON v.fk_producto = p.id_producto
      LEFT JOIN colores co ON co.id_color = v.fk_color ${predicate}
      GROUP BY p.id_producto, p.marca, p.modelo, p.precio, p.imagen, p.descripcion, c.id_categoria, c.categoria, co.id_color, co.color
      ORDER BY ${orderBy} LIMIT ? OFFSET ?`, [...values, ...orderValues, query.pageSize, (query.page - 1) * query.pageSize]),
    rows<RowDataPacket & { total: number }>(`SELECT COUNT(*) AS total FROM (SELECT p.id_producto, co.id_color FROM productos p
      LEFT JOIN producto_variantes v ON v.fk_producto = p.id_producto LEFT JOIN colores co ON co.id_color = v.fk_color ${predicate}
      GROUP BY p.id_producto, co.id_color) filtered`, values)
  ]);
  response.json({ data: products, meta: { page: query.page, pageSize: query.pageSize, total: Number(totals[0]?.total ?? 0) } });
});

router.get('/products/:id', async (request, response) => {
  const id = idParam.parse(request.params.id);
  const product = await rows<RowDataPacket>(
    `SELECT p.id_producto, p.marca, p.modelo, p.precio, p.imagen, p.descripcion, p.fk_categoria, c.id_categoria, c.categoria
     FROM productos p INNER JOIN categorias c ON c.id_categoria = p.fk_categoria WHERE p.id_producto = ? LIMIT 1`, [id]
  );
  if (!product[0]) throw new ApiError(404, 'PRODUCT_NOT_FOUND', 'Product not found');
  const variants = await rows<RowDataPacket>(
    `SELECT v.id_variante, p.id_producto AS fk_producto, v.stock, COALESCE(v.imagen, p.imagen) AS imagen_producto,
       t.id_talla, t.talla, c.id_color, c.color, c.imagen AS color_imagen
     FROM productos p JOIN producto_variantes v ON v.fk_producto = p.id_producto
      JOIN tallas t ON t.id_talla = v.fk_talla JOIN colores c ON c.id_color = v.fk_color
     WHERE p.id_producto = ?
     ORDER BY t.id_talla, c.color`, [id]
  );
  response.json({ data: { ...product[0], variants } });
});

const productSchema = z.object({
  marca: z.string().trim().min(1).max(50), modelo: z.string().trim().min(1).max(100),
  precio: z.number().finite().min(0), imagen: z.string().max(255).nullable().optional(),
  descripcion: z.string().max(20000).nullable().optional(), fk_categoria: z.number().int().positive(),
  variants: z.array(z.object({ fk_talla: z.number().int().positive(), fk_color: z.number().int().positive(), stock: z.number().int().min(0), imagen: z.string().max(255).nullable().optional() }).strict()).min(1).max(500)
}).strict();

router.post('/products', requireEmployee, async (request, response) => {
  const input = productSchema.parse(request.body);
  const id = await transaction(async (connection) => {
    const [insert] = await connection.execute<import('mysql2/promise').ResultSetHeader>(
      'INSERT INTO productos (marca, modelo, precio, imagen, descripcion, fk_categoria) VALUES (?, ?, ?, ?, ?, ?)',
      [input.marca, input.modelo, input.precio, input.imagen ?? null, input.descripcion ?? null, input.fk_categoria]
    );
    for (const variant of input.variants) {
      await connection.execute('INSERT INTO producto_variantes (fk_producto, fk_talla, fk_color, imagen, stock) VALUES (?, ?, ?, ?, ?)', [insert.insertId, variant.fk_talla, variant.fk_color, variant.imagen ?? null, variant.stock]);
    }
    return insert.insertId;
  });
  response.status(201).json({ data: { id_producto: id } });
});

router.patch('/products/:id', requireManager, async (request, response) => {
  const id = idParam.parse(request.params.id);
  const input = z.object({ marca: z.string().trim().min(1).max(50).optional(), modelo: z.string().trim().min(1).max(100).optional(), precio: z.number().min(0).optional(), imagen: z.string().max(255).nullable().optional(), descripcion: z.string().max(20000).nullable().optional(), fk_categoria: z.number().int().positive().optional() }).strict().refine((value) => Object.keys(value).length > 0).parse(request.body);
  const fields: string[] = [];
  const values: (string | number | null)[] = [];
  for (const key of ['marca', 'modelo', 'precio', 'imagen', 'descripcion', 'fk_categoria'] as const) {
    if (Object.hasOwn(input, key)) { fields.push(`${key} = ?`); values.push(input[key] ?? null); }
  }
  const [result] = await pool.execute<import('mysql2/promise').ResultSetHeader>(`UPDATE productos SET ${fields.join(', ')} WHERE id_producto = ?`, [...values, id]);
  if (!result.affectedRows) throw new ApiError(404, 'PRODUCT_NOT_FOUND', 'Product not found');
  response.json({ data: { id_producto: id, updated: true } });
});

router.put('/variants/:id/stock', requireEmployee, async (request, response) => {
  const id = idParam.parse(request.params.id);
  const input = z.object({ stock: z.number().int().min(0) }).strict().parse(request.body);
  const [result] = await pool.execute<import('mysql2/promise').ResultSetHeader>('UPDATE producto_variantes SET stock = ? WHERE id_variante = ?', [input.stock, id]);
  if (!result.affectedRows) throw new ApiError(404, 'VARIANT_NOT_FOUND', 'Product variant not found');
  response.json({ data: { id_variante: id, stock: input.stock } });
});

router.post('/variants/:id/adjust-stock', requireEmployee, async (request, response) => {
  const id = idParam.parse(request.params.id);
  const input = z.object({ adjustment: z.number().int().min(-100000).max(100000) }).strict().parse(request.body);
  const [result] = await pool.execute<import('mysql2/promise').ResultSetHeader>('UPDATE producto_variantes SET stock = stock + ? WHERE id_variante = ? AND stock + ? >= 0', [input.adjustment, id, input.adjustment]);
  if (!result.affectedRows) throw new ApiError(409, 'INSUFFICIENT_STOCK', 'Stock adjustment would make inventory negative or the variant does not exist');
  response.json({ data: { id_variante: id, adjustment: input.adjustment } });
});

router.post('/categories', requireManager, async (request, response) => {
  const input = z.object({ categoria: z.string().trim().min(1).max(50) }).strict().parse(request.body);
  const [result] = await pool.execute<import('mysql2/promise').ResultSetHeader>('INSERT INTO categorias (categoria) VALUES (?)', [input.categoria]);
  response.status(201).json({ data: { id_categoria: result.insertId, ...input } });
});

router.post('/colors', requireManager, async (request, response) => {
  const input = z.object({ color: z.string().trim().min(1).max(50), imagen: z.string().trim().min(1).max(255) }).strict().parse(request.body);
  const [result] = await pool.execute<import('mysql2/promise').ResultSetHeader>('INSERT INTO colores (color, imagen) VALUES (?, ?)', [input.color, input.imagen]);
  response.status(201).json({ data: { id_color: result.insertId, ...input } });
});

router.post('/sizes', requireManager, async (request, response) => {
  const input = z.object({ talla: z.string().trim().min(1).max(20) }).strict().parse(request.body);
  const [result] = await pool.execute<import('mysql2/promise').ResultSetHeader>('INSERT INTO tallas (talla) VALUES (?)', [input.talla]);
  response.status(201).json({ data: { id_talla: result.insertId, ...input } });
});

router.get('/stores', requireEmployee, async (_request, response) => {
  const data = await rows<RowDataPacket>('SELECT id_tienda, pais, ciudad, calle, postal FROM tiendas ORDER BY ciudad');
  response.json({ data });
});

router.post('/stores', requireManager, async (request, response) => {
  const input = z.object({ pais: z.string().trim().min(1).max(50), ciudad: z.string().trim().min(1).max(80), calle: z.string().trim().min(1).max(200), postal: z.string().trim().min(1).max(15) }).strict().parse(request.body);
  const [result] = await pool.execute<import('mysql2/promise').ResultSetHeader>('INSERT INTO tiendas (pais, ciudad, calle, postal) VALUES (?, ?, ?, ?)', [input.pais, input.ciudad, input.calle, input.postal]);
  response.status(201).json({ data: { id_tienda: result.insertId, ...input } });
});

export default router;
