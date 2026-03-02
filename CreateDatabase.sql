create database if not exists shawarmas;

-- drop database if exists shawarmas;

use shawarmas;

create table colores(id_color int primary key auto_increment,
						color varchar(50) not null unique
                        );
                        
create table tallas(id_talla int primary key auto_increment,
						talla varchar(50) not null unique
                        );
                        
create table categorias(id_categoria int primary key auto_increment,
						categoria varchar(50) not null unique
                        );

create table clientes(id_user int primary key auto_increment,
							nombre varchar(50) not null,
                            apellido1 varchar(100) not null,
                            apellido2 varchar(100),
                            mail varchar(255) not null unique,
                            passw varchar(1024) not null
						   );
                           
create table tiendas(id_tienda int primary key auto_increment,
							pais enum('España', 'Portugal') not null, 
                            ciudad enum('Madrid','Barcelona','Valencia','Oporto','Lisboa') not null,
                            calle varchar(200) not null,
                            postal varchar(15) not null
						   );
                       
create table productos(id_producto int primary key auto_increment,
							marca varchar(50) not null,
                            modelo varchar(50) not null,
                            precio decimal(10,2) not null,
                            stock int not null,
                            imagen varchar(255),
                            fk_categoria int, 
                            fk_talla int, 
                            fk_color int,
						foreign key (fk_categoria) references categorias(id_categoria),
                        foreign key (fk_talla) references tallas(id_talla),
                        foreign key (fk_color) references colores(id_color)
						   );
                           
create table pedidos(id_pedido int primary key auto_increment,
							fecha_pedido datetime not null,
                            fecha_entrega datetime,
                            pais varchar(30) not null,
                            ciudad varchar(50) not null,
                            calle varchar(200) not null,
                            postal varchar(15) not null,
                            fk_id_user int not null,
                            fk_tienda int not null,
						foreign key (fk_id_user) references clientes(id_user),
						foreign key (fk_tienda) references tiendas(id_tienda)
						   );

create table empleados(id_empleado int primary key auto_increment,
							nombre varchar(50) not null,
                            apellido1 varchar(100) not null,
                            apellido2 varchar(100),
                            mail varchar(255) not null unique,
                            passw varchar(1024) not null,
                            fk_tienda int not null,
						foreign key (fk_tienda) references tiendas(id_tienda)
						   );

create table productos_pedidos(id_producto_pedido int primary key auto_increment,
									fk_producto int not null,
                                    fk_pedido int not null,
                                    cantidad int not null,
								foreign key (fk_producto) references productos(id_producto),
								foreign key (fk_pedido) references pedidos(id_pedido)
								);
                                
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
INSERT INTO productos (marca, modelo, precio, stock, fk_categoria, fk_talla, fk_color, imagen) VALUES
('Nike', 'AirMax', 99.99, 540, 1, 1, 2, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 540, 1, 2, 2, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 700, 1, 2, 3, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 540, 1, 3, 2, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 700, 1, 3, 3, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 600, 1, 4, 1, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 540, 1, 5, 2, '/productos/airMax.png'),
-- ('Nike', 'AirMax', 99.99, 600, 1, 5, 1, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 700, 1, 5, 3, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 540, 1, 6, 2, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 600, 1, 6, 1, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 700, 1, 6, 3, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 580, 1, 7, 2, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 630, 1, 7, 1, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 750, 1, 7, 3, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 690, 1, 8, 2, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 640, 1, 8, 1, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 720, 1, 8, 3, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 710, 1, 9, 2, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 660, 1, 9, 1, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 730, 1, 9, 3, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 740, 1, 10, 2, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 620, 1, 10, 1, '/productos/airMax.png'),
('Nike', 'AirMax', 99.99, 710, 1, 10, 3, '/productos/airMax.png'),

