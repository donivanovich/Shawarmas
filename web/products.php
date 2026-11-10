<?php
declare(strict_types=1);

session_start([
    'cookie_httponly' => true,
    'cookie_samesite' => 'Lax',
    'cookie_secure' => !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off'
]);
require_once __DIR__ . '/database-connection.php';

$errorLogin = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['usuario'], $_POST['password'])) {
    $email = trim((string) $_POST['usuario']);
    $pass = (string) $_POST['password'];
    $stmt = $conn->prepare('SELECT id_user, nombre, apellido1, apellido2, mail, passw FROM clientes WHERE mail = ? LIMIT 1');
    $stmt->bind_param('s', $email);
    $stmt->execute();
    $cliente = $stmt->get_result()->fetch_assoc();
    $stmt->close();

    if ($cliente && verify_password_shared($pass, (string) $cliente['passw'])) {
        session_regenerate_id(true);
        $_SESSION['id_user'] = (int) $cliente['id_user'];
        $_SESSION['nombre'] = (string) $cliente['nombre'];
        $_SESSION['apellido1'] = (string) $cliente['apellido1'];
        $_SESSION['apellido2'] = (string) ($cliente['apellido2'] ?? '');
        $_SESSION['mail'] = (string) $cliente['mail'];
        $_SESSION['nombre_completo'] = trim($_SESSION['nombre'] . ' ' . $_SESSION['apellido1'] . ' ' . $_SESSION['apellido2']);
    } else {
        $errorLogin = 'Usuario o contraseña incorrectos.';
    }
}

