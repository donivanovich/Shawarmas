# Shawarmas

Shawarmas is a clothing store monorepo with a PHP storefront, a shared TypeScript/Node.js REST API, a centralized Express image service, an Nginx production gateway, a MySQL 8.4 database, and optional Java and WPF desktop clients.

## Features

- Product catalog, product variants, customer accounts, cart and order flows in the PHP storefront.
- Centralized REST API (`services/api`) handling authentication, RBAC, catalog, inventory, orders, and internal image management.
- MySQL 8.4 persistence (`utf8mb4_unicode_ci`) for products, size/color inventory, customers, employees, orders, and API sessions.
- Shared product, color-swatch, and brand image delivery served publicly through the `/cdn/` gateway path in production (`https://shawarmas.donivanovich.dev/cdn`) and `http://localhost:3000` locally.
- Java Swing and .NET 8 WPF desktop clients communicating exclusively with the REST API and image service.

## Technology

| Area | Technology |
| --- | --- |
| Production Gateway | Nginx 1.27 Alpine (`127.0.0.1:3100:8080`, fronted by Cloudflare Tunnel) |
| Storefront | PHP 8.3, Apache, cURL |
| REST API | Node.js 22, TypeScript 5.9, Express 5, Zod, mysql2 |
| Database | MySQL 8.4 (`utf8mb4_unicode_ci`, external `mysql_backend` in production) |
| Image service | Node.js 22, Express 5, Multer |
| Desktop clients | Java 17+, Maven, Swing; .NET 8 WPF |
| Orchestration | Docker Compose v2 (`docker-compose.yml` dev / `docker-compose.pi.yml` Raspberry Pi 5 prod) |

## Repository layout

```text
infrastructure/  Nginx production gateway configuration (infrastructure/nginx/default.conf)
services/api/    TypeScript REST API, UTF-8 and smoke tests, Dockerfile
web/             PHP storefront, styles, fonts, scripts, Dockerfile
server/          Express image API, tests, Dockerfile, and seeded image assets
app/             Java/Maven desktop client
wpf/             .NET 8 WPF solution, MVVM views, services, and resources
db/              Initial schema, incremental SQL migrations, UTF-8 mojibake repair script
docs/            Architecture, database, deployment, and security guides
.github/         GitHub Actions CI/CD workflows and Dependabot config
```

## Architecture

- **Production (Raspberry Pi 5, `/opt/docker/apps/Shawarmas`, `docker-compose.pi.yml`):** Cloudflare Tunnel maps `shawarmas.donivanovich.dev` -> `localhost:3100` (`gateway`). Nginx forwards `/` to `http://web:80` and `/cdn/` to `http://image-server:3000/` (stripping the `/cdn/` prefix and blocking `/cdn/api/*`). `web`, `api`, and `image-server` publish no host ports. `api` talks internally to `IMAGE_SERVER_URL=http://image-server:3000` and connects to external MySQL via the `mysql_backend` Docker network.
- See [Architecture](docs/ARCHITECTURE.md), [Database](docs/DATABASE.md), [Deployment](docs/DEPLOYMENT.md), and [Security](docs/SECURITY.md) for diagrams, routing, backups, and UTF-8 troubleshooting.

## Requirements

- Git and Docker with Docker Compose v2 for local or production stacks.
- JDK 17 and Maven to build the Java client.
- Windows with .NET 8 SDK and WPF targeting support to build the WPF client.
- Node.js 20+ (22 recommended) to run `services/api` and `server` tests outside Docker.

## Configure and start (local development)

Copy the examples and set private values before starting. Never reuse example passwords or API keys in production.

```powershell
Copy-Item db\.env.example db\.env
Copy-Item server\.env.example server\.env
Copy-Item services\api\.env.example services\api\.env
# Edit db/.env, server/.env, and services/api/.env so DB credentials and UPLOAD_API_KEY/IMAGE_SERVER_API_KEY match.
docker compose up --build -d
docker compose ps
```

Local development services are available at:

- Storefront: <http://localhost:8080>
- Catalog: <http://localhost:8080/products.php>
- REST API readiness: <http://127.0.0.1:3001/health/ready>
- Image service health: <http://localhost:3000/health>
- Local MySQL (loopback only): `127.0.0.1:3307`

`db/schema.sql` initializes a new, empty database volume only—never run it against an existing database. `docker compose down` preserves named volumes (`shawarmas-db`, `shawarmas-images`); never use `docker compose down -v` on data you want to keep.

For Raspberry Pi 5 production deployment (`docker-compose.pi.yml`), see [Deployment](docs/DEPLOYMENT.md).

## Run the clients

