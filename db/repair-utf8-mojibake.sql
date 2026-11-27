SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
USE shawarmas;

-- =============================================================================
-- Safe, idempotent UTF-8 double-encoding (mojibake) diagnostic & repair script
-- =============================================================================
-- Problem addressed:
--   Rows inserted or migrated over a latin1/Windows-1252 client connection
--   into utf8mb4 columns store UTF-8 bytes twice, e.g.:
--     U+00E1 ('á', UTF-8 C3 A1) stored as HEX C383C2A1
--     U+00F3 ('ó', UTF-8 C3 B3) stored as HEX C383C2B3
--     U+20AC ('€', UTF-8 E2 82 AC) stored as HEX C3A2E2809AC2AC
--
-- Safety guarantees:
--   1. Always take a mysqldump backup before running against production:
--        mysqldump --default-character-set=utf8mb4 --single-transaction \
--          shawarmas > shawarmas-before-utf8-fix.sql
--   2. Inspect affected rows first with the preview SELECT below.
--   3. Only rows matching double-encoded UTF-8 byte sequences (HEX patterns)
--      AND whose reverse conversion via latin1 -> BINARY -> utf8mb4 produces
--      a non-null, strictly shorter string without introducing '?' lossy
--      replacement characters are modified.
--   4. Already-valid UTF-8 text (Spanish accents, €, other scripts, emojis)
--      is NEVER modified. Running this script multiple times is idempotent.
-- =============================================================================

-- 1. Diagnostic check: database and table character sets / collations
SELECT
    SCHEMA_NAME,
    DEFAULT_CHARACTER_SET_NAME,
    DEFAULT_COLLATION_NAME
FROM information_schema.SCHEMATA
WHERE SCHEMA_NAME = DATABASE();

SELECT
    TABLE_NAME,
    TABLE_COLLATION
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY TABLE_NAME;

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CHARACTER_SET_NAME,
    COLLATION_NAME
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND CHARACTER_SET_NAME IS NOT NULL
  AND (CHARACTER_SET_NAME <> 'utf8mb4' OR COLLATION_NAME <> 'utf8mb4_unicode_ci')
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- 2. Diagnostic preview: product descriptions that will be repaired
SELECT
    id_producto,
    marca,
    modelo,
    descripcion AS current_descripcion,
    CONVERT(BINARY CONVERT(descripcion USING latin1) USING utf8mb4) AS repaired_descripcion
FROM productos
WHERE descripcion IS NOT NULL
  AND HEX(descripcion) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
  AND CONVERT(BINARY CONVERT(descripcion USING latin1) USING utf8mb4) IS NOT NULL
  AND OCTET_LENGTH(CONVERT(BINARY CONVERT(descripcion USING latin1) USING utf8mb4)) < OCTET_LENGTH(descripcion)
  AND (
      LENGTH(descripcion) - LENGTH(REPLACE(descripcion, '?', ''))
      = LENGTH(CONVERT(BINARY CONVERT(descripcion USING latin1) USING utf8mb4))
        - LENGTH(REPLACE(CONVERT(BINARY CONVERT(descripcion USING latin1) USING utf8mb4), '?', ''))
  )
ORDER BY id_producto;

-- 3. Transactional, targeted, idempotent repair across text columns
START TRANSACTION;

-- productos.descripcion
UPDATE productos
SET descripcion = CONVERT(BINARY CONVERT(descripcion USING latin1) USING utf8mb4)
WHERE descripcion IS NOT NULL
  AND HEX(descripcion) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
  AND CONVERT(BINARY CONVERT(descripcion USING latin1) USING utf8mb4) IS NOT NULL
  AND OCTET_LENGTH(CONVERT(BINARY CONVERT(descripcion USING latin1) USING utf8mb4)) < OCTET_LENGTH(descripcion)
  AND (
      LENGTH(descripcion) - LENGTH(REPLACE(descripcion, '?', ''))
      = LENGTH(CONVERT(BINARY CONVERT(descripcion USING latin1) USING utf8mb4))
        - LENGTH(REPLACE(CONVERT(BINARY CONVERT(descripcion USING latin1) USING utf8mb4), '?', ''))
  );

