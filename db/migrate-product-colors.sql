USE shawarmas;

ALTER TABLE colores
    ADD COLUMN imagen VARCHAR(255) NULL;

UPDATE colores SET imagen = CASE color
    WHEN 'Blanco' THEN '/colors/white.png'
    WHEN 'Negro' THEN '/colors/black.png'
    WHEN 'Gris' THEN '/colors/gray.png'
    WHEN 'Azul' THEN '/colors/blue.png'
    WHEN 'Rojo' THEN '/colors/red.png'
    WHEN 'Verde' THEN '/colors/green.png'
    WHEN 'Amarillo' THEN '/colors/yellow.png'
    WHEN 'Naranja' THEN '/colors/lawngreen.png'
    WHEN 'Rosa' THEN '/colors/red.png'
    WHEN 'Morado' THEN '/colors/panda.png'
    WHEN 'Marron' THEN '/colors/brown.png'
    WHEN 'Cian' THEN '/colors/cyan.png'
    WHEN 'Beige' THEN '/colors/beige.png'
    ELSE imagen
END;

ALTER TABLE producto_variantes
    ADD COLUMN imagen VARCHAR(255) NULL;

INSERT IGNORE INTO colores (color, imagen) VALUES
    ('Beige', '/colors/beige.png'),
    ('Panda', '/colors/panda.png');

INSERT INTO producto_variantes (fk_producto, fk_talla, fk_color, stock, imagen)
SELECT p.id_producto, t.id_talla, c.id_color,
    CASE
        WHEN p.modelo = 'Samba OG' AND c.color = 'Negro' AND t.talla = '45' THEN 0
        WHEN p.modelo = 'Superstar' AND c.color = 'Negro' AND t.talla = '43' THEN 0
        WHEN p.modelo = 'Air Jordan 4 Retro' AND c.color = 'Blanco' AND t.talla = '44' THEN 0
        ELSE 12
    END,
    p.imagen
FROM productos p
INNER JOIN tallas t
INNER JOIN colores c
WHERE (
    (p.modelo = 'Samba OG' AND c.color IN ('Blanco', 'Negro', 'Azul') AND t.talla IN ('39', '40', '41', '42', '43', '44', '45'))
    OR (p.modelo = 'Superstar' AND c.color IN ('Blanco', 'Negro', 'Rojo') AND t.talla IN ('39', '40', '41', '42', '43'))
    OR (p.modelo = 'Air Jordan 4 Retro' AND c.color IN ('Negro', 'Panda', 'Blanco') AND t.talla IN ('40', '41', '42', '43', '44'))
)
AND NOT EXISTS (
        SELECT 1
        FROM producto_variantes existing
        WHERE existing.fk_producto = p.id_producto
          AND existing.fk_talla = t.id_talla
          AND existing.fk_color = c.id_color
    );

UPDATE producto_variantes v
INNER JOIN productos p ON p.id_producto = v.fk_producto
INNER JOIN colores c ON c.id_color = v.fk_color
SET v.imagen = p.imagen
WHERE p.modelo IN ('Samba OG', 'Superstar', 'Air Jordan 4 Retro');
