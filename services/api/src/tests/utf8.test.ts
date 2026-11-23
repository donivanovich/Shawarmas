import assert from 'node:assert/strict';
import * as nodeCrypto from 'node:crypto';
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { createServer, request as httpRequest, type IncomingHttpHeaders } from 'node:http';
import path from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';
import type { PoolConnection, ResultSetHeader } from 'mysql2/promise';

process.env.NODE_ENV = 'test';
process.env.DB_HOST = '127.0.0.1';
process.env.DB_PORT = '3307';
process.env.DB_NAME = 'shawarmas';
process.env.DB_USER = 'test';
process.env.DB_PASSWORD = 'test-only-password';
process.env.IMAGE_SERVER_URL = 'http://127.0.0.1:3000';

const { createApp } = await import('../app.js');
const { pool } = await import('../database.js');
const { requireAuth } = await import('../shared/auth.js');

const currentDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(currentDir, '../../../..');

const SAMPLE_PRODUCT_DESCRIPTION =
  'Camiseta de edición especial: diseño cómodo, algodón y máxima calidad.';
const REQUIRED_SPECIAL_CHARS = ['á', 'é', 'í', 'ó', 'ú', 'ñ', 'ü', '€'] as const;

const MOJIBAKE_PATTERNS = [
  'Ã¡',
  'Ã©',
  'Ã­',
  'Ã³',
  'Ãº',
  'Ã±',
  'Ã¼',
  'Ã\u0081',
  'Ã\u0089',
  'Ã\u008d',
  'Ã\u0093',
  'Ã\u009a',
  'Ã\u0091',
  'Ã\u009c',
  'â‚¬',
  'PantalÃ³n',
  'inspiraciÃ³n',
  'dÃa',
  'vÃ¡lida',
  '\uFFFD'
];

const assertNoMojibake = (text: string, context: string) => {
  for (const pattern of MOJIBAKE_PATTERNS) {
    assert.equal(
      text.includes(pattern),
      false,
      `Detected mojibake sequence "${pattern}" in ${context}: ${text}`
    );
  }
};

type HttpTestResponse = {
  status: number;
  headers: IncomingHttpHeaders;
  rawBody: string;
  json: <T = unknown>() => T;
};

const startTestClient = async () => {
  const app = createApp();
  const server = createServer((req, res) => {
    if (req.headers.authorization) {
      const expressReq = req as unknown as import('express').Request;
      expressReq.get = ((name: string) => req.headers[name.toLowerCase()] as string | undefined) as import('express').Request['get'];
      void requireAuth(expressReq, res as unknown as import('express').Response, () => {
        app(req, res);
      });
      return;
    }
    app(req, res);
  });
  server.on('connection', (socket) => {
    if (!socket.remoteAddress) {
      Object.defineProperty(socket, 'remoteAddress', { value: '127.0.0.1', configurable: true });
    }
  });
  const pipePath =
    process.platform === 'win32'
      ? `\\\\.\\pipe\\shawarmas-utf8-test-${process.pid}-${Date.now()}-${Math.random().toString(16).slice(2)}`
      : path.join('/tmp', `shawarmas-utf8-test-${process.pid}-${Date.now()}-${Math.random().toString(16).slice(2)}.sock`);

  await new Promise<void>((resolve, reject) => {
    server.once('error', reject);
    server.listen(pipePath, () => resolve());
  });

  const request = (
    method: string,
    urlPath: string,
    options: { headers?: Record<string, string>; body?: unknown } = {}
  ): Promise<HttpTestResponse> =>
    new Promise((resolve, reject) => {
      const payload =
        options.body === undefined
          ? undefined
          : typeof options.body === 'string'
            ? options.body
            : JSON.stringify(options.body);
      const headers: Record<string, string> = {
        Accept: 'application/json',
        ...(payload !== undefined ? { 'Content-Type': 'application/json; charset=utf-8' } : {}),
        ...(options.headers ?? {})
      };
      if (payload !== undefined) {
        headers['Content-Length'] = String(Buffer.byteLength(payload, 'utf8'));
      }

      const req = httpRequest(
        {
          socketPath: pipePath,
          path: urlPath,
          method,
          headers
        },
        (res) => {
          const chunks: Buffer[] = [];
          res.on('data', (chunk: Buffer) => chunks.push(Buffer.from(chunk)));
          res.on('end', () => {
            const rawBody = Buffer.concat(chunks).toString('utf8');
            resolve({
              status: res.statusCode ?? 0,
              headers: res.headers,
              rawBody,
              json: <T = unknown>() => JSON.parse(rawBody) as T
            });
          });
        }
      );
      req.on('error', reject);
      if (payload !== undefined) {
        req.write(payload, 'utf8');
      }
      req.end();
    });

  const close = () =>
    new Promise<void>((resolve, reject) => {
      server.close((error) => (error ? reject(error) : resolve()));
    });

  return { request, close };
};