-- productos.marca
UPDATE productos
SET marca = CONVERT(BINARY CONVERT(marca USING latin1) USING utf8mb4)
WHERE HEX(marca) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
  AND CONVERT(BINARY CONVERT(marca USING latin1) USING utf8mb4) IS NOT NULL
  AND OCTET_LENGTH(CONVERT(BINARY CONVERT(marca USING latin1) USING utf8mb4)) < OCTET_LENGTH(marca)
  AND (
      LENGTH(marca) - LENGTH(REPLACE(marca, '?', ''))
      = LENGTH(CONVERT(BINARY CONVERT(marca USING latin1) USING utf8mb4))
        - LENGTH(REPLACE(CONVERT(BINARY CONVERT(marca USING latin1) USING utf8mb4), '?', ''))
  );

-- productos.modelo
UPDATE productos
SET modelo = CONVERT(BINARY CONVERT(modelo USING latin1) USING utf8mb4)
WHERE HEX(modelo) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
  AND CONVERT(BINARY CONVERT(modelo USING latin1) USING utf8mb4) IS NOT NULL
  AND OCTET_LENGTH(CONVERT(BINARY CONVERT(modelo USING latin1) USING utf8mb4)) < OCTET_LENGTH(modelo)
  AND (
      LENGTH(modelo) - LENGTH(REPLACE(modelo, '?', ''))
      = LENGTH(CONVERT(BINARY CONVERT(modelo USING latin1) USING utf8mb4))
        - LENGTH(REPLACE(CONVERT(BINARY CONVERT(modelo USING latin1) USING utf8mb4), '?', ''))
  );

-- categorias.categoria
UPDATE categorias
SET categoria = CONVERT(BINARY CONVERT(categoria USING latin1) USING utf8mb4)
WHERE HEX(categoria) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
  AND CONVERT(BINARY CONVERT(categoria USING latin1) USING utf8mb4) IS NOT NULL
  AND OCTET_LENGTH(CONVERT(BINARY CONVERT(categoria USING latin1) USING utf8mb4)) < OCTET_LENGTH(categoria)
  AND (
      LENGTH(categoria) - LENGTH(REPLACE(categoria, '?', ''))
      = LENGTH(CONVERT(BINARY CONVERT(categoria USING latin1) USING utf8mb4))
        - LENGTH(REPLACE(CONVERT(BINARY CONVERT(categoria USING latin1) USING utf8mb4), '?', ''))
  );

-- colores.color
UPDATE colores
SET color = CONVERT(BINARY CONVERT(color USING latin1) USING utf8mb4)
WHERE HEX(color) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
  AND CONVERT(BINARY CONVERT(color USING latin1) USING utf8mb4) IS NOT NULL
  AND OCTET_LENGTH(CONVERT(BINARY CONVERT(color USING latin1) USING utf8mb4)) < OCTET_LENGTH(color)
  AND (
      LENGTH(color) - LENGTH(REPLACE(color, '?', ''))
      = LENGTH(CONVERT(BINARY CONVERT(color USING latin1) USING utf8mb4))
        - LENGTH(REPLACE(CONVERT(BINARY CONVERT(color USING latin1) USING utf8mb4), '?', ''))
  );

-- tiendas (pais, ciudad, calle)
UPDATE tiendas
SET
    pais = IF(
        HEX(pais) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
        AND CONVERT(BINARY CONVERT(pais USING latin1) USING utf8mb4) IS NOT NULL
        AND OCTET_LENGTH(CONVERT(BINARY CONVERT(pais USING latin1) USING utf8mb4)) < OCTET_LENGTH(pais)
        AND (LENGTH(pais) - LENGTH(REPLACE(pais, '?', '')) = LENGTH(CONVERT(BINARY CONVERT(pais USING latin1) USING utf8mb4)) - LENGTH(REPLACE(CONVERT(BINARY CONVERT(pais USING latin1) USING utf8mb4), '?', ''))),
        CONVERT(BINARY CONVERT(pais USING latin1) USING utf8mb4),
        pais
    ),
    ciudad = IF(
        HEX(ciudad) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
        AND CONVERT(BINARY CONVERT(ciudad USING latin1) USING utf8mb4) IS NOT NULL
        AND OCTET_LENGTH(CONVERT(BINARY CONVERT(ciudad USING latin1) USING utf8mb4)) < OCTET_LENGTH(ciudad)
        AND (LENGTH(ciudad) - LENGTH(REPLACE(ciudad, '?', '')) = LENGTH(CONVERT(BINARY CONVERT(ciudad USING latin1) USING utf8mb4)) - LENGTH(REPLACE(CONVERT(BINARY CONVERT(ciudad USING latin1) USING utf8mb4), '?', ''))),
        CONVERT(BINARY CONVERT(ciudad USING latin1) USING utf8mb4),
        ciudad
    ),
    calle = IF(
        HEX(calle) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
        AND CONVERT(BINARY CONVERT(calle USING latin1) USING utf8mb4) IS NOT NULL
        AND OCTET_LENGTH(CONVERT(BINARY CONVERT(calle USING latin1) USING utf8mb4)) < OCTET_LENGTH(calle)
        AND (LENGTH(calle) - LENGTH(REPLACE(calle, '?', '')) = LENGTH(CONVERT(BINARY CONVERT(calle USING latin1) USING utf8mb4)) - LENGTH(REPLACE(CONVERT(BINARY CONVERT(calle USING latin1) USING utf8mb4), '?', ''))),
        CONVERT(BINARY CONVERT(calle USING latin1) USING utf8mb4),
        calle
    )