Both desktop clients authenticate and operate through the REST API (`API_BASE_URL`, default `http://127.0.0.1:3001/api/v1`) and load images from `IMAGE_BASE_URL` (default `http://localhost:3000`; set `https://shawarmas.donivanovich.dev/cdn` for the production CDN). Neither desktop client connects directly to MySQL.

### Java

Open `app/` as a Maven project and run `com.shawarmas.Login`, or build with `mvn -f app/pom.xml -B clean package`. Details: [Java client guide](app/README.md).

### WPF

Open `wpf/Shawarmas.sln` in Visual Studio, or run `dotnet build wpf/Shawarmas.sln --configuration Release`. Details: [WPF client guide](wpf/README.md).

### Web and image service

Guides: [web/README.md](web/README.md) and [server/README.md](server/README.md). Database rows continue storing relative image paths (`/products/<filename>`, `/colors/<filename>`); clients prepend `IMAGE_BASE_URL` at runtime.

## Security and credentials

Runtime `.env` files are ignored by Git. `UPLOAD_API_KEY` and `IMAGE_SERVER_API_KEY` stay strictly server-side; `/cdn/api/*` is blocked at the Nginx gateway. Session cookies enforce `HttpOnly`, `SameSite=Lax`, and `Secure` behind HTTPS/Cloudflare. See [Security](docs/SECURITY.md).

## Validation

Run automated test suites locally with:

```powershell
npm --prefix services/api ci; npm --prefix services/api test
npm --prefix server ci; npm --prefix server test
```

`services/api` tests include TypeScript compilation, API smoke checks, UTF-8 / mojibake regression checks, and production gateway/Compose contract checks.

## CI/CD (GitHub Actions)

This repository uses GitHub Actions to automate continuous integration, multi-arch container delivery, security checks, and Raspberry Pi 5 deployment across all monorepo components (`services/api`, `server`, `web`, `db`, `app`, `wpf`, and `infrastructure/nginx`).

### Workflows overview

| Workflow | File | Purpose |
| --- | --- | --- |
| **CI** | `.github/workflows/ci.yml` | Builds, lints, and tests affected monorepo services and desktop clients, validates `docker-compose.yml` and `docker-compose.pi.yml`, validates Docker builds, and exposes a single `CI Gate` check for branch protection. |
| **CD - Publish Docker Images** | `.github/workflows/cd-docker.yml` | Runs only after **CI** succeeds on `master` (or on Releases / manual dispatch), building and publishing multi-architecture (`linux/amd64`, `linux/arm64`) images for `api`, `image-server`, and `web` to GitHub Container Registry (`ghcr.io`). |
| **CD - Deploy to Raspberry Pi** | `.github/workflows/cd-deploy-rpi.yml` | Runs automatically on `master` only after **CI** and **CD - Publish Docker Images** succeed (or via manual `workflow_dispatch`), verifies `linux/arm64` manifests in GHCR, connects to the Raspberry Pi 5 over SSH, pulls new images, updates containers with `docker compose -f docker-compose.pi.yml up -d`, verifies health/readiness probes (including `gateway`), and rolls back automatically on failure. |
| **Security Audit** | `.github/workflows/security.yml` | Checks that no runtime `.env` files are tracked in Git and runs `npm audit --omit=dev --audit-level=high` on `services/api` and `server`. |
| **Dependabot** | `.github/dependabot.yml` | Opens weekly dependency update PRs for GitHub Actions, npm (`services/api`, `server`), Maven (`app`), and Dockerfiles (`services/api`, `server`, `web`). |

### When workflows run

- **CI (`ci.yml`)**: Runs on every `push` and `pull_request` targeting `master` (and `main` if renamed), plus manual `workflow_dispatch`. On PRs, `detect-changes` runs only affected components and cancels stale runs; on pushes to `master`/`main` and manual runs, the full suite executes.
- **CD - Publish Docker Images (`cd-docker.yml`)**: Triggered via `workflow_run` only after **CI** finishes with `conclusion == success` on a `push` to `master`/`main` (skipping non-container commits), on published Releases, or via `workflow_dispatch`. Never runs on PRs.
- **CD - Deploy to Raspberry Pi (`cd-deploy-rpi.yml`)**: Triggered via `workflow_run` only after **CD - Publish Docker Images** finishes with `conclusion == success` on `master`, or via manual `workflow_dispatch` on `master`. Never deploys from PRs.
- **Security Audit (`security.yml`)**: Runs weekly (Mondays 06:00 UTC), manually, and on lockfile changes.

### Validations performed by CI

