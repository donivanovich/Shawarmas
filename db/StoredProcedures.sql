use shawarmas;

call registrarCliente('Juan', 'Pérez', 'García', 'juan.perez@example.com', '321231', @resultado);
select @resultado;

CALL verificarLogin('pedro@gmail.com', '1234', @codigo);
SELECT @codigo;

CALL actualizarStock(10, 5, @codigo);
SELECT @codigo;

CALL productosPorCategoria(1);

CALL obtenerPedido(1);

CALL cambiarContrasena('pedro@gmail.com', '12345', @codigo);
SELECT @codigo; 


-- PROCEDIMIENTO DE REGISTRO DEL CLIENTE------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

-- VERIFICAR SI UN MAIL Y SU CONTRASEÑA SON CORRECTOS---------------------------------------------------------------------------------------------------------------------------------------------

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

-- ACTUALIZAR STOCK ------------------------------------------------------------------------------------------------------------------------------------------------------------------
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


-- BUSCAR PRODUCTOS POR CATEGORIA ----------------------------------------------------------------------------------------------------------------------------------------------------------------

delimiter //

create procedure productosPorCategoria(in _id_categoria int)

begin
    select id_producto, marca, modelo, precio, stock
    from productos
    where fk_categoria = _id_categoria;
end;//

delimiter ;

-- VER DATOS DE UN PEDIDO --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

-- CAMBIAR CONTRASEÑA DE CLIENTE -------------------------------------------------------------------------------------------------------------------------------------------------------------

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