WHERE HEX(pais) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
   OR HEX(ciudad) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
   OR HEX(calle) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280';

-- clientes (nombre, apellido1, apellido2)
UPDATE clientes
SET
    nombre = IF(
        HEX(nombre) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
        AND CONVERT(BINARY CONVERT(nombre USING latin1) USING utf8mb4) IS NOT NULL
        AND OCTET_LENGTH(CONVERT(BINARY CONVERT(nombre USING latin1) USING utf8mb4)) < OCTET_LENGTH(nombre)
        AND (LENGTH(nombre) - LENGTH(REPLACE(nombre, '?', '')) = LENGTH(CONVERT(BINARY CONVERT(nombre USING latin1) USING utf8mb4)) - LENGTH(REPLACE(CONVERT(BINARY CONVERT(nombre USING latin1) USING utf8mb4), '?', ''))),
        CONVERT(BINARY CONVERT(nombre USING latin1) USING utf8mb4),
        nombre
    ),
    apellido1 = IF(
        HEX(apellido1) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
        AND CONVERT(BINARY CONVERT(apellido1 USING latin1) USING utf8mb4) IS NOT NULL
        AND OCTET_LENGTH(CONVERT(BINARY CONVERT(apellido1 USING latin1) USING utf8mb4)) < OCTET_LENGTH(apellido1)
        AND (LENGTH(apellido1) - LENGTH(REPLACE(apellido1, '?', '')) = LENGTH(CONVERT(BINARY CONVERT(apellido1 USING latin1) USING utf8mb4)) - LENGTH(REPLACE(CONVERT(BINARY CONVERT(apellido1 USING latin1) USING utf8mb4), '?', ''))),
        CONVERT(BINARY CONVERT(apellido1 USING latin1) USING utf8mb4),
        apellido1
    ),
    apellido2 = IF(
        apellido2 IS NOT NULL
        AND HEX(apellido2) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
        AND CONVERT(BINARY CONVERT(apellido2 USING latin1) USING utf8mb4) IS NOT NULL
        AND OCTET_LENGTH(CONVERT(BINARY CONVERT(apellido2 USING latin1) USING utf8mb4)) < OCTET_LENGTH(apellido2)
        AND (LENGTH(apellido2) - LENGTH(REPLACE(apellido2, '?', '')) = LENGTH(CONVERT(BINARY CONVERT(apellido2 USING latin1) USING utf8mb4)) - LENGTH(REPLACE(CONVERT(BINARY CONVERT(apellido2 USING latin1) USING utf8mb4), '?', ''))),
        CONVERT(BINARY CONVERT(apellido2 USING latin1) USING utf8mb4),
        apellido2
    )
