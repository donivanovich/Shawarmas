# Database

## Initialization and migrations

`db/schema.sql` defines the initial schema and demo data. Compose mounts it into MySQL's initialization directory; MySQL runs it only when the database data directory is empty. The script currently contains `DROP TABLE` statements as part of its reset-style initialization. Never run it against a database with data to preserve, and never delete the named database volume as a migration strategy.

For an existing database, back it up first, determine its current schema level, and apply only the required incremental scripts. The repository has no migration ledger, so operators must track applied files. Preserve this history and do not reorder or rename migration files.

Incremental scripts currently present (review their preconditions before use):

- `migrate-variants.sql` — product size/color variant inventory.
- `migrate-product-colors.sql` — color-related product data.
- `migrate-product-color-corrections.sql` — color data corrections.
- `migrate-new-product-colors.sql` — additional product colors.
- `migrate-product-descriptions.sql` — product descriptions.
- `migrate-image-server.sql` — image path/server data changes.
- `migrate-product-image-refresh.sql` — product image references.
- `migrate-new-swm-collection.sql` — additional SWM collection data.

Filename order is not guaranteed to be execution order. Inspect SQL preconditions and the history of the target database before choosing a sequence. No migration is run automatically by this repository's Compose setup.

## Tables and relationships

- `productos` references `categorias` and stores product details and a primary image path.
- `producto_variantes` links each product to one size and color and owns stock plus an optional variant image. A unique constraint prevents duplicate product/size/color combinations.
- `colores` and `tallas` provide the selectable variant values; color rows include swatch image paths.
- `clientes` own `pedidos`; `empleados` are associated with `tiendas`.
- `productos_pedidos` links order lines to variants and stores quantity.
- `pedidos` stores delivery details and references a customer and store.

The schema also defines `tiendas` and `categorias` lookup data. Password columns hold hashes; credentials should be managed through application workflows, not SQL edits.

## Image references

Product and variant images use relative paths in `productos.imagen` and `producto_variantes.imagen`, for example `/products/nike-air-force-1-sneakers-black.png`. Color swatches use `/colors/black.png`. Clients join relative paths to `IMAGE_BASE_URL`. Preserve filenames and these route prefixes when restoring or moving image storage.

## Backup and restore

Back up MySQL and `shawarmas-images` together so records and referenced files remain consistent. A database backup can be created with `mysqldump` using the configured application or administrative account. For the image volume, stop writes and archive `/app/storage` from the image-server container. Restore both into their existing named volumes, then start the services and check representative image paths and records. Do not use `docker compose down -v` during routine maintenance.