type StoredProduct = {
  id_producto: number;
  marca: string;
  modelo: string;
  precio: number;
  imagen: string | null;
  descripcion: string | null;
  fk_categoria: number;
};

type StoredVariant = {
  id_variante: number;
  fk_producto: number;
  fk_talla: number;
  fk_color: number;
  imagen: string | null;
  stock: number;
};

type StoredCustomer = {
  id_user: number;
  nombre: string;
  apellido1: string;
  apellido2: string | null;
  mail: string;
  passw: string;
  creado_en: string;
};

type StoredOrder = {
  id_pedido: number;
  fecha_pedido: string;
  fecha_entrega: string;
  entregado: number;
  pais: string;
  ciudad: string;
  calle: string;
  postal: string;
  fk_id_user: number;
  fk_tienda: number;
};

type StoredOrderItem = {
  fk_variante: number;
  fk_pedido: number;
  cantidad: number;
};

const createIsolatedDatabaseMock = () => {
  const categories = new Map<number, string>([
    [1, 'Zapatillas'],
    [2, 'Sudaderas'],
    [3, 'Camisetas'],
    [4, 'Pantalones'],
    [5, 'Accesorios'],
    [6, 'Abrigos']
  ]);
  const colors = new Map<number, { color: string; imagen: string }>([
    [1, { color: 'Blanco', imagen: '/colors/white.png' }],
    [2, { color: 'Negro', imagen: '/colors/black.png' }]
  ]);
  const sizes = new Map<number, string>([
    [12, 'S'],
    [13, 'M'],
    [14, 'L']
  ]);
  const stores = new Map<number, { id_tienda: number; pais: string; ciudad: string; calle: string; postal: string }>([
    [1, { id_tienda: 1, pais: 'España', ciudad: 'Madrid', calle: 'Calle de Velarde, 10', postal: '28004' }]
  ]);

  const products = new Map<number, StoredProduct>();
  const variants = new Map<number, StoredVariant>();
  const customers = new Map<number, StoredCustomer>();
  const employees = new Map<number, { id_empleado: number; mode_use: 'admin' | 'editor' | 'writter' }>([
    [1, { id_empleado: 1, mode_use: 'admin' }]
  ]);
  const sessions = new Map<
    string,
    { id_session: string; token_hash: string; user_type: 'customer' | 'employee'; user_id: number; expires_at: Date; revoked_at: Date | null }
  >();
  const orders = new Map<number, StoredOrder>();
  const orderItems: StoredOrderItem[] = [];

  let nextProductId = 100;
  let nextVariantId = 1000;
  let nextCustomerId = 50;
  let nextOrderId = 500;

  const employeeToken = 'a'.repeat(48);
  const employeeTokenHash = nodeCrypto.createHash('sha256').update(employeeToken).digest('hex');
  sessions.set(employeeTokenHash, {
    id_session: '00000000-0000-4000-8000-000000000001',
    token_hash: employeeTokenHash,
    user_type: 'employee',
    user_id: 1,
    expires_at: new Date(Date.now() + 86400 * 1000),
    revoked_at: null
  });

  const executeQuery = async (sql: string, values: unknown[] = []): Promise<[unknown, unknown]> => {
    const normalized = sql.replace(/\s+/g, ' ').trim();

    if (normalized.startsWith('SELECT id_session, user_type, user_id, expires_at, revoked_at FROM api_sessions')) {
      const hash = String(values[0]);
      const session = sessions.get(hash);
      return [session ? [session] : [], []];
    }

    if (normalized.startsWith('INSERT INTO api_sessions')) {
      const [idSession, tokenHash, userType, userId] = values as [string, string, 'customer' | 'employee', number];
      sessions.set(tokenHash, {
        id_session: idSession,
        token_hash: tokenHash,
        user_type: userType,
        user_id: Number(userId),
        expires_at: new Date(Date.now() + 86400 * 1000),
        revoked_at: null
      });
      return [{ affectedRows: 1, insertId: 0 } as ResultSetHeader, []];
    }

    if (normalized.startsWith('SELECT mode_use FROM empleados WHERE id_empleado = ?')) {
      const emp = employees.get(Number(values[0]));
      return [emp ? [{ mode_use: emp.mode_use }] : [], []];
    }

    if (normalized.startsWith('SELECT id_user FROM clientes WHERE mail = ?')) {
      const email = String(values[0]);
      const excludeId = values.length > 1 ? Number(values[1]) : undefined;
      const found = [...customers.values()].filter((c) => c.mail === email && c.id_user !== excludeId);
      return [found.map((c) => ({ id_user: c.id_user })), []];
    }

    if (normalized.startsWith('SELECT id_empleado FROM empleados WHERE mail = ?')) {
      return [[], []];
    }

    if (normalized.startsWith('INSERT INTO clientes (nombre, apellido1, apellido2, mail, passw)')) {
      const [nombre, apellido1, apellido2, mail, passw] = values as [string, string, string | null, string, string];
      const id = nextCustomerId++;
      customers.set(id, {
        id_user: id,
        nombre,
        apellido1,
        apellido2: apellido2 ?? null,
        mail,
        passw,
        creado_en: '2026-11-23T15:00:00.000Z'
      });
      return [{ affectedRows: 1, insertId: id } as ResultSetHeader, []];
    }

    if (normalized.startsWith('SELECT id_user FROM clientes WHERE id_user = ?')) {
      const customer = customers.get(Number(values[0]));
      return [customer ? [{ id_user: customer.id_user }] : [], []];
    }

    if (normalized.startsWith('SELECT * FROM clientes WHERE id_user = ?')) {
      const customer = customers.get(Number(values[0]));
      return [customer ? [{ ...customer }] : [], []];
    }

    if (normalized.startsWith('UPDATE clientes SET nombre = ?, apellido1 = ?, apellido2 = ?, mail = ? WHERE id_user = ?')) {
      const [nombre, apellido1, apellido2, mail, id] = values as [string, string, string | null, string, number];
      const customer = customers.get(Number(id));
      if (!customer) return [{ affectedRows: 0 } as ResultSetHeader, []];
      customer.nombre = nombre;
      customer.apellido1 = apellido1;
      customer.apellido2 = apellido2 ?? null;
      customer.mail = mail;
      return [{ affectedRows: 1 } as ResultSetHeader, []];
    }

    if (normalized.startsWith('INSERT INTO productos (marca, modelo, precio, imagen, descripcion, fk_categoria)')) {
      const [marca, modelo, precio, imagen, descripcion, fkCategoria] = values as [
        string,
        string,
        number,
        string | null,
        string | null,
        number
      ];
      const id = nextProductId++;
      products.set(id, {
        id_producto: id,
        marca,
        modelo,
        precio: Number(precio),
        imagen: imagen ?? null,
        descripcion: descripcion ?? null,
        fk_categoria: Number(fkCategoria)
      });
      return [{ affectedRows: 1, insertId: id } as ResultSetHeader, []];
    }

    if (normalized.startsWith('INSERT INTO producto_variantes (fk_producto, fk_talla, fk_color, imagen, stock)')) {
      const [fkProducto, fkTalla, fkColor, imagen, stock] = values as [number, number, number, string | null, number];
      const id = nextVariantId++;
      variants.set(id, {
        id_variante: id,
        fk_producto: Number(fkProducto),
        fk_talla: Number(fkTalla),
        fk_color: Number(fkColor),
        imagen: imagen ?? null,
        stock: Number(stock)
      });
      return [{ affectedRows: 1, insertId: id } as ResultSetHeader, []];
    }

    if (normalized.startsWith('UPDATE productos SET ')) {
      const id = Number(values[values.length - 1]);
      const product = products.get(id);
      if (!product) return [{ affectedRows: 0 } as ResultSetHeader, []];
      const setClause = normalized.slice('UPDATE productos SET '.length, normalized.indexOf(' WHERE id_producto = ?'));
      const columns = setClause.split(',').map((part) => part.trim().split(' ')[0]!);
      columns.forEach((col, index) => {
        const val = values[index];
        if (col === 'marca') product.marca = String(val);
        if (col === 'modelo') product.modelo = String(val);
        if (col === 'precio') product.precio = Number(val);
        if (col === 'imagen') product.imagen = val === null ? null : String(val);
        if (col === 'descripcion') product.descripcion = val === null ? null : String(val);
        if (col === 'fk_categoria') product.fk_categoria = Number(val);
      });
      return [{ affectedRows: 1 } as ResultSetHeader, []];
    }

    if (normalized.startsWith('SELECT p.id_producto, p.marca, p.modelo, p.precio, p.imagen, p.descripcion, p.fk_categoria, c.id_categoria, c.categoria FROM productos p')) {
      const id = Number(values[0]);
      const product = products.get(id);
      if (!product) return [[], []];
      const categoria = categories.get(product.fk_categoria) ?? 'Camisetas';
      return [
        [
          {
            ...product,
            id_categoria: product.fk_categoria,
            categoria
          }
        ],
        []
      ];
    }

    if (normalized.startsWith('SELECT v.id_variante, p.id_producto AS fk_producto, v.stock')) {
      const id = Number(values[0]);
      const product = products.get(id);
      if (!product) return [[], []];
      const rows = [...variants.values()]
        .filter((v) => v.fk_producto === id)
        .map((v) => {
          const color = colors.get(v.fk_color) ?? { color: 'Blanco', imagen: '/colors/white.png' };
          const talla = sizes.get(v.fk_talla) ?? 'M';
          return {
            id_variante: v.id_variante,
            fk_producto: product.id_producto,
            stock: v.stock,
            imagen_producto: v.imagen ?? product.imagen,
            id_talla: v.fk_talla,
            talla,
            id_color: v.fk_color,
            color: color.color,
            color_imagen: color.imagen
          };
        });
      return [rows, []];
    }

    if (normalized.startsWith('SELECT p.id_producto, p.marca, p.modelo, p.precio, COALESCE(MAX(v.imagen), p.imagen) AS imagen, p.descripcion')) {
      const term = values.length > 2 ? String(values[0]).replace(/^%|%$/g, '').toLowerCase() : '';
      const matched = [...products.values()]
        .filter((p) => {
          if (!term) return true;
          return (
            p.marca.toLowerCase().includes(term) ||
            p.modelo.toLowerCase().includes(term) ||
            (p.descripcion ?? '').toLowerCase().includes(term)
          );
        })
        .map((p) => {
          const prodVariants = [...variants.values()].filter((v) => v.fk_producto === p.id_producto);
          const firstVar = prodVariants[0];
          const color = firstVar ? colors.get(firstVar.fk_color) : undefined;
          return {
            id_producto: p.id_producto,
            marca: p.marca,
            modelo: p.modelo,
            precio: p.precio,
            imagen: firstVar?.imagen ?? p.imagen,
            descripcion: p.descripcion,
            id_categoria: p.fk_categoria,
            categoria: categories.get(p.fk_categoria) ?? 'Camisetas',
            id_color: firstVar?.fk_color ?? null,
            color: color?.color ?? null,
            stock: prodVariants.reduce((sum, v) => sum + v.stock, 0),
            variantes: prodVariants.length
          };
        });
      return [matched, []];
    }

    if (normalized.startsWith('SELECT COUNT(*) AS total FROM (SELECT p.id_producto, co.id_color FROM productos p')) {
      return [[{ total: products.size }], []];
    }

    if (normalized.startsWith('SELECT p.id_producto, v.id_variante, p.marca, p.modelo, p.precio, v.stock FROM productos p JOIN producto_variantes v')) {
      const [productId, variantId] = values as [number, number];
      const product = products.get(Number(productId));
      const variant = variants.get(Number(variantId));
      if (!product || !variant || variant.fk_producto !== product.id_producto) return [[], []];
      return [
        [
          {
            id_producto: product.id_producto,
            id_variante: variant.id_variante,
            marca: product.marca,
            modelo: product.modelo,
            precio: product.precio,
            stock: variant.stock
          }
        ],
        []
      ];
    }

    if (normalized.startsWith('SELECT id_tienda FROM tiendas')) {
      const firstStore = [...stores.values()][0];
      return [firstStore ? [{ id_tienda: firstStore.id_tienda }] : [], []];
    }

    if (normalized.startsWith('INSERT INTO pedidos ')) {
      const [pais, ciudad, calle, postal, customerId, storeId] = values as [string, string, string, string, number, number];
      const id = nextOrderId++;
      orders.set(id, {
        id_pedido: id,
        fecha_pedido: '2026-11-23 15:00:00',
        fecha_entrega: '2026-11-26 15:00:00',
        entregado: 0,
        pais,
        ciudad,
        calle,
        postal,
        fk_id_user: Number(customerId),
        fk_tienda: Number(storeId)
      });
      return [{ affectedRows: 1, insertId: id } as ResultSetHeader, []];
    }

    if (normalized.startsWith('UPDATE producto_variantes SET stock = stock - ? WHERE id_variante = ? AND stock >= ?')) {
      const [qty, variantId] = values as [number, number];
      const variant = variants.get(Number(variantId));
      if (!variant || variant.stock < Number(qty)) return [{ affectedRows: 0 } as ResultSetHeader, []];
      variant.stock -= Number(qty);
      return [{ affectedRows: 1 } as ResultSetHeader, []];
    }

    if (normalized.startsWith('INSERT INTO productos_pedidos (fk_variante, fk_pedido, cantidad)')) {
      const [fkVariante, fkPedido, cantidad] = values as [number, number, number];
      orderItems.push({ fk_variante: Number(fkVariante), fk_pedido: Number(fkPedido), cantidad: Number(cantidad) });
      return [{ affectedRows: 1, insertId: orderItems.length } as ResultSetHeader, []];
    }

    if (normalized.startsWith('SELECT p.id_pedido, p.fecha_pedido, p.fecha_entrega, p.entregado, p.pais, p.ciudad, p.calle, p.postal, p.fk_id_user FROM pedidos p WHERE p.id_pedido = ?')) {
      const id = Number(values[0]);
      const order = orders.get(id);
      if (!order) return [[], []];
      return [[{ ...order }], []];
    }

    if (normalized.startsWith('SELECT pp.cantidad, pr.id_producto, pr.marca, pr.modelo, pr.precio')) {
      const orderId = Number(values[0]);
      const items = orderItems
        .filter((item) => item.fk_pedido === orderId)
        .map((item) => {
          const variant = variants.get(item.fk_variante)!;
          const product = products.get(variant.fk_producto)!;
          const color = colors.get(variant.fk_color) ?? { color: 'Blanco', imagen: '/colors/white.png' };
          const talla = sizes.get(variant.fk_talla) ?? 'M';
          return {
            cantidad: item.cantidad,
            id_producto: product.id_producto,
            marca: product.marca,
            modelo: product.modelo,
            precio: product.precio,
            imagen: variant.imagen ?? product.imagen,
            id_variante: variant.id_variante,
            talla,
            color: color.color
          };
        });
      return [items, []];
    }

    throw new Error(`Unhandled SQL in isolated UTF-8 test mock: ${normalized}`);
  };

  return {
    employeeToken,
    products,
    customers,
    orders,
    executeQuery
  };
};

