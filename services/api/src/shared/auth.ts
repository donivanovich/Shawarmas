import { createHash, randomBytes, randomUUID, timingSafeEqual } from 'node:crypto';
import { promisify } from 'node:util';
import { pbkdf2 as pbkdf2Callback } from 'node:crypto';
import bcrypt from 'bcryptjs';
import type { NextFunction, Request, Response } from 'express';
import { pool, rows } from '../database.js';
import { config } from '../config.js';
import { ApiError } from './errors.js';
import type { Principal } from './types.js';
import type { RowDataPacket } from 'mysql2/promise';

const pbkdf2 = promisify(pbkdf2Callback);
const digestToken = (token: string) => createHash('sha256').update(token).digest('hex');

export const hashPassword = async (password: string): Promise<string> => {
  const salt = randomBytes(16);
  const hash = await pbkdf2(password, salt, 120000, 32, 'sha256') as Buffer;
  return `pbkdf2$${salt.toString('base64')}$${hash.toString('base64')}`;
};

export const verifyPassword = async (password: string, stored: string): Promise<boolean> => {
  if (stored.startsWith('pbkdf2$')) {
    const parts = stored.split('$');
    if (parts.length !== 3) return false;
    try {
      const salt = Buffer.from(parts[1]!, 'base64');
      const expected = Buffer.from(parts[2]!, 'base64');
      if (salt.length !== 16 || expected.length < 16 || expected.length > 64) return false;
      const actual = await pbkdf2(password, salt, 120000, expected.length, 'sha256') as Buffer;
      return timingSafeEqual(actual, expected);
    } catch {
      return false;
    }
  }
  // PHP password_hash() bcrypt hashes use $2y$; bcryptjs accepts $2b$.
  if (/^\$2[aby]\$/.test(stored)) {
    return bcrypt.compare(password, stored.replace(/^\$2y\$/, '$2b$'));
  }
  return false;
};

export const emailInUse = async (email: string, exclude?: { type: 'customer' | 'employee'; id: number }): Promise<boolean> => {
  const customerSql = `SELECT id_user FROM clientes WHERE mail = ?${exclude?.type === 'customer' ? ' AND id_user <> ?' : ''} LIMIT 1`;
  const employeeSql = `SELECT id_empleado FROM empleados WHERE mail = ?${exclude?.type === 'employee' ? ' AND id_empleado <> ?' : ''} LIMIT 1`;
  const customerValues = exclude?.type === 'customer' ? [email, exclude.id] : [email];
  const employeeValues = exclude?.type === 'employee' ? [email, exclude.id] : [email];
  const [customers, employees] = await Promise.all([
    rows<RowDataPacket>(customerSql, customerValues), rows<RowDataPacket>(employeeSql, employeeValues)
  ]);
  return customers.length > 0 || employees.length > 0;
};

type SessionRow = RowDataPacket & { id_session: string; user_type: 'customer' | 'employee'; user_id: number; expires_at: Date; revoked_at: Date | null };

export const issueSession = async (type: Principal['type'], id: number, role: Principal['role']) => {
  const token = randomBytes(32).toString('base64url');
  const idSession = randomUUID();
  await pool.execute(
    'INSERT INTO api_sessions (id_session, token_hash, user_type, user_id, expires_at) VALUES (?, ?, ?, ?, DATE_ADD(UTC_TIMESTAMP(), INTERVAL ? DAY))',
    [idSession, digestToken(token), type, id, config.SESSION_TTL_DAYS]
  );
  return { token, expiresInSeconds: config.SESSION_TTL_DAYS * 86400, principal: { type, id, role, sessionId: idSession } satisfies Principal };
};

export const requireAuth = async (request: Request, _response: Response, next: NextFunction) => {
  try {
    const value = request.get('authorization');
    const match = value?.match(/^Bearer ([A-Za-z0-9_-]{40,60})$/);
    if (!match) throw new ApiError(401, 'UNAUTHENTICATED', 'A valid bearer token is required');
    const tokenHash = digestToken(match[1]!);
    const sessionRows = await rows<SessionRow>(
      'SELECT id_session, user_type, user_id, expires_at, revoked_at FROM api_sessions WHERE token_hash = ? LIMIT 1', [tokenHash]
    );
    const session = sessionRows[0];
    if (!session || session.revoked_at || new Date(session.expires_at).getTime() <= Date.now()) {
      throw new ApiError(401, 'SESSION_EXPIRED', 'The session is invalid or expired');
    }
    let role: Principal['role'];
    if (session.user_type === 'customer') {
      const users = await rows<RowDataPacket & { id_user: number }>('SELECT id_user FROM clientes WHERE id_user = ? LIMIT 1', [session.user_id]);
      if (!users[0]) throw new ApiError(401, 'SESSION_REVOKED', 'The account no longer exists');
      role = 'customer';
    } else {
      const employees = await rows<RowDataPacket & { mode_use: Principal['role'] }>('SELECT mode_use FROM empleados WHERE id_empleado = ? LIMIT 1', [session.user_id]);
      if (!employees[0]) throw new ApiError(401, 'SESSION_REVOKED', 'The account no longer exists');
      role = employees[0].mode_use;
    }
    request.principal = { type: session.user_type, id: session.user_id, role, sessionId: session.id_session };
    next();
  } catch (error) {
    next(error);
  }
};

export const requireRoles = (...roles: Principal['role'][]) => (request: Request, _response: Response, next: NextFunction) => {
  if (!request.principal || !roles.includes(request.principal.role)) {
    next(new ApiError(request.principal ? 403 : 401, request.principal ? 'FORBIDDEN' : 'UNAUTHENTICATED', request.principal ? 'This role cannot perform the requested operation' : 'Authentication is required'));
    return;
  }
  next();
};

export const requireEmployee = requireRoles('writter', 'editor', 'admin');
export const requireManager = requireRoles('editor', 'admin');
export const requireAdmin = requireRoles('admin');
