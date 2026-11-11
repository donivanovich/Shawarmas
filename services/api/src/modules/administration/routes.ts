import { Router } from 'express';
import multer from 'multer';
import { z } from 'zod';
import type { RowDataPacket } from 'mysql2/promise';
import { pool, rows } from '../../database.js';
import { hashPassword, requireAdmin, requireEmployee, requireManager } from '../../shared/auth.js';
import { ApiError } from '../../shared/errors.js';
import { config } from '../../config.js';

const router = Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 10 * 1024 * 1024, files: 1 }, fileFilter: (_request, file, callback) => callback(null, ['image/png', 'image/jpeg', 'image/webp'].includes(file.mimetype)) });

router.post('/images/products', requireManager, upload.single('image'), async (request, response) => {
  if (!request.file) throw new ApiError(400, 'IMAGE_REQUIRED', 'A PNG, JPEG or WebP image is required');
  if (!config.IMAGE_SERVER_API_KEY) throw new ApiError(503, 'IMAGE_UPLOAD_UNAVAILABLE', 'Image upload is not configured');
  const body = new FormData();
  const imageBytes = new ArrayBuffer(request.file.buffer.byteLength);
  new Uint8Array(imageBytes).set(request.file.buffer);
  body.append('image', new Blob([imageBytes], { type: request.file.mimetype }), request.file.originalname);
  const upstream = await fetch(`${config.IMAGE_SERVER_URL.replace(/\/$/, '')}/api/products`, {
    method: 'POST', headers: { 'X-API-Key': config.IMAGE_SERVER_API_KEY }, body, signal: AbortSignal.timeout(15000)
  });
  const payload = await upstream.json().catch(() => null);
  if (!upstream.ok) throw new ApiError(upstream.status === 413 ? 413 : 502, 'IMAGE_UPLOAD_FAILED', upstream.status === 413 ? 'The image exceeds the upload limit' : 'The image service rejected the upload');
  response.status(201).json({ data: payload });
});

router.delete('/images/products/:filename', requireManager, async (request, response) => {
  const filename = z.string().regex(/^[a-zA-Z0-9][a-zA-Z0-9._-]{0,150}\.(png|jpe?g|webp)$/i).parse(request.params.filename);
  const path = `/products/${filename}`;
  const references = await rows<RowDataPacket & { total: number }>(
    'SELECT (SELECT COUNT(*) FROM productos WHERE imagen = ?) + (SELECT COUNT(*) FROM producto_variantes WHERE imagen = ?) AS total', [path, path]
  );
  if (Number(references[0]?.total ?? 0) > 0) throw new ApiError(409, 'IMAGE_IN_USE', 'This image is referenced by a product or variant');
  if (!config.IMAGE_SERVER_API_KEY) throw new ApiError(503, 'IMAGE_DELETE_UNAVAILABLE', 'Image deletion is not configured');
  const upstream = await fetch(`${config.IMAGE_SERVER_URL.replace(/\/$/, '')}/api/products/${encodeURIComponent(filename)}`, {
    method: 'DELETE', headers: { 'X-API-Key': config.IMAGE_SERVER_API_KEY }, signal: AbortSignal.timeout(15000)
  });
  if (!upstream.ok && upstream.status !== 404) throw new ApiError(502, 'IMAGE_DELETE_FAILED', 'The image service could not delete the image');
  response.status(204).end();
});

router.get('/roles', requireEmployee, (request, response) => {
  const roles = request.principal?.role === 'admin' ? ['writter', 'editor', 'admin'] : ['writter'];
  response.json({ data: { current: request.principal?.role, assignable: roles } });
});