-- Adidas Ultraboost (colores: Azul, Verde, Rojo)
('Adidas', 'Ultraboost', 129.99, 590, 1, 1, 4, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 620, 1, 1, 5, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 650, 1, 1, 6, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 600, 1, 2, 4, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 640, 1, 2, 5, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 670, 1, 2, 6, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 610, 1, 3, 4, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 660, 1, 3, 5, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 690, 1, 3, 6, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 610, 1, 4, 4, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 660, 1, 4, 5, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 690, 1, 4, 6, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 610, 1, 5, 4, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 660, 1, 5, 5, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 690, 1, 5, 6, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 500, 1, 6, 4, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 530, 1, 6, 5, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 560, 1, 6, 6, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 520, 1, 7, 4, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 540, 1, 7, 5, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 570, 1, 7, 6, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 530, 1, 8, 4, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 550, 1, 8, 5, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 590, 1, 8, 6, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 560, 1, 9, 4, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 580, 1, 9, 5, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 600, 1, 9, 6, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 570, 1, 10, 4, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 610, 1, 10, 5, '/productos/ultraboost.png'),
('Adidas', 'Ultraboost', 129.99, 630, 1, 10, 6, '/productos/ultraboost.png'),

-- Puma Classic (colores: Naranja, Amarillo, Rosa)
('Puma', 'Classic', 79.99, 720, 1, 1, 1, '/productos/pumaClassic.png'),
('Puma', 'Classic', 79.99, 730, 1, 1, 2, '/productos/pumaClassic.png'),
('Puma', 'Classic', 79.99, 720, 1, 2, 1, '/productos/pumaClassic.png'),
('Puma', 'Classic', 79.99, 730, 1, 2, 2, '/productos/pumaClassic.png'),
('Puma', 'Classic', 79.99, 720, 1, 3, 1, '/productos/pumaClassic.png'),
('Puma', 'Classic', 79.99, 730, 1, 3, 2, '/productos/pumaClassic.png'),
('Puma', 'Classic', 79.99, 690, 1, 4, 1, '/productos/pumaClassic.png'),
('Puma', 'Classic', 79.99, 700, 1, 4, 2, '/productos/pumaClassic.png'),
('Puma', 'Classic', 79.99, 660, 1, 5, 1, '/productos/pumaClassic.png'),
('Puma', 'Classic', 79.99, 670, 1, 5, 2, '/productos/pumaClassic.png'),
('Puma', 'Classic', 79.99, 510, 1, 6, 1, '/productos/pumaClassic.png'),
('Puma', 'Classic', 79.99, 520, 1, 6, 2, '/productos/pumaClassic.png'),
('Puma', 'Classic', 79.99, 540, 1, 7, 1, '/productos/pumaClassic.png'),
('Puma', 'Classic', 79.99, 550, 1, 7, 2, '/productos/pumaClassic.png'),
('Puma', 'Classic', 79.99, 570, 1, 8, 1, '/productos/pumaClassic.png'),
('Puma', 'Classic', 79.99, 580, 1, 8, 2, '/productos/pumaClassic.png'),
('Puma', 'Classic', 79.99, 600, 1, 9, 1, '/productos/pumaClassic.png'),
('Puma', 'Classic', 79.99, 610, 1, 9, 2, '/productos/pumaClassic.png'),
('Puma', 'Classic', 79.99, 630, 1, 10, 1, '/productos/pumaClassic.png'),
('Puma', 'Classic', 79.99, 640, 1, 10, 2, '/productos/pumaClassic.png');

insert into productos_pedidos(fk_producto, fk_pedido, cantidad) values
 (1, 1, 3),
 (2, 1, 4),
 (3, 1, 1);
 

delimiter //

