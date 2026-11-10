<?php
session_start();
require_once __DIR__ . '/database-connection.php';
$carrito = $_SESSION['carrito'] ?? [];
$cartCount = 0;
foreach ($carrito as $sizes) {
    foreach ((array) $sizes as $quantity) {
        $cartCount += max(0, (int) $quantity);
    }
}
$productos = [];
if ($carrito) {
    $ids = array_map('intval', array_keys($carrito));
    $placeholders = implode(',', array_fill(0, count($ids), '?'));
    $types = str_repeat('i', count($ids));
    $stmt = $conn->prepare("SELECT p.id_producto, p.marca, p.modelo, p.precio, p.imagen, v.imagen AS variante_imagen,
        v.id_variante, v.stock, t.talla, co.color
        FROM productos p
        INNER JOIN producto_variantes v ON v.fk_producto = p.id_producto
        INNER JOIN tallas t ON t.id_talla = v.fk_talla
        INNER JOIN colores co ON co.id_color = v.fk_color
        WHERE p.id_producto IN ($placeholders)");
    $stmt->bind_param($types, ...$ids);
    $stmt->execute();
    foreach ($stmt->get_result()->fetch_all(MYSQLI_ASSOC) as $producto) {
        $productos[(int) $producto['id_producto']][(int) $producto['id_variante']] = $producto;
    }
    $stmt->close();
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Carrito</title>
    <link rel="icon" href="assets/img/favicon/favicon.ico?v=20261110-1" type="image/x-icon">
    <link rel="stylesheet" href="alternative.css?v=20261110-1">
    <link rel="stylesheet" href="cart-summary.css?v=20261110-1">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
</head>
<body>
    <header class="alternative-header">
        <a class="alternative-brand" href="index.php" aria-label="Shawarmas, inicio"><img src="assets/img/logo.png?v=20261110-2" alt="Shawarmas" style="transform: scale(1.5);"></a>
        <button class="menu-toggle" type="button" aria-expanded="false" aria-controls="alternative-nav"><i class="bi bi-list"></i><span>Menú</span></button>
        <nav id="alternative-nav" aria-label="Navegación principal"><a href="index.php">Inicio</a><a href="products.php">Colección</a><a href="index.php#categorias">Categorías</a></nav>
        <div class="alternative-actions"><a href="products.php?buscar=" aria-label="Buscar productos"><i class="bi bi-search"></i></a><button class="user-trigger" type="button" aria-expanded="false" aria-controls="perfil" aria-label="Abrir perfil"><i class="bi bi-person"></i></button><a class="cart-link" href="cart-summary.php" aria-label="Ver carrito"><i class="bi bi-bag"></i><span><?= $cartCount ?></span></a><div id="perfil" class="user-panel"><?php if (!empty($_SESSION['id_user'])): ?><strong><?= escapar((string) $_SESSION['nombre_completo']) ?></strong><span><?= escapar((string) $_SESSION['mail']) ?></span><a href="logout.php">Cerrar sesión</a><?php else: ?><strong>Tu perfil</strong><span>Inicia sesión para ver tus datos y comprar.</span><a class="profile-login-button" href="login.php">Iniciar sesión</a><a href="register.php">Crear cuenta</a><?php endif; ?></div></div>
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
                <a href="checkout.php" class="boton-compra">Continuar con el pedido</a>
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
