create database if not exists shawarmas;
drop database if exists shawarmas;

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
                                
select * from pedidos;