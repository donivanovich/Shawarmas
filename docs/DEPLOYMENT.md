# Deployment

Shawarmas separates **local development** (`docker-compose.yml`) from **production on Raspberry Pi 5** (`docker-compose.pi.yml`).

## Production deployment (Raspberry Pi 5 — 64-bit ARM64)

- **Target host:** Raspberry Pi 5 (16 GB), Raspberry Pi OS Lite 64-bit (`aarch64`), Docker Engine + Docker Compose v2.
- **Deployment path:** `/opt/docker/apps/Shawarmas`
- **Public entrypoint:** Cloudflare Tunnel routing `shawarmas.donivanovich.dev` -> `http://localhost:3100` (`gateway` container listening on `127.0.0.1:3100:8080`).
- **Database:** External MySQL 8.4 container connected via the external Docker network `mysql_backend`.

### Initial setup from scratch on Raspberry Pi 5

1. Confirm 64-bit architecture and external MySQL network:
   ```bash
   uname -m                           # must output aarch64
   docker network inspect mysql_backend
   ```
2. Prepare `/opt/docker/apps/Shawarmas` with `docker-compose.pi.yml`, `infrastructure/nginx/default.conf`, and private `.env` files (never commit `.env` files):
   ```bash
   cp .env.example .env
   cp server/.env.example server/.env
   cp services/api/.env.example services/api/.env
   ```
3. Configure production environment variables:
   - Root `.env`:
     - `IMAGE_BASE_URL=https://shawarmas.donivanovich.dev/cdn`
     - `SESSION_COOKIE_SECURE=true`
     - `GHCR_OWNER=donivanovich`
     - `IMAGE_TAG=latest` *(automatically overridden by CD with `sha-<commit>`)*
   - `server/.env`:
     - `NODE_ENV=production`
     - `PORT=3000`
     - `IMAGE_STORAGE_PATH=/app/storage`
     - `MAX_FILE_SIZE_MB=10`
     - `UPLOAD_API_KEY=<long-random-secret>`
     - `IMAGE_BASE_URL=https://shawarmas.donivanovich.dev/cdn`
   - `services/api/.env`:
     - `NODE_ENV=production`
     - `API_PORT=3001`
     - `API_CORS_ORIGINS=https://shawarmas.donivanovich.dev`
     - `DB_HOST=<mysql-service-name-on-mysql_backend>`
     - `DB_PORT=3306`
     - `DB_NAME=shawarmas`
     - `DB_USER=<restricted-api-db-user>`
     - `DB_PASSWORD=<unique-strong-password>`
     - `IMAGE_SERVER_URL=http://image-server:3000` *(always internal)*
     - `IMAGE_SERVER_API_KEY=<exact-same-value-as-UPLOAD_API_KEY>`
4. Pull multi-architecture ARM64 images and start the stack:
   ```bash
   docker compose -f docker-compose.pi.yml pull
   docker compose -f docker-compose.pi.yml up -d
   docker compose -f docker-compose.pi.yml ps
   ```
5. Verify locally on the Raspberry Pi and publicly through Cloudflare:
   ```bash
   curl -fsSI http://127.0.0.1:3100/
   curl -fsSI http://127.0.0.1:3100/cdn/brand/logo.png
   curl -fsSI https://shawarmas.donivanovich.dev/
   curl -fsSI https://shawarmas.donivanovich.dev/cdn/brand/logo.png
   ```

### Updating containers in production

Automated updates run through `.github/workflows/cd-deploy-rpi.yml` after `CI` and `CD - Publish Docker Images` succeed on `master`. For manual updates on the Raspberry Pi:

```bash
cd /opt/docker/apps/Shawarmas
IMAGE_TAG=sha-<commit> docker compose -f docker-compose.pi.yml pull api image-server web
IMAGE_TAG=sha-<commit> docker compose -f docker-compose.pi.yml up -d --no-build --remove-orphans
docker compose -f docker-compose.pi.yml ps
```

Never run `docker compose down -v`: doing so deletes the `shawarmas-images` volume.

### Troubleshooting production

| Symptom | Diagnostic command | Common cause & fix |
| --- | --- | --- |
| 502/504 from Cloudflare | `docker compose -f docker-compose.pi.yml ps` and `logs gateway web api` | Check `gateway` bound on `127.0.0.1:3100`, `api` `/health/ready`, or external `mysql_backend` availability. |
| Images return 404 on `/cdn/...` | `curl -I http://127.0.0.1:3100/cdn/brand/logo.png` | Verify `infrastructure/nginx/default.conf` keeps the trailing slash in `proxy_pass http://image-server:3000/;` and `IMAGE_BASE_URL=https://shawarmas.donivanovich.dev/cdn`. |
| Upload/delete fails from API | `docker compose -f docker-compose.pi.yml logs api image-server` | Confirm `IMAGE_SERVER_URL=http://image-server:3000` and `IMAGE_SERVER_API_KEY` matches `UPLOAD_API_KEY`. |
| Corrupted Spanish accents | Run section 2 of `db/repair-utf8-mojibake.sql` | Double-encoded rows in MySQL; follow the backup + repair steps in [Database](DATABASE.md). |
| Missing `Secure` on session cookie | `curl -I https://shawarmas.donivanovich.dev/products.php` | Ensure `SESSION_COOKIE_SECURE=true` in `.env` and `X-Forwarded-Proto` is forwarded by Nginx. |

## Local development (`docker-compose.yml`)

Create `db/.env`, `server/.env`, and `services/api/.env` from their `.env.example` templates with matching API database credentials and upload API key, then run:

```bash
docker compose up --build -d
docker compose ps
```

Local Compose starts a local `mysql:8.4` (`127.0.0.1:3307`), `image-server` (`127.0.0.1:3000`), `api` (`127.0.0.1:3001`), and `web` (`127.0.0.1:8080`).

## Desktop applications (Java and WPF)

Configure the following environment variables in the IDE run profile or shell before launching Java or WPF:

- `API_BASE_URL`: `http://127.0.0.1:3001/api/v1` for local development (or a private/VPN/SSH-tunneled API endpoint—never expose the API publicly without deliberate authentication/rate-limit planning).
- `IMAGE_BASE_URL`: `http://localhost:3000` locally, or `https://shawarmas.donivanovich.dev/cdn` when reading images from the production CDN.

Desktop clients do not require MySQL credentials or direct database access.
