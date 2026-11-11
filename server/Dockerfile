FROM node:22-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

COPY src ./src
COPY storage/products /app/storage-seed/products
COPY storage/brand /app/storage/brand
COPY storage/colors /app/storage/colors
RUN mkdir -p /app/storage/products \
    && chown -R node:node /app

USER node

ENV NODE_ENV=production
ENV PORT=3000
ENV IMAGE_SEED_PATH=/app/storage-seed/products
EXPOSE 3000

CMD ["node", "src/server.js"]
