# Shawarmas

Shawarmas is a clothing store monorepo with a PHP storefront, a MySQL database, a shared Express image service, and optional Java and WPF desktop clients. This repository keeps the existing applications and their database/image interfaces together.

## Features

- Product catalog, product variants, customer accounts, cart and order flows in the PHP storefront.
- MySQL persistence for products, size/color inventory, customers, employees and orders.
- Shared product, color-swatch and brand image delivery for all three clients.
- Java and WPF desktop clients for employee workflows.

## Technology

| Area | Technology |
| --- | --- |
| Storefront | PHP 8.3, Apache, MySQLi |
| Database | MySQL 8.4 |
| Image service | Node.js 20+, Express 5, Multer |
| Desktop clients | Java 17+, Maven, Swing; .NET 8 WPF |
| Local services | Docker Compose v2 |

## Repository layout

```text
web/       PHP storefront, styles, fonts, scripts, Dockerfile
app/       Java/Maven desktop client and Eclipse project metadata
wpf/       WPF solution, MVVM views, services and visual/audio resources
server/    Express image API, tests, Dockerfile and image assets
db/        Initial schema, ordered incremental SQL migrations, DB env example
docs/      Architecture, database, deployment and security guides
```

Existing directory names and image paths are retained so local IDE projects, Docker build contexts, and database references continue to work.

## Architecture

See [Architecture](docs/ARCHITECTURE.md) for the component diagram and client connections. See [Database](docs/DATABASE.md), [Deployment](docs/DEPLOYMENT.md), and [Security](docs/SECURITY.md) for operational details.

## Requirements

- Git and Docker Desktop with Docker Compose v2 for the complete local stack.
- JDK 17 and Maven to build the Java client.
- Windows with .NET 8 SDK and WPF targeting support to build the WPF client.
- Node.js 20+ to run image-server tests outside Docker.

## Configure and start

Copy the examples and set private values before starting. Do not reuse the example passwords or upload key for a shared or public deployment.

```powershell
Copy-Item db\.env.example db\.env
Copy-Item server\.env.example server\.env
# Edit db/.env and server/.env; use unique values for all secrets.
docker compose up --build -d
docker compose ps
```

Services are available at:

- Storefront: <http://localhost:8080>
- Catalog: <http://localhost:8080/products.php>
- Image health: <http://localhost:3000/health>
- MySQL from desktop clients: `127.0.0.1:3307`

Compose binds MySQL to loopback only. Containers use the internal hostname `db:3306`; host applications use `127.0.0.1:3307`. `db/schema.sql` initializes a new, empty database volume only. It contains destructive reset statements and must not be run against an existing database. Apply only the migration(s) appropriate to the database's current state; see [Database](docs/DATABASE.md).

The images under `server/storage/` are preserved in source control. On image-server startup, repository product images seed only missing files in the named image volume. Existing volume files are retained. Color swatches and brand assets remain at their established routes. `docker compose down` preserves both named volumes; `docker compose down -v` deletes database and image data.

## Run the clients

Start MySQL with `docker compose up -d db` first. Set `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` and `DB_PASSWORD` in the client process environment. Set `IMAGE_BASE_URL` when the default `http://localhost:3000` is not suitable.

### Java

Open `app/` as an existing Maven project in Eclipse and run `com.shawarmas.Login`, or build with `mvn -f app/pom.xml package`. Details: [Java client guide](app/README.md).

### WPF

Open `wpf/Shawarmas.sln` in Visual Studio, or run `dotnet build wpf/Shawarmas.csproj` and `dotnet run --project wpf/Shawarmas.csproj`. Details: [WPF client guide](wpf/README.md).

### Web and image service

The storefront and image service run through Compose. Their guides are [web/README.md](web/README.md) and [server/README.md](server/README.md). The image API preserves `/products/`, `/colors/`, `/brand/`, `POST /api/products` and `DELETE /api/products/:filename`; database rows continue storing relative paths.

## Security and credentials

Runtime `.env` files are ignored by Git. Desktop clients require `DB_PASSWORD` and no longer fall back to a source-coded password. PHP receives the database password from its Compose environment. Keep `UPLOAD_API_KEY` private, use HTTPS and a trusted reverse proxy outside local development, and back up the database and image volume. See [Security](docs/SECURITY.md).

## Validation

