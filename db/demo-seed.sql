-- Local demo users and orders. Safe to run repeatedly.
-- Password for all seeded users: Shawarmas123!
SET NAMES utf8mb4;

-- Remove the superseded sample account and its orders.
DELETE FROM productos_pedidos
WHERE fk_pedido IN (
    SELECT id_pedido FROM pedidos
    WHERE fk_id_user IN (SELECT id_user FROM clientes WHERE mail = 'nombre@gmail.com')
);
DELETE FROM pedidos
WHERE fk_id_user IN (SELECT id_user FROM clientes WHERE mail = 'nombre@gmail.com');
DELETE FROM clientes WHERE mail = 'nombre@gmail.com';

INSERT INTO clientes (nombre, apellido1, apellido2, mail, passw) VALUES
    ('Cliente', 'Demo', '', 'cliente@shawarmas.local', 'pbkdf2$AAECAwQFBgcICQoLDA0ODw==$DvtlSGIhzT+MSaLNKcAKvlHPDNgHxNtsefJ2s9B55uY='),
    ('Ana', 'Martinez', 'Lopez', 'ana.martinez@gmail.com', 'pbkdf2$QEFCQ0RFRkdISUpLTE1OTw==$/hky0cX19fE9Pvbeco4ws43/EfU7O01tW3+pYRFp+6A='),
    ('Carlos', 'Rivera', 'Mendez', 'carlos.rivera@outlook.com', 'pbkdf2$UFFSU1RVVldYWVpbXF1eXw==$4uBpK6ijYmSkes/aoZVGmtaT1oTWvbiI2PeXrt2msMo='),
    ('Laura', 'Gomez', 'Santos', 'laura.gomez@yahoo.com', 'pbkdf2$YGFiY2RlZmdoaWprbG1ubw==$qJgpYgXvNxVb9P3HNxa2EYPyFa3z3qSSdcwUxcjOpTo='),
    ('Diego', 'Santos', 'Martin', 'diego.santos@gmail.com', 'pbkdf2$cHFyc3R1dnd4eXp7fH1+fw==$FeJ+1UgKPjNciJoRPWjA2XX8XY/Yk56LbTpK0vnEYyU=')
ON DUPLICATE KEY UPDATE
    nombre = VALUES(nombre), apellido1 = VALUES(apellido1), apellido2 = VALUES(apellido2), passw = VALUES(passw);

INSERT INTO empleados (nombre, apellido1, apellido2, mail, passw, mode_use, volume, fk_tienda)
VALUES (
    'Empleado', 'Demo', '', 'empleado@shawarmas.local',
    'pbkdf2$ICEiIyQlJicoKSorLC0uLw==$kEqQ1Jj/v5b5RyJM6XWMo2Wp9NdVYaZ2XrjmGcWLJUY=',
    'writter', 50, (SELECT id_tienda FROM tiendas WHERE ciudad = 'Madrid' LIMIT 1)
)
ON DUPLICATE KEY UPDATE
    nombre = VALUES(nombre), apellido1 = VALUES(apellido1), apellido2 = VALUES(apellido2),
    passw = VALUES(passw), mode_use = VALUES(mode_use), fk_tienda = VALUES(fk_tienda);

SET @cliente_demo_id = (SELECT id_user FROM clientes WHERE mail = 'cliente@shawarmas.local' LIMIT 1);
SET @ana_id = (SELECT id_user FROM clientes WHERE mail = 'ana.martinez@gmail.com' LIMIT 1);
SET @carlos_id = (SELECT id_user FROM clientes WHERE mail = 'carlos.rivera@outlook.com' LIMIT 1);
SET @laura_id = (SELECT id_user FROM clientes WHERE mail = 'laura.gomez@yahoo.com' LIMIT 1);
SET @diego_id = (SELECT id_user FROM clientes WHERE mail = 'diego.santos@gmail.com' LIMIT 1);

-- Repair Spanish seed rows written by older runs with the wrong client encoding.
UPDATE pedidos p
JOIN clientes c ON c.id_user = p.fk_id_user
SET p.pais = 'España'
WHERE c.mail IN ('cliente@shawarmas.local', 'ana.martinez@gmail.com', 'carlos.rivera@outlook.com', 'laura.gomez@yahoo.com', 'diego.santos@gmail.com')
  AND p.ciudad IN ('Madrid', 'Barcelona', 'Valencia', 'Sevilla')
  AND p.pais LIKE 'Espa%';
