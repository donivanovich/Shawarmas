USE shawarmas;

START TRANSACTION;

INSERT IGNORE INTO colores (color, imagen) VALUES ('Panda', '/colors/panda.png');

INSERT INTO producto_variantes (fk_producto, fk_talla, fk_color, imagen, stock)
SELECT p.id_producto, tallas_producto.fk_talla, c.id_color, CONCAT('/products/', panda.imagen), 12
FROM (
    SELECT 'Campus' modelo, 'adidas-campus-sneakers-panda.png' imagen
    UNION ALL SELECT 'Superstar', 'adidas-superstar-sneakers-panda.png'
) panda
INNER JOIN productos p ON p.marca = 'Adidas' AND p.modelo = panda.modelo
INNER JOIN colores c ON c.color = 'Panda'
INNER JOIN (
    SELECT DISTINCT fk_producto, fk_talla
    FROM producto_variantes
) tallas_producto ON tallas_producto.fk_producto = p.id_producto
ON DUPLICATE KEY UPDATE imagen = VALUES(imagen);

UPDATE producto_variantes v
INNER JOIN productos p ON p.id_producto = v.fk_producto
INNER JOIN colores c ON c.id_color = v.fk_color
SET v.imagen = CASE
    WHEN p.modelo = 'Samba OG' AND c.color = 'Blanco' THEN '/products/adidas-samba-og-sneakers-white.png'
    WHEN p.modelo = 'Campus' AND c.color = 'Negro' THEN '/products/adidas-campus-sneakers-black.png'
    WHEN p.modelo = 'Campus' AND c.color = 'Panda' THEN '/products/adidas-campus-sneakers-panda.png'
    WHEN p.modelo = 'Superstar' AND c.color = 'Blanco' THEN '/products/adidas-superstar-sneakers-white.png'
    WHEN p.modelo = 'Superstar' AND c.color = 'Panda' THEN '/products/adidas-superstar-sneakers-panda.png'
END
WHERE p.marca = 'Adidas'
  AND ((p.modelo = 'Samba OG' AND c.color = 'Blanco')
    OR (p.modelo = 'Campus' AND c.color IN ('Negro', 'Panda'))
    OR (p.modelo = 'Superstar' AND c.color IN ('Blanco', 'Panda')));

UPDATE producto_variantes v
INNER JOIN productos p ON p.id_producto = v.fk_producto
INNER JOIN colores c ON c.id_color = v.fk_color
INNER JOIN productos_pedidos pp ON pp.fk_variante = v.id_variante
SET v.stock = 0
WHERE p.marca = 'Adidas' AND p.modelo = 'Samba OG' AND c.color = 'Panda';

DELETE v
FROM producto_variantes v
INNER JOIN productos p ON p.id_producto = v.fk_producto
INNER JOIN colores c ON c.id_color = v.fk_color
WHERE p.marca = 'Adidas' AND p.modelo = 'Samba OG' AND c.color = 'Panda'
  AND NOT EXISTS (
      SELECT 1 FROM productos_pedidos pp WHERE pp.fk_variante = v.id_variante
  );

COMMIT;
