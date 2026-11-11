import { cp, mkdir } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createApp } from './app.js';
import { loadConfig } from './config/env.js';

const config = loadConfig();
await mkdir(`${config.storagePath}/products`, { recursive: true });
await mkdir(`${config.storagePath}/colors`, { recursive: true });
// Seed only missing files so the named volume gets repository assets on first
// startup while uploaded files and operator-managed replacements stay intact.
const seedProducts = process.env.IMAGE_SEED_PATH || fileURLToPath(new URL('../storage/products', import.meta.url));
await cp(seedProducts, path.join(config.storagePath, 'products'), { recursive: true, force: false, errorOnExist: false });
const app = createApp(config);

app.listen(config.port, () => {
  console.log(`Image server listening on port ${config.port}`);
});
