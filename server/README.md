# Centralized image server

This service provides centralized HTTP storage and delivery for product, color-swatch, and brand images shared by the web, Java, and WPF clients. Image binaries live in the persistent Docker volume `shawarmas-images` (seeded from `storage/products` on first start without overwriting existing files), while MySQL stores only relative paths such as `/products/550e8400-e29b-41d4-a716-446655440000.png`.

## Architecture

### Production (Raspberry Pi 5 — `docker-compose.pi.yml`)

```text
Browser / Clients -> https://shawarmas.donivanovich.dev/cdn/<path>
                        -> Cloudflare Tunnel -> gateway (Nginx 127.0.0.1:3100:8080)
                           -> strips /cdn/ -> http://image-server:3000/<path>
                           -> blocks /cdn/api/* and /cdn/health (404)

api (internal) -> http://image-server:3000/api/products (POST/DELETE with X-API-Key)
```

- `image-server` publishes **no host ports** in production.
- Public read routes are served under `https://shawarmas.donivanovich.dev/cdn` (no separate CDN subdomain is required).
- Upload and delete routes (`/api/products`, `/api/products/:filename`) are called internally by `services/api` via `IMAGE_SERVER_URL=http://image-server:3000` using `X-API-Key`.

### Local development (`docker-compose.yml`)

`image-server` is published on `127.0.0.1:3000` with `IMAGE_BASE_URL=http://localhost:3000`.

## Endpoints and caching

| Internal Route | Production Public URL | Auth | Cache-Control |
| --- | --- | --- | --- |
| `GET /products/:filename` | `https://shawarmas.donivanovich.dev/cdn/products/:filename` | Public | `public, max-age=31536000, immutable` |
| `GET /colors/:filename` | `https://shawarmas.donivanovich.dev/cdn/colors/:filename` | Public | `public, max-age=31536000, immutable` |
| `GET /brand/:filename` | `https://shawarmas.donivanovich.dev/cdn/brand/:filename` | Public | `public, max-age=3600` |
| `GET /health` | Blocked on `/cdn/health` (internal only) | Internal | N/A |
| `POST /api/products` | Blocked on `/cdn/api/*` (internal only) | `X-API-Key` | N/A |
| `DELETE /api/products/:filename` | Blocked on `/cdn/api/*` (internal only) | `X-API-Key` | N/A |

Only PNG, JPG, JPEG, and WebP files whose extension, MIME type, and file signature match are accepted. Generated UUID filenames avoid collisions and path traversal.

## Configuration (`server/.env`)

Copy `server/.env.example` to `server/.env` (ignored by Git):

| Variable | Local example | Production (Raspberry Pi 5) |
| --- | --- | --- |
| `PORT` | `3000` | `3000` |
| `NODE_ENV` | `development` / `production` | `production` |
| `IMAGE_STORAGE_PATH` | `/app/storage` | `/app/storage` |
| `MAX_FILE_SIZE_MB` | `10` | `10` |
| `UPLOAD_API_KEY` | unique secret | unique secret (must match `services/api/.env` `IMAGE_SERVER_API_KEY`) |
| `IMAGE_BASE_URL` | `http://localhost:3000` | `https://shawarmas.donivanovich.dev/cdn` |

## Persistent storage

Compose mounts the named volume `shawarmas-images` at `/app/storage`. On startup, `src/server.js` copies only missing product seed files from `/app/storage-seed/products` into `/app/storage/products`, preserving uploaded images and existing files across container updates. Never use `docker compose down -v` during routine maintenance.

## Tests

```powershell
cd server
npm ci
npm test
```