const withMockDatabase = async (fn: (mockDb: ReturnType<typeof createIsolatedDatabaseMock>) => Promise<void>) => {
  const mockDb = createIsolatedDatabaseMock();
  const originalExecute = pool.execute.bind(pool);
  const originalGetConnection = pool.getConnection.bind(pool);

  async function executeShim(sql: string, values?: unknown[]) {
    return mockDb.executeQuery(sql, values ?? []);
  }

  (pool as unknown as { execute: typeof executeShim }).execute = executeShim;
  (pool as unknown as { getConnection: () => Promise<PoolConnection> }).getConnection = async () =>
    ({
      beginTransaction: async () => {},
      commit: async () => {},
      rollback: async () => {},
      release: () => {},
      execute: executeShim
    }) as unknown as PoolConnection;

  try {
    await fn(mockDb);
  } finally {
    (pool as unknown as { execute: typeof originalExecute }).execute = originalExecute;
    (pool as unknown as { getConnection: typeof originalGetConnection }).getConnection = originalGetConnection;
  }
};

test('1. Prueba de inserción de un producto con caracteres españoles (á é í ó ú ñ ü €)', async () => {
  await withMockDatabase(async (mockDb) => {
    const client = await startTestClient();
    try {
      const descriptionWithAllChars = `${SAMPLE_PRODUCT_DESCRIPTION} Caracteres: ${REQUIRED_SPECIAL_CHARS.join(' ')}`;
      const createRes = await client.request('POST', '/api/v1/products', {
        headers: { Authorization: `Bearer ${mockDb.employeeToken}` },
        body: {
          marca: 'Diseño Español & Co.',
          modelo: 'Colección Pingüino Edición ÁÉÍÓÚÑÜ €',
          precio: 34.95,
          imagen: '/products/swm-essentials-shirt-beige.png',
          descripcion: descriptionWithAllChars,
          fk_categoria: 3,
          variants: [{ fk_talla: 13, fk_color: 1, stock: 20 }]
        }
      });

      assert.equal(createRes.status, 201);
      const createdId = createRes.json<{ data: { id_producto: number } }>().data.id_producto;
      const storedRow = mockDb.products.get(createdId);
      assert.ok(storedRow, 'Product row must exist in isolated MySQL store');
      assert.strictEqual(storedRow.descripcion, descriptionWithAllChars);
      assert.strictEqual(storedRow.marca, 'Diseño Español & Co.');
      assert.strictEqual(storedRow.modelo, 'Colección Pingüino Edición ÁÉÍÓÚÑÜ €');
      assertNoMojibake(storedRow.descripcion ?? '', 'Inserted MySQL product description');
    } finally {
      await client.close();
    }
  });
});