UPDATE pedidos p
JOIN clientes c ON c.id_user = p.fk_id_user
SET p.calle = 'Carrer de Colón, 22', p.pais = 'España'
WHERE c.mail = 'ana.martinez@gmail.com' AND p.ciudad = 'Valencia' AND p.postal = '46004'
  AND p.calle LIKE 'Carrer de Col%';

-- Madrid, Spain: existing seed order is reused if this file is run again.
INSERT INTO pedidos (fecha_pedido, fecha_entrega, entregado, pais, ciudad, calle, postal, fk_id_user, fk_tienda)
SELECT DATE_SUB(NOW(), INTERVAL 18 DAY), DATE_SUB(NOW(), INTERVAL 14 DAY), TRUE,
       'España', 'Madrid', 'Calle de Atocha, 27', '28012', @cliente_demo_id,
       (SELECT id_tienda FROM tiendas WHERE ciudad = 'Madrid' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM pedidos WHERE fk_id_user = @cliente_demo_id AND calle = 'Calle de Atocha, 27');
SET @pedido_madrid_id = (SELECT id_pedido FROM pedidos WHERE fk_id_user = @cliente_demo_id AND calle = 'Calle de Atocha, 27' ORDER BY id_pedido DESC LIMIT 1);
INSERT INTO productos_pedidos (fk_variante, fk_pedido, cantidad)
SELECT v.id_variante, @pedido_madrid_id, 1 FROM producto_variantes v
JOIN productos p ON p.id_producto = v.fk_producto JOIN tallas t ON t.id_talla = v.fk_talla JOIN colores c ON c.id_color = v.fk_color
WHERE p.marca = 'Nike' AND p.modelo = 'Air Force 1' AND t.talla = '42' AND c.color = 'Negro'
ON DUPLICATE KEY UPDATE cantidad = VALUES(cantidad);
INSERT INTO productos_pedidos (fk_variante, fk_pedido, cantidad)
SELECT v.id_variante, @pedido_madrid_id, 1 FROM producto_variantes v
JOIN productos p ON p.id_producto = v.fk_producto JOIN tallas t ON t.id_talla = v.fk_talla JOIN colores c ON c.id_color = v.fk_color
WHERE p.marca = 'Adidas' AND p.modelo = 'Samba OG' AND t.talla = '40' AND c.color = 'Blanco'
ON DUPLICATE KEY UPDATE cantidad = VALUES(cantidad);

-- Barcelona, Spain: pending Adidas order.
INSERT INTO pedidos (fecha_pedido, fecha_entrega, entregado, pais, ciudad, calle, postal, fk_id_user, fk_tienda)
SELECT DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_ADD(NOW(), INTERVAL 2 DAY), FALSE,
       'España', 'Barcelona', 'Carrer de Mallorca, 401', '08013', @ana_id,
       (SELECT id_tienda FROM tiendas WHERE ciudad = 'Barcelona' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM pedidos WHERE fk_id_user = @ana_id AND calle = 'Carrer de Mallorca, 401');
SET @pedido_barcelona_id = (SELECT id_pedido FROM pedidos WHERE fk_id_user = @ana_id AND calle = 'Carrer de Mallorca, 401' ORDER BY id_pedido DESC LIMIT 1);
INSERT INTO productos_pedidos (fk_variante, fk_pedido, cantidad)
SELECT v.id_variante, @pedido_barcelona_id, 1 FROM producto_variantes v
JOIN productos p ON p.id_producto = v.fk_producto JOIN tallas t ON t.id_talla = v.fk_talla JOIN colores c ON c.id_color = v.fk_color
WHERE p.marca = 'Adidas' AND p.modelo = 'Campus' AND t.talla = '40' AND c.color = 'Panda'
ON DUPLICATE KEY UPDATE cantidad = VALUES(cantidad);