The image-server automated suite can be run with `cd server; npm ci; npm test`, and the REST API build and test suite with `cd services/api; npm ci; npm test`. Java and WPF build commands are above. Validation depends on Docker, Maven and the Windows WPF toolchain being available; see the final change report for the commands actually run.

## CI/CD (GitHub Actions)

This repository uses GitHub Actions to automate continuous integration, container image delivery, security checks, and optional VPS deployment across all monorepo components (`services/api`, `server`, `web`, `db`, `app`, and `wpf`).

### Workflows overview

| Workflow | File | Purpose |
| --- | --- | --- |
| **CI** | `.github/workflows/ci.yml` | Builds, lints, and tests affected monorepo services and desktop clients, validates `docker-compose.yml` and Docker builds, and exposes a single `CI Gate` check for branch protection. |
| **CD - Publish Docker Images** | `.github/workflows/cd-docker.yml` | Builds and publishes `api`, `image-server`, and `web` images to GitHub Container Registry (`ghcr.io`) with immutable SHA, branch, and semantic release tags. |
| **CD - Deploy to VPS** | `.github/workflows/cd-deploy-vps.yml` | Manual, environment-gated SSH deployment to a self-hosted Docker Compose server with pre-flight checks, post-deploy health verification, and automatic rollback on failure. |
| **Security Audit** | `.github/workflows/security.yml` | Checks that no runtime `.env` files are tracked in Git and runs `npm audit --omit=dev --audit-level=high` on `services/api` and `server`. |
| **Dependabot** | `.github/dependabot.yml` | Opens weekly dependency update PRs for GitHub Actions, npm (`services/api`, `server`), Maven (`app`), and Dockerfiles (`services/api`, `server`, `web`). |

### When workflows run

- **CI (`ci.yml`)**: Runs on every `push` and `pull_request` targeting `master` (and `main` if renamed), plus manual `workflow_dispatch`.
  - On **pull requests**, a `detect-changes` job inspects the PR diff so only affected components run (saving runner minutes, especially on `windows-latest` for WPF). Because `services/api`'s UTF-8 test scans repository text files, the `api` job runs whenever text/code/SQL/web files change. Stale PR runs are automatically cancelled via `concurrency`.
  - On **pushes to `master`/`main`** and **manual runs**, all jobs execute for full-stack verification.
- **CD - Publish Docker Images (`cd-docker.yml`)**: Runs on `push` to `master`/`main` when `services/api/**`, `server/**`, `web/**`, `docker-compose.yml`, or the workflow file change; on published GitHub Releases (`release: published`); and via manual `workflow_dispatch` (with a service selector). It never runs on pull requests.
- **CD - Deploy to VPS (`cd-deploy-vps.yml`)**: Runs only on manual `workflow_dispatch` inside the `production` GitHub Environment.
- **Security Audit (`security.yml`)**: Runs weekly (Mondays at 06:00 UTC), manually via `workflow_dispatch`, and on `push`/`pull_request` when `services/api/package-lock.json`, `server/package-lock.json`, or the workflow file change.

### Validations performed by CI

| Job | Runner | Validations |
| --- | --- | --- |
| `api` | `ubuntu-latest` (Node 22) | Reproducible `npm ci`, TypeScript strict compilation (`tsc -p tsconfig.json`), API smoke tests, and repo-wide UTF-8 / SQL / HTML charset verification (`npm test`). |
| `image-server` | `ubuntu-latest` (Node 22) | Reproducible `npm ci` and automated image API suite (`npm test` via `node --test` + Supertest). |
| `web-db-compose` | `ubuntu-latest` (PHP 8.3) | PHP syntax check (`php -l`) on all `web/*.php`, JS syntax check (`node --check`) on `web/**/*.js`, shell syntax check (`bash -n db/create-api-user.sh`), and `docker compose config --quiet` using ephemeral copies of `.env.example`. |
| `java-client` | `ubuntu-latest` (JDK 17) | Maven build and packaging (`mvn -f app/pom.xml -B clean package`). *Note: the Java client currently has no unit tests.* |
| `wpf-client` | `windows-latest` (.NET 8) | Solution restore and Release compilation (`dotnet build wpf/Shawarmas.sln --configuration Release --no-restore`). *Note: the WPF client currently has no unit tests.* |
| `docker-build` | `ubuntu-latest` (Buildx) | Validates `Dockerfile` builds for `services/api`, `server`, and `web` (`push: false`) with GitHub Actions cache. |
| `ci-gate` | `ubuntu-latest` | Aggregates every CI job result (`success` or `skipped` allowed; fails on any `failure` or `cancelled`). Configure **`CI Gate`** as the required status check in branch protection rules. |

