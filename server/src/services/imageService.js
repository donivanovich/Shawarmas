import { access, mkdir, unlink, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { randomUUID } from 'node:crypto';

export const allowedTypes = new Map([
  ['.png', { mime: 'image/png', signature: (buffer) => buffer.subarray(0, 8).equals(Buffer.from('89504e470d0a1a0a', 'hex')) }],
  ['.jpg', { mime: 'image/jpeg', signature: (buffer) => buffer.subarray(0, 3).equals(Buffer.from('ffd8ff', 'hex')) }],
  ['.jpeg', { mime: 'image/jpeg', signature: (buffer) => buffer.subarray(0, 3).equals(Buffer.from('ffd8ff', 'hex')) }],
  ['.webp', { mime: 'image/webp', signature: (buffer) => buffer.subarray(0, 4).toString('ascii') === 'RIFF' && buffer.subarray(8, 12).toString('ascii') === 'WEBP' }]
]);

export const getSafeFilename = (filename) => /^[a-zA-Z0-9][a-zA-Z0-9._-]{0,150}$/.test(filename) ? filename : null;

export const getProductPath = (storagePath, filename) => {
  const safeFilename = getSafeFilename(filename);
  if (!safeFilename || path.basename(safeFilename) !== safeFilename) {
    return null;
  }

  const extension = path.extname(safeFilename).toLowerCase();
  if (!allowedTypes.has(extension)) {
    return null;
  }

  return path.join(storagePath, 'products', safeFilename);
};

export const validateImage = (file) => {
  if (!file) {
    return { valid: false, error: 'An image file is required' };
  }

  const extension = path.extname(file.originalname).toLowerCase();
  const type = allowedTypes.get(extension);
  if (!type || file.mimetype !== type.mime || !type.signature(file.buffer)) {
    return { valid: false, error: 'Only valid PNG, JPG, JPEG, and WebP images are accepted' };
  }

  return { valid: true, extension, mime: type.mime };
};

export const saveImage = async ({ buffer, extension, storagePath }) => {
  const directory = path.join(storagePath, 'products');
  await mkdir(directory, { recursive: true });

  let filename;
  let destination;
  do {
    filename = `${randomUUID()}${extension}`;
    destination = path.join(directory, filename);
  } while (await fileExists(destination));

  await writeFile(destination, buffer, { flag: 'wx' });
  return { filename, destination };
};

export const deleteImage = (storagePath, filename) => unlink(getProductPath(storagePath, filename));

const fileExists = async (filename) => {
  try {
    await access(filename);
    return true;
  } catch (error) {
    if (error.code === 'ENOENT') return false;
    throw error;
  }
};
