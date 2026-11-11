<?php
declare(strict_types=1);

require_once __DIR__ . '/api-client.php';
start_store_session();

$productos = api_try('GET', '/products?pageSize=4&sort=newest', null, false);
$categorias = api_try('GET', '/categories', null, false);
$productos = isset($productos['_error']) ? [] : $productos;
$categorias = isset($categorias['_error']) ? [] : $categorias;
$heroCandidates = api_try('GET', '/products?pageSize=50&sort=newest', null, false);
$heroProducto = !isset($heroCandidates['_error']) && $heroCandidates ? $heroCandidates[array_rand($heroCandidates)] : null;

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
    <title>Shawarmas</title>
    <link rel="icon" href="<?= escapar(imagen_url('/brand/favicon.ico')) ?>" type="image/x-icon">
    <link rel="stylesheet" href="alternative.css?v=20261110-4">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
</head>
<body>
    <header class="alternative-header">
        <a class="alternative-brand" href="index.php" aria-label="Shawarmas, inicio">
            <img src="<?= escapar(imagen_url('/brand/logo.png')) ?>" alt="Shawarmas">
        </a>
        <button class="menu-toggle" type="button" aria-expanded="false" aria-controls="alternative-nav">
            <i class="bi bi-list"></i><span>Menú</span>
        </button>
        <nav id="alternative-nav" aria-label="Navegación principal">
            <a class="active" href="index.php">Inicio</a>
            <a href="products.php">Colección</a>
            <a href="#categorias">Categorías</a>
        </nav>
        <div class="alternative-actions">
            <a href="products.php?buscar=" aria-label="Buscar productos"><i class="bi bi-search"></i></a>
            <button class="user-trigger" type="button" aria-expanded="false" aria-controls="perfil" aria-label="Abrir perfil"><i class="bi bi-person"></i></button>
            <a class="cart-link" href="cart-summary.php" aria-label="Ver carrito">
                <i class="bi bi-bag"></i><span><?= $cartCount ?></span>
            </a>
            <div id="perfil" class="user-panel">
                <?php if (!empty($_SESSION['id_user'])): ?>
                    <strong><?= escapar((string) $_SESSION['nombre_completo']) ?></strong>
                    <span><?= escapar((string) $_SESSION['mail']) ?></span>
                    <a href="account.php">Cuenta</a><a href="logout.php">Cerrar sesión</a>
                <?php else: ?>
                    <strong>Tu perfil</strong>
                    <span>Inicia sesión para ver tus datos y comprar.</span>
                    <a class="profile-login-button" href="login.php">Iniciar sesión</a>
                    <a href="register.php">Crear cuenta</a>
                <?php endif; ?>
            </div>
        </div>
    </header>

    <main>
        <section class="alternative-hero">
            <div class="hero-copy">
                <p class="kicker">NUEVA COLECCIÓN / 2026</p>
                <h1>Viste<br><em>lo que eres.</em></h1>
                <p class="hero-description">Piezas esenciales, zapatillas icónicas y una selección hecha para moverte a tu manera.</p>
                <a class="solid-button" href="products.php">Explorar colección <i class="bi bi-arrow-up-right"></i></a>
            </div>
            <div class="hero-art" aria-label="Selección de zapatillas y ropa">
                <span class="hero-index">01 / 04</span>
                <?php if ($heroProducto): ?><img src="<?= escapar(imagen_url($heroProducto['imagen'])) ?>" alt="<?= escapar($heroProducto['marca'] . ' ' . $heroProducto['modelo']) ?>"><?php endif; ?>
                <p>THE EVERYDAY<br><strong>UNIFORM</strong></p>
            </div>
        </section>

        <section class="manifesto">
            <p class="kicker">POR QUÉ SHAWARMAS</p>
            <h2>Menos ruido.<br><em>Más actitud.</em></h2>
            <div class="manifesto-points">
                <article><span>01</span><strong>Selección precisa</strong><p>Solo piezas que merecen un sitio en tu armario.</p></article>
                <article><span>02</span><strong>Compra sin fricción</strong><p>Descubre, elige tu talla y recibe tu pedido rápido.</p></article>
                <article><span>03</span><strong>Hecho para durar</strong><p>Marcas reconocidas y básicos que combinan con todo.</p></article>
            </div>
        </section>

        <section class="collection" id="coleccion">
            <div class="section-topline">
                <div><p class="kicker">SELECCIÓN EDITORIAL</p><h2>Favoritos de la semana</h2></div>
                <a class="underlined-link" href="products.php">Ver todo <i class="bi bi-arrow-up-right"></i></a>
            </div>
            <div class="alternative-products">
                <?php foreach ($productos as $index => $producto): ?>
                    <a class="alternative-product" href="product.php?id=<?= (int) $producto['id_producto'] ?>">
                        <div class="product-visual">
                            <span><?= str_pad((string) ($index + 1), 2, '0', STR_PAD_LEFT) ?></span>
                            <img src="<?= escapar(imagen_url($producto['imagen'])) ?>" alt="<?= escapar($producto['marca'] . ' ' . $producto['modelo']) ?>" loading="lazy">
                            <?php if ((int) $producto['stock'] < 10): ?><small>ÚLTIMAS UNIDADES</small><?php endif; ?>
                        </div>
                        <div class="product-meta">
                            <span><?= escapar((string) $producto['categoria']) ?> / <?= escapar((string) $producto['marca']) ?></span>
                            <strong><?= escapar((string) $producto['modelo']) ?></strong>
                            <b><?= number_format((float) $producto['precio'], 2, ',', '.') ?> €</b>
                        </div>
                    </a>
                <?php endforeach; ?>
            </div>
        </section>

        <section class="category-section" id="categorias">
            <div class="section-topline"><div><p class="kicker">ENCUENTRA TU LÍNEA</p><h2>Categorías</h2></div></div>
            <div class="category-list">
                <?php foreach ($categorias as $index => $categoria): ?>
                    <a href="products.php?categoria=<?= (int) $categoria['id_categoria'] ?>">
                        <span><?= str_pad((string) ($index + 1), 2, '0', STR_PAD_LEFT) ?></span>
                        <strong><?= escapar((string) $categoria['categoria']) ?></strong>
                        <small><?= (int) $categoria['total'] ?> productos</small>
                        <i class="bi bi-arrow-up-right"></i>
                    </a>
                <?php endforeach; ?>
            </div>
        </section>
    </main>

    <footer class="alternative-footer">
        <div><img class="footer-logo" src="<?= escapar(imagen_url('/brand/logo.png')) ?>" alt="Shawarmas"></div>
        <p>Ropa urbana para todos los días.</p>
        <a href="products.php">Ir a la colección <i class="bi bi-arrow-right"></i></a>
    </footer>
    <script>
        const menuToggle = document.querySelector('.menu-toggle');
        const nav = document.querySelector('#alternative-nav');
        menuToggle?.addEventListener('click', () => {
            const open = nav.classList.toggle('is-open');
            menuToggle.setAttribute('aria-expanded', String(open));
        });
        const profileButton = document.querySelector('.user-trigger');
        const profilePanel = document.querySelector('#perfil');
        profileButton?.addEventListener('click', event => {
            event.stopPropagation();
            const open = profilePanel.classList.toggle('open');
            profileButton.setAttribute('aria-expanded', String(open));
        });
        document.addEventListener('click', event => {
            if (profilePanel && !profilePanel.contains(event.target) && !profileButton.contains(event.target)) {
                profilePanel.classList.remove('open');
                profileButton.setAttribute('aria-expanded', 'false');
            }
        });
    </script>
</body>
</html>
