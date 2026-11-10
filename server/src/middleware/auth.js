export const requireApiKey = (expectedKey) => (req, res, next) => {
  const providedKey = req.get('x-api-key');
  if (!providedKey || providedKey !== expectedKey) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  return next();
};
