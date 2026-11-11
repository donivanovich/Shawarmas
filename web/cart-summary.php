<?php
require_once __DIR__ . '/api-client.php';
start_store_session();
$carrito = $_SESSION['carrito'] ?? [];
$cartCount = 0;
foreach ($carrito as $sizes) {
    foreach ((array) $sizes as $quantity) {
        $cartCount += max(0, (int) $quantity);
    }
}
$productos = [];
if ($carrito) {
    foreach ($carrito as $productId => $variantsInCart) {
        $product = api_try('GET', '/products/' . (int) $productId, null, false);
        if (isset($product['_error'])) continue;
        foreach ($product['variants'] ?? [] as $variant) {
            $product['id_producto'] = (int) $product['id_producto'];
            $product['variante_imagen'] = $variant['imagen'] ?? null;
            $product['id_variante'] = (int) $variant['id_variante'];
            $product['stock'] = (int) $variant['stock'];
            $product['talla'] = $variant['talla'];
            $product['color'] = $variant['color'];
            if (isset($variantsInCart[$product['id_variante']])) {
                $productos[$product['id_producto']][$product['id_variante']] = $product;
            }
        }
    }
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Carrito</title>
    <link rel="icon" href="<?= escapar(imagen_url('/brand/favicon.ico')) ?>" type="image/x-icon">
    <link rel="stylesheet" href="alternative.css?v=20261110-4">
    <link rel="stylesheet" href="cart-summary.css?v=20261110-1">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
</head>
<body>
    <header class="alternative-header">
        <a class="alternative-brand" href="index.php" aria-label="Shawarmas, inicio"><img src="<?= escapar(imagen_url('/brand/logo.png')) ?>" alt="Shawarmas"></a>
        <button class="menu-toggle" type="button" aria-expanded="false" aria-controls="alternative-nav"><i class="bi bi-list"></i><span>Menú</span></button>
        <nav id="alternative-nav" aria-label="Navegación principal"><a href="index.php">Inicio</a><a href="products.php">Colección</a><a href="index.php#categorias">Categorías</a></nav>
        <div class="alternative-actions"><a href="products.php?buscar=" aria-label="Buscar productos"><i class="bi bi-search"></i></a><button class="user-trigger" type="button" aria-expanded="false" aria-controls="perfil" aria-label="Abrir perfil"><i class="bi bi-person"></i></button><a class="cart-link" href="cart-summary.php" aria-label="Ver carrito"><i class="bi bi-bag"></i><span><?= $cartCount ?></span></a><div id="perfil" class="user-panel"><?php if (!empty($_SESSION['id_user'])): ?><strong><?= escapar((string) $_SESSION['nombre_completo']) ?></strong><span><?= escapar((string) $_SESSION['mail']) ?></span><a href="account.php">Cuenta</a><a href="logout.php">Cerrar sesión</a><?php else: ?><strong>Tu perfil</strong><span>Inicia sesión para ver tus datos y comprar.</span><a class="profile-login-button" href="login.php">Iniciar sesión</a><a href="register.php">Crear cuenta</a><?php endif; ?></div></div>
    </header>
    <main class="carrito-pagina">
        <div class="carrito-cabecera">
            <div>
                <a class="page-return" href="products.php"><i class="bi bi-arrow-left"></i> Volver a productos</a>
                <h1>Tu carrito</h1>
                <p>Revisa tus artículos antes de finalizar la compra.</p>
            </div>
            <a class="enlace-secundario" href="products.php">Seguir comprando <i class="bi bi-arrow-right"></i></a>
        </div>
        <?php if (isset($_GET['pedido']) && $_GET['pedido'] === 'ok'): ?>
            <p class="mensaje-exito"><i class="bi bi-check-circle"></i> Pedido realizado correctamente. Tu carrito está vacío.</p>
        <?php endif; ?>
        <div class="grid-carrito">
        <?php if (!$productos): ?>
            <div class="carrito-vacio">
                <p>Tu carrito está vacío.</p>
                <a class="enlace-secundario" href="products.php">Explorar productos</a>
            </div>
        <?php else: ?>
            <?php foreach ($productos as $id_producto => $tallasProducto): ?>
                <?php foreach ($tallasProducto as $id_variante => $producto): ?>
                        <?php if (!isset($carrito[$id_producto][$id_variante]) || (int) $carrito[$id_producto][$id_variante] < 1) { continue; } ?>
                    <?php $cantidad = min((int) $carrito[$id_producto][$id_variante], (int) $producto['stock']); ?>
                    <div class="producto-card">
                        <img src="<?php echo escapar(imagen_url($producto['variante_imagen'] ?: $producto['imagen'])); ?>" alt="<?php echo escapar($producto['marca'] . ' ' . $producto['modelo']); ?>" loading="lazy">
                        <h3><?php echo escapar($producto['marca'] . ' ' . $producto['modelo']); ?></h3>
                        <p><strong>Precio:</strong> <?php echo number_format((float) $producto['precio'], 2, ',', '.'); ?> €</p>
                        <p><strong>Talla:</strong> <?php echo escapar((string) $producto['talla']); ?></p>
                        <p><strong>Color:</strong> <?php echo escapar((string) $producto['color']); ?></p>
                        <p><strong>Cantidad:</strong> <?php echo $cantidad; ?></p>
                        <form method="POST" action="remove-from-cart.php">
                            <input type="hidden" name="token_csrf" value="<?php echo escapar(token_csrf()); ?>">
                            <input type="hidden" name="id_producto" value="<?php echo $id_producto; ?>">
                            <input type="hidden" name="id_variante" value="<?php echo $id_variante; ?>">
                            <button class="btn-quitar">Quitar</button>
                        </form>
                    </div>
                <?php endforeach; ?>
            <?php endforeach; ?>
        <?php endif; ?>
        </div>
        <?php if ($productos): ?>
            <div class="carrito-acciones">
                <a href="<?= !empty($_SESSION['id_user']) ? 'checkout.php' : 'login.php?redirect=checkout.php' ?>" class="boton-compra">Continuar con el pedido</a>
            </div>
        <?php endif; ?>
    </main>
<script>
    const menuToggle = document.querySelector('.menu-toggle');
    const siteNav = document.querySelector('#alternative-nav');
    menuToggle?.addEventListener('click', () => {
        const open = siteNav.classList.toggle('is-open');
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