test('2. Prueba de lectura del mismo producto desde MySQL preservando exactamente los caracteres UTF-8', async () => {
  await withMockDatabase(async (mockDb) => {
    const client = await startTestClient();
    try {
      const descriptionWithAllChars = `${SAMPLE_PRODUCT_DESCRIPTION} (${REQUIRED_SPECIAL_CHARS.join(' ')})`;
      const createRes = await client.request('POST', '/api/v1/products', {
        headers: { Authorization: `Bearer ${mockDb.employeeToken}` },
        body: {
          marca: 'SWM',
          modelo: 'Pantalón Inspiración Día a Día',
          precio: 49.99,
          descripcion: descriptionWithAllChars,
          fk_categoria: 4,
          variants: [{ fk_talla: 13, fk_color: 2, stock: 12 }]
        }
      });
      const productId = createRes.json<{ data: { id_producto: number } }>().data.id_producto;

      const getRes = await client.request('GET', `/api/v1/products/${productId}`);
      assert.equal(getRes.status, 200);
      const product = getRes.json<{ data: { id_producto: number; modelo: string; descripcion: string } }>().data;
      assert.strictEqual(product.modelo, 'Pantalón Inspiración Día a Día');
      assert.strictEqual(product.descripcion, descriptionWithAllChars);
      for (const ch of REQUIRED_SPECIAL_CHARS) {
        assert.equal(product.descripcion.includes(ch), true, `Missing character "${ch}" when reading from MySQL`);
      }
    } finally {
      await client.close();
    }
  });
});