router.get('/customers', requireManager, async (request, response) => {
  const query = z.object({ q: z.string().trim().max(100).optional(), page: z.coerce.number().int().min(1).default(1), pageSize: z.coerce.number().int().min(1).max(100).default(50) }).parse(request.query);
  const term = query.q ? `%${query.q}%` : null;
  const data = await rows<RowDataPacket>(
    `SELECT id_user, nombre, apellido1, apellido2, mail, creado_en FROM clientes
     WHERE (? IS NULL OR nombre LIKE ? OR apellido1 LIKE ? OR mail LIKE ?)
     ORDER BY id_user DESC LIMIT ? OFFSET ?`,
    [term, term, term, term, query.pageSize, (query.page - 1) * query.pageSize]
  );
  response.json({ data, meta: { page: query.page, pageSize: query.pageSize } });
});

router.get('/inventory', requireEmployee, async (request, response) => {
  const query = z.object({ q: z.string().trim().max(100).optional(), pageSize: z.coerce.number().int().min(1).max(500).default(200) }).parse(request.query);
  const term = query.q ? `%${query.q}%` : null;
  const data = await rows<RowDataPacket>(
    `SELECT p.id_producto, p.marca, p.modelo, p.precio, p.imagen, c.categoria,
       v.id_variante, v.stock, v.imagen AS variante_imagen, t.id_talla, t.talla, co.id_color, co.color
     FROM productos p JOIN categorias c ON c.id_categoria = p.fk_categoria
     JOIN producto_variantes v ON v.fk_producto = p.id_producto
     JOIN tallas t ON t.id_talla = v.fk_talla JOIN colores co ON co.id_color = v.fk_color
     WHERE (? IS NULL OR p.marca LIKE ? OR p.modelo LIKE ? OR co.color LIKE ? OR t.talla LIKE ?)
     ORDER BY p.marca, p.modelo, co.color, t.talla LIMIT ?`,
    [term, term, term, term, term, query.pageSize]
  );
  response.json({ data });
});

router.post('/customers', requireEmployee, async (request, response) => {
  const input = z.object({ nombre: z.string().trim().min(1).max(50), apellido1: z.string().trim().min(1).max(100), apellido2: z.string().trim().max(100).nullable().optional(), email: z.string().trim().email().max(255), password: z.string().min(8).max(200) }).strict().parse(request.body);
  try {
    const [result] = await pool.execute<import('mysql2/promise').ResultSetHeader>('INSERT INTO clientes (nombre, apellido1, apellido2, mail, passw) VALUES (?, ?, ?, ?, ?)', [input.nombre, input.apellido1, input.apellido2 ?? null, input.email.toLowerCase(), await hashPassword(input.password)]);
    response.status(201).json({ data: { id_user: result.insertId, nombre: input.nombre, apellido1: input.apellido1, apellido2: input.apellido2 ?? null, mail: input.email.toLowerCase() } });
  } catch (error) {
    if (typeof error === 'object' && error !== null && 'code' in error && error.code === 'ER_DUP_ENTRY') throw new ApiError(409, 'EMAIL_IN_USE', 'An account with this email already exists');
    throw error;
  }
});

router.patch('/customers/:id', requireManager, async (request, response) => {
  const id = z.coerce.number().int().positive().parse(request.params.id);
  const input = z.object({ nombre: z.string().trim().min(1).max(50), apellido1: z.string().trim().min(1).max(100), apellido2: z.string().trim().max(100).nullable(), email: z.string().trim().email().max(255) }).strict().parse(request.body);
  const [result] = await pool.execute<import('mysql2/promise').ResultSetHeader>('UPDATE clientes SET nombre = ?, apellido1 = ?, apellido2 = ?, mail = ? WHERE id_user = ?', [input.nombre, input.apellido1, input.apellido2, input.email.toLowerCase(), id]);
  if (!result.affectedRows) throw new ApiError(404, 'CUSTOMER_NOT_FOUND', 'Customer not found');
  response.json({ data: { id_user: id, ...input, email: input.email.toLowerCase() } });
});