### How deployment works

1. **Container delivery (GHCR)**: `cd-docker.yml` authenticates to `ghcr.io` using the scoped built-in `GITHUB_TOKEN` (`packages: write` on the publish job only) and pushes:
   - `ghcr.io/<owner>/shawarmas-api`
   - `ghcr.io/<owner>/shawarmas-image-server`
   - `ghcr.io/<owner>/shawarmas-web`
   Each build receives traceable tags (`sha-<commit>`, branch name, semantic version on GitHub Releases, and `latest` only on the default branch).
2. **VPS deployment (`cd-deploy-vps.yml`)**: Connects to the target Linux server over SSH using `StrictHostKeyChecking=yes`, verifies that private runtime files (`db/.env`, `server/.env`, `services/api/.env`) exist on the host, records the previous commit SHA, checks out the requested Git ref, builds the updated Docker images before recreating containers (`docker compose up -d --remove-orphans`, never touching named volumes `shawarmas-db` or `shawarmas-images`), and verifies loopback health endpoints (`/health`, `/health/ready`, and storefront `/`). If build, startup, or health checks fail, it automatically checks out the previous commit and restores the stack.

### Required secrets and GitHub settings

- **CI, Security Audit, and GHCR publishing (`ci.yml`, `security.yml`, `cd-docker.yml`)**: No manual secrets required; they use the default `GITHUB_TOKEN` with least-privilege `permissions`. Ensure **Settings -> Actions -> General -> Workflow permissions** allows workflows to declare `packages: write` (or keep default read permissions, since `cd-docker.yml` explicitly requests `packages: write` at the job level).
- **VPS deployment (`cd-deploy-vps.yml`)**: Create a GitHub Environment named **`production`** under **Settings -> Environments** (optionally with required reviewers and deployment branch restrictions) and add these environment secrets:

| Secret | Required | Description |
| --- | --- | --- |
| `VPS_HOST` | Yes | Public hostname or IP address of the VPS. |
| `VPS_USER` | Yes | Non-root SSH user with permission to run `git` and `docker compose`. |
| `VPS_SSH_KEY` | Yes | Private SSH key authorized on the VPS (`~/.ssh/authorized_keys`). |
| `VPS_SSH_KNOWN_HOSTS` | Yes | Verified SSH host key line from `ssh-keyscan -p <port> <host>`. |
| `VPS_DEPLOY_PATH` | Yes | Absolute path to the cloned repository on the VPS containing `db/.env`, `server/.env`, and `services/api/.env`. |
| `VPS_PORT` | No | Custom SSH port (defaults to `22`). |

### Viewing results and troubleshooting failures

1. Open the **Actions** tab in GitHub to inspect workflow runs, filter by workflow or branch, and view per-job logs. On Pull Requests, check the **Checks** tab and the required **`CI Gate`** status.
2. When a job fails:
   - **`api` / `image-server`**: Reproduce locally with `npm --prefix services/api ci && npm --prefix services/api test` or `npm --prefix server ci && npm --prefix server test`. If `utf8.test.ts` fails, check the reported file for non-UTF-8 encoding, BOM, or missing `accept-charset="UTF-8"` / `SET NAMES utf8mb4`.
   - **`web-db-compose`**: Run `php -l` on modified PHP files, `node --check` on JS files, `bash -n db/create-api-user.sh`, and `docker compose config --quiet` (with local `.env` files).
   - **`java-client` / `wpf-client`**: Reproduce with `mvn -f app/pom.xml -B clean package` or `dotnet build wpf/Shawarmas.sln --configuration Release` on Windows.
   - **`docker-build` / `cd-docker`**: Reproduce with `docker build ./services/api`, `docker build ./server`, or `docker build ./web`.
   - **`security`**: Run `npm audit --omit=dev --audit-level=high` inside `services/api` or `server` and update vulnerable lockfile entries, or remove accidentally staged `.env` files from Git history.
   - **`cd-deploy-vps`**: Check whether required `production` environment secrets are set, verify SSH connectivity and `known_hosts`, and inspect `docker compose logs` on the VPS if health checks triggered a rollback.

## License

No license is declared. Contact the repository owner before redistributing this project or its assets.
