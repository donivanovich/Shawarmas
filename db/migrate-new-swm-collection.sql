USE shawarmas;

START TRANSACTION;

INSERT IGNORE INTO colores (color, imagen) VALUES ('Rosa', '/colors/pink.png');

UPDATE colores
SET imagen = '/colors/pink.png'
WHERE color = 'Rosa';

INSERT INTO productos (marca, modelo, precio, imagen, fk_categoria, stock, fk_talla, fk_color)
SELECT 'SWM', nuevos.modelo, nuevos.precio, CONCAT('/products/', nuevos.imagen), cat.id_categoria, 12, t.id_talla, c.id_color
FROM (
    SELECT 'Aurora' modelo, 59.99 precio, 'swm-aurora-hoodie-black.png' imagen, 'Sudaderas' categoria
    UNION ALL SELECT 'Core', 49.99, 'swm-core-pants-black.png', 'Pantalones'
    UNION ALL SELECT 'Cosmos Nav', 24.99, 'swm-cosmos-nav-shirt-black.png', 'Camisetas'
    UNION ALL SELECT 'Metamorphosis', 59.99, 'swm-metamorphosis-hoodie-black.png', 'Sudaderas'
    UNION ALL SELECT 'Synapse', 59.99, 'swm-synapse-hoodie-black.png', 'Sudaderas'
    UNION ALL SELECT 'The Tank', 89.99, 'swm-the-tank-sneakers-black.png', 'Zapatillas'
    UNION ALL SELECT 'Urban Explorer', 24.99, 'swm-urban-explorer-shirt-black.png', 'Camisetas'
) nuevos
INNER JOIN categorias cat ON cat.categoria = nuevos.categoria
INNER JOIN tallas t ON t.talla = CASE WHEN cat.categoria = 'Zapatillas' THEN '40' ELSE 'M' END
INNER JOIN colores c ON c.color = 'Negro'
WHERE NOT EXISTS (
    SELECT 1
    FROM productos existing
    WHERE existing.marca = 'SWM' AND existing.modelo = nuevos.modelo
);

INSERT INTO producto_variantes (fk_producto, fk_talla, fk_color, imagen, stock)
SELECT p.id_producto, t.id_talla, c.id_color, CONCAT('/products/', variantes.imagen), 12
FROM (
    SELECT 'Aurora' modelo, 'Negro' color, 'swm-aurora-hoodie-black.png' imagen
    UNION ALL SELECT 'Aurora', 'Gris', 'swm-aurora-hoodie-gray.png'
    UNION ALL SELECT 'Aurora', 'Rosa', 'swm-aurora-hoodie-pink.png'
    UNION ALL SELECT 'Aurora', 'Blanco', 'swm-aurora-hoodie-white.png'
    UNION ALL SELECT 'Core', 'Negro', 'swm-core-pants-black.png'
    UNION ALL SELECT 'Core', 'Azul', 'swm-core-pants-blue.png'
    UNION ALL SELECT 'Cosmos Nav', 'Beige', 'swm-cosmos-nav-shirt-beige.png'
    UNION ALL SELECT 'Cosmos Nav', 'Negro', 'swm-cosmos-nav-shirt-black.png'
    UNION ALL SELECT 'Cosmos Nav', 'Azul', 'swm-cosmos-nav-shirt-blue.png'
    UNION ALL SELECT 'Cosmos Nav', 'Verde', 'swm-cosmos-nav-shirt-green.png'
    UNION ALL SELECT 'Cosmos Nav', 'Blanco', 'swm-cosmos-nav-shirt-white.png'
    UNION ALL SELECT 'Metamorphosis', 'Negro', 'swm-metamorphosis-hoodie-black.png'
    UNION ALL SELECT 'Metamorphosis', 'Azul', 'swm-metamorphosis-hoodie-blue.png'
    UNION ALL SELECT 'Synapse', 'Negro', 'swm-synapse-hoodie-black.png'
    UNION ALL SELECT 'Synapse', 'Blanco', 'swm-synapse-hoodie-white.png'
    UNION ALL SELECT 'The Tank', 'Negro', 'swm-the-tank-sneakers-black.png'
    UNION ALL SELECT 'The Tank', 'Panda', 'swm-the-tank-sneakers-panda.png'
    UNION ALL SELECT 'Urban Explorer', 'Negro', 'swm-urban-explorer-shirt-black.png'
    UNION ALL SELECT 'Urban Explorer', 'Blanco', 'swm-urban-explorer-shirt-white.png'
) variantes
INNER JOIN productos p ON p.marca = 'SWM' AND p.modelo = variantes.modelo
INNER JOIN categorias cat ON cat.id_categoria = p.fk_categoria
INNER JOIN tallas t ON (
    (cat.categoria = 'Zapatillas' AND t.talla IN ('38', '39', '40', '41', '42', '43'))
    OR (cat.categoria <> 'Zapatillas' AND t.talla IN ('S', 'M', 'L', 'XL'))
)
INNER JOIN colores c ON c.color = variantes.color
ON DUPLICATE KEY UPDATE imagen = VALUES(imagen);

COMMIT;
