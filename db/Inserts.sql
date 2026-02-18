use shawarmas;
INSERT INTO tallas(talla) VALUES
	('36'),('37'),('38'),('39'),('40'),('41'),
    ('42'),('43'),('44'),('45'),('XS'),('S'),
    ('M'),('L'),('XL'),('XXL');
    
INSERT INTO colores(color) VALUES
	('Blanco'),('Negro'),('Grís'),('Azul'),('Rojo'),('Verde'),
    ('Amarillo'),('Naranja'),('Rosa'),('Morado'),('Marrón');
    
INSERT INTO categorias(categoria) VALUES
	('Zapatillas'),('Sudaderas'),('Camisetas'),('Pantalones'),('Accesorios'),('Abrigos');
  
insert into tiendas(pais, ciudad, calle, postal) values
 ('España','Madrid','Calle de Velarde, 10','28004'),
 ('España','Valencia','Carrer de Pérez Pujol, 5','46002'),
 ('España','Barcelona','Carrer de la Palla, 25','08002'),
 ('Portugal','Oporto','Rua dos Clérigos, 76','4050-205'),
 ('Portugal','Lisboa','Praça dos Restauradores, 50','1250-188');

insert into empleados(nombre,apellido1,apellido2,mail,passw,fk_tienda) values 
 ('Ivan', 'Kosolovskyy', 'Fetsyk','donnie@shawarmas.com','1234','1'),
 ('Javier', 'Jiménez', 'Simón','jaji@shawarmas.com','1234','1');
    
insert into clientes(nombre,apellido1,apellido2,mail,passw) values 
 ('Pedro', 'Castro', 'Grimaldo','pedro@gmail.com','1234'),
 ('Guillermo', 'Antonio', 'Pérez','galo@gmail.com','1234');
    
insert into pedidos(fecha_pedido, pais, ciudad, calle, postal, fk_id_user, fk_tienda) values
 (sysdate(), 'España', 'Madrid','Calle Alcala 18','28028','1','1');
 
-- Nike AirMax (colores: Negro, Blanco, Gris)
INSERT INTO productos (marca, modelo, precio, stock, fk_categoria, fk_talla, fk_color) VALUES

('Nike', 'AirMax', 99.99, 540, 1, 1, 2),
('Nike', 'AirMax', 99.99, 540, 1, 2, 2),
('Nike', 'AirMax', 99.99, 700, 1, 2, 3),
('Nike', 'AirMax', 99.99, 540, 1, 3, 2),
('Nike', 'AirMax', 99.99, 700, 1, 3, 3),
('Nike', 'AirMax', 99.99, 600, 1, 4, 1),
('Nike', 'AirMax', 99.99, 540, 1, 5, 2),
-- ('Nike', 'AirMax', 99.99, 600, 1, 5, 1),
('Nike', 'AirMax', 99.99, 700, 1, 5, 3),
('Nike', 'AirMax', 99.99, 540, 1, 6, 2),
('Nike', 'AirMax', 99.99, 600, 1, 6, 1),
('Nike', 'AirMax', 99.99, 700, 1, 6, 3),
('Nike', 'AirMax', 99.99, 580, 1, 7, 2),
('Nike', 'AirMax', 99.99, 630, 1, 7, 1),
('Nike', 'AirMax', 99.99, 750, 1, 7, 3),
('Nike', 'AirMax', 99.99, 690, 1, 8, 2),
('Nike', 'AirMax', 99.99, 640, 1, 8, 1),
('Nike', 'AirMax', 99.99, 720, 1, 8, 3),
('Nike', 'AirMax', 99.99, 710, 1, 9, 2),
('Nike', 'AirMax', 99.99, 660, 1, 9, 1),
('Nike', 'AirMax', 99.99, 730, 1, 9, 3),
('Nike', 'AirMax', 99.99, 740, 1, 10, 2),
('Nike', 'AirMax', 99.99, 620, 1, 10, 1),
('Nike', 'AirMax', 99.99, 710, 1, 10, 3),

