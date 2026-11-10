import { mkdir } from 'node:fs/promises';
import { createApp } from './app.js';
import { loadConfig } from './config/env.js';

const config = loadConfig();
await mkdir(`${config.storagePath}/products`, { recursive: true });
await mkdir(`${config.storagePath}/colors`, { recursive: true });
const app = createApp(config);

app.listen(config.port, () => {
  console.log(`Image server listening on port ${config.port}`);
});
