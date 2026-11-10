import express from 'express';
import multer from 'multer';
import path from 'node:path';
import { constants as fsConstants } from 'node:fs';
import { access } from 'node:fs/promises';
import { requireApiKey } from '../middleware/auth.js';
import { allowedTypes, deleteImage, getProductPath, saveImage, validateImage } from '../services/imageService.js';

const contentTypeByExtension = new Map([...allowedTypes].map(([extension, type]) => [extension, type.mime]));
const filenameParam = (req) => req.params.filename;

export const createImageRouter = ({ config }) => {
  const router = express.Router();
  const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: config.maxFileSizeBytes },
    fileFilter: (req, file, callback) => {
      const extension = path.extname(file.originalname).toLowerCase();
      const expected = allowedTypes.get(extension);
      callback(null, Boolean(expected && file.mimetype === expected.mime));
    }
  });

  router.get('/products/:filename', async (req, res, next) => {
    const filename = filenameParam(req);
    const productPath = getProductPath(config.storagePath, filename);
    if (!productPath) return res.status(404).json({ error: 'Image not found' });

    try {
      await access(productPath, fsConstants.R_OK);
      res.set('Cache-Control', 'public, max-age=31536000, immutable');
      res.type(contentTypeByExtension.get(path.extname(filename).toLowerCase()));
      return res.sendFile(productPath, { dotfiles: 'deny' }, (error) => {
        if (error && !res.headersSent) next(error);
      });
    } catch (error) {
      if (error.code === 'ENOENT' || error.code === 'EACCES') {
        return res.status(404).json({ error: 'Image not found' });
      }
      return next(error);
    }
  });

  router.get('/colors/:filename', async (req, res, next) => {
    const filename = req.params.filename;
    if (!/^[a-zA-Z0-9][a-zA-Z0-9._-]{0,150}\.png$/i.test(filename)) {
      return res.status(404).json({ error: 'Color image not found' });
    }

    const colorPath = path.join(config.storagePath, 'colors', filename);
    try {
      await access(colorPath, fsConstants.R_OK);
      res.set('Cache-Control', 'public, max-age=31536000, immutable');
      res.type('image/png');
      return res.sendFile(colorPath, { dotfiles: 'deny' }, (error) => {
        if (error && !res.headersSent) next(error);
      });
    } catch (error) {
      if (error.code === 'ENOENT' || error.code === 'EACCES') {
        return res.status(404).json({ error: 'Color image not found' });
      }
      return next(error);
    }
  });

  router.post('/api/products', requireApiKey(config.uploadApiKey), upload.single('image'), async (req, res, next) => {
    try {
      const validation = validateImage(req.file);
      if (!validation.valid) return res.status(400).json({ error: validation.error });

      const saved = await saveImage({
        buffer: req.file.buffer,
        extension: validation.extension,
        storagePath: config.storagePath
      });
      return res.status(201).json({
        filename: saved.filename,
        path: `/products/${saved.filename}`,
        url: `${config.imageBaseUrl}/products/${saved.filename}`,
        size: req.file.size,
        contentType: validation.mime
      });
    } catch (error) {
      return next(error);
    }
  });

  router.delete('/api/products/:filename', requireApiKey(config.uploadApiKey), async (req, res, next) => {
    const productPath = getProductPath(config.storagePath, filenameParam(req));
    if (!productPath) return res.status(404).json({ error: 'Image not found' });

    try {
      await deleteImage(config.storagePath, filenameParam(req));
      return res.status(204).send();
    } catch (error) {
      if (error.code === 'ENOENT' || error.code === 'EACCES') {
        return res.status(404).json({ error: 'Image not found' });
      }
      return next(error);
    }
  });

  return router;
};
