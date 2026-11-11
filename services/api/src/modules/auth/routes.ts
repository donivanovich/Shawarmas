import { createHash, randomBytes } from 'node:crypto';
import { Router } from 'express';
import { config } from '../../config.js';
import { z } from 'zod';
import { pool, rows } from '../../database.js';
import { issueSession, hashPassword, requireAuth, verifyPassword } from '../../shared/auth.js';
import { ApiError } from '../../shared/errors.js';
import type { AuthedRequest } from '../../shared/types.js';

const router = Router();
const credentialsSchema = z.object({ email: z.string().trim().email().max(255), password: z.string().min(1).max(200) });
const registrationSchema = z.object({
  nombre: z.string().trim().min(1).max(50), apellido1: z.string().trim().min(1).max(100),
  apellido2: z.string().trim().max(100).nullable().optional(), email: z.string().trim().email().max(255),
  password: z.string().min(8).max(200)
});

router.post('/register', async (request, response) => {
  const input = registrationSchema.parse(request.body);
  const passwordHash = await hashPassword(input.password);
  try {
    const [result] = await pool.execute<{ insertId: number } & import('mysql2').ResultSetHeader>(
      'INSERT INTO clientes (nombre, apellido1, apellido2, mail, passw) VALUES (?, ?, ?, ?, ?)',
      [input.nombre, input.apellido1, input.apellido2 ?? null, input.email.toLowerCase(), passwordHash]
    );
    const session = await issueSession('customer', result.insertId, 'customer');
    response.status(201).json({ data: { token: session.token, tokenType: 'Bearer', expiresIn: session.expiresInSeconds, user: { id: result.insertId, type: 'customer', role: 'customer', nombre: input.nombre, apellido1: input.apellido1, apellido2: input.apellido2 ?? null, email: input.email.toLowerCase() } } });
  } catch (error) {
    if (typeof error === 'object' && error !== null && 'code' in error && error.code === 'ER_DUP_ENTRY') throw new ApiError(409, 'EMAIL_IN_USE', 'An account with this email already exists');
    throw error;
  }
});

router.post('/login', async (request, response) => {
  const input = credentialsSchema.parse(request.body);
  const email = input.email.toLowerCase();
  const customer = await rows<import('mysql2').RowDataPacket & { id_user: number; nombre: string; apellido1: string; apellido2: string | null; mail: string; passw: string }>(
    'SELECT id_user, nombre, apellido1, apellido2, mail, passw FROM clientes WHERE mail = ? LIMIT 1', [email]
  );
  if (customer[0] && await verifyPassword(input.password, customer[0].passw)) {
    const user = customer[0];
    if (!user.passw.startsWith('pbkdf2$')) {
      await pool.execute('UPDATE clientes SET passw = ? WHERE id_user = ?', [await hashPassword(input.password), user.id_user]);
    }
    const session = await issueSession('customer', user.id_user, 'customer');
    response.json({ data: { token: session.token, tokenType: 'Bearer', expiresIn: session.expiresInSeconds, user: { id: user.id_user, type: 'customer', role: 'customer', nombre: user.nombre, apellido1: user.apellido1, apellido2: user.apellido2, email: user.mail } } });
    return;
  }
  const employee = await rows<import('mysql2').RowDataPacket & { id_empleado: number; nombre: string; apellido1: string; apellido2: string | null; mail: string; passw: string; mode_use: 'writter' | 'editor' | 'admin'; fk_tienda: number }>(
    'SELECT id_empleado, nombre, apellido1, apellido2, mail, passw, mode_use, fk_tienda FROM empleados WHERE mail = ? LIMIT 1', [email]
  );
  if (employee[0] && await verifyPassword(input.password, employee[0].passw)) {
    const user = employee[0];
    // Upgrade supported legacy password hashes to the shared PBKDF2 format.
    if (!user.passw.startsWith('pbkdf2$')) {
      await pool.execute('UPDATE empleados SET passw = ? WHERE id_empleado = ?', [await hashPassword(input.password), user.id_empleado]);
    }
    const session = await issueSession('employee', user.id_empleado, user.mode_use);
    response.json({ data: { token: session.token, tokenType: 'Bearer', expiresIn: session.expiresInSeconds, user: { id: user.id_empleado, type: 'employee', role: user.mode_use, nombre: user.nombre, apellido1: user.apellido1, apellido2: user.apellido2, email: user.mail, fk_tienda: user.fk_tienda } } });
    return;
  }
  if (customer[0] && !customer[0].passw.startsWith('pbkdf2$') && await verifyPassword(input.password, customer[0].passw)) {
    await pool.execute('UPDATE clientes SET passw = ? WHERE id_user = ?', [await hashPassword(input.password), customer[0].id_user]);
  }
  throw new ApiError(401, 'INVALID_CREDENTIALS', 'Email or password is incorrect');
});

