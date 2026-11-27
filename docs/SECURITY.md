# Security

## Network and surface minimization

- **Single ingress point in production:** Only the Nginx `gateway` container binds a host port (`127.0.0.1:3100:8080`), reachable externally exclusively through Cloudflare Tunnel (`shawarmas.donivanovich.dev`).
- **Internal-only services:** `web`, `api`, and `image-server` publish **no host ports** in `docker-compose.pi.yml`.
- **Blocked management routes on CDN:** `infrastructure/nginx/default.conf` explicitly returns `404` for `/cdn/api/*` and `/cdn/health`, keeping `image-server` upload/delete endpoints reachable only over the internal Docker network (`http://image-server:3000`).
- **Database network isolation:** Only `api` attaches to the external `mysql_backend` Docker network. `gateway`, `web`, and `image-server` have no route to MySQL. Neither desktop client (`app`, `wpf`) holds database credentials or connects to MySQL.
- **Container hardening:** `api` runs as non-root `node` with `read_only: true`, `tmpfs: [/tmp]`, and `cap_drop: [ALL]`. `image-server` runs as non-root `node`. `web` disables `expose_php`, sets `ServerTokens Prod`, and turns `ServerSignature Off`.

## Credentials and secrets

- Runtime `.env` files (`.env`, `db/.env`, `server/.env`, `services/api/.env`) are ignored by Git and verified absent by `.github/workflows/security.yml`.
- Use `.env.example` files strictly as templates and replace every placeholder with unique high-entropy secrets.
- `UPLOAD_API_KEY` (`server/.env`) and `IMAGE_SERVER_API_KEY` (`services/api/.env`) must match and stay strictly server-side. Never embed upload keys in browsers or desktop distributions.
- GitHub Actions deployment credentials (`RPI_HOST`, `RPI_USER`, `RPI_SSH_KEY`, `RPI_SSH_KNOWN_HOSTS`, `RPI_DEPLOY_PATH`, optional `GHCR_PULL_TOKEN`) live only in the `production` GitHub Environment and are never stored in YAML or the repository.

## Application controls

- **Authentication and sessions:** Passwords use PBKDF2-SHA256 (with transparent upgrade from legacy PHP bcrypt hashes). API bearer tokens are stored as SHA-256 hashes in `api_sessions` with expiration and revocation.
- **Storefront cookies and CSRF:** PHP sets `HttpOnly`, `SameSite=Lax`, and `Secure` (via `SESSION_COOKIE_SECURE=true` or `X-Forwarded-Proto: https` behind Nginx/Cloudflare). State-changing storefront forms enforce CSRF tokens.
- **Input validation and SQL safety:** The REST API validates payloads with strict Zod schemas and uses parameterized `mysql2` prepared statements with `UTF8MB4_UNICODE_CI`.
- **Upload validation:** Both `api` and `image-server` restrict uploads to PNG, JPEG, and WebP, enforce size limits, validate magic-byte signatures, generate UUID filenames, and prevent path traversal.
- **Dependency and supply-chain hygiene:** `.github/workflows/security.yml` runs `npm audit --omit=dev --audit-level=high` weekly and on lockfile changes; `.github/dependabot.yml` tracks updates for npm, Maven, Dockerfiles, and GitHub Actions.

If a real credential has ever been committed or shared, rotate it immediately in the affected service.