test('3. Prueba de respuesta JSON de la API (Content-Type UTF-8, serialización íntegra y búsqueda)', async () => {
  await withMockDatabase(async (mockDb) => {
    const client = await startTestClient();
    try {
      const fullDescription = `${SAMPLE_PRODUCT_DESCRIPTION} Símbolos: á é í ó ú ñ ü €`;
      const createRes = await client.request('POST', '/api/v1/products', {
        headers: { Authorization: `Bearer ${mockDb.employeeToken}` },
        body: {
          marca: 'SWM',
          modelo: 'Camiseta Edición Especial',
          precio: 29.99,
          descripcion: fullDescription,
          fk_categoria: 3,
          variants: [{ fk_talla: 13, fk_color: 1, stock: 8 }]
        }
      });
      const productId = createRes.json<{ data: { id_producto: number } }>().data.id_producto;

      const listRes = await client.request('GET', `/api/v1/products?q=${encodeURIComponent('algodón y máxima calidad')}`);
      assert.equal(listRes.status, 200);
      assert.match(String(listRes.headers['content-type']), /application\/json;\s*charset=utf-8/i);
      assertNoMojibake(listRes.rawBody, 'GET /api/v1/products raw JSON response');

      const items = listRes.json<{ data: Array<{ id_producto: number; descripcion: string }> }>().data;
      assert.equal(items.length, 1);
      assert.strictEqual(items[0]?.id_producto, productId);
      assert.strictEqual(items[0]?.descripcion, fullDescription);
    } finally {
      await client.close();
    }
  });
});

