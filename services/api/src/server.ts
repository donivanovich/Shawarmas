import { createApp } from './app.js';
import { config } from './config.js';
import { pool } from './database.js';

const app = createApp();
const server = app.listen(config.API_PORT, '0.0.0.0', () => console.log(`Shawarmas API listening on ${config.API_PORT}`));

const shutdown = async () => {
  server.close(async () => {
    await pool.end();
    process.exit(0);
  });
  setTimeout(() => process.exit(1), 10000).unref();
};
process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);
