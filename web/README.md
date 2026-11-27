# Shawarmas Web Store

The PHP 8.3 storefront uses the TypeScript REST API for account, catalog, cart, and order operations. It does not connect directly to MySQL.

## Runtime communication

- **API:** `API_BASE_URL=http://api:3001/api/v1` over the internal Docker network (`shawarmas_internal` in production, default Compose network locally).
- **Images (browser URLs):** `IMAGE_BASE_URL` is joined to relative paths stored in MySQL (`/products/...`, `/colors/...`, `/brand/...`):
  - **Production (Raspberry Pi 5):** `https://shawarmas.donivanovich.dev/cdn` (routed through the Nginx `gateway` container which strips `/cdn/` before forwarding to `image-server:3000`).
  - **Local development:** `http://localhost:3000`.
- **Sessions & security:** `web/api-client.php` sets UTF-8 headers (`Content-Type: text/html; charset=UTF-8`), CSRF tokens on state-changing forms, and `HttpOnly` / `SameSite=Lax` / `Secure` cookies (detecting `SESSION_COOKIE_SECURE=true` or `X-Forwarded-Proto: https`). `web/Dockerfile` enables UTF-8 charset and disables `expose_php` and Apache version banners.

## Local development

Configure `db/.env`, `server/.env`, and `services/api/.env` from their `.env.example` templates, then start the local stack:

```sh
docker compose up -d --build
```

Open <http://localhost:8080>.

## Production (Raspberry Pi 5)

In `docker-compose.pi.yml`, `web` publishes **no host ports** and is exposed solely through the Nginx `gateway` (`127.0.0.1:3100:8080` -> Cloudflare Tunnel `shawarmas.donivanovich.dev`). Health is checked inside the container via PHP cURL against `http://127.0.0.1:80/`.
