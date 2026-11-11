import { randomUUID } from 'node:crypto';
import cors from 'cors';
import express from 'express';
import rateLimit from 'express-rate-limit';
import helmet from 'helmet';
import swaggerUi from 'swagger-ui-express';
import { config } from './config.js';
import { errorHandler } from './shared/errors.js';
import authRoutes from './modules/auth/routes.js';
import catalogRoutes from './modules/catalog/routes.js';
import orderRoutes from './modules/orders/routes.js';
import administrationRoutes from './modules/administration/routes.js';
import openapi from './openapi.js';

export const createApp = () => {
  const app = express();
  app.disable('x-powered-by');
  app.set('trust proxy', config.NODE_ENV === 'production' ? 1 : false);
  app.use((request, response, next) => { request.requestId = randomUUID(); response.setHeader('X-Request-Id', request.requestId); next(); });
  app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
  app.use(cors({ origin: (origin, callback) => {
    if (!origin || config.corsOrigins.includes(origin)) return callback(null, true);
    callback(new Error('Origin is not allowed by CORS'));
  }, credentials: false, methods: ['GET', 'POST', 'PATCH', 'PUT', 'DELETE', 'OPTIONS'], allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-Id'] }));
  app.use(express.json({ limit: '256kb', strict: true }));
  app.get('/health/live', (_request, response) => response.json({ data: { status: 'ok' } }));
  app.get('/health/ready', async (_request, response, next) => {
    try { const { pool } = await import('./database.js'); await pool.query('SELECT 1'); await pool.query('SELECT 1 FROM api_sessions LIMIT 0'); response.json({ data: { status: 'ready' } }); }
    catch (error) { next(error); }
  });
  app.use('/docs', swaggerUi.serve, swaggerUi.setup(openapi));
  app.get('/openapi.json', (_request, response) => response.json(openapi));
  const loginLimit = rateLimit({ windowMs: 15 * 60 * 1000, limit: 15, standardHeaders: 'draft-8', legacyHeaders: false, message: { error: { code: 'RATE_LIMITED', message: 'Too many login attempts; try again later' } } });
  const api = express.Router();
  api.use('/auth/login', loginLimit);
  api.use('/auth/register', rateLimit({ windowMs: 60 * 60 * 1000, limit: 8, standardHeaders: 'draft-8', legacyHeaders: false }));
  api.use('/auth', authRoutes);
  api.use(catalogRoutes);
  api.use(orderRoutes);
  api.use('/admin', administrationRoutes);
  app.use('/api/v1', api);
  app.use((_request, response) => response.status(404).json({ error: { code: 'NOT_FOUND', message: 'Route not found', requestId: response.getHeader('X-Request-Id') } }));
  app.use(errorHandler);
  return app;
};