WHERE HEX(nombre) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
   OR HEX(apellido1) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
   OR (apellido2 IS NOT NULL AND HEX(apellido2) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280');

-- empleados (nombre, apellido1, apellido2)
UPDATE empleados
SET
    nombre = IF(
        HEX(nombre) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
        AND CONVERT(BINARY CONVERT(nombre USING latin1) USING utf8mb4) IS NOT NULL
        AND OCTET_LENGTH(CONVERT(BINARY CONVERT(nombre USING latin1) USING utf8mb4)) < OCTET_LENGTH(nombre)
        AND (LENGTH(nombre) - LENGTH(REPLACE(nombre, '?', '')) = LENGTH(CONVERT(BINARY CONVERT(nombre USING latin1) USING utf8mb4)) - LENGTH(REPLACE(CONVERT(BINARY CONVERT(nombre USING latin1) USING utf8mb4), '?', ''))),
        CONVERT(BINARY CONVERT(nombre USING latin1) USING utf8mb4),
        nombre
    ),
    apellido1 = IF(
        HEX(apellido1) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
        AND CONVERT(BINARY CONVERT(apellido1 USING latin1) USING utf8mb4) IS NOT NULL
        AND OCTET_LENGTH(CONVERT(BINARY CONVERT(apellido1 USING latin1) USING utf8mb4)) < OCTET_LENGTH(apellido1)
        AND (LENGTH(apellido1) - LENGTH(REPLACE(apellido1, '?', '')) = LENGTH(CONVERT(BINARY CONVERT(apellido1 USING latin1) USING utf8mb4)) - LENGTH(REPLACE(CONVERT(BINARY CONVERT(apellido1 USING latin1) USING utf8mb4), '?', ''))),
        CONVERT(BINARY CONVERT(apellido1 USING latin1) USING utf8mb4),
        apellido1
    ),
    apellido2 = IF(
        apellido2 IS NOT NULL
        AND HEX(apellido2) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
        AND CONVERT(BINARY CONVERT(apellido2 USING latin1) USING utf8mb4) IS NOT NULL
        AND OCTET_LENGTH(CONVERT(BINARY CONVERT(apellido2 USING latin1) USING utf8mb4)) < OCTET_LENGTH(apellido2)
        AND (LENGTH(apellido2) - LENGTH(REPLACE(apellido2, '?', '')) = LENGTH(CONVERT(BINARY CONVERT(apellido2 USING latin1) USING utf8mb4)) - LENGTH(REPLACE(CONVERT(BINARY CONVERT(apellido2 USING latin1) USING utf8mb4), '?', ''))),
        CONVERT(BINARY CONVERT(apellido2 USING latin1) USING utf8mb4),
        apellido2
    )
WHERE HEX(nombre) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
   OR HEX(apellido1) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
   OR (apellido2 IS NOT NULL AND HEX(apellido2) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280');

-- pedidos (pais, ciudad, calle)
UPDATE pedidos
SET
    pais = IF(
        HEX(pais) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
        AND CONVERT(BINARY CONVERT(pais USING latin1) USING utf8mb4) IS NOT NULL
        AND OCTET_LENGTH(CONVERT(BINARY CONVERT(pais USING latin1) USING utf8mb4)) < OCTET_LENGTH(pais)
        AND (LENGTH(pais) - LENGTH(REPLACE(pais, '?', '')) = LENGTH(CONVERT(BINARY CONVERT(pais USING latin1) USING utf8mb4)) - LENGTH(REPLACE(CONVERT(BINARY CONVERT(pais USING latin1) USING utf8mb4), '?', ''))),
        CONVERT(BINARY CONVERT(pais USING latin1) USING utf8mb4),
        pais
    ),
    ciudad = IF(
        HEX(ciudad) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
        AND CONVERT(BINARY CONVERT(ciudad USING latin1) USING utf8mb4) IS NOT NULL
        AND OCTET_LENGTH(CONVERT(BINARY CONVERT(ciudad USING latin1) USING utf8mb4)) < OCTET_LENGTH(ciudad)
        AND (LENGTH(ciudad) - LENGTH(REPLACE(ciudad, '?', '')) = LENGTH(CONVERT(BINARY CONVERT(ciudad USING latin1) USING utf8mb4)) - LENGTH(REPLACE(CONVERT(BINARY CONVERT(ciudad USING latin1) USING utf8mb4), '?', ''))),
        CONVERT(BINARY CONVERT(ciudad USING latin1) USING utf8mb4),
        ciudad
    ),
    calle = IF(
        HEX(calle) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
        AND CONVERT(BINARY CONVERT(calle USING latin1) USING utf8mb4) IS NOT NULL
        AND OCTET_LENGTH(CONVERT(BINARY CONVERT(calle USING latin1) USING utf8mb4)) < OCTET_LENGTH(calle)
        AND (LENGTH(calle) - LENGTH(REPLACE(calle, '?', '')) = LENGTH(CONVERT(BINARY CONVERT(calle USING latin1) USING utf8mb4)) - LENGTH(REPLACE(CONVERT(BINARY CONVERT(calle USING latin1) USING utf8mb4), '?', ''))),
        CONVERT(BINARY CONVERT(calle USING latin1) USING utf8mb4),
        calle
    )
WHERE HEX(pais) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
   OR HEX(ciudad) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280'
   OR HEX(calle) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280';

COMMIT;

-- 4. Post-repair verification: should return 0 rows
SELECT id_producto, marca, modelo, descripcion
FROM productos
WHERE descripcion IS NOT NULL
  AND HEX(descripcion) REGEXP 'C383C2|C382C2|C3A2E2809A|C3A2E282AC|C383E280';