$categoria = filter_input(INPUT_GET, 'categoria', FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
$maximo = filter_input(INPUT_GET, 'maximo', FILTER_VALIDATE_FLOAT, ['options' => ['min_range' => 0]]);
$colorId = filter_input(INPUT_GET, 'color', FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
$marca = trim((string) ($_GET['marca'] ?? ''));
$busqueda = trim((string) ($_GET['buscar'] ?? ''));
$filtrosActivos = [];
if ($busqueda !== '') {
    $filtrosActivos['buscar'] = $busqueda;
}
if ($categoria) {
    $filtrosActivos['categoria'] = $categoria;
}
if ($marca !== '') {
    $filtrosActivos['marca'] = $marca;
}
if ($colorId) {
    $filtrosActivos['color'] = $colorId;
}
if ($maximo !== false && $maximo !== null) {
    $filtrosActivos['maximo'] = $maximo;
}
$urlColeccionFiltrada = 'products.php' . ($filtrosActivos ? '?' . http_build_query($filtrosActivos) : '');

$sql = 'SELECT p.id_producto, p.marca, p.modelo, p.precio, COALESCE(SUM(v.stock), 0) AS stock,
               COALESCE(MAX(v.imagen), p.imagen) AS imagen, c.categoria, co.id_color, co.color
        FROM productos p
        INNER JOIN categorias c ON c.id_categoria = p.fk_categoria
        LEFT JOIN producto_variantes v ON v.fk_producto = p.id_producto
        LEFT JOIN colores co ON co.id_color = v.fk_color
        WHERE 1 = 1';
$types = '';
$params = [];
if ($categoria) {
    $sql .= ' AND p.fk_categoria = ?';
    $types .= 'i';
    $params[] = $categoria;
}
if ($marca !== '') {
    $sql .= ' AND p.marca = ?';
    $types .= 's';
    $params[] = $marca;
}
if ($colorId) {
    $sql .= ' AND co.id_color = ?';
    $types .= 'i';
    $params[] = $colorId;
}
if ($maximo !== false && $maximo !== null) {
    $sql .= ' AND p.precio <= ?';
    $types .= 'd';
    $params[] = $maximo;
}
if ($busqueda !== '') {
    $sql .= ' AND (p.marca LIKE ? OR p.modelo LIKE ?)';
    $types .= 'ss';
    $like = '%' . $busqueda . '%';
    $params[] = $like;
    $params[] = $like;
}
$sql .= ' GROUP BY p.id_producto, p.marca, p.modelo, p.precio, p.imagen, c.categoria, co.id_color, co.color ORDER BY RAND()';

$stmt = $conn->prepare($sql);
if ($types !== '') {
    $stmt->bind_param($types, ...$params);
}
$stmt->execute();
$productos = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
$stmt->close();

$categorias = $conn->query('SELECT id_categoria, categoria FROM categorias ORDER BY categoria')->fetch_all(MYSQLI_ASSOC);
$marcas = $conn->query('SELECT DISTINCT marca FROM productos ORDER BY marca')->fetch_all(MYSQLI_ASSOC);
$colores = $conn->query('SELECT DISTINCT co.id_color, co.color
    FROM producto_variantes v
    INNER JOIN colores co ON co.id_color = v.fk_color
    ORDER BY co.color')->fetch_all(MYSQLI_ASSOC);
$cartCount = 0;
foreach ($_SESSION['carrito'] ?? [] as $sizes) {
    foreach ((array) $sizes as $quantity) {
        $cartCount += max(0, (int) $quantity);
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Productos</title>
    <link rel="icon" href="assets/img/favicon/favicon.ico?v=20261110-1" type="image/x-icon">
    <link rel="stylesheet" href="alternative.css?v=20261110-1">
    <link rel="stylesheet" href="products.css?v=20261110-2">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
</head>
<body>
    <header class="alternative-header">
        <a class="alternative-brand" href="index.php" aria-label="Shawarmas, inicio"><img src="assets/img/logo-shawarmas.png?v=20261110-2" alt="Shawarmas" style="transform: scale(1.5);"></a>
        <button class="menu-toggle" type="button" aria-expanded="false" aria-controls="alternative-nav"><i class="bi bi-list"></i><span>Menú</span></button>
        <nav id="alternative-nav" aria-label="Navegación principal"><a href="index.php">Inicio</a><a class="active" href="products.php">Colección</a><a href="index.php#categorias">Categorías</a></nav>
        <div class="alternative-actions">
            <a href="products.php?buscar=" aria-label="Buscar productos"><i class="bi bi-search"></i></a>
            <button class="user-trigger" type="button" aria-expanded="false" aria-label="Abrir perfil"><i class="bi bi-person"></i></button>
            <a class="cart-link" href="cart-summary.php" aria-label="Ver carrito"><i class="bi bi-bag"></i><span><?= $cartCount ?></span></a>
            <div id="perfil" class="user-panel">
                <?php if (!empty($_SESSION['id_user'])): ?>
                    <strong><?= escapar((string) $_SESSION['nombre_completo']) ?></strong>
                    <span><?= escapar((string) $_SESSION['mail']) ?></span>
                    <a href="logout.php">Cerrar sesión</a>
                <?php else: ?>
                    <strong>Tu perfil</strong>
                    <span>Inicia sesión para ver tus datos y comprar.</span>
                    <a href="login.php">Iniciar sesión</a>
                    <a href="register.php">Crear cuenta</a>
                <?php endif; ?>
            </div>
        </div>
    </header>

    <main class="contenedor-principal">
        <aside class="filtro-lateral">
            <div class="filtro-titulo"><button class="filtro-toggle" type="button" aria-expanded="true"><i class="bi bi-sliders"></i><span>Filtros</span></button><h2>Filtrar productos</h2><button class="filtro-cerrar" type="button" aria-label="Ocultar filtros"><i class="bi bi-chevron-up"></i></button></div>
            <form method="get">
                <label for="buscar">Buscar</label>
                <input id="buscar" name="buscar" value="<?= escapar($busqueda) ?>" maxlength="100">
                <label for="categoria">Categoría</label>
                <select id="categoria" name="categoria">
                    <option value="">Todas</option>
                    <?php foreach ($categorias as $item): ?>
                        <option value="<?= (int) $item['id_categoria'] ?>" <?= $categoria === (int) $item['id_categoria'] ? 'selected' : '' ?>>
                            <?= escapar((string) $item['categoria']) ?>
                        </option>
                    <?php endforeach; ?>
                </select>
                <label for="marca">Marca</label>
                <select id="marca" name="marca">
                    <option value="">Todas</option>
                    <?php foreach ($marcas as $item): ?>
                        <option value="<?= escapar((string) $item['marca']) ?>" <?= $marca === (string) $item['marca'] ? 'selected' : '' ?>><?= escapar((string) $item['marca']) ?></option>
                    <?php endforeach; ?>
                </select>
                <label for="color">Color</label>
                <select id="color" name="color">
                    <option value="">Todos</option>
                    <?php foreach ($colores as $item): ?>
                        <option value="<?= (int) $item['id_color'] ?>" <?= $colorId === (int) $item['id_color'] ? 'selected' : '' ?>><?= escapar((string) $item['color']) ?></option>
                    <?php endforeach; ?>
                </select>
                <label for="maximo">Precio máximo</label>
                <input id="maximo" name="maximo" type="number" min="0" step="0.01" value="<?= $maximo !== false && $maximo !== null ? escapar((string) $maximo) : '' ?>">
                <button type="submit">Aplicar filtros</button>
                <a class="filtros-reset" href="products.php">Restablecer filtros</a>
            </form>
        </aside>

        <section class="productos-container">
            <a class="page-return" href="index.php"><i class="bi bi-arrow-left"></i> Volver al inicio</a>
            <div class="catalogo-barra"><div><p class="eyebrow">TIENDA SHAWARMAS</p><h1>Productos</h1></div></div>
            <?php if (!$productos): ?>
                <p>No hay productos que coincidan con los filtros.</p>
            <?php else: ?>
                <section class="grilla-productos">
                    <?php foreach ($productos as $producto): ?>
                        <?php $colorTarjeta = (int) ($producto['id_color'] ?? 0); ?>
                        <article class="tarjeta-producto <?= (int) $producto['stock'] < 1 ? 'is-sold-out' : '' ?>" data-detail-url="product.php?id=<?= (int) $producto['id_producto'] ?><?= $colorTarjeta ? '&color=' . $colorTarjeta : '' ?>&return=<?= rawurlencode($urlColeccionFiltrada) ?>" tabindex="0">
                            <div class="catalog-image">
                                <?php if ((int) $producto['stock'] < 1): ?><span class="diagonal-ribbon">FUERA DE STOCK</span><?php endif; ?>
                                <img src="<?= escapar(imagen_url($producto['imagen'])) ?>" alt="<?= escapar($producto['marca'] . ' ' . $producto['modelo'] . ($producto['color'] ? ', ' . $producto['color'] : '')) ?>" loading="lazy">
                            </div>
                            <div class="contenido">
                                <h3><?= escapar($producto['marca'] . ' ' . $producto['modelo']) ?></h3>
                                <?php if ($producto['color']): ?><small class="product-card-color">Color: <?= escapar((string) $producto['color']) ?></small><?php endif; ?>
                                <p><?= number_format((float) $producto['precio'], 2, ',', '.') ?> €</p>
                                <?php if ((int) $producto['stock'] < 1): ?><small class="sold-out-label">Fuera de stock</small><?php endif; ?>
                            </div>
                        </article>
                    <?php endforeach; ?>
                </section>
            <?php endif; ?>
        </section>
    </main>
    <script>
        const menuToggle = document.querySelector('.menu-toggle');
        const siteNav = document.querySelector('#alternative-nav');
        menuToggle?.addEventListener('click', () => {
            const open = siteNav.classList.toggle('is-open');
            menuToggle.setAttribute('aria-expanded', String(open));
        });
        const filterPanel = document.querySelector('.filtro-lateral');
        const filterToggle = document.querySelector('.filtro-toggle');
        const filterClose = document.querySelector('.filtro-cerrar');
        const setFilters = (hidden) => {
            filterPanel.classList.toggle('is-hidden', hidden);
            filterToggle.setAttribute('aria-expanded', String(!hidden));
            filterToggle.querySelector('i').className = hidden ? 'bi bi-chevron-down' : 'bi bi-sliders';
        };
        filterToggle.addEventListener('click', () => setFilters(!filterPanel.classList.contains('is-hidden')));
        filterClose.addEventListener('click', () => setFilters(true));
        document.querySelectorAll('.tarjeta-producto').forEach(card => {
            card.addEventListener('click', () => { window.location.href = card.dataset.detailUrl; });
            card.addEventListener('keydown', event => {
                if (event.key === 'Enter' || event.key === ' ') {
                    event.preventDefault();
                    window.location.href = card.dataset.detailUrl;
                }
            });
        });
        const profileButton = document.querySelector('.user-trigger');
        const profilePanel = document.querySelector('.user-panel');
        profileButton.addEventListener('click', () => {
            const open = profilePanel.classList.toggle('open');
            profileButton.setAttribute('aria-expanded', open);
        });
        document.addEventListener('click', event => {
            if (!profilePanel.contains(event.target) && !profileButton.contains(event.target)) profilePanel.classList.remove('open');
        });
    </script>
</body>
</html>