router.patch('/customers/:id/password', requireAdmin, async (request, response) => {
  const id = z.coerce.number().int().positive().parse(request.params.id);
  const input = z.object({ password: z.string().min(8).max(200) }).strict().parse(request.body);
  const [result] = await pool.execute<import('mysql2/promise').ResultSetHeader>('UPDATE clientes SET passw = ? WHERE id_user = ?', [await hashPassword(input.password), id]);
  if (!result.affectedRows) throw new ApiError(404, 'CUSTOMER_NOT_FOUND', 'Customer not found');
  await pool.execute('UPDATE api_sessions SET revoked_at = UTC_TIMESTAMP() WHERE user_type = \'customer\' AND user_id = ?', [id]);
  response.json({ data: { id_user: id, passwordUpdated: true } });
});

router.get('/employees', requireManager, async (_request, response) => {
  const data = await rows<RowDataPacket>('SELECT id_empleado, nombre, apellido1, apellido2, mail, fullscreen, mute, mode_use, volume, fk_tienda, creado_en FROM empleados ORDER BY id_empleado');
  response.json({ data });
});

router.post('/employees', requireAdmin, async (request, response) => {
  const input = z.object({ nombre: z.string().trim().min(1).max(50), apellido1: z.string().trim().min(1).max(100), apellido2: z.string().trim().max(100).nullable().optional(), email: z.string().trim().email().max(255), password: z.string().min(8).max(200), mode_use: z.enum(['writter', 'editor', 'admin']), fk_tienda: z.number().int().positive(), fullscreen: z.boolean().default(false), mute: z.boolean().default(false), volume: z.number().int().min(0).max(100).default(50) }).strict().parse(request.body);
  const [result] = await pool.execute<import('mysql2/promise').ResultSetHeader>(
    'INSERT INTO empleados (nombre, apellido1, apellido2, mail, passw, mode_use, fk_tienda, fullscreen, mute, volume) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [input.nombre, input.apellido1, input.apellido2 ?? null, input.email.toLowerCase(), await hashPassword(input.password), input.mode_use, input.fk_tienda, input.fullscreen, input.mute, input.volume]
  );
  response.status(201).json({ data: { id_empleado: result.insertId, ...input, email: input.email.toLowerCase(), password: undefined } });
});

router.patch('/employees/:id', requireAdmin, async (request, response) => {
  const id = z.coerce.number().int().positive().parse(request.params.id);
  const input = z.object({ nombre: z.string().trim().min(1).max(50), apellido1: z.string().trim().min(1).max(100), apellido2: z.string().trim().max(100).nullable(), email: z.string().trim().email().max(255), mode_use: z.enum(['writter', 'editor', 'admin']), fk_tienda: z.number().int().positive() }).strict().parse(request.body);
  const [result] = await pool.execute<import('mysql2/promise').ResultSetHeader>('UPDATE empleados SET nombre = ?, apellido1 = ?, apellido2 = ?, mail = ?, mode_use = ?, fk_tienda = ? WHERE id_empleado = ?', [input.nombre, input.apellido1, input.apellido2, input.email.toLowerCase(), input.mode_use, input.fk_tienda, id]);
  if (!result.affectedRows) throw new ApiError(404, 'EMPLOYEE_NOT_FOUND', 'Employee not found');
  await pool.execute('UPDATE api_sessions SET revoked_at = UTC_TIMESTAMP() WHERE user_type = \'employee\' AND user_id = ? AND id_session <> ?', [id, request.principal!.sessionId]);
  response.json({ data: { id_empleado: id, ...input, email: input.email.toLowerCase() } });
});

router.patch('/employees/me/preferences', requireEmployee, async (request, response) => {
  const input = z.object({ fullscreen: z.boolean(), mute: z.boolean(), volume: z.number().int().min(0).max(100) }).strict().parse(request.body);
  const id = request.principal!.id;
  await pool.execute('UPDATE empleados SET fullscreen = ?, mute = ?, volume = ? WHERE id_empleado = ?', [input.fullscreen, input.mute, input.volume, id]);
  response.json({ data: { id_empleado: id, ...input } });
});

export default router;