test('4. Prueba del procesamiento de datos desde PHP (api-client.php, cabeceras UTF-8 y función escapar)', () => {
  const apiClientPhp = readFileSync(path.join(repoRoot, 'web', 'api-client.php'), 'utf8');
  assertNoMojibake(apiClientPhp, 'web/api-client.php');
  assert.match(apiClientPhp, /ini_set\('default_charset',\s*'UTF-8'\)/);
  assert.match(apiClientPhp, /mb_internal_encoding\('UTF-8'\)/);
  assert.match(apiClientPhp, /header\('Content-Type:\s*text\/html;\s*charset=UTF-8'\)/i);
  assert.match(apiClientPhp, /Content-Type:\s*application\/json;\s*charset=utf-8/i);
  assert.match(apiClientPhp, /JSON_THROW_ON_ERROR\s*\|\s*JSON_UNESCAPED_UNICODE/);
  assert.match(apiClientPhp, /htmlspecialchars\(\$valor,\s*ENT_QUOTES\s*\|\s*ENT_SUBSTITUTE,\s*'UTF-8'\)/);
  assert.equal(apiClientPhp.includes("exit('Solicitud no válida.');"), true);

  // Simulación del comportamiento de escapar() y json_decode/json_encode de PHP con UTF-8
  const phpEscaparSimulation = (valor: string) =>
    valor
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#039;');

  const input = `${SAMPLE_PRODUCT_DESCRIPTION} (${REQUIRED_SPECIAL_CHARS.join(' ')}) <script>"test"</script>`;
  const jsonPayload = JSON.stringify({ descripcion: input });
  const decodedInPhp = JSON.parse(jsonPayload) as { descripcion: string };
  assert.strictEqual(decodedInPhp.descripcion, input);

  const escapedHtml = phpEscaparSimulation(decodedInPhp.descripcion);
  assert.equal(escapedHtml.includes(SAMPLE_PRODUCT_DESCRIPTION), true);
  for (const ch of REQUIRED_SPECIAL_CHARS) {
    assert.equal(escapedHtml.includes(ch), true, `PHP escapar() must preserve UTF-8 character "${ch}"`);
  }
  assertNoMojibake(escapedHtml, 'PHP escaped HTML output');
});

