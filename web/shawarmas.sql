-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3306
-- Tiempo de generación: 12-06-2025 a las 18:19:48
-- Versión del servidor: 9.1.0
-- Versión de PHP: 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `shawarmas`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

DROP TABLE IF EXISTS `categorias`;
CREATE TABLE IF NOT EXISTS `categorias` (
  `id_categoria` int NOT NULL AUTO_INCREMENT,
  `categoria` varchar(50) NOT NULL,
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `categoria` (`categoria`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id_categoria`, `categoria`) VALUES
(1, 'Zapatillas'),
(2, 'Sudaderas'),
(3, 'Camisetas'),
(4, 'Pantalones'),
(5, 'Accesorios'),
(6, 'Abrigos');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

DROP TABLE IF EXISTS `clientes`;
CREATE TABLE IF NOT EXISTS `clientes` (
  `id_user` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `apellido1` varchar(100) NOT NULL,
  `apellido2` varchar(100) DEFAULT NULL,
  `mail` varchar(191) NOT NULL,
  `passw` varchar(191) NOT NULL,
  PRIMARY KEY (`id_user`),
  UNIQUE KEY `mail` (`mail`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`id_user`, `nombre`, `apellido1`, `apellido2`, `mail`, `passw`) VALUES
(3, 'Guillermo', 'Antonio', 'Pérez', 'galo@gmail.com', '1234'),
(5, 'Ignacio', 'Ramos', 'Gómez', 'nacho@gmail.com', '$2y$10$wRAyPMziwFaFp5Gb/b7vb.dOXZF2qTQGqVbvjc1el9Ea/dkzPRlYm'),
(6, 'Javier', 'Jiménez', 'Simón', 'jaji@gmail.com', '$2y$10$OVnKJ7ZYWpaKf4rmXaAF1O/1/m3JutJKlWEFNOIkJEDn25/owJTiW'),
(8, 'Ivan', 'Kosolovskyy', 'Fetsyk', 'donnie@gmail.com', '$2y$10$d0LZm99C644R4J4XE9XwkuyjkI7iSmmHVyepGtbWyPMqxJleI02Yy');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `colores`
--

DROP TABLE IF EXISTS `colores`;
CREATE TABLE IF NOT EXISTS `colores` (
  `id_color` int NOT NULL AUTO_INCREMENT,
  `color` varchar(50) NOT NULL,
  PRIMARY KEY (`id_color`),
  UNIQUE KEY `color` (`color`)
) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `colores`
--

INSERT INTO `colores` (`id_color`, `color`) VALUES
(1, 'Blanco'),
(2, 'Negro'),
(3, 'Grís'),
(4, 'Azul'),
(5, 'Rojo'),
(6, 'Verde'),
(7, 'Amarillo'),
(8, 'Naranja'),
(9, 'Rosa'),
(10, 'Morado'),
(11, 'Marrón');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleados`
--

DROP TABLE IF EXISTS `empleados`;
CREATE TABLE IF NOT EXISTS `empleados` (
  `id_empleado` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `apellido1` varchar(100) NOT NULL,
  `apellido2` varchar(100) DEFAULT NULL,
  `mail` varchar(191) NOT NULL,
  `passw` varchar(191) NOT NULL,
  `fk_tienda` int NOT NULL,
  PRIMARY KEY (`id_empleado`),
  UNIQUE KEY `mail` (`mail`),
  KEY `fk_tienda` (`fk_tienda`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `empleados`
--

INSERT INTO `empleados` (`id_empleado`, `nombre`, `apellido1`, `apellido2`, `mail`, `passw`, `fk_tienda`) VALUES
(1, 'Ivan', 'Kosolovskyy', 'Fetsyk', 'donnie@shawarmas.com', '1234', 1),
(2, 'Javier', 'Jiménez', 'Simón', 'jaji@shawarmas.com', '1234', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pedidos`
--

DROP TABLE IF EXISTS `pedidos`;
CREATE TABLE IF NOT EXISTS `pedidos` (
  `id_pedido` int NOT NULL AUTO_INCREMENT,
  `fecha_pedido` datetime NOT NULL,
  `fecha_entrega` datetime DEFAULT NULL,
  `pais` varchar(30) NOT NULL,
  `ciudad` varchar(50) NOT NULL,
  `calle` varchar(200) NOT NULL,
  `postal` varchar(15) NOT NULL,
  `fk_id_user` int NOT NULL,
  `fk_tienda` int NOT NULL,
  PRIMARY KEY (`id_pedido`),
  KEY `fk_id_user` (`fk_id_user`),
  KEY `fk_tienda` (`fk_tienda`)
) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `pedidos`
--

INSERT INTO `pedidos` (`id_pedido`, `fecha_pedido`, `fecha_entrega`, `pais`, `ciudad`, `calle`, `postal`, `fk_id_user`, `fk_tienda`) VALUES
(2, '2025-05-29 21:43:22', NULL, '', '', '', '', 0, 0),
(3, '2025-05-29 21:44:28', NULL, '', '', '', '', 0, 0),
(4, '2025-05-29 21:45:23', NULL, '', '', '', '', 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

DROP TABLE IF EXISTS `productos`;
CREATE TABLE IF NOT EXISTS `productos` (
  `id_producto` int NOT NULL AUTO_INCREMENT,
  `marca` varchar(50) NOT NULL,
  `modelo` varchar(50) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `stock` int NOT NULL,
  `imagen` varchar(255) DEFAULT NULL,
  `fk_categoria` int DEFAULT NULL,
  `fk_talla` int DEFAULT NULL,
  `fk_color` int DEFAULT NULL,
  PRIMARY KEY (`id_producto`),
  KEY `fk_categoria` (`fk_categoria`),
  KEY `fk_talla` (`fk_talla`),
  KEY `fk_color` (`fk_color`)
) ENGINE=MyISAM AUTO_INCREMENT=73 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`id_producto`, `marca`, `modelo`, `precio`, `stock`, `imagen`, `fk_categoria`, `fk_talla`, `fk_color`) VALUES
(1, 'Nike', 'Air Force One', 94.99, 540, 'assets/img/airForceN.png', 1, 6, 2),
(2, 'Nike', 'Jordan 4 Retro', 94.99, 250, 'assets/img/jordan 4 retro.png', 1, 6, 2),
(3, 'Nike', 'Jordan 1', 119.99, 170, 'assets/img/jordan1.jpg', 1, 6, 2),
(4, 'Adidas', 'Campus', 80.99, 250, 'assets/img/campus.png', 1, 6, 2),
(5, 'Adidas', 'Samba', 119.99, 250, 'assets/img/AdidasSamba.png', 1, 6, 2),
(6, 'Adidas', 'Superstar', 76.93, 250, 'assets/img/SuperStar.png', 1, 6, 2),
(7, 'Zara', 'Vaquero Baggy Negro', 43.75, 300, 'assets/img/Baggy Zara.png', 1, 6, 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos_pedidos`
--

DROP TABLE IF EXISTS `productos_pedidos`;
CREATE TABLE IF NOT EXISTS `productos_pedidos` (
  `id_producto_pedido` int NOT NULL AUTO_INCREMENT,
  `fk_producto` int NOT NULL,
  `fk_pedido` int NOT NULL,
  `cantidad` int NOT NULL,
  PRIMARY KEY (`id_producto_pedido`),
  KEY `fk_producto` (`fk_producto`),
  KEY `fk_pedido` (`fk_pedido`)
) ENGINE=MyISAM AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tallas`
--

DROP TABLE IF EXISTS `tallas`;
CREATE TABLE IF NOT EXISTS `tallas` (
  `id_talla` int NOT NULL AUTO_INCREMENT,
  `talla` varchar(50) NOT NULL,
  PRIMARY KEY (`id_talla`),
  UNIQUE KEY `talla` (`talla`)
) ENGINE=MyISAM AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `tallas`
--

INSERT INTO `tallas` (`id_talla`, `talla`) VALUES
(1, '36'),
(2, '37'),
(3, '38'),
(4, '39'),
(5, '40'),
(6, '41'),
(7, '42'),
(8, '43'),
(9, '44'),
(10, '45'),
(11, 'XS'),
(12, 'S'),
(13, 'M'),
(14, 'L'),
(15, 'XL'),
(16, 'XXL');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tiendas`
--

DROP TABLE IF EXISTS `tiendas`;
CREATE TABLE IF NOT EXISTS `tiendas` (
  `id_tienda` int NOT NULL AUTO_INCREMENT,
  `pais` enum('España','Portugal') NOT NULL,
  `ciudad` enum('Madrid','Barcelona','Valencia','Oporto','Lisboa') NOT NULL,
  `calle` varchar(200) NOT NULL,
  `postal` varchar(15) NOT NULL,
  PRIMARY KEY (`id_tienda`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `tiendas`
--

INSERT INTO `tiendas` (`id_tienda`, `pais`, `ciudad`, `calle`, `postal`) VALUES
(1, 'España', 'Madrid', 'Calle de Velarde, 10', '28004'),
(2, 'España', 'Valencia', 'Carrer de Pérez Pujol, 5', '46002'),
(3, 'España', 'Barcelona', 'Carrer de la Palla, 25', '08002'),
(4, 'Portugal', 'Oporto', 'Rua dos Clérigos, 76', '4050-205'),
(5, 'Portugal', 'Lisboa', 'Praça dos Restauradores, 50', '1250-188');
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
