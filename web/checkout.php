<?php
declare(strict_types=1);
session_start();
require_once __DIR__ . '/database-connection.php';

if (empty($_SESSION['id_user'])) {
    header('Location: index.php');
    exit;
}

$carrito = $_SESSION['carrito'] ?? [];
$cartCount = 0;
foreach ($carrito as $sizes) {
    foreach ((array) $sizes as $quantity) {
        $cartCount += max(0, (int) $quantity);
    }
}
$mensaje = '';
$productosDetalle = [];
$total = 0.0;

foreach ($carrito as $idProducto => $tallasProducto) {
    if (!is_array($tallasProducto)) {
        continue;
    }
    foreach ($tallasProducto as $idVariante => $cantidad) {
        $idProducto = (int) $idProducto;
        $idVariante = (int) $idVariante;
        $stmt = $conn->prepare('SELECT p.id_producto, p.marca, p.modelo, p.precio, p.imagen, v.imagen AS variante_imagen, v.stock, v.id_variante, t.talla, co.color
            FROM productos p
            INNER JOIN producto_variantes v ON v.fk_producto = p.id_producto
            INNER JOIN tallas t ON t.id_talla = v.fk_talla
            INNER JOIN colores co ON co.id_color = v.fk_color
            WHERE v.id_variante = ? AND p.id_producto = ?');
        $stmt->bind_param('ii', $idVariante, $idProducto);
        $stmt->execute();
        $producto = $stmt->get_result()->fetch_assoc();
        $stmt->close();
        if (!$producto || (int) $cantidad < 1 || (int) $cantidad > (int) $producto['stock']) {
            continue;
        }
        $producto['id_variante'] = $idVariante;
        $producto['cantidad'] = (int) $cantidad;
        $producto['subtotal'] = (float) $cantidad * (float) $producto['precio'];
        $total += $producto['subtotal'];
        $productosDetalle[] = $producto;
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && $productosDetalle) {
    validar_csrf();
    $pais = trim((string) ($_POST['pais'] ?? ''));
    $ciudad = trim((string) ($_POST['ciudad'] ?? ''));
    $calle = trim((string) ($_POST['calle'] ?? ''));
    $postal = trim((string) ($_POST['postal'] ?? ''));

    if ($pais === '' || $ciudad === '' || $calle === '' || $postal === '') {
        $mensaje = 'Completa todos los datos de envío.';
    } elseif (preg_match('/^\d{1,5}$/', $postal) !== 1) {
        $mensaje = 'El código postal debe contener solo números y un máximo de 5 dígitos.';
    } else {
        $_SESSION['envio'] = compact('pais', 'ciudad', 'calle', 'postal');
        header('Location: payment.php');
        exit;
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dirección de envío</title>
    <link rel="icon" href="assets/img/favicon/favicon.ico?v=20261110-1" type="image/x-icon">
    <link rel="stylesheet" href="alternative.css?v=20261110-1">
    <link rel="stylesheet" href="checkout.css?v=20261110-2">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
</head>
<body>
    <header class="alternative-header">
        <a class="alternative-brand" href="index.php" aria-label="Shawarmas, inicio"><img src="assets/img/logo-shawarmas.png?v=20261110-2" alt="Shawarmas"></a>
        <button class="menu-toggle" type="button" aria-expanded="false" aria-controls="alternative-nav"><i class="bi bi-list"></i><span>Menú</span></button>
        <nav id="alternative-nav" aria-label="Navegación principal"><a href="index.php">Inicio</a><a href="products.php">Colección</a><a href="index.php#categorias">Categorías</a></nav>
        <div class="alternative-actions"><a href="products.php?buscar=" aria-label="Buscar productos"><i class="bi bi-search"></i></a><button class="user-trigger" type="button" aria-expanded="false" aria-controls="perfil" aria-label="Abrir perfil"><i class="bi bi-person"></i></button><a class="cart-link" href="cart-summary.php" aria-label="Ver carrito"><i class="bi bi-bag"></i><span><?= $cartCount ?></span></a><div id="perfil" class="user-panel"><?php if (!empty($_SESSION['id_user'])): ?><strong><?= escapar((string) $_SESSION['nombre_completo']) ?></strong><span><?= escapar((string) $_SESSION['mail']) ?></span><a href="logout.php">Cerrar sesión</a><?php else: ?><strong>Tu perfil</strong><span>Inicia sesión para ver tus datos y comprar.</span><a class="profile-login-button" href="login.php">Iniciar sesión</a><a href="register.php">Crear cuenta</a><?php endif; ?></div></div>
    </header>
    <main class="contenedor">
        <section class="panel-izquierdo">
            <a class="page-return" href="cart-summary.php"><i class="bi bi-arrow-left"></i> Volver al carrito</a>
            <h1>Datos de envío</h1>
            <form method="post">
                <input type="hidden" name="token_csrf" value="<?php echo escapar(token_csrf()); ?>">
                <label for="pais">País</label>
                <input id="pais" name="pais" required>
                <label for="ciudad">Ciudad</label>
                <input id="ciudad" name="ciudad" required>
                <label for="calle">Dirección</label>
                <input id="calle" name="calle" required>
                <label for="postal">Código postal</label>
                <input id="postal" name="postal" type="text" inputmode="numeric" pattern="[0-9]{1,5}" maxlength="5" required>
                <button type="submit" class="btn-compra">Continuar al pago <i class="bi bi-arrow-right"></i></button>
            </form>
            <p class="total"><strong>Total: <?php echo number_format($total, 2, ',', '.'); ?> €</strong></p>
            <?php if ($mensaje !== ''): ?>
                <p class="mensaje"><?php echo escapar($mensaje); ?></p>
            <?php endif; ?>
        </section>
        <section class="panel-derecho">
            <h2>Productos</h2>
            <?php if ($productosDetalle): ?>
                <?php foreach ($productosDetalle as $producto): ?>
                    <article class="etiqueta-producto">
                        <img src="<?php echo escapar(imagen_url($producto['variante_imagen'] ?: $producto['imagen'])); ?>" alt="<?php echo escapar($producto['marca'] . ' ' . $producto['modelo']); ?>">
                        <div>
                            <strong><?php echo escapar($producto['marca'] . ' ' . $producto['modelo']); ?></strong>
                            <p>Talla: <?php echo escapar((string) $producto['talla']); ?></p>
                            <p>Color: <?php echo escapar((string) $producto['color']); ?></p>
                            <p>Cantidad: <?php echo $producto['cantidad']; ?></p>
                            <p>Subtotal: <?php echo number_format($producto['subtotal'], 2, ',', '.'); ?> €</p>
                        </div>
                    </article>
                <?php endforeach; ?>
            <?php else: ?>
                <p>Tu carrito está vacío.</p>
            <?php endif; ?>
        </section>
    </main>
    <script>
        const soloDigitos = value => value.replace(/\D/g, '');
        document.getElementById('postal').addEventListener('input', event => {
            event.target.value = soloDigitos(event.target.value).slice(0, 5);
        });
    </script>
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