router.get('/me', requireAuth, async (request, response) => {
  const principal = request.principal!;
  const table = principal.type === 'customer' ? 'clientes' : 'empleados';
  const key = principal.type === 'customer' ? 'id_user' : 'id_empleado';
  const record = await rows<import('mysql2').RowDataPacket>(`SELECT * FROM ${table} WHERE ${key} = ? LIMIT 1`, [principal.id]);
  const user = record[0];
  if (!user) throw new ApiError(404, 'ACCOUNT_NOT_FOUND', 'Account not found');
  delete user.passw;
  delete user.id_user;
  delete user.id_empleado;
  response.json({ data: { id: principal.id, type: principal.type, role: principal.role, ...user } });
});

router.patch('/me', requireAuth, async (request, response) => {
  const principal = request.principal!;
  const input = z.object({ nombre: z.string().trim().min(1).max(50), apellido1: z.string().trim().min(1).max(100), apellido2: z.string().trim().max(100).nullable().optional(), email: z.string().trim().email().max(255) }).strict().parse(request.body);
  const table = principal.type === 'customer' ? 'clientes' : 'empleados';
  const key = principal.type === 'customer' ? 'id_user' : 'id_empleado';
  try {
    await pool.execute(`UPDATE ${table} SET nombre = ?, apellido1 = ?, apellido2 = ?, mail = ? WHERE ${key} = ?`, [input.nombre, input.apellido1, input.apellido2 ?? null, input.email.toLowerCase(), principal.id]);
  } catch (error) {
    if (typeof error === 'object' && error !== null && 'code' in error && error.code === 'ER_DUP_ENTRY') throw new ApiError(409, 'EMAIL_IN_USE', 'An account with this email already exists');
    throw error;
  }
  response.json({ data: { id: principal.id, ...input, email: input.email.toLowerCase() } });
});

router.patch('/me/password', requireAuth, async (request, response) => {
  const input = z.object({ currentPassword: z.string().min(1).max(200), newPassword: z.string().min(8).max(200) }).strict().parse(request.body);
  const principal = request.principal!;
  const table = principal.type === 'customer' ? 'clientes' : 'empleados';
  const key = principal.type === 'customer' ? 'id_user' : 'id_empleado';
  const current = await rows<import('mysql2').RowDataPacket & { passw: string }>(`SELECT passw FROM ${table} WHERE ${key} = ? LIMIT 1`, [principal.id]);
  if (!current[0] || !(await verifyPassword(input.currentPassword, current[0].passw))) throw new ApiError(400, 'PASSWORD_MISMATCH', 'Current password is incorrect');
  const hash = await hashPassword(input.newPassword);
  await pool.execute(`UPDATE ${table} SET passw = ? WHERE ${key} = ?`, [hash, principal.id]);
  await pool.execute('UPDATE api_sessions SET revoked_at = UTC_TIMESTAMP() WHERE user_type = ? AND user_id = ? AND id_session <> ?', [principal.type, principal.id, principal.sessionId]);
  response.json({ data: { changed: true } });
});

router.post('/refresh', requireAuth, async (request, response) => {
  const principal = request.principal!;
  const oldToken = request.get('authorization')!.slice('Bearer '.length);
  const token = randomBytes(32).toString('base64url');
  const hash = createHash('sha256').update(token).digest('hex');
  const [result] = await pool.execute<import('mysql2').ResultSetHeader>(
    'UPDATE api_sessions SET token_hash = ?, expires_at = DATE_ADD(UTC_TIMESTAMP(), INTERVAL ? DAY) WHERE id_session = ? AND token_hash = ? AND revoked_at IS NULL AND expires_at > UTC_TIMESTAMP()',
    [hash, config.SESSION_TTL_DAYS, principal.sessionId, createHash('sha256').update(oldToken).digest('hex')]
  );
  if (!result.affectedRows) throw new ApiError(401, 'SESSION_EXPIRED', 'The session is invalid or expired');
  response.json({ data: { token, tokenType: 'Bearer', expiresIn: config.SESSION_TTL_DAYS * 86400 } });
});

router.post('/logout', requireAuth, async (request, response) => {
  await pool.execute('UPDATE api_sessions SET revoked_at = UTC_TIMESTAMP() WHERE id_session = ? AND revoked_at IS NULL', [(request as AuthedRequest).principal.sessionId]);
  response.status(204).end();
});

export default router;
