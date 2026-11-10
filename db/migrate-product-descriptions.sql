USE shawarmas;
SET NAMES utf8mb4;

SET @tiene_descripcion = (
    SELECT COUNT(*)
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'productos'
      AND column_name = 'descripcion'
);
SET @alter_descripcion = IF(@tiene_descripcion = 0,
    'ALTER TABLE productos ADD COLUMN descripcion TEXT NULL',
    'SELECT 1');
PREPARE sentencia_descripcion FROM @alter_descripcion;
EXECUTE sentencia_descripcion;
DEALLOCATE PREPARE sentencia_descripcion;

UPDATE productos p
INNER JOIN categorias cat ON cat.id_categoria = p.fk_categoria
SET p.descripcion = CASE
    WHEN p.marca = 'Nike' AND p.modelo = 'Air Force 1' THEN 'Un icono de perfil limpio y versátil. Su diseño combina con looks urbanos de diario.'
    WHEN p.marca = 'Adidas' AND p.modelo = 'Samba OG' THEN 'Una silueta clásica de inspiración futbolística, con perfil bajo y líneas atemporales para el día a día.'
    WHEN p.marca = 'Adidas' AND p.modelo = 'Campus' THEN 'Inspiradas en el estilo retro de las pistas, estas zapatillas aportan una silueta sencilla y fácil de combinar.'
    WHEN p.marca = 'Jordan' AND p.modelo = 'Air Jordan 1' THEN 'Una silueta de baloncesto de caña alta con presencia y carácter urbano. Un clásico para completar cualquier conjunto.'
    WHEN p.marca = 'Adidas' AND p.modelo = 'Superstar' THEN 'Reconocibles por su puntera de goma y sus líneas icónicas, son un básico urbano que nunca pasa de moda.'
    WHEN p.marca = 'Jordan' AND p.modelo = 'Air Jordan 4 Retro' THEN 'Una silueta de baloncesto con diseño estructurado y detalles marcados, pensada para destacar dentro y fuera de la cancha.'
    WHEN p.marca = 'Nike' AND p.modelo = 'Tech Fleece' THEN 'Pantalón de inspiración deportiva con una silueta cómoda y actual, ideal para moverte con libertad durante el día.'
    WHEN p.marca = 'Puma' AND p.modelo = 'BMW M3 T7' THEN 'Una mezcla de estilo deportivo y referencias al automovilismo, con una silueta cómoda para tus planes cotidianos.'
    WHEN p.marca = 'Under Armour' AND p.modelo = 'UA Baseline Short' THEN 'Un pantalón corto de aire deportivo y corte ligero, pensado para acompañarte en el entrenamiento y en tu tiempo libre.'
    WHEN p.marca = 'Adidas' AND p.modelo = 'Essentials Big Logo' THEN 'Una camiseta de líneas sencillas con el logotipo como protagonista. Un básico cómodo para combinar a diario.'
    WHEN p.marca = 'Jordan' AND p.modelo = 'Sketch' THEN 'Una sudadera de estilo relajado con el carácter gráfico de Jordan. Ideal para sumar una capa cómoda a tu look.'
    WHEN p.marca = 'New Balance' AND p.modelo = 'Athletics 90s' THEN 'Una sudadera de inspiración noventera con una silueta casual que funciona dentro y fuera de la rutina deportiva.'
    WHEN p.marca = 'New Balance' AND p.modelo = 'Running' THEN 'Una camiseta de estética deportiva y diseño versátil, lista para acompañar tus entrenamientos o tus días activos.'
    WHEN p.marca = 'New Era' AND p.modelo = 'Los Angeles Dodgers' THEN 'Una gorra de estilo clásico para mostrar tu afición por Los Angeles Dodgers y completar tus conjuntos urbanos.'
    WHEN p.marca = 'New Era' AND p.modelo = 'MLB 9TWENTY' THEN 'La silueta relajada de la 9TWENTY aporta un toque deportivo y fácil de llevar a cualquier look.'
    WHEN p.marca = 'Nike' AND p.modelo = 'Swoosh Padded' THEN 'Un abrigo acolchado de líneas deportivas que añade una capa cálida y funcional para los días fríos.'
    WHEN p.marca = 'Puma' AND p.modelo = 'Sport' THEN 'Una camiseta de inspiración deportiva con un diseño sencillo para entrenar o vestir con comodidad.'
    WHEN p.marca = 'The North Face' AND p.modelo = 'Retro Nuptse 1996' THEN 'Una chaqueta de volumen característico y espíritu outdoor, reinterpretada con una estética urbana reconocible.'
    WHEN p.marca = 'UGG' AND p.modelo = 'Retrofor' THEN 'Una sudadera de aspecto relajado que suma comodidad y una silueta desenfadada a tus capas de diario.'
    WHEN p.marca = 'Under Armour' AND p.modelo = 'Golf 96' THEN 'Una gorra deportiva de perfil clásico para completar tus conjuntos de golf y tus looks casuales.'
    WHEN p.marca = 'Vans' AND p.modelo = 'Originals Standards Varsity Loose Crew' THEN 'Una sudadera de corte amplio con aire universitario y espíritu skate, pensada para llevar con comodidad.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Aurora' THEN 'Una sudadera de líneas actuales y estilo relajado, creada para aportar comodidad y personalidad a tus looks diarios.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Core' THEN 'Un pantalón versátil de silueta cómoda y estética urbana, fácil de combinar durante toda la semana.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Cosmos Nav' THEN 'Una camiseta de diseño contemporáneo y carácter urbano, pensada para dar un punto distintivo a tus conjuntos.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Metamorphosis' THEN 'Una sudadera de estilo urbano con una presencia gráfica marcada y una silueta cómoda para el día a día.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Synapse' THEN 'Una sudadera de diseño limpio y espíritu contemporáneo, ideal para crear capas cómodas con un toque urbano.'
    WHEN p.marca = 'SWM' AND p.modelo = 'The Tank' THEN 'Una zapatilla de inspiración deportiva con una silueta contundente que aporta carácter a tus looks urbanos.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Urban Explorer' THEN 'Una camiseta casual de estética urbana y diseño versátil, preparada para acompañarte en tus planes diarios.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Essentials' AND cat.categoria = 'Accesorios' THEN 'Una gorra esencial de diseño sencillo que completa tus conjuntos diarios con un toque relajado.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Essentials' AND cat.categoria = 'Sudaderas' THEN 'Una sudadera cómoda de líneas esenciales, pensada para combinar fácilmente con tus prendas favoritas.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Essentials' AND cat.categoria = 'Pantalones' THEN 'Un pantalón de estilo básico y silueta cómoda, ideal para crear conjuntos casuales sin complicaciones.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Essentials' AND cat.categoria = 'Camisetas' THEN 'Una camiseta básica y versátil que funciona como punto de partida para cualquier look cotidiano.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Frostline' THEN 'Un abrigo de estética funcional y líneas limpias, preparado para sumar una capa cómoda en los días fríos.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Night Division' THEN 'Un abrigo de inspiración urbana con una silueta sobria y contundente para los días de frío.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Osaka Street' THEN 'Un pantalón de estilo streetwear con una silueta relajada que aporta comodidad y carácter a tus conjuntos.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Sakura Spirit' THEN 'Una sudadera de estilo casual con un aire distintivo, pensada para acompañar tus looks urbanos.'
    WHEN p.marca = 'SWM' AND p.modelo = 'Urban Retro' THEN 'Una zapatilla de inspiración retro con una silueta urbana fácil de llevar en tus planes diarios.'
    ELSE p.descripcion
END;
