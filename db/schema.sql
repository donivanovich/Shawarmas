CREATE DATABASE IF NOT EXISTS shawarmas
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE shawarmas;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS productos_pedidos;
DROP TABLE IF EXISTS producto_variantes;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS empleados;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS tiendas;
DROP TABLE IF EXISTS categorias;
DROP TABLE IF EXISTS tallas;
DROP TABLE IF EXISTS colores;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE colores (
    id_color INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    color VARCHAR(50) NOT NULL UNIQUE,
    imagen VARCHAR(255) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE tallas (
    id_talla INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    talla VARCHAR(20) NOT NULL UNIQUE
) ENGINE = InnoDB;

CREATE TABLE categorias (
    id_categoria INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    categoria VARCHAR(50) NOT NULL UNIQUE
) ENGINE = InnoDB;

CREATE TABLE tiendas (
    id_tienda INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pais VARCHAR(50) NOT NULL,
    ciudad VARCHAR(80) NOT NULL,
    calle VARCHAR(200) NOT NULL,
    postal VARCHAR(15) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE clientes (
    id_user INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido1 VARCHAR(100) NOT NULL,
    apellido2 VARCHAR(100) NULL,
    mail VARCHAR(255) NOT NULL UNIQUE,
    passw VARCHAR(255) NOT NULL,
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

CREATE TABLE empleados (
    id_empleado INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido1 VARCHAR(100) NOT NULL,
    apellido2 VARCHAR(100) NULL,
    mail VARCHAR(255) NOT NULL UNIQUE,
    passw VARCHAR(255) NOT NULL,
    fullscreen BOOLEAN NOT NULL DEFAULT FALSE,
    mute BOOLEAN NOT NULL DEFAULT FALSE,
    mode_use ENUM('writter', 'editor', 'admin') NOT NULL DEFAULT 'writter',
    volume TINYINT UNSIGNED NOT NULL DEFAULT 50,
    fk_tienda INT UNSIGNED NOT NULL,
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_empleados_tienda FOREIGN KEY (fk_tienda) REFERENCES tiendas(id_tienda)
) ENGINE = InnoDB;

CREATE TABLE productos (
    id_producto INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    imagen VARCHAR(255) NULL,
    descripcion TEXT NULL,
    fk_categoria INT UNSIGNED NOT NULL,
    CONSTRAINT chk_productos_precio CHECK (precio >= 0),
    CONSTRAINT fk_productos_categoria FOREIGN KEY (fk_categoria) REFERENCES categorias(id_categoria)
) ENGINE = InnoDB;

CREATE TABLE producto_variantes (
    id_variante INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fk_producto INT UNSIGNED NOT NULL,
    fk_talla INT UNSIGNED NOT NULL,
    fk_color INT UNSIGNED NOT NULL,
    imagen VARCHAR(255) NULL,
    stock INT UNSIGNED NOT NULL DEFAULT 0,
    UNIQUE KEY uq_producto_talla_color (fk_producto, fk_talla, fk_color),
    CONSTRAINT fk_variantes_producto FOREIGN KEY (fk_producto) REFERENCES productos(id_producto) ON DELETE CASCADE,
    CONSTRAINT fk_variantes_talla FOREIGN KEY (fk_talla) REFERENCES tallas(id_talla),
    CONSTRAINT fk_variantes_color FOREIGN KEY (fk_color) REFERENCES colores(id_color)
) ENGINE = InnoDB;

CREATE TABLE pedidos (
    id_pedido INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_entrega DATETIME NULL,
    entregado BOOLEAN NOT NULL DEFAULT FALSE,
    pais VARCHAR(50) NOT NULL,
    ciudad VARCHAR(80) NOT NULL,
    calle VARCHAR(200) NOT NULL,
    postal VARCHAR(15) NOT NULL,
    fk_id_user INT UNSIGNED NOT NULL,
    fk_tienda INT UNSIGNED NOT NULL,
    CONSTRAINT fk_pedidos_cliente FOREIGN KEY (fk_id_user) REFERENCES clientes(id_user),
    CONSTRAINT fk_pedidos_tienda FOREIGN KEY (fk_tienda) REFERENCES tiendas(id_tienda)
) ENGINE = InnoDB;

CREATE TABLE productos_pedidos (
    id_producto_pedido INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fk_variante INT UNSIGNED NOT NULL,
    fk_pedido INT UNSIGNED NOT NULL,
    cantidad INT UNSIGNED NOT NULL,
    UNIQUE KEY uq_variante_pedido (fk_variante, fk_pedido),
    CONSTRAINT chk_productos_pedidos_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_productos_pedidos_variante FOREIGN KEY (fk_variante) REFERENCES producto_variantes(id_variante),
    CONSTRAINT fk_productos_pedidos_pedido FOREIGN KEY (fk_pedido) REFERENCES pedidos(id_pedido) ON DELETE CASCADE
) ENGINE = InnoDB;

INSERT INTO colores (color, imagen) VALUES
    ('Blanco', '/colors/white.png'), ('Negro', '/colors/black.png'),
    ('Gris', '/colors/gray.png'), ('Azul', '/colors/blue.png'),
    ('Rojo', '/colors/red.png'), ('Verde', '/colors/green.png'),
    ('Amarillo', '/colors/yellow.png'), ('Naranja', '/colors/lawngreen.png'),
    ('Rosa', '/colors/pink.png'), ('Morado', '/colors/panda.png'),
    ('Marron', '/colors/brown.png'), ('Cian', '/colors/cyan.png'),
    ('Beige', '/colors/beige.png'), ('Panda', '/colors/panda.png');

INSERT INTO tallas (talla) VALUES
    ('36'), ('37'), ('38'), ('39'), ('40'), ('41'), ('42'), ('43'),
    ('44'), ('45'), ('XS'), ('S'), ('M'), ('L'), ('XL'), ('XXL'), ('Unica');

INSERT INTO categorias (categoria) VALUES
    ('Zapatillas'), ('Sudaderas'), ('Camisetas'), ('Pantalones'),
    ('Accesorios'), ('Abrigos');

INSERT INTO tiendas (pais, ciudad, calle, postal) VALUES
    ('España', 'Madrid', 'Calle de Velarde, 10', '28004'),
    ('España', 'Valencia', 'Carrer de Pérez Pujol, 5', '46002'),
    ('España', 'Barcelona', 'Carrer de la Palla, 25', '08002'),
    ('Portugal', 'Oporto', 'Rua dos Clérigos, 76', '4050-205'),
    ('Portugal', 'Lisboa', 'Praça dos Restauradores, 50', '1250-188');

INSERT INTO productos
    (marca, modelo, precio, imagen, fk_categoria)
VALUES
    ('Nike', 'Air Force 1', 119.99, '/products/nike-air-force-1-sneakers-black.png', 1),
    ('Adidas', 'Samba OG', 129.99, '/products/adidas-samba-og-sneakers-white.png', 1),
    ('Adidas', 'Campus', 99.99, '/products/adidas-campus-sneakers-black.png', 1),
    ('Jordan', 'Air Jordan 1', 149.99, '/products/jordan-air-jordan-1-sneakers-cyan.png', 1),
    ('Adidas', 'Superstar', 89.99, '/products/adidas-superstar-sneakers-white.png', 1),
    ('Jordan', 'Air Jordan 4 Retro', 169.99, '/products/jordan-air-jordan-4-retro-sneakers-panda.png', 1),
    ('Nike', 'Tech Fleece', 89.99, '/products/nike-tech-fleece-pants-black.png', 4),
    ('Puma', 'BMW M3 T7', 79.99, '/products/puma-bmw-m3-t7-pants-yellow.png', 4),
    ('Under Armour', 'UA Baseline Short', 29.99, '/products/under-armour-ua-baseline-short-pants-red.png', 4),
    ('Adidas', 'Essentials Big Logo', 24.99, '/products/adidas-essentials-big-logo-shirt-white.png', 3),
    ('Jordan', 'Sketch', 74.99, '/products/jordan-sketch-hoodie-black.png', 2),
    ('New Balance', 'Athletics 90s', 69.99, '/products/new-balance-athletics-90s-hoodie-black.png', 2),
    ('New Balance', 'Running', 34.99, '/products/new-balance-running-shirt-blue.png', 3),
    ('New Era', 'Los Angeles Dodgers', 29.99, '/products/new-era-los-angeles-dodgers-cap-black.png', 5),
    ('New Era', 'MLB 9TWENTY', 29.99, '/products/new-era-mlb-9twenty-cap-beige.png', 5),
    ('Nike', 'Swoosh Padded', 129.99, '/products/nike-swoosh-padded-coat-black.png', 6),
    ('Puma', 'Sport', 34.99, '/products/puma-sport-shirt-black.png', 3),
    ('The North Face', 'Retro Nuptse 1996', 249.99, '/products/the-north-face-retro-nuptse-1996-coat-brown.png', 6),
    ('UGG', 'Retrofor', 109.99, '/products/ugg-retrofor-hoodie-green.png', 2),
    ('Under Armour', 'Golf 96', 27.99, '/products/under-armour-golf-96-cap-black.png', 5),
    ('Vans', 'Originals Standards Varsity Loose Crew', 69.99, '/products/vans-originals-standards-varsity-loose-crew-hoodie-green.png', 2);

INSERT INTO productos (marca, modelo, precio, imagen, fk_categoria)
VALUES
    ('SWM', 'Essentials', 19.99, '/products/swm-essentials-cap-beige.png', 5),
    ('SWM', 'Essentials', 59.99, '/products/swm-essentials-hoodie-beige.png', 2),
    ('SWM', 'Essentials', 49.99, '/products/swm-essentials-pants-beige.png', 4),
    ('SWM', 'Essentials', 24.99, '/products/swm-essentials-shirt-beige.png', 3),
    ('SWM', 'Aurora', 59.99, '/products/swm-aurora-hoodie-black.png', 2),
    ('SWM', 'Core', 49.99, '/products/swm-core-pants-black.png', 4),
    ('SWM', 'Cosmos Nav', 24.99, '/products/swm-cosmos-nav-shirt-black.png', 3),
    ('SWM', 'Metamorphosis', 59.99, '/products/swm-metamorphosis-hoodie-black.png', 2),
    ('SWM', 'Synapse', 59.99, '/products/swm-synapse-hoodie-black.png', 2),
    ('SWM', 'The Tank', 89.99, '/products/swm-the-tank-sneakers-black.png', 1),
    ('SWM', 'Urban Explorer', 24.99, '/products/swm-urban-explorer-shirt-black.png', 3),
    ('SWM', 'Frostline', 129.99, '/products/swm-frostline-coat-black.png', 6),
    ('SWM', 'Night Division', 139.99, '/products/swm-night-division-coat-black.png', 6),
    ('SWM', 'Osaka Street', 54.99, '/products/swm-osaka-street-pants-black.png', 4),
    ('SWM', 'Osaka Street', 54.99, '/products/swm-osaka-street-pants-blue.png', 4),
    ('SWM', 'Osaka Street', 54.99, '/products/swm-osaka-street-pants-gray.png', 4),
    ('SWM', 'Sakura Spirit', 64.99, '/products/swm-sakura-spirit-hoodie-beige.png', 2),
    ('SWM', 'Sakura Spirit', 64.99, '/products/swm-sakura-spirit-hoodie-red.png', 2),
    ('SWM', 'Urban Retro', 89.99, '/products/swm-urban-retro-sneakers-beige.png', 1),
    ('SWM', 'Urban Retro', 89.99, '/products/swm-urban-retro-sneakers-black.png', 1);

INSERT INTO producto_variantes (fk_producto, fk_talla, fk_color, stock)
SELECT p.id_producto, t.id_talla, c.id_color, 12
FROM productos p
INNER JOIN tallas t
INNER JOIN colores c
WHERE p.marca = 'SWM'
  AND (
      (p.imagen LIKE '%-cap-%' AND t.talla = 'Unica')
      OR (p.imagen LIKE '%-sneakers-%' AND t.talla IN ('38', '39', '40', '41', '42', '43'))
      OR (p.imagen NOT LIKE '%-cap-%' AND p.imagen NOT LIKE '%-sneakers-%' AND t.talla IN ('S', 'M', 'L', 'XL'))
  )
  AND c.color = CASE
      WHEN p.imagen LIKE '%-beige.%' THEN 'Beige'
      WHEN p.imagen LIKE '%-blue.%' THEN 'Azul'
      WHEN p.imagen LIKE '%-gray.%' THEN 'Gris'
      WHEN p.imagen LIKE '%-red.%' THEN 'Rojo'
      ELSE 'Negro'
  END;

INSERT INTO producto_variantes (fk_producto, fk_talla, fk_color, stock) VALUES
    (1, 3, 2, 24), (1, 4, 2, 30), (1, 5, 2, 35), (1, 6, 2, 40), (1, 7, 2, 28), (1, 8, 2, 16), (1, 9, 2, 8),
    (3, 3, 14, 5), (3, 4, 14, 8), (3, 5, 14, 10), (3, 6, 14, 12), (3, 7, 14, 9),
    (4, 4, 12, 6), (4, 5, 12, 10), (4, 6, 12, 12), (4, 7, 12, 9), (4, 8, 12, 4), (4, 9, 12, 3), (4, 10, 12, 2),
    (7, 11, 2, 12), (7, 12, 2, 16), (7, 13, 2, 20), (7, 14, 2, 18), (7, 15, 2, 14), (7, 16, 2, 8),
    (8, 11, 7, 10), (8, 12, 7, 14), (8, 13, 7, 18), (8, 14, 7, 16), (8, 15, 7, 12), (8, 16, 7, 7),
    (9, 11, 5, 14), (9, 12, 5, 18), (9, 13, 5, 22), (9, 14, 5, 20), (9, 15, 5, 16), (9, 16, 5, 10),
    (10, 11, 1, 18), (10, 12, 1, 24), (10, 13, 1, 28), (10, 14, 1, 22), (10, 15, 1, 16), (10, 16, 1, 10),
    (11, 11, 2, 8), (11, 12, 2, 12), (11, 13, 2, 16), (11, 14, 2, 14), (11, 15, 2, 10), (11, 16, 2, 6),
    (12, 11, 2, 8), (12, 12, 2, 12), (12, 13, 2, 16), (12, 14, 2, 14), (12, 15, 2, 10), (12, 16, 2, 6),
    (13, 11, 4, 14), (13, 12, 4, 18), (13, 13, 4, 20), (13, 14, 4, 16), (13, 15, 4, 12), (13, 16, 4, 8),
    (14, 11, 2, 12), (14, 12, 2, 16), (14, 13, 2, 18), (14, 14, 2, 14), (14, 15, 2, 10), (14, 16, 2, 6),
    (15, 11, 13, 10), (15, 12, 13, 14), (15, 13, 13, 18), (15, 14, 13, 16), (15, 15, 13, 12), (15, 16, 13, 8),
    (16, 11, 2, 8), (16, 12, 2, 12), (16, 13, 2, 16), (16, 14, 2, 14), (16, 15, 2, 10), (16, 16, 2, 6),
    (17, 11, 2, 6), (17, 12, 2, 10), (17, 13, 2, 12), (17, 14, 2, 10), (17, 15, 2, 8), (17, 16, 2, 5),
    (18, 11, 11, 8), (18, 12, 11, 12), (18, 13, 11, 16), (18, 14, 11, 14), (18, 15, 11, 10), (18, 16, 11, 6),
    (19, 11, 6, 10), (19, 12, 6, 14), (19, 13, 6, 18), (19, 14, 6, 16), (19, 15, 6, 12), (19, 16, 6, 8),
    (20, 12, 2, 6), (20, 13, 2, 10), (20, 14, 2, 12), (20, 15, 2, 8),
    (21, 11, 6, 8), (21, 12, 6, 12), (21, 13, 6, 16), (21, 14, 6, 14), (21, 15, 6, 10), (21, 16, 6, 6),
    (2, 4, 1, 18), (2, 5, 1, 26), (2, 6, 1, 34), (2, 7, 1, 30), (2, 8, 1, 18), (2, 9, 1, 10), (2, 10, 1, 6),
    (5, 4, 14, 9), (5, 5, 14, 13), (5, 6, 14, 15), (5, 7, 14, 10), (5, 8, 14, 5),
    (6, 5, 14, 4), (6, 6, 14, 8), (6, 7, 14, 11), (6, 8, 14, 7), (6, 9, 14, 3);

INSERT INTO producto_variantes (fk_producto, fk_talla, fk_color, stock, imagen)
SELECT p.id_producto, t.id_talla, c.id_color, 12, CASE
    WHEN p.modelo IN ('Samba OG', 'Superstar') AND c.color = 'Blanco' THEN p.imagen
    WHEN p.modelo = 'Air Jordan 4 Retro' AND c.color = 'Panda' THEN p.imagen
    ELSE c.imagen
END
FROM productos p
INNER JOIN tallas t
INNER JOIN colores c
WHERE (
    (p.modelo = 'Superstar' AND c.color = 'Panda' AND t.talla IN ('39', '40', '41', '42', '43'))
    OR (p.modelo = 'Air Jordan 4 Retro' AND c.color = 'Panda' AND t.talla IN ('40', '41', '42', '43', '44'))
);

UPDATE producto_variantes v
INNER JOIN productos p ON p.id_producto = v.fk_producto
INNER JOIN colores c ON c.id_color = v.fk_color
SET v.imagen = p.imagen
WHERE p.modelo IN ('Samba OG', 'Superstar', 'Air Jordan 4 Retro');

INSERT INTO producto_variantes (fk_producto, fk_talla, fk_color, imagen, stock)
SELECT p.id_producto, tallas_producto.fk_talla, c.id_color, CONCAT('/products/', nuevos.imagen), 12
FROM (
    SELECT 'Adidas' marca, 'Samba OG' modelo, 'Negro' color, 'adidas-samba-og-sneakers-black.png' imagen
    UNION ALL SELECT 'Adidas', 'Samba OG', 'Blanco', 'adidas-samba-og-sneakers-white.png'
    UNION ALL SELECT 'Adidas', 'Campus', 'Negro', 'adidas-campus-sneakers-black.png'
    UNION ALL SELECT 'Adidas', 'Campus', 'Gris', 'adidas-campus-sneakers-gray.png'
    UNION ALL SELECT 'Adidas', 'Campus', 'Verde', 'adidas-campus-sneakers-green.png'
    UNION ALL SELECT 'Adidas', 'Campus', 'Blanco', 'adidas-campus-sneakers-white.png'
    UNION ALL SELECT 'Adidas', 'Campus', 'Panda', 'adidas-campus-sneakers-panda.png'
    UNION ALL SELECT 'Adidas', 'Superstar', 'Negro', 'adidas-superstar-sneakers-black.png'
    UNION ALL SELECT 'Adidas', 'Superstar', 'Blanco', 'adidas-superstar-sneakers-white.png'
    UNION ALL SELECT 'Adidas', 'Superstar', 'Panda', 'adidas-superstar-sneakers-panda.png'
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
WHERE (p.modelo = 'Samba OG' AND c.color = 'Blanco')
   OR (p.modelo = 'Campus' AND c.color IN ('Negro', 'Panda'))
   OR (p.modelo = 'Superstar' AND c.color IN ('Blanco', 'Panda'));

UPDATE productos p
INNER JOIN categorias cat ON cat.id_categoria = p.fk_categoria
SET p.descripcion = CASE
    WHEN p.marca = 'Nike' AND p.modelo = 'Air Force 1' THEN 'Un icono de perfil limpio y versátil. Su diseño combina con looks urbanos de diario.'
    WHEN p.marca = 'Adidas' AND p.modelo = 'Samba OG' THEN 'Una silueta clásica de inspiración futbolística, con perfil bajo y líneas atemporales para el día a día.'
    WHEN p.marca = 'Adidas' AND p.modelo = 'Campus' THEN 'Inspiradas en el estilo retro de las pistas, estas zapatillas aportan una silueta sencilla y fácil de combinar.'
    WHEN p.marca = 'Jordan' AND p.modelo = 'Air Jordan 1' THEN 'Una silueta de baloncesto de caña alta con presencia y carácter urbano. Un clásico para completar cualquier conjunto.'
    WHEN p.marca = 'Adidas' AND p.modelo = 'Superstar' THEN 'Reconocibles por su puntera de goma y sus líneas icónicas, son un básico urbano que nunca pasa de moda.'
    WHEN p.marca = 'Jordan' AND p.modelo = 'Air Jordan 4 Retro' THEN 'Una silueta de baloncesto con diseño estructurado y detalles marcados, pensada para destacar dentro y fuera de la cancha.'
    WHEN p.marca = 'Nike' AND p.modelo = 'Tech Fleece' THEN 'Pantalón de inspiración deportiva con una silueta cómoda y actual, ideal para moverte con libertad durante el día.'
    WHEN p.marca = 'Puma' AND p.modelo = 'BMW M3 T7' THEN 'Una mezcla de estilo deportivo y referencias al automovilismo, con una silueta cómoda para tus planes cotidianos.'
    WHEN p.marca = 'Under Armour' AND p.modelo = 'UA Baseline Short' THEN 'Un pantalón corto de aire deportivo y corte ligero, pensado para acompañarte en el entrenamiento y en tu tiempo libre.'
    WHEN p.marca = 'Adidas' AND p.modelo = 'Essentials Big Logo' THEN 'Una camiseta de líneas sencillas con el logotipo como protagonista. Un básico cómodo para combinar a diario.'
    WHEN p.marca = 'Jordan' AND p.modelo = 'Sketch' THEN 'Una sudadera de estilo relajado con el carácter gráfico de Jordan. Ideal para sumar una capa cómoda a tu look.'
    WHEN p.marca = 'New Balance' AND p.modelo = 'Athletics 90s' THEN 'Una sudadera de inspiración noventera con una silueta casual que funciona dentro y fuera de la rutina deportiva.'
    WHEN p.marca = 'New Balance' AND p.modelo = 'Running' THEN 'Una camiseta de estética deportiva y diseño versátil, lista para acompañar tus entrenamientos o tus días activos.'
    WHEN p.marca = 'New Era' AND p.modelo = 'Los Angeles Dodgers' THEN 'Una gorra de estilo clásico para mostrar tu afición por Los Angeles Dodgers y completar tus conjuntos urbanos.'
    WHEN p.marca = 'New Era' AND p.modelo = 'MLB 9TWENTY' THEN 'La silueta relajada de la 9TWENTY aporta un toque deportivo y fácil de llevar a cualquier look.'
    WHEN p.marca = 'Nike' AND p.modelo = 'Swoosh Padded' THEN 'Un abrigo acolchado de líneas deportivas que añade una capa cálida y funcional para los días fríos.'
    WHEN p.marca = 'Puma' AND p.modelo = 'Sport' THEN 'Una camiseta de inspiración deportiva con un diseño sencillo para entrenar o vestir con comodidad.'
    WHEN p.marca = 'The North Face' AND p.modelo = 'Retro Nuptse 1996' THEN 'Una chaqueta de volumen característico y espíritu outdoor, reinterpretada con una estética urbana reconocible.'
    WHEN p.marca = 'UGG' AND p.modelo = 'Retrofor' THEN 'Una sudadera de aspecto relajado que suma comodidad y una silueta desenfadada a tus capas de diario.'
    WHEN p.marca = 'Under Armour' AND p.modelo = 'Golf 96' THEN 'Una gorra deportiva de perfil clásico para completar tus conjuntos de golf y tus looks casuales.'
    WHEN p.marca = 'Vans' AND p.modelo = 'Originals Standards Varsity Loose Crew' THEN 'Una sudadera de corte amplio con aire universitario y espíritu skate, pensada para llevar con comodidad.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Aurora' THEN 'Una sudadera de líneas actuales y estilo relajado, creada para aportar comodidad y personalidad a tus looks diarios.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Core' THEN 'Un pantalón versátil de silueta cómoda y estética urbana, fácil de combinar durante toda la semana.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Cosmos Nav' THEN 'Una camiseta de diseño contemporáneo y carácter urbano, pensada para dar un punto distintivo a tus conjuntos.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Metamorphosis' THEN 'Una sudadera de estilo urbano con una presencia gráfica marcada y una silueta cómoda para el día a día.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Synapse' THEN 'Una sudadera de diseño limpio y espíritu contemporáneo, ideal para crear capas cómodas con un toque urbano.'
    WHEN p.marca = 'SWM' AND p.modelo = 'The Tank' THEN 'Una zapatilla de inspiración deportiva con una silueta contundente que aporta carácter a tus looks urbanos.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Urban Explorer' THEN 'Una camiseta casual de estética urbana y diseño versátil, preparada para acompañarte en tus planes diarios.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Essentials' AND cat.categoria = 'Accesorios' THEN 'Una gorra esencial de diseño sencillo que completa tus conjuntos diarios con un toque relajado.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Essentials' AND cat.categoria = 'Sudaderas' THEN 'Una sudadera cómoda de líneas esenciales, pensada para combinar fácilmente con tus prendas favoritas.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Essentials' AND cat.categoria = 'Pantalones' THEN 'Un pantalón de estilo básico y silueta cómoda, ideal para crear conjuntos casuales sin complicaciones.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Essentials' AND cat.categoria = 'Camisetas' THEN 'Una camiseta básica y versátil que funciona como punto de partida para cualquier look cotidiano.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Frostline' THEN 'Un abrigo de estética funcional y líneas limpias, preparado para sumar una capa cómoda en los días fríos.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Night Division' THEN 'Un abrigo de inspiración urbana con una silueta sobria y contundente para los días de frío.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Osaka Street' THEN 'Un pantalón de estilo streetwear con una silueta relajada que aporta comodidad y carácter a tus conjuntos.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Sakura Spirit' THEN 'Una sudadera de estilo casual con un aire distintivo, pensada para acompañar tus looks urbanos.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Urban Retro' THEN 'Una zapatilla de inspiración retro con una silueta urbana fácil de llevar en tus planes diarios.'
    ELSE p.descripcion
END;
