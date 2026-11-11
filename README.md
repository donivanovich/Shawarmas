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

The image-server automated suite can be run with `cd server; npm ci; npm test`. Java and WPF build commands are above. Validation depends on Docker, Maven and the Windows WPF toolchain being available; see the final change report for the commands actually run.

## License

No license is declared. Contact the repository owner before redistributing this project or its assets.
