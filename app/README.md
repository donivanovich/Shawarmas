# Shawarmas Java Client

## Requirements

- JDK 17 or newer and Maven (Eclipse with m2e is optional).
- MySQL 8.0 or compatible.

## Configuration and run

Start MySQL with `docker compose up -d db` from the repository root. Set `DB_HOST=127.0.0.1`, `DB_PORT=3307`, `DB_NAME`, `DB_USER` and `DB_PASSWORD` in the IDE run profile or process environment. The password is required. Import `app/` as an existing Maven project in Eclipse and run `com.shawarmas.Login`, or build with `mvn -f app/pom.xml package`.

Compose initializes a new database volume from `db/schema.sql`; the application does not create or migrate the schema. See [database guidance](../docs/DATABASE.md).

## Features

The client supports sign-in, customer registration, product browsing and role-based order workflows. The UI is in Spanish.

## Security

Database credentials are supplied through environment variables. Registration and authentication use prepared statements and PBKDF2-HMAC-SHA256 with random salts. Never commit local secrets.

## Eclipse troubleshooting

If Eclipse has stale project paths, remove the project from the workspace without deleting files, then import `app/` through `File > Import > Maven > Existing Maven Projects`. Use `Project > Clean` before launching `com.shawarmas.Login`.
