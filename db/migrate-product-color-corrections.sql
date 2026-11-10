USE shawarmas;

START TRANSACTION;

INSERT IGNORE INTO colores (color, imagen) VALUES
    ('Beige', '/colors/beige.png'),
    ('Panda', '/colors/panda.png');

CREATE TEMPORARY TABLE producto_colores_deseados (
    id_producto INT UNSIGNED NOT NULL PRIMARY KEY,
    id_color INT UNSIGNED NOT NULL
) ENGINE = InnoDB;

INSERT INTO producto_colores_deseados (id_producto, id_color)
SELECT p.id_producto, c.id_color
FROM productos p
INNER JOIN colores c ON c.color = CASE
    WHEN p.marca = 'Adidas' AND p.modelo IN ('Samba OG', 'Campus', 'Superstar') THEN 'Panda'
    WHEN p.marca = 'Jordan' AND p.modelo = 'Air Jordan 4 Retro' THEN 'Panda'
    WHEN p.marca = 'New Era' AND p.modelo = 'MLB 9TWENTY' THEN 'Beige'
    WHEN p.marca = 'SWM' AND p.modelo = 'Essentials' THEN 'Beige'
END
WHERE (p.marca = 'Adidas' AND p.modelo IN ('Samba OG', 'Campus', 'Superstar'))
   OR (p.marca = 'Jordan' AND p.modelo = 'Air Jordan 4 Retro')
   OR (p.marca = 'New Era' AND p.modelo = 'MLB 9TWENTY')
   OR (p.marca = 'SWM' AND p.modelo = 'Essentials');

INSERT INTO producto_variantes (fk_producto, fk_talla, fk_color, imagen, stock)
SELECT d.id_producto, v.fk_talla, d.id_color, p.imagen, SUM(v.stock)
FROM producto_colores_deseados d
INNER JOIN productos p ON p.id_producto = d.id_producto
INNER JOIN producto_variantes v ON v.fk_producto = d.id_producto
GROUP BY d.id_producto, v.fk_talla, d.id_color, p.imagen
ON DUPLICATE KEY UPDATE
    imagen = VALUES(imagen),
    stock = VALUES(stock);

UPDATE producto_variantes v
INNER JOIN producto_colores_deseados d ON d.id_producto = v.fk_producto
INNER JOIN productos_pedidos pp ON pp.fk_variante = v.id_variante
SET v.stock = 0
WHERE v.fk_color <> d.id_color;

DELETE v
FROM producto_variantes v
INNER JOIN producto_colores_deseados d ON d.id_producto = v.fk_producto
WHERE v.fk_color <> d.id_color
  AND NOT EXISTS (
      SELECT 1
      FROM productos_pedidos pp
      WHERE pp.fk_variante = v.id_variante
  );

DROP TEMPORARY TABLE producto_colores_deseados;
COMMIT;
