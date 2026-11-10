USE shawarmas;

INSERT IGNORE INTO colores (color, imagen) VALUES
    ('Beige', '/colors/beige.png'),
    ('Panda', '/colors/panda.png');

UPDATE productos SET imagen = CASE modelo
    WHEN 'Air Force 1' THEN '/products/nike-air-force-1-sneakers-black.png'
    WHEN 'Samba OG' THEN '/products/adidas-samba-og-sneakers-white.png'
    WHEN 'Campus' THEN '/products/adidas-campus-sneakers-black.png'
    WHEN 'Air Jordan 1' THEN '/products/jordan-air-jordan-1-sneakers-cyan.png'
    WHEN 'Superstar' THEN '/products/adidas-superstar-sneakers-white.png'
    WHEN 'Air Jordan 4 Retro' THEN '/products/jordan-air-jordan-4-retro-sneakers-panda.png'
    WHEN 'Tech Fleece' THEN '/products/nike-tech-fleece-pants-black.png'
    WHEN 'BMW M3 T7' THEN '/products/puma-bmw-m3-t7-pants-yellow.png'
    WHEN 'UA Baseline Short' THEN '/products/under-armour-ua-baseline-short-pants-red.png'
    WHEN 'Essentials Big Logo' THEN '/products/adidas-essentials-big-logo-shirt-white.png'
    WHEN 'Sketch' THEN '/products/jordan-sketch-hoodie-black.png'
    WHEN 'Athletics 90s' THEN '/products/new-balance-athletics-90s-hoodie-black.png'
    WHEN 'Running' THEN '/products/new-balance-running-shirt-blue.png'
    WHEN 'Los Angeles Dodgers' THEN '/products/new-era-los-angeles-dodgers-cap-black.png'
    WHEN 'MLB 9TWENTY' THEN '/products/new-era-mlb-9twenty-cap-beige.png'
    WHEN 'Swoosh Padded' THEN '/products/nike-swoosh-padded-coat-black.png'
    WHEN 'Sport' THEN '/products/puma-sport-shirt-black.png'
    WHEN 'Retro Nuptse 1996' THEN '/products/the-north-face-retro-nuptse-1996-coat-brown.png'
    WHEN 'Retrofor' THEN '/products/ugg-retrofor-hoodie-green.png'
    WHEN 'Golf 96' THEN '/products/under-armour-golf-96-cap-black.png'
    WHEN 'Originals Standards Varsity Loose Crew' THEN '/products/vans-originals-standards-varsity-loose-crew-hoodie-green.png'
    ELSE imagen
END
WHERE marca <> 'SWM';

UPDATE productos
SET modelo = CASE
    WHEN imagen LIKE '%/swm-essentials-%' THEN 'Essentials'
    WHEN imagen LIKE '%/swm-frostline-%' THEN 'Frostline'
    WHEN imagen LIKE '%/swm-night-division-%' THEN 'Night Division'
    WHEN imagen LIKE '%/swm-osaka-street-%' THEN 'Osaka Street'
    WHEN imagen LIKE '%/swm-sakura-spirit-%' THEN 'Sakura Spirit'
    WHEN imagen LIKE '%/swm-urban-retro-%' THEN 'Urban Retro'
    ELSE modelo
END
WHERE marca = 'SWM';

INSERT INTO productos (marca, modelo, precio, imagen, fk_categoria, stock, fk_talla, fk_color)
SELECT 'SWM', datos.modelo, datos.precio, CONCAT('/products/', datos.imagen), datos.fk_categoria,
    12, 13, CASE WHEN datos.imagen LIKE 'swm-essentials-%' OR datos.modelo LIKE '%Beige' OR datos.modelo = 'Essentials Cap' THEN 13 ELSE 2 END
FROM (
    SELECT 'Essentials' modelo, 19.99 precio, 'swm-essentials-cap-beige.png' imagen, 5 fk_categoria
    UNION ALL SELECT 'Essentials', 59.99, 'swm-essentials-hoodie-beige.png', 2
    UNION ALL SELECT 'Essentials', 49.99, 'swm-essentials-pants-beige.png', 4
    UNION ALL SELECT 'Essentials', 24.99, 'swm-essentials-shirt-beige.png', 3
    UNION ALL SELECT 'Frostline', 129.99, 'swm-frostline-coat-black.png', 6
    UNION ALL SELECT 'Night Division', 139.99, 'swm-night-division-coat-black.png', 6
    UNION ALL SELECT 'Osaka Street', 54.99, 'swm-osaka-street-pants-black.png', 4
    UNION ALL SELECT 'Osaka Street', 54.99, 'swm-osaka-street-pants-blue.png', 4
    UNION ALL SELECT 'Osaka Street', 54.99, 'swm-osaka-street-pants-gray.png', 4
    UNION ALL SELECT 'Sakura Spirit', 64.99, 'swm-sakura-spirit-hoodie-beige.png', 2
    UNION ALL SELECT 'Sakura Spirit', 64.99, 'swm-sakura-spirit-hoodie-red.png', 2
    UNION ALL SELECT 'Urban Retro', 89.99, 'swm-urban-retro-sneakers-beige.png', 1
    UNION ALL SELECT 'Urban Retro', 89.99, 'swm-urban-retro-sneakers-black.png', 1
) datos
WHERE NOT EXISTS (
    SELECT 1 FROM productos p WHERE p.marca = 'SWM' AND p.imagen = CONCAT('/products/', datos.imagen)
);

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
  END
  AND NOT EXISTS (
      SELECT 1
      FROM producto_variantes v
      WHERE v.fk_producto = p.id_producto
        AND v.fk_talla = t.id_talla
        AND v.fk_color = c.id_color
  );