-- Lisbon, Portugal: two Sakura Spirit hoodies.
INSERT INTO pedidos (fecha_pedido, fecha_entrega, entregado, pais, ciudad, calle, postal, fk_id_user, fk_tienda)
SELECT DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_ADD(NOW(), INTERVAL 1 DAY), FALSE,
       'Portugal', 'Lisboa', 'Rua Augusta, 120', '1100-053', @carlos_id,
       (SELECT id_tienda FROM tiendas WHERE ciudad = 'Lisboa' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM pedidos WHERE fk_id_user = @carlos_id AND calle = 'Rua Augusta, 120');
SET @pedido_lisboa_id = (SELECT id_pedido FROM pedidos WHERE fk_id_user = @carlos_id AND calle = 'Rua Augusta, 120' ORDER BY id_pedido DESC LIMIT 1);
INSERT INTO productos_pedidos (fk_variante, fk_pedido, cantidad)
SELECT v.id_variante, @pedido_lisboa_id, 2 FROM producto_variantes v
JOIN productos p ON p.id_producto = v.fk_producto JOIN tallas t ON t.id_talla = v.fk_talla JOIN colores c ON c.id_color = v.fk_color
WHERE p.marca = 'SWM' AND p.modelo = 'Sakura Spirit' AND t.talla = 'M' AND c.color = 'Beige'
ON DUPLICATE KEY UPDATE cantidad = VALUES(cantidad);

-- Porto, Portugal: delivered Urban Retro sneakers.
INSERT INTO pedidos (fecha_pedido, fecha_entrega, entregado, pais, ciudad, calle, postal, fk_id_user, fk_tienda)
SELECT DATE_SUB(NOW(), INTERVAL 24 DAY), DATE_SUB(NOW(), INTERVAL 20 DAY), TRUE,
       'Portugal', 'Oporto', 'Rua de Santa Catarina, 88', '4000-447', @laura_id,
       (SELECT id_tienda FROM tiendas WHERE ciudad = 'Oporto' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM pedidos WHERE fk_id_user = @laura_id AND calle = 'Rua de Santa Catarina, 88');
SET @pedido_oporto_id = (SELECT id_pedido FROM pedidos WHERE fk_id_user = @laura_id AND calle = 'Rua de Santa Catarina, 88' ORDER BY id_pedido DESC LIMIT 1);
INSERT INTO productos_pedidos (fk_variante, fk_pedido, cantidad)
SELECT v.id_variante, @pedido_oporto_id, 1 FROM producto_variantes v
JOIN productos p ON p.id_producto = v.fk_producto JOIN tallas t ON t.id_talla = v.fk_talla JOIN colores c ON c.id_color = v.fk_color
WHERE p.marca = 'SWM' AND p.modelo = 'Urban Retro' AND t.talla = '41' AND c.color = 'Negro'
ON DUPLICATE KEY UPDATE cantidad = VALUES(cantidad);

-- Valencia, Spain: delivered Jordan sneakers.
INSERT INTO pedidos (fecha_pedido, fecha_entrega, entregado, pais, ciudad, calle, postal, fk_id_user, fk_tienda)
SELECT DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY), TRUE,
       'España', 'Valencia', 'Carrer de Colón, 22', '46004', @ana_id,
       (SELECT id_tienda FROM tiendas WHERE ciudad = 'Valencia' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM pedidos WHERE fk_id_user = @ana_id AND calle = 'Carrer de Colón, 22');
SET @pedido_valencia_id = (SELECT id_pedido FROM pedidos WHERE fk_id_user = @ana_id AND calle = 'Carrer de Colón, 22' ORDER BY id_pedido DESC LIMIT 1);
INSERT INTO productos_pedidos (fk_variante, fk_pedido, cantidad)
SELECT v.id_variante, @pedido_valencia_id, 1 FROM producto_variantes v
JOIN productos p ON p.id_producto = v.fk_producto JOIN tallas t ON t.id_talla = v.fk_talla JOIN colores c ON c.id_color = v.fk_color
WHERE p.marca = 'Jordan' AND p.modelo = 'Air Jordan 1' AND t.talla = '42' AND c.color = 'Cian'
ON DUPLICATE KEY UPDATE cantidad = VALUES(cantidad);

