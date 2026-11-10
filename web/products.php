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
$busqueda = trim((string) ($_GET['buscar'] ?? ''));
$filtrosActivos = [];
if ($busqueda !== '') {
    $filtrosActivos['buscar'] = $busqueda;
}
if ($categoria) {
    $filtrosActivos['categoria'] = $categoria;
}
if ($maximo !== false && $maximo !== null) {
    $filtrosActivos['maximo'] = $maximo;
}
$urlColeccionFiltrada = 'products.php' . ($filtrosActivos ? '?' . http_build_query($filtrosActivos) : '');

$sql = 'SELECT p.id_producto, p.marca, p.modelo, p.precio, COALESCE(SUM(v.stock), 0) AS stock, p.imagen, c.categoria
        FROM productos p
        INNER JOIN categorias c ON c.id_categoria = p.fk_categoria
        LEFT JOIN producto_variantes v ON v.fk_producto = p.id_producto
        WHERE 1 = 1';
$types = '';
$params = [];
if ($categoria) {
    $sql .= ' AND p.fk_categoria = ?';
    $types .= 'i';
    $params[] = $categoria;
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
$sql .= ' GROUP BY p.id_producto, p.marca, p.modelo, p.precio, p.imagen, c.categoria ORDER BY p.id_producto';

$stmt = $conn->prepare($sql);
if ($types !== '') {
    $stmt->bind_param($types, ...$params);
}
$stmt->execute();
$productos = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
$stmt->close();

$categorias = $conn->query('SELECT id_categoria, categoria FROM categorias ORDER BY categoria')->fetch_all(MYSQLI_ASSOC);
$variantes = $conn->query('SELECT v.id_variante, v.fk_producto, v.stock, t.talla, co.color
    FROM producto_variantes v
    INNER JOIN tallas t ON t.id_talla = v.fk_talla
    INNER JOIN colores co ON co.id_color = v.fk_color
    ORDER BY v.fk_producto, t.id_talla')->fetch_all(MYSQLI_ASSOC);
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
    <link rel="stylesheet" href="products.css?v=20261110-1">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
</head>
<body>
    <header class="alternative-header">
        <a class="alternative-brand" href="index.php" aria-label="Shawarmas, inicio"><img src="assets/img/logo-shawarmas.png?v=20261110-2" alt="Shawarmas"></a>
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
                        <article class="tarjeta-producto <?= (int) $producto['stock'] < 1 ? 'is-sold-out' : '' ?>" data-detail-url="product.php?id=<?= (int) $producto['id_producto'] ?>&return=<?= rawurlencode($urlColeccionFiltrada) ?>" tabindex="0">
                            <div class="catalog-image">
                                <?php if ((int) $producto['stock'] < 1): ?><span class="diagonal-ribbon">FUERA DE STOCK</span><?php endif; ?>
                                <img src="<?= escapar((string) $producto['imagen']) ?>" alt="<?= escapar($producto['marca'] . ' ' . $producto['modelo']) ?>" loading="lazy">
                            </div>
                            <div class="contenido">
                                <h3><?= escapar($producto['marca'] . ' ' . $producto['modelo']) ?></h3>
                                <p><?= number_format((float) $producto['precio'], 2, ',', '.') ?> €</p>
                                <?php if ((int) $producto['stock'] < 1): ?><small class="sold-out-label">Fuera de stock</small><?php endif; ?>
                                <form class="producto-carrito-form" action="add-to-cart.php" method="post">
                                    <input type="hidden" name="token_csrf" value="<?= escapar(token_csrf()) ?>">
                                    <input type="hidden" name="id_producto" value="<?= (int) $producto['id_producto'] ?>">
                                    <label for="talla-<?= (int) $producto['id_producto'] ?>">Talla</label>
                                    <select id="talla-<?= (int) $producto['id_producto'] ?>" name="id_variante" required>
                                        <option value="">Selecciona una talla</option>
                                        <?php foreach ($variantes as $variante): ?>
                                            <?php if ((int) $variante['fk_producto'] !== (int) $producto['id_producto']) { continue; } ?>
                                            <option value="<?= (int) $variante['id_variante'] ?>" <?= (int) $variante['stock'] < 1 ? 'disabled' : '' ?>>
                                                <?= escapar((string) $variante['talla']) ?> · <?= escapar((string) $variante['color']) ?><?= (int) $variante['stock'] < 1 ? ' — Agotada' : '' ?>
                                            </option>
                                        <?php endforeach; ?>
                                    </select>
                                    <input type="hidden" name="cantidad" value="1">
                                    <button type="button" class="carrito-icono" aria-label="Elegir talla y añadir al carrito" title="Elegir talla y añadir al carrito" <?= (int) $producto['stock'] < 1 ? 'disabled' : '' ?>><i class="bi bi-bag-plus"></i></button>
                                </form>
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
            const form = card.querySelector('.producto-carrito-form');
            const button = card.querySelector('.carrito-icono');
            const openDetail = event => {
                if (!event.target.closest('button, select, option, form')) {
                    window.location.href = card.dataset.detailUrl;
                }
            };
            card.addEventListener('click', openDetail);
            card.addEventListener('keydown', event => {
                if (event.key === 'Enter' || event.key === ' ') {
                    event.preventDefault();
                    openDetail(event);
                }
            });
            button.addEventListener('click', event => {
                event.stopPropagation();
                if (form.classList.contains('is-open')) {
                    form.requestSubmit();
                    return;
                }
                form.classList.add('is-open');
                form.querySelector('select').focus();
            });
            form.addEventListener('click', event => event.stopPropagation());
            form.addEventListener('submit', event => {
                if (!form.querySelector('select').value) {
                    event.preventDefault();
                    form.querySelector('select').focus();
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
