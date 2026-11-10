const integerFromEnv = (name, fallback) => {
  const value = process.env[name] ?? String(fallback);
  const parsed = Number.parseInt(value, 10);

  if (!Number.isInteger(parsed) || parsed <= 0) {
    throw new Error(`${name} must be a positive integer`);
  }

  return parsed;
};

export const loadConfig = () => {
  const uploadApiKey = process.env.UPLOAD_API_KEY?.trim();
  if (!uploadApiKey) {
    throw new Error('UPLOAD_API_KEY is required');
  }

  const port = integerFromEnv('PORT', 3000);
  const maxFileSizeMb = integerFromEnv('MAX_FILE_SIZE_MB', 10);
  const storagePath = process.env.IMAGE_STORAGE_PATH?.trim();
  if (!storagePath) {
    throw new Error('IMAGE_STORAGE_PATH is required');
  }

  const imageBaseUrl = (process.env.IMAGE_BASE_URL?.trim() || `http://localhost:${port}`).replace(/\/+$/, '');

  return {
    imageBaseUrl,
    maxFileSizeBytes: maxFileSizeMb * 1024 * 1024,
    port,
    storagePath,
    uploadApiKey
  };
};