-- Seville, Spain: pending Air Force 1 order.
INSERT INTO pedidos (fecha_pedido, fecha_entrega, entregado, pais, ciudad, calle, postal, fk_id_user, fk_tienda)
SELECT DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_ADD(NOW(), INTERVAL 3 DAY), FALSE,
       'España', 'Sevilla', 'Calle Sierpes, 22', '41004', @diego_id,
       (SELECT id_tienda FROM tiendas WHERE ciudad = 'Madrid' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM pedidos WHERE fk_id_user = @diego_id AND calle = 'Calle Sierpes, 22');
SET @pedido_sevilla_id = (SELECT id_pedido FROM pedidos WHERE fk_id_user = @diego_id AND calle = 'Calle Sierpes, 22' ORDER BY id_pedido DESC LIMIT 1);
INSERT INTO productos_pedidos (fk_variante, fk_pedido, cantidad)
SELECT v.id_variante, @pedido_sevilla_id, 1 FROM producto_variantes v
JOIN productos p ON p.id_producto = v.fk_producto JOIN tallas t ON t.id_talla = v.fk_talla JOIN colores c ON c.id_color = v.fk_color
WHERE p.marca = 'Nike' AND p.modelo = 'Air Force 1' AND t.talla = '43' AND c.color = 'Negro'
ON DUPLICATE KEY UPDATE cantidad = VALUES(cantidad);

-- Oporto, Portugal: delivered Adidas Campus order.
INSERT INTO pedidos (fecha_pedido, fecha_entrega, entregado, pais, ciudad, calle, postal, fk_id_user, fk_tienda)
SELECT DATE_SUB(NOW(), INTERVAL 35 DAY), DATE_SUB(NOW(), INTERVAL 31 DAY), TRUE,
       'Portugal', 'Oporto', 'Rua de Cedofeita, 155', '4050-179', @carlos_id,
       (SELECT id_tienda FROM tiendas WHERE ciudad = 'Oporto' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM pedidos WHERE fk_id_user = @carlos_id AND calle = 'Rua de Cedofeita, 155');
SET @pedido_oporto_carlos_id = (SELECT id_pedido FROM pedidos WHERE fk_id_user = @carlos_id AND calle = 'Rua de Cedofeita, 155' ORDER BY id_pedido DESC LIMIT 1);
INSERT INTO productos_pedidos (fk_variante, fk_pedido, cantidad)
SELECT v.id_variante, @pedido_oporto_carlos_id, 1 FROM producto_variantes v
JOIN productos p ON p.id_producto = v.fk_producto JOIN tallas t ON t.id_talla = v.fk_talla JOIN colores c ON c.id_color = v.fk_color
WHERE p.marca = 'Adidas' AND p.modelo = 'Campus' AND t.talla = '39' AND c.color = 'Panda'
ON DUPLICATE KEY UPDATE cantidad = VALUES(cantidad);

-- Lisbon, Portugal: delivered Samba OG order.
INSERT INTO pedidos (fecha_pedido, fecha_entrega, entregado, pais, ciudad, calle, postal, fk_id_user, fk_tienda)
SELECT DATE_SUB(NOW(), INTERVAL 16 DAY), DATE_SUB(NOW(), INTERVAL 12 DAY), TRUE,
       'Portugal', 'Lisboa', 'Avenida da Liberdade, 45', '1250-096', @laura_id,
       (SELECT id_tienda FROM tiendas WHERE ciudad = 'Lisboa' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM pedidos WHERE fk_id_user = @laura_id AND calle = 'Avenida da Liberdade, 45');
SET @pedido_lisboa_laura_id = (SELECT id_pedido FROM pedidos WHERE fk_id_user = @laura_id AND calle = 'Avenida da Liberdade, 45' ORDER BY id_pedido DESC LIMIT 1);
INSERT INTO productos_pedidos (fk_variante, fk_pedido, cantidad)
SELECT v.id_variante, @pedido_lisboa_laura_id, 1 FROM producto_variantes v
JOIN productos p ON p.id_producto = v.fk_producto JOIN tallas t ON t.id_talla = v.fk_talla JOIN colores c ON c.id_color = v.fk_color
WHERE p.marca = 'Adidas' AND p.modelo = 'Samba OG' AND t.talla = '41' AND c.color = 'Blanco'
ON DUPLICATE KEY UPDATE cantidad = VALUES(cantidad);