create procedure registrarCliente(in _nombre varchar(50),
								  in _apellido1 varchar(100),
								  in _apellido2 varchar(100),
							  	  in _mail varchar(255),
							  	  in _passw varchar(1024),
								  out _codigo int
)
begin
    set _codigo = -99;

    if (_nombre = '' or 
        _apellido1 = '' or
        _mail = '' or
        _passw = '') then
        set _codigo = -1; -- Campo obligatorio no introducido

    elseif (char_length(_passw) < 4) then
        set _codigo = -2; -- Contraseña muy corta

    elseif exists (select 1 from clientes where mail = _mail) then
        set _codigo = -3; -- Correo ya registrado

    elseif (_mail not like '%@%.%') then
        set _codigo = -4; -- Formato incorrecto de correo

    else
        insert into clientes(nombre, apellido1, apellido2, mail, passw)
        values (_nombre, _apellido1, _apellido2, _mail, _passw);
        set _codigo = 0; -- Registro exitoso
    end if;

end;//
delimiter ;

delimiter //

create procedure verificarLogin(in _mail varchar(255),
								in _passw varchar(1024),
								out _codigo int
)
begin
    declare cantidadDeVerificaciones int default 0;

    set _codigo = -99;

    if (_mail = '' or _passw = '') then
        set _codigo = -1; -- CAMPOS VACIOS

    else
        select count(*) into cantidadDeVerificaciones 
        from clientes 
        where mail = _mail and passw = _passw;

        if cantidadDeVerificaciones = 1 then
            set _codigo = 0; -- EXITO
        else
            set _codigo = -2; -- LA CONTRASEÑA NO SE ASOCIA CON EL MAIL
        end if;

    end if;
end;//

delimiter ;

delimiter //

create procedure actualizarStock(in _id_producto int,
								 in _cantidad_vendida int,
								 out _codigo int
)
begin
    declare stockActual int;

    select stock into stockActual 
    from productos 
    where id_producto = _id_producto;

    if stockActual is null then
        set _codigo = -1; -- PRODUCTO NO ENCONTRADO

    elseif stockActual < _cantidad_vendida then
        set _codigo = -2; -- STOCK INSUFICIENTE

    else
        update productos 
        set stock = stock - _cantidad_vendida 
        where id_producto = _id_producto;

        set _codigo = 0; -- EXITO
    end if;
end;//

delimiter ;

delimiter //

create procedure productosPorCategoria(in _id_categoria int)

begin
    select id_producto, marca, modelo, precio, stock
    from productos
    where fk_categoria = _id_categoria;
end;//

delimiter ;

delimiter //

create procedure obtenerPedido(in _id_pedido int)

begin
    select p.id_pedido, p.fecha_pedido, p.fecha_entrega,
           c.nombre, c.apellido1, c.mail,
           pr.marca, pr.modelo, pp.cantidad
    from pedidos p
    join clientes c on p.fk_id_user = c.id_user
    join productos_pedidos pp on pp.fk_pedido = p.id_pedido
    join productos pr on pr.id_producto = pp.fk_producto
    where p.id_pedido = _id_pedido;
end;//

delimiter ;

delimiter //

create procedure cambiarContrasena(in _mail varchar(255),
								   in _nueva_passw varchar(1024),
								   out _codigo int
)
begin
    declare correosEncontrados int;

    select count(*) into correosEncontrados from clientes where mail = _mail;

    if correosEncontrados = 0 then
        set _codigo = -1; -- CORREO NO ENCONTRADO

    elseif char_length(_nueva_passw) < 4 then
        set _codigo = -2; -- CONTRASEÑA CORTA

    else
        update clientes 
        set passw = _nueva_passw 
        where mail = _mail;

        set _codigo = 0; -- EXITO
    end if;
end;//

delimiter ;

create view catalogo as
select p.id_producto, p.marca, p.modelo, p.precio, p.stock, c.color, 
	   t.talla, cat.categoria, p.imagen
from productos p
left join colores c on p.fk_color = c.id_color
left join tallas t on p.fk_talla = t.id_talla
left join categorias cat on p.fk_categoria = cat.id_categoria
left join productos_pedidos pp on p.id_producto = pp.fk_producto
where p.stock > 0
group by p.id_producto, p.marca, p.modelo, p.precio, p.stock, 
         c.color, t.talla, cat.categoria, p.imagen;
