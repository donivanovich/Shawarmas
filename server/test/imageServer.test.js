import assert from 'node:assert/strict';
import { mkdtemp, mkdir, rm, writeFile } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import request from 'supertest';
import test from 'node:test';
import { createApp } from '../src/app.js';

const apiKey = 'test-key';
const png = Buffer.from('89504e470d0a1a0a', 'hex');
let storagePath;

const makeApp = () => createApp({
  imageBaseUrl: 'http://localhost:3000',
  maxFileSizeBytes: 1024,
  port: 3000,
  storagePath,
  uploadApiKey: apiKey
});

test.beforeEach(async () => {
  storagePath = await mkdtemp(path.join(os.tmpdir(), 'shawarmas-image-server-'));
  await mkdir(path.join(storagePath, 'colors'), { recursive: true });
  await writeFile(path.join(storagePath, 'colors', 'black.png'), png);
});

test.afterEach(async () => {
  await rm(storagePath, { recursive: true, force: true });
});

test('health endpoint reports server status', async () => {
  const response = await request(makeApp()).get('/health');
  assert.equal(response.status, 200);
  assert.deepEqual(response.body, { status: 'ok' });
});

test('uploads and retrieves a valid image', async () => {
  const app = makeApp();
  const upload = await request(app)
    .post('/api/products')
    .set('x-api-key', apiKey)
    .attach('image', png, { filename: 'product.png', contentType: 'image/png' });

  assert.equal(upload.status, 201);
  assert.match(upload.body.path, /^\/products\/[0-9a-f-]+\.png$/);

  const image = await request(app).get(upload.body.path);
  assert.equal(image.status, 200);
  assert.equal(image.headers['content-type'], 'image/png');
  assert.equal(image.headers['cache-control'], 'public, max-age=31536000, immutable');
  assert.deepEqual(image.body, png);
});

test('returns 404 for a missing image', async () => {
  const response = await request(makeApp()).get('/products/missing.png');
  assert.equal(response.status, 404);
});

test('returns a public color swatch image', async () => {
  const response = await request(makeApp()).get('/colors/black.png');
  assert.equal(response.status, 200);
});

test('rejects invalid image content', async () => {
  const response = await request(makeApp())
    .post('/api/products')
    .set('x-api-key', apiKey)
    .attach('image', Buffer.from('not an image'), { filename: 'bad.png', contentType: 'image/png' });
  assert.equal(response.status, 400);
});

test('requires authentication for upload and deletion', async () => {
  const app = makeApp();
  const upload = await request(app)
    .post('/api/products')
    .attach('image', png, { filename: 'product.png', contentType: 'image/png' });
  assert.equal(upload.status, 401);

  const deletion = await request(app).delete('/api/products/product.png');
  assert.equal(deletion.status, 401);
});

test('deletes an uploaded image', async () => {
  const app = makeApp();
  const upload = await request(app)
    .post('/api/products')
    .set('x-api-key', apiKey)
    .attach('image', png, { filename: 'product.png', contentType: 'image/png' });

  const deletion = await request(app)
    .delete(`/api${upload.body.path}`)
    .set('x-api-key', apiKey);
  assert.equal(deletion.status, 204);
  assert.equal((await request(app).get(upload.body.path)).status, 404);
});

test('keeps images available when the app is recreated', async () => {
  const firstApp = makeApp();
  const upload = await request(firstApp)
    .post('/api/products')
    .set('x-api-key', apiKey)
    .attach('image', png, { filename: 'product.png', contentType: 'image/png' });

  const secondApp = makeApp();
  const response = await request(secondApp).get(upload.body.path);
  assert.equal(response.status, 200);
  assert.deepEqual(response.body, png);
});