test('5. Prueba de caracteres especiales en formularios (registro, actualización de perfil y dirección de pedido)', async () => {
  await withMockDatabase(async (mockDb) => {
    const client = await startTestClient();
    try {
      const prodRes = await client.request('POST', '/api/v1/products', {
        headers: { Authorization: `Bearer ${mockDb.employeeToken}` },
        body: {
          marca: 'SWM',
          modelo: 'Edición Otoño-Invierno',
          precio: 59.99,
          descripcion: SAMPLE_PRODUCT_DESCRIPTION,
          fk_categoria: 3,
          variants: [{ fk_talla: 13, fk_color: 1, stock: 10 }]
        }
      });
      const productId = prodRes.json<{ data: { id_producto: number } }>().data.id_producto;

      // Formulario de registro
      const registerPayload = {
        nombre: 'Álvaro Íñigo',
        apellido1: 'Muñoz-Peña',
        apellido2: 'Güell Órdenes Úrsula',
        email: 'alvaro.munoz@shawarmas.local',
        password: 'ContraseñaÜnica123!€'
      };
      const registerRes = await client.request('POST', '/api/v1/auth/register', { body: registerPayload });
      assert.equal(registerRes.status, 201);
      const session = registerRes.json<{
        data: { token: string; user: { nombre: string; apellido1: string; apellido2: string } };
      }>().data;
      assert.strictEqual(session.user.nombre, registerPayload.nombre);
      assert.strictEqual(session.user.apellido1, registerPayload.apellido1);
      assert.strictEqual(session.user.apellido2, registerPayload.apellido2);

      // Actualización de perfil con todos los caracteres: á é í ó ú ñ ü €
      const updatedProfile = {
        nombre: 'Águeda Érika Íñiga',
        apellido1: 'Óñez Úbeda',
        apellido2: 'Güemes (€)',
        email: 'alvaro.munoz@shawarmas.local'
      };
      const patchMeRes = await client.request('PATCH', '/api/v1/auth/me', {
        headers: { Authorization: `Bearer ${session.token}` },
        body: updatedProfile
      });
      assert.equal(patchMeRes.status, 200);

      const meRes = await client.request('GET', '/api/v1/auth/me', {
        headers: { Authorization: `Bearer ${session.token}` }
      });
      assert.equal(meRes.status, 200);
      const meData = meRes.json<{ data: { nombre: string; apellido1: string; apellido2: string } }>().data;
      assert.strictEqual(meData.nombre, updatedProfile.nombre);
      assert.strictEqual(meData.apellido1, updatedProfile.apellido1);
      assert.strictEqual(meData.apellido2, updatedProfile.apellido2);

      // Formulario de envío en checkout
      const shippingForm = {
        pais: 'España',
        ciudad: 'Málaga — San Sebastián',
        calle: 'Calle de la Cigüeña, 27 — 3º Ático Única (Tarifa 50 €)',
        postal: '29001',
        items: [{ productId, variantId: 1000, quantity: 1 }]
      };
      const orderRes = await client.request('POST', '/api/v1/orders', {
        headers: { Authorization: `Bearer ${session.token}` },
        body: shippingForm
      });
      assert.equal(orderRes.status, 201);
      const orderId = orderRes.json<{ data: { id_pedido: number } }>().data.id_pedido;

      const orderDetailRes = await client.request('GET', `/api/v1/orders/${orderId}`, {
        headers: { Authorization: `Bearer ${session.token}` }
      });
      assert.equal(orderDetailRes.status, 200);
      const orderDetail = orderDetailRes.json<{
        data: { pais: string; ciudad: string; calle: string; postal: string };
      }>().data;
      assert.strictEqual(orderDetail.pais, shippingForm.pais);
      assert.strictEqual(orderDetail.ciudad, shippingForm.ciudad);
      assert.strictEqual(orderDetail.calle, shippingForm.calle);

      // Comprobar que todos los formularios HTML de web/*.php declaran accept-charset="UTF-8" y <meta charset="UTF-8">
      const htmlViews = [
        'index.php',
        'products.php',
        'product.php',
        'account.php',
        'login.php',
        'register.php',
        'cart-summary.php',
        'checkout.php',
        'payment.php',
        'orders.php'
      ];
      for (const viewFile of htmlViews) {
        const content = readFileSync(path.join(repoRoot, 'web', viewFile), 'utf8');
        assert.match(content, /<meta\s+charset="UTF-8">/i, `web/${viewFile} must declare <meta charset="UTF-8">`);
        const formMatches = content.match(/<form\b[^>]*>/gi) ?? [];
        for (const formTag of formMatches) {
          assert.match(
            formTag,
            /accept-charset="UTF-8"/i,
            `Form tag in web/${viewFile} must declare accept-charset="UTF-8": ${formTag}`
          );
        }
      }
    } finally {
      await client.close();
    }
  });
});

