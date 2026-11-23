import assert from 'node:assert/strict';
import { createServer, request as httpRequest } from 'node:http';
import path from 'node:path';
import { pbkdf2Sync, randomBytes } from 'node:crypto';
import bcrypt from 'bcryptjs';
import test from 'node:test';

process.env.NODE_ENV = 'test';
process.env.DB_HOST = '127.0.0.1';
process.env.DB_PORT = '3307';
process.env.DB_NAME = 'shawarmas';
process.env.DB_USER = 'test';
process.env.DB_PASSWORD = 'test-only-password';
process.env.IMAGE_SERVER_URL = 'http://127.0.0.1:3000';

const { createApp } = await import('../app.js');
const { hashPassword, verifyPassword } = await import('../shared/auth.js');

test('password hashing stays compatible with the existing PBKDF2 format', async () => {
  const password = 'ExistingAccount123!';
  const salt = randomBytes(16);
  const expected = pbkdf2Sync(password, salt, 120000, 32, 'sha256');
  const legacyHash = `pbkdf2$${salt.toString('base64')}$${expected.toString('base64')}`;
  assert.equal(await verifyPassword(password, legacyHash), true);
  assert.equal(await verifyPassword('wrong-password', legacyHash), false);
  const newHash = await hashPassword(password);
  assert.match(newHash, /^pbkdf2\$/);
  assert.equal(await verifyPassword(password, newHash), true);
});

test('password verification supports existing PHP bcrypt hashes', async () => {
  const hash = (await bcrypt.hash('LegacyPhp123!', 4)).replace(/^\$2b\$/, '$2y$');
  assert.equal(await verifyPassword('LegacyPhp123!', hash), true);
  assert.equal(await verifyPassword('wrong-password', hash), false);
});

test('health and validation responses use the documented safe envelope', async () => {
  const server = createServer(createApp());
  server.on('connection', (socket) => {
    if (!socket.remoteAddress) {
      Object.defineProperty(socket, 'remoteAddress', { value: '127.0.0.1', configurable: true });
    }
  });
  const pipePath =
    process.platform === 'win32'
      ? `\\\\.\\pipe\\shawarmas-smoke-test-${process.pid}-${Date.now()}`
      : path.join('/tmp', `shawarmas-smoke-test-${process.pid}-${Date.now()}.sock`);
  await new Promise<void>((resolve) => server.listen(pipePath, resolve));
  const callApi = (method: string, urlPath: string, body?: unknown) =>
    new Promise<{ status: number; json: () => Promise<unknown> }>((resolve, reject) => {
      const payload = body === undefined ? undefined : JSON.stringify(body);
      const req = httpRequest(
        {
          socketPath: pipePath,
          path: urlPath,
          method,
          headers: payload ? { 'content-type': 'application/json', 'content-length': Buffer.byteLength(payload) } : undefined
        },
        (res) => {
          const chunks: Buffer[] = [];
          res.on('data', (chunk: Buffer) => chunks.push(Buffer.from(chunk)));
          res.on('end', () => {
            const raw = Buffer.concat(chunks).toString('utf8');
            resolve({ status: res.statusCode ?? 0, json: async () => JSON.parse(raw) });
          });
        }
      );
      req.on('error', reject);
      if (payload) req.write(payload);
      req.end();
    });
  try {
    const health = await callApi('GET', '/health/live');
    assert.equal(health.status, 200);
    assert.deepEqual((await health.json() as { data: unknown }).data, { status: 'ok' });
    const login = await callApi('POST', '/api/v1/auth/login', { email: 'not-an-email', password: 'short' });
    assert.equal(login.status, 400);
    const payload = await login.json() as { error: { code: string; requestId: string; message: string } };
    assert.equal(payload.error.code, 'VALIDATION_ERROR');
    assert.ok(payload.error.requestId);
    assert.equal(JSON.stringify(payload).includes('not-an-email'), false);
  } finally {
    await new Promise<void>((resolve, reject) => server.close((error) => error ? reject(error) : resolve()));
  }
});
