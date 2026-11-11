import assert from 'node:assert/strict';
import { createServer } from 'node:http';
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
  await new Promise<void>((resolve) => server.listen(0, '127.0.0.1', resolve));
  const address = server.address();
  assert.ok(address && typeof address !== 'string');
  const baseUrl = `http://127.0.0.1:${address.port}`;
  try {
    const health = await fetch(`${baseUrl}/health/live`);
    assert.equal(health.status, 200);
    assert.deepEqual((await health.json() as { data: unknown }).data, { status: 'ok' });
    const login = await fetch(`${baseUrl}/api/v1/auth/login`, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ email: 'not-an-email', password: 'short' }) });
    assert.equal(login.status, 400);
    const payload = await login.json() as { error: { code: string; requestId: string; message: string } };
    assert.equal(payload.error.code, 'VALIDATION_ERROR');
    assert.ok(payload.error.requestId);
    assert.equal(JSON.stringify(payload).includes('not-an-email'), false);
  } finally {
    await new Promise<void>((resolve, reject) => server.close((error) => error ? reject(error) : resolve()));
  }
});
