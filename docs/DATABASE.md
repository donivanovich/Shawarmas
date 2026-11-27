# Database

## Character set and UTF-8 enforcement

All database tables and text columns are designed for `utf8mb4` with collation `utf8mb4_unicode_ci`:

- `db/schema.sql` and all incremental SQL scripts start with `SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;`.
- `services/api/src/database.ts` opens pooled `mysql2` connections with `charset: 'UTF8MB4_UNICODE_CI'`.
- `web/api-client.php` enforces `UTF-8` (`default_charset`, `mb_internal_encoding`, `Content-Type: text/html; charset=UTF-8`, `JSON_UNESCAPED_UNICODE`, and `htmlspecialchars(..., 'UTF-8')`).
- `app/src/com/shawarmas/ApiClient.java` sends `Content-Type: application/json; charset=utf-8` using `StandardCharsets.UTF_8`.

Always invoke the `mysql` CLI with `--default-character-set=utf8mb4` when applying SQL files or restoring dumps.

## Initialization and migrations

`db/schema.sql` defines the initial schema and demo data for a **new, empty** database only. It contains `DROP TABLE` statements for clean initialization—**never** run it against a database with data to preserve, and **never** use `docker compose down -v` as a migration step.

For an existing database (such as the external MySQL service on `mysql_backend` in production):

1. Back up the database first.
2. Inspect its current schema state and apply only the needed incremental scripts.
3. Do not reorder or rename existing migration files.

Incremental SQL scripts in `db/`:

- `migrate-variants.sql` — product size/color variant inventory.
- `migrate-product-colors.sql` — color-related product data.
- `migrate-product-color-corrections.sql` — color data corrections.
- `migrate-new-product-colors.sql` — additional product colors.
- `migrate-product-descriptions.sql` — product descriptions (`utf8mb4_unicode_ci`).
- `migrate-image-server.sql` — image path/server data changes.
- `migrate-product-image-refresh.sql` — product image references.
- `migrate-new-swm-collection.sql` — additional SWM collection data.
- `migrate-api-sessions.sql` — `api_sessions` table for REST API bearer tokens.
- `repair-utf8-mojibake.sql` — diagnostic preview and safe, transactional, idempotent repair for double-encoded UTF-8 rows.

## Tables and relationships

- `productos` references `categorias` and stores product details (`marca`, `modelo`, `precio`, `imagen`, `descripcion`).
- `producto_variantes` links each product to one size (`tallas`) and color (`colores`) and owns `stock` plus an optional variant `imagen`. A unique constraint prevents duplicate product/size/color combinations.
- `colores` includes swatch image paths (`/colors/*.png`).
- `clientes` own `pedidos`; `empleados` are associated with `tiendas`; `api_sessions` stores SHA-256 hashes of active API tokens.
- `productos_pedidos` links order lines to variants and stores `cantidad`.

## Image references

Product and variant images store relative paths in `productos.imagen` and `producto_variantes.imagen` (for example `/products/nike-air-force-1-sneakers-black.png`). Color swatches store `/colors/black.png`. Clients prepend `IMAGE_BASE_URL` at runtime (`https://shawarmas.donivanovich.dev/cdn` in production or `http://localhost:3000` locally), so changing CDN paths never requires rewriting database rows.

## Troubleshooting UTF-8 / double-encoding (mojibake)

If Spanish characters (`á`, `é`, `í`, `ó`, `ú`, `ñ`, `ü`, `€`) appear corrupted in product descriptions while static HTML labels render correctly, the rows in MySQL were previously inserted through a `latin1` client session (double-encoded UTF-8: e.g., `á` stored as hex `C383C2A1` instead of `C3A1`).

### Safe repair procedure (existing production MySQL)

1. Take a full UTF-8 backup first:
   ```bash
   mysqldump --default-character-set=utf8mb4 --single-transaction \
     -h <DB_HOST> -u <DB_USER> -p shawarmas > shawarmas-backup-$(date +%F).sql
   ```
2. Run the read-only diagnostic queries (sections 1 and 2 of `db/repair-utf8-mojibake.sql`) to inspect table/column collations and preview the exact rows that will change.
3. Apply `db/repair-utf8-mojibake.sql` explicitly with UTF-8:
   ```bash
   mysql --default-character-set=utf8mb4 -h <DB_HOST> -u <DB_USER> -p shawarmas < db/repair-utf8-mojibake.sql
   ```
   The script runs inside a transaction and updates **only** rows whose `HEX()` matches double-encoded UTF-8 patterns and whose reverse conversion produces a valid, strictly shorter string without introducing `?` replacement characters. Already-valid UTF-8 text is untouched, and re-running the script is idempotent.
4. Verify section 4 of the script returns `0` affected rows and inspect a product page (for example `/product.php?id=11`).

## Backup and restore

Back up MySQL and the `shawarmas-images` Docker volume together so database image paths and files stay consistent:

```bash
# 1. Database backup (UTF-8)
mysqldump --default-character-set=utf8mb4 --single-transaction \
  -h <DB_HOST> -u <DB_USER> -p shawarmas | gzip > shawarmas-db-$(date +%F).sql.gz

# 2. Image volume backup (read-only mount)
docker run --rm \
  -v shawarmas_shawarmas-images:/source:ro \
  -v "$(pwd)":/backup \
  alpine tar czf "/backup/shawarmas-images-$(date +%F).tar.gz" -C /source .
```

Never run `docker compose down -v` during routine maintenance or upgrades.