test('6. Comprobación de ausencia de mojibake en resultados y coherencia UTF-8 en MySQL/Docker/Repositorio', () => {
  const poolConfig = (pool as unknown as { pool?: { config?: { connectionConfig?: { charset?: string } } } })
    .pool?.config?.connectionConfig;
  if (poolConfig?.charset) {
    assert.match(poolConfig.charset, /utf8mb4/i);
  }

  const dbDir = path.join(repoRoot, 'db');
  const sqlFiles = readdirSync(dbDir).filter((name) => name.endsWith('.sql'));
  assert.ok(sqlFiles.length >= 10);

  for (const sqlFile of sqlFiles) {
    const fullPath = path.join(dbDir, sqlFile);
    const rawBytes = readFileSync(fullPath);
    assert.equal(
      rawBytes.subarray(0, 3).equals(Buffer.from([0xef, 0xbb, 0xbf])),
      false,
      `SQL file db/${sqlFile} must be saved as UTF-8 without BOM`
    );
    const content = rawBytes.toString('utf8');
    assertNoMojibake(content, `db/${sqlFile}`);

    const firstSetNames = content.indexOf('SET NAMES utf8mb4');
    assert.ok(firstSetNames !== -1, `db/${sqlFile} must include SET NAMES utf8mb4`);

    for (const keyword of ['CREATE TABLE', 'INSERT INTO', 'UPDATE ']) {
      const keywordIndex = content.indexOf(keyword);
      if (keywordIndex !== -1) {
        assert.ok(
          firstSetNames < keywordIndex,
          `db/${sqlFile} must execute SET NAMES utf8mb4 before "${keyword}"`
        );
      }
    }
  }

  const schemaContent = readFileSync(path.join(dbDir, 'schema.sql'), 'utf8');
  assert.equal(
    schemaContent.includes(
      'Pantalón de inspiración deportiva con una silueta cómoda y actual, ideal para moverte con libertad durante el día.'
    ),
    true
  );
  const createTableMatches = schemaContent.match(/CREATE TABLE[^;]+;/g) ?? [];
  assert.equal(createTableMatches.length, 10);
  for (const tableSql of createTableMatches) {
    assert.match(
      tableSql,
      /DEFAULT CHARSET\s*=\s*utf8mb4\s+COLLATE\s*=\s*utf8mb4_unicode_ci/i,
      `Table definition in db/schema.sql must explicitly use utf8mb4_unicode_ci`
    );
  }

  const skipDirs = new Set(['.git', 'node_modules', 'vendor', 'dist', 'bin', 'obj', 'target']);
  const textExtensions = new Set([
    '.php',
    '.ts',
    '.js',
    '.json',
    '.html',
    '.sql',
    '.css',
    '.scss',
    '.md',
    '.sh',
    '.yml',
    '.yaml',
    '.java',
    '.cs',
    '.xaml'
  ]);

  const scanDir = (dir: string) => {
    for (const entry of readdirSync(dir)) {
      if (skipDirs.has(entry)) continue;
      const fullPath = path.join(dir, entry);
      const stat = statSync(fullPath);
      if (stat.isDirectory()) {
        scanDir(fullPath);
      } else if (textExtensions.has(path.extname(entry).toLowerCase())) {
        if (path.resolve(fullPath) === path.resolve(repoRoot, 'services/api/src/tests/utf8.test.ts')) {
          continue;
        }
        const bytes = readFileSync(fullPath);
        const decoded = new TextDecoder('utf-8', { fatal: true }).decode(bytes);
        assertNoMojibake(decoded, path.relative(repoRoot, fullPath));
      }
    }
  };

  if (existsSync(repoRoot)) {
    scanDir(repoRoot);
  }
});
