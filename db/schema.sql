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
    color VARCHAR(50) NOT NULL UNIQUE
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
    fk_categoria INT UNSIGNED NOT NULL,
    CONSTRAINT chk_productos_precio CHECK (precio >= 0),
    CONSTRAINT fk_productos_categoria FOREIGN KEY (fk_categoria) REFERENCES categorias(id_categoria)
) ENGINE = InnoDB;

CREATE TABLE producto_variantes (
    id_variante INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fk_producto INT UNSIGNED NOT NULL,
    fk_talla INT UNSIGNED NOT NULL,
    fk_color INT UNSIGNED NOT NULL,
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

INSERT INTO colores (color) VALUES
    ('Blanco'), ('Negro'), ('Gris'), ('Azul'), ('Rojo'), ('Verde'),
    ('Amarillo'), ('Naranja'), ('Rosa'), ('Morado'), ('Marron'), ('Cian');

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
    ('Nike', 'Air Force 1', 119.99, 'assets/img/air-force.png', 1),
    ('Adidas', 'Samba OG', 129.99, 'assets/img/adidas-samba.png', 1),
    ('Adidas', 'Campus', 99.99, 'assets/img/campus.png', 1),
    ('Jordan', 'Air Jordan 1', 149.99, 'assets/img/jordan-1.jpg', 1),
    ('Adidas', 'Superstar', 89.99, 'assets/img/superstar.png', 1),
    ('Jordan', 'Air Jordan 4 Retro', 169.99, 'assets/img/jordan-4-retro.png', 1),
    ('Nike', 'Tech Fleece', 89.99, 'assets/img/nike-tech-fleece.png', 4),
    ('Puma', 'BMW M3 T7', 79.99, 'assets/img/puma-bmw-m3-t7.png', 4),
    ('Under Armour', 'UA Baseline Short', 29.99, 'assets/img/under-armour-ua-baseline-short.png', 4),
    ('Adidas', 'Essentials Big Logo', 24.99, 'assets/img/adidas-essentials-big-logo.png', 3),
    ('Jordan', 'Sketch', 74.99, 'assets/img/jordan-sketch.png', 2),
    ('New Balance', 'Athletics 90s', 69.99, 'assets/img/new-balance-athletics-90s.png', 2),
    ('New Balance', 'Running', 34.99, 'assets/img/new-balance-running.png', 3),
    ('New Era', 'Los Angeles Dodgers', 29.99, 'assets/img/new-era-los-angeles-dodgers.png', 5),
    ('New Era', 'MLB 9TWENTY', 29.99, 'assets/img/new-era-mlb-9twenty.png', 5),
    ('Nike', 'Swoosh Padded', 129.99, 'assets/img/nike-swoosh-padded.png', 6),
    ('Puma', 'Sport', 34.99, 'assets/img/puma-sport.png', 3),
    ('The North Face', 'Retro Nuptse 1996', 249.99, 'assets/img/the-north-face-retro-nuptse-1996.png', 6),
    ('UGG', 'Retrofor', 109.99, 'assets/img/ugg-retrofor.png', 2),
    ('Under Armour', 'Golf 96', 27.99, 'assets/img/under-armour-golf-96.png', 5),
    ('Vans', 'Originals Standards Varsity Loose Crew', 69.99, 'assets/img/vans-originals-standards-varsity-loose-crew.png', 2);

INSERT INTO producto_variantes (fk_producto, fk_talla, fk_color, stock) VALUES
    (1, 3, 2, 24), (1, 4, 2, 30), (1, 5, 2, 35), (1, 6, 2, 40), (1, 7, 2, 28), (1, 8, 2, 16), (1, 9, 2, 8),
    (2, 4, 1, 18), (2, 5, 1, 26), (2, 6, 1, 34), (2, 7, 1, 30), (2, 8, 1, 18), (2, 9, 1, 10), (2, 10, 1, 6),
    (3, 3, 2, 8), (3, 4, 2, 14), (3, 5, 2, 18), (3, 6, 2, 20), (3, 7, 2, 12), (3, 3, 1, 5), (3, 4, 1, 8), (3, 5, 1, 10),
    (4, 4, 12, 6), (4, 5, 12, 10), (4, 6, 12, 12), (4, 7, 12, 9), (4, 8, 12, 4), (4, 9, 12, 3), (4, 10, 12, 2),
    (5, 4, 1, 9), (5, 5, 1, 13), (5, 6, 1, 15), (5, 7, 1, 10), (5, 8, 1, 5),
    (6, 5, 2, 4), (6, 6, 2, 8), (6, 7, 2, 11), (6, 8, 2, 7), (6, 9, 2, 3),
    (7, 11, 2, 12), (7, 12, 2, 16), (7, 13, 2, 20), (7, 14, 2, 18), (7, 15, 2, 14), (7, 16, 2, 8),
    (8, 11, 7, 10), (8, 12, 7, 14), (8, 13, 7, 18), (8, 14, 7, 16), (8, 15, 7, 12), (8, 16, 7, 7),
    (9, 11, 5, 14), (9, 12, 5, 18), (9, 13, 5, 22), (9, 14, 5, 20), (9, 15, 5, 16), (9, 16, 5, 10),
    (10, 11, 1, 18), (10, 12, 1, 24), (10, 13, 1, 28), (10, 14, 1, 22), (10, 15, 1, 16), (10, 16, 1, 10),
    (11, 11, 2, 8), (11, 12, 2, 12), (11, 13, 2, 16), (11, 14, 2, 14), (11, 15, 2, 10), (11, 16, 2, 6),
    (12, 11, 2, 8), (12, 12, 2, 12), (12, 13, 2, 16), (12, 14, 2, 14), (12, 15, 2, 10), (12, 16, 2, 6),
    (13, 11, 4, 14), (13, 12, 4, 18), (13, 13, 4, 20), (13, 14, 4, 16), (13, 15, 4, 12), (13, 16, 4, 8),
    (14, 11, 2, 12), (14, 12, 2, 16), (14, 13, 2, 18), (14, 14, 2, 14), (14, 15, 2, 10), (14, 16, 2, 6),
    (15, 11, 2, 10), (15, 12, 2, 14), (15, 13, 2, 18), (15, 14, 2, 16), (15, 15, 2, 12), (15, 16, 2, 8),
    (16, 11, 2, 8), (16, 12, 2, 12), (16, 13, 2, 16), (16, 14, 2, 14), (16, 15, 2, 10), (16, 16, 2, 6),
    (17, 11, 2, 6), (17, 12, 2, 10), (17, 13, 2, 12), (17, 14, 2, 10), (17, 15, 2, 8), (17, 16, 2, 5),
    (18, 11, 11, 8), (18, 12, 11, 12), (18, 13, 11, 16), (18, 14, 11, 14), (18, 15, 11, 10), (18, 16, 11, 6),
    (19, 11, 6, 10), (19, 12, 6, 14), (19, 13, 6, 18), (19, 14, 6, 16), (19, 15, 6, 12), (19, 16, 6, 8),
    (20, 12, 2, 6), (20, 13, 2, 10), (20, 14, 2, 12), (20, 15, 2, 8),
    (21, 11, 6, 8), (21, 12, 6, 12), (21, 13, 6, 16), (21, 14, 6, 14), (21, 15, 6, 10), (21, 16, 6, 6);