-- Adidas Ultraboost (colores: Azul, Verde, Rojo)
('Adidas', 'Ultraboost', 129.99, 590, 1, 1, 4),
('Adidas', 'Ultraboost', 129.99, 620, 1, 1, 5),
('Adidas', 'Ultraboost', 129.99, 650, 1, 1, 6),
('Adidas', 'Ultraboost', 129.99, 600, 1, 2, 4),
('Adidas', 'Ultraboost', 129.99, 640, 1, 2, 5),
('Adidas', 'Ultraboost', 129.99, 670, 1, 2, 6),
('Adidas', 'Ultraboost', 129.99, 610, 1, 3, 4),
('Adidas', 'Ultraboost', 129.99, 660, 1, 3, 5),
('Adidas', 'Ultraboost', 129.99, 690, 1, 3, 6),
('Adidas', 'Ultraboost', 129.99, 610, 1, 4, 4),
('Adidas', 'Ultraboost', 129.99, 660, 1, 4, 5),
('Adidas', 'Ultraboost', 129.99, 690, 1, 4, 6),
('Adidas', 'Ultraboost', 129.99, 610, 1, 5, 4),
('Adidas', 'Ultraboost', 129.99, 660, 1, 5, 5),
('Adidas', 'Ultraboost', 129.99, 690, 1, 5, 6),
('Adidas', 'Ultraboost', 129.99, 500, 1, 6, 4),
('Adidas', 'Ultraboost', 129.99, 530, 1, 6, 5),
('Adidas', 'Ultraboost', 129.99, 560, 1, 6, 6),
('Adidas', 'Ultraboost', 129.99, 520, 1, 7, 4),
('Adidas', 'Ultraboost', 129.99, 540, 1, 7, 5),
('Adidas', 'Ultraboost', 129.99, 570, 1, 7, 6),
('Adidas', 'Ultraboost', 129.99, 530, 1, 8, 4),
('Adidas', 'Ultraboost', 129.99, 550, 1, 8, 5),
('Adidas', 'Ultraboost', 129.99, 590, 1, 8, 6),
('Adidas', 'Ultraboost', 129.99, 560, 1, 9, 4),
('Adidas', 'Ultraboost', 129.99, 580, 1, 9, 5),
('Adidas', 'Ultraboost', 129.99, 600, 1, 9, 6),
('Adidas', 'Ultraboost', 129.99, 570, 1, 10, 4),
('Adidas', 'Ultraboost', 129.99, 610, 1, 10, 5),
('Adidas', 'Ultraboost', 129.99, 630, 1, 10, 6),

-- Puma Classic (colores: Naranja, Amarillo, Rosa)
('Puma', 'Classic', 79.99, 720, 1, 1, 1),
('Puma', 'Classic', 79.99, 730, 1, 1, 2),
('Puma', 'Classic', 79.99, 720, 1, 2, 1),
('Puma', 'Classic', 79.99, 730, 1, 2, 2),
('Puma', 'Classic', 79.99, 720, 1, 3, 1),
('Puma', 'Classic', 79.99, 730, 1, 3, 2),
('Puma', 'Classic', 79.99, 690, 1, 4, 1),
('Puma', 'Classic', 79.99, 700, 1, 4, 2),
('Puma', 'Classic', 79.99, 660, 1, 5, 1),
('Puma', 'Classic', 79.99, 670, 1, 5, 2),
('Puma', 'Classic', 79.99, 510, 1, 6, 1),
('Puma', 'Classic', 79.99, 520, 1, 6, 2),
('Puma', 'Classic', 79.99, 540, 1, 7, 1),
('Puma', 'Classic', 79.99, 550, 1, 7, 2),
('Puma', 'Classic', 79.99, 570, 1, 8, 1),
('Puma', 'Classic', 79.99, 580, 1, 8, 2),
('Puma', 'Classic', 79.99, 600, 1, 9, 1),
('Puma', 'Classic', 79.99, 610, 1, 9, 2),
('Puma', 'Classic', 79.99, 630, 1, 10, 1),
('Puma', 'Classic', 79.99, 640, 1, 10, 2);

SET SQL_SAFE_UPDATES = 0;
UPDATE productos SET imagen = '/productos/airMax.png' WHERE modelo = 'AirMax';
UPDATE productos SET imagen = '/productos/pumaClassic.png' WHERE modelo = 'Classic';
UPDATE productos SET imagen = '/productos/ultraboost.png' WHERE modelo = 'Ultraboost';
SET SQL_SAFE_UPDATES = 1;

insert into productos_pedidos(fk_producto, fk_pedido, cantidad) values
 (1, 1, 3),
 (2, 1, 4),
 (3, 1, 1);
