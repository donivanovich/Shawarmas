USE shawarmas;

START TRANSACTION;

INSERT IGNORE INTO colores (color, imagen) VALUES
    ('Blanco', '/colors/white.png'),
    ('Negro', '/colors/black.png'),
    ('Gris', '/colors/gray.png'),
    ('Azul', '/colors/blue.png'),
    ('Verde', '/colors/green.png'),
    ('Panda', '/colors/panda.png');

INSERT INTO producto_variantes (fk_producto, fk_talla, fk_color, imagen, stock)
SELECT p.id_producto, tallas_producto.fk_talla, c.id_color, CONCAT('/products/', nuevos.imagen), 12
FROM (
    SELECT 'Adidas' marca, 'Samba OG' modelo, 'Negro' color, 'adidas-samba-og-sneakers-black.png' imagen
    UNION ALL SELECT 'Adidas', 'Samba OG', 'Blanco', 'adidas-samba-og-sneakers-white.png'
    UNION ALL SELECT 'Adidas', 'Campus', 'Negro', 'adidas-campus-sneakers-black.png'
    UNION ALL SELECT 'Adidas', 'Campus', 'Gris', 'adidas-campus-sneakers-gray.png'
    UNION ALL SELECT 'Adidas', 'Campus', 'Verde', 'adidas-campus-sneakers-green.png'
    UNION ALL SELECT 'Adidas', 'Campus', 'Blanco', 'adidas-campus-sneakers-white.png'
    UNION ALL SELECT 'Adidas', 'Superstar', 'Negro', 'adidas-superstar-sneakers-black.png'
    UNION ALL SELECT 'Adidas', 'Superstar', 'Blanco', 'adidas-superstar-sneakers-white.png'
    UNION ALL SELECT 'Jordan', 'Air Jordan 1', 'Negro', 'jordan-air-jordan-1-sneakers-black.png'
    UNION ALL SELECT 'Jordan', 'Air Jordan 1', 'Azul', 'jordan-air-jordan-1-sneakers-blue.png'
    UNION ALL SELECT 'Jordan', 'Air Jordan 1', 'Panda', 'jordan-air-jordan-1-sneakers-panda.png'
    UNION ALL SELECT 'Nike', 'Air Force 1', 'Blanco', 'nike-air-force-1-sneakers-white.png'
) nuevos
INNER JOIN productos p ON p.marca = nuevos.marca AND p.modelo = nuevos.modelo
INNER JOIN colores c ON c.color = nuevos.color
INNER JOIN (
    SELECT DISTINCT fk_producto, fk_talla
    FROM producto_variantes
) tallas_producto ON tallas_producto.fk_producto = p.id_producto
ON DUPLICATE KEY UPDATE imagen = VALUES(imagen);

COMMIT;
