import express from 'express';
import multer from 'multer';
import { createImageRouter } from './routes/imageRoutes.js';

export const createApp = (config) => {
  const app = express();
  app.disable('x-powered-by');
  app.use(express.json({ limit: '100kb' }));

  app.get('/health', (req, res) => res.json({ status: 'ok' }));
  app.use(createImageRouter({ config }));

  app.use((error, req, res, next) => {
    if (error instanceof multer.MulterError && error.code === 'LIMIT_FILE_SIZE') {
      return res.status(413).json({ error: 'Image exceeds the configured file size limit' });
    }
    if (error instanceof multer.MulterError) {
      return res.status(400).json({ error: 'Invalid image upload' });
    }
    console.error(error);
    return res.status(500).json({ error: 'Internal server error' });
  });

  return app;
};
