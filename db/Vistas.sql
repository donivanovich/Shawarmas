use shawarmas;

-- PRODUCTOS

DROP VIEW IF EXISTS catalogo; 

CREATE VIEW catalogo AS
SELECT p.id_producto, p.marca, p.modelo, p.precio, p.stock, c.color, 
	   t.talla, cat.categoria, p.imagen
FROM productos p
LEFT JOIN colores c ON p.fk_color = c.id_color
LEFT JOIN tallas t ON p.fk_talla = t.id_talla
LEFT JOIN categorias cat ON p.fk_categoria = cat.id_categoria
LEFT JOIN productos_pedidos pp ON p.id_producto = pp.fk_producto
WHERE p.stock > 0
GROUP BY p.id_producto, p.marca, p.modelo, p.precio, p.stock, 
         c.color, t.talla, cat.categoria, p.imagen;

SELECT * FROM catalogo;