| Job | Runner | Validations |
| --- | --- | --- |
| `api` | `ubuntu-latest` (Node 22) | Reproducible `npm ci`, TypeScript compilation (`tsc -p tsconfig.json`), API smoke tests, UTF-8 / mojibake repair regression tests, and production gateway/Compose contract checks (`npm test`). |
| `image-server` | `ubuntu-latest` (Node 22) | Reproducible `npm ci` and automated image API suite (`npm test` via `node --test` + Supertest). |
| `web-db-compose` | `ubuntu-latest` (PHP 8.3) | PHP syntax check (`php -l`), JS syntax check (`node --check`), shell syntax check (`bash -n db/create-api-user.sh`), and `docker compose config --quiet` on both `docker-compose.yml` and `docker-compose.pi.yml`. |
| `java-client` | `ubuntu-latest` (JDK 17) | Maven build and packaging (`mvn -f app/pom.xml -B clean package`). *No Java unit tests exist yet.* |
| `wpf-client` | `windows-latest` (.NET 8) | Solution restore and Release compilation (`dotnet build wpf/Shawarmas.sln --configuration Release --no-restore`). *No WPF unit tests exist yet.* |
| `docker-build` | `ubuntu-latest` (Buildx) | Validates `Dockerfile` builds for `services/api`, `server`, and `web` (`push: false`) with GHA cache. |
| `ci-gate` | `ubuntu-latest` | Aggregates all CI job results. Configure **`CI Gate`** as the required status check in branch protection rules. |

### Required secrets and GitHub settings

- **CI, Security Audit, and GHCR publishing (`ci.yml`, `security.yml`, `cd-docker.yml`)**: Use the scoped built-in `GITHUB_TOKEN`; no manual secrets required.
- **Raspberry Pi 5 deployment (`cd-deploy-rpi.yml`)**: Create a GitHub Environment named **`production`** under **Settings -> Environments** (restrict **Deployment branches** to `master` only) and configure:

#### Required Environment Secrets (`production`)

| Secret | Required | Description |
| --- | --- | --- |
| `RPI_HOST` | Yes | Reachable hostname, DDNS, Tailscale/VPN IP, or IP of the Raspberry Pi 5. |
| `RPI_USER` | Yes | Non-root SSH user on the Raspberry Pi with permission to run `docker` and `docker compose`. |
| `RPI_SSH_KEY` | Yes | Private SSH key authorized on the Raspberry Pi (`~/.ssh/authorized_keys`). |
| `RPI_SSH_KNOWN_HOSTS` | Yes | Verified SSH host key entry from `ssh-keyscan -p <port> <host>`. |
| `RPI_DEPLOY_PATH` | Yes | Absolute production path on the Raspberry Pi (e.g. `/opt/docker/apps/Shawarmas`). |
| `RPI_PORT` | No | Custom SSH port (defaults to `22`). |
| `GHCR_PULL_TOKEN` | No | Token with `read:packages` (only needed if GHCR packages are private). |
| `GHCR_PULL_USER` | No | GitHub username paired with `GHCR_PULL_TOKEN` (defaults to repository owner). |

#### Optional Environment Variables (`production`)

| Variable | Default | Description |
| --- | --- | --- |
| `RPI_COMPOSE_FILE` | `docker-compose.pi.yml` | Compose filename inside `RPI_DEPLOY_PATH`. |
| `RPI_SERVICES` | `api image-server web` | Space-separated application services to pull and verify image updates for. |
| `RPI_HEALTH_WAIT_SECONDS` | `90` | Maximum seconds to wait for container health checks after `docker compose up -d`. |

### Viewing results and troubleshooting failures

1. Open the **Actions** tab in GitHub to inspect workflow runs and per-job logs. On Pull Requests, check the **`CI Gate`** status.
2. When a job fails:
   - **`api` / `image-server`**: Reproduce locally with `npm --prefix services/api ci && npm --prefix services/api test` or `npm --prefix server ci && npm --prefix server test`.
   - **`web-db-compose`**: Run `php -l`, `node --check`, `bash -n db/create-api-user.sh`, and `docker compose -f docker-compose.yml config --quiet` / `docker compose -f docker-compose.pi.yml config --quiet`.
   - **`java-client` / `wpf-client`**: Reproduce with `mvn -f app/pom.xml -B clean package` or `dotnet build wpf/Shawarmas.sln --configuration Release`.
   - **`cd-deploy-rpi`**: Inspect `verify-release` logs (CI status and `linux/arm64` manifests), verify `production` environment secrets, and check `docker compose -f docker-compose.pi.yml logs` on the Raspberry Pi if automatic rollback triggered. Manual rollback is always available via **Actions -> `CD - Deploy to Raspberry Pi` -> Run workflow** with a previous `sha-<commit>` tag.

## License

No license is declared. Contact the repository owner before redistributing this project or its assets.
