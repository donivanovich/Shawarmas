<?php
declare(strict_types=1);
require_once __DIR__ . '/api-client.php';
start_store_session();

if (empty($_SESSION['id_user'])) {
    header('Location: login.php?redirect=checkout.php');
    exit;
}

$envio = $_SESSION['envio'] ?? null;
if (!is_array($envio)) {
    header('Location: checkout.php');
    exit;
}

$carrito = $_SESSION['carrito'] ?? [];
$cartCount = 0;
$mensaje = '';
$productosDetalle = [];
$cartItems = [];
$total = 0.0;
foreach ($carrito as $idProducto => $tallasProducto) {
    if (!is_array($tallasProducto)) {
        continue;
    }
    foreach ($tallasProducto as $idVariante => $cantidad) {
        $cartCount += max(0, (int) $cantidad);
        $idProducto = (int) $idProducto;
        $idVariante = (int) $idVariante;
        $product = api_try('GET', '/products/' . $idProducto, null, false);
        $producto = null;
        foreach ($product['variants'] ?? [] as $variant) {
            if ((int) $variant['id_variante'] === $idVariante) {
                $producto = array_merge($product, $variant);
                break;
            }
        }
        if (!$producto || (int) $cantidad < 1) {
            continue;
        }
        $producto['id_variante'] = $idVariante;
        $producto['cantidad'] = (int) $cantidad;
        $cartItems[] = ['productId' => $idProducto, 'variantId' => $idVariante, 'quantity' => (int) $cantidad];
        $productosDetalle[] = $producto;
    }
}

if ($cartItems) {
    $quote = api_try('POST', '/cart/quote', ['items' => $cartItems]);
    if (isset($quote['_error'])) {
        $mensaje = $quote['_error'];
    } else {
        $productosDetalle = $quote['items'] ?? [];
        $total = (float) ($quote['total'] ?? 0);
    }
}

if (!$productosDetalle) {
    header('Location: cart-summary.php');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    validar_csrf();
    $tarjeta = preg_replace('/\D/', '', (string) ($_POST['tarjeta'] ?? ''));
    $caducidad = trim((string) ($_POST['caducidad'] ?? ''));
    $cvc = trim((string) ($_POST['cvc'] ?? ''));
    $pagoValido = preg_match('/^\d{16}$/', $tarjeta) === 1
        && preg_match('/^(0[1-9]|1[0-2])\/(\d{2})$/', $caducidad, $partes) === 1
        && preg_match('/^\d{3}$/', $cvc) === 1;
    if ($pagoValido) {
        $mes = (int) $partes[1];
        $ano = 2000 + (int) $partes[2];
        $pagoValido = $ano > (int) date('Y') || ($ano === (int) date('Y') && $mes >= (int) date('n'));
    }

    if (!$pagoValido) {
        $mensaje = 'Revisa la tarjeta, la fecha de caducidad y el CVC.';
    } else {
        try {
            $result = api_request('POST', '/orders', [
                'pais' => (string) $envio['pais'], 'ciudad' => (string) $envio['ciudad'],
                'calle' => (string) $envio['calle'], 'postal' => (string) $envio['postal'], 'items' => $cartItems
            ]);
            unset($_SESSION['carrito'], $_SESSION['envio']);
            $_SESSION['last_order_id'] = (int) ($result['id_pedido'] ?? 0);
            header('Location: cart-summary.php?pedido=ok');
            exit;
        } catch (ApiClientException) {
            $mensaje = 'No se pudo completar el pedido. Comprueba el stock e inténtalo de nuevo.';
        }
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Pago</title>
    <link rel="icon" href="<?= escapar(imagen_url('/brand/favicon.ico')) ?>" type="image/x-icon">
    <link rel="stylesheet" href="alternative.css?v=20261110-4">
    <link rel="stylesheet" href="checkout.css?v=20261110-2">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
</head>
<body>
    <header class="alternative-header">
        <a class="alternative-brand" href="index.php" aria-label="Shawarmas, inicio"><img src="<?= escapar(imagen_url('/brand/logo.png')) ?>" alt="Shawarmas"></a>
        <button class="menu-toggle" type="button" aria-expanded="false" aria-controls="alternative-nav"><i class="bi bi-list"></i><span>Menú</span></button>
        <nav id="alternative-nav" aria-label="Navegación principal"><a href="index.php">Inicio</a><a href="products.php">Colección</a><a href="index.php#categorias">Categorías</a></nav>
        <div class="alternative-actions"><a href="products.php?buscar=" aria-label="Buscar productos"><i class="bi bi-search"></i></a><button class="user-trigger" type="button" aria-expanded="false" aria-controls="perfil" aria-label="Abrir perfil"><i class="bi bi-person"></i></button><a class="cart-link" href="cart-summary.php" aria-label="Ver carrito"><i class="bi bi-bag"></i><span><?= $cartCount ?></span></a><div id="perfil" class="user-panel"><strong><?= escapar((string) $_SESSION['nombre_completo']) ?></strong><span><?= escapar((string) $_SESSION['mail']) ?></span><a href="account.php">Cuenta</a><a href="logout.php">Cerrar sesión</a></div></div>
    </header>
    <main class="contenedor">
        <section class="panel-izquierdo">
            <a class="page-return" href="checkout.php"><i class="bi bi-arrow-left"></i> Volver a datos de envío</a>
            <h1>Pago</h1>
            <p class="ayuda-pago">Introduce los datos de tu tarjeta. No se almacenan.</p>
            <?php if ($mensaje !== ''): ?><p class="mensaje"><?= escapar($mensaje) ?></p><?php endif; ?>
            <form method="post">
                <input type="hidden" name="token_csrf" value="<?= escapar(token_csrf()) ?>">
                <label for="tarjeta">Número de tarjeta</label>
                <input id="tarjeta" name="tarjeta" inputmode="numeric" autocomplete="cc-number" pattern="[0-9 ]{19}" maxlength="19" required>
                <div class="pago-fila">
                    <div><label for="caducidad">Caducidad (MM/AA)</label><input id="caducidad" name="caducidad" inputmode="numeric" placeholder="MM/AA" pattern="(0[1-9]|1[0-2])\/\d{2}" maxlength="5" required></div>
                    <div><label for="cvc">CVC</label><input id="cvc" name="cvc" inputmode="numeric" pattern="\d{3}" maxlength="3" required></div>
                </div>
                <button type="submit" class="btn-compra">Realizar pedido <i class="bi bi-check2"></i></button>
            </form>
        </section>
        <section class="panel-derecho">
            <h2>Productos</h2>
            <?php foreach ($productosDetalle as $producto): ?>
                <article class="etiqueta-producto">
                    <img src="<?= escapar(imagen_url($producto['variante_imagen'] ?: $producto['imagen'])) ?>" alt="<?= escapar($producto['marca'] . ' ' . $producto['modelo']) ?>">
                    <div><strong><?= escapar($producto['marca'] . ' ' . $producto['modelo']) ?></strong><p>Talla: <?= escapar((string) $producto['talla']) ?></p><p>Color: <?= escapar((string) $producto['color']) ?></p><p>Cantidad: <?= $producto['cantidad'] ?></p><p>Subtotal: <?= number_format($producto['subtotal'], 2, ',', '.') ?> €</p></div>
                </article>
            <?php endforeach; ?>
            <p class="total"><strong>Total: <?= number_format($total, 2, ',', '.') ?> €</strong></p>
        </section>
    </main>
    <script>
        const soloDigitos = value => value.replace(/\D/g, '');
        document.getElementById('tarjeta').addEventListener('input', event => {
            const digitos = soloDigitos(event.target.value).slice(0, 16);
            event.target.value = digitos.replace(/(.{4})/g, '$1 ').trim();
        });
        document.getElementById('caducidad').addEventListener('input', event => {
            const digitos = soloDigitos(event.target.value).slice(0, 4);
            event.target.value = digitos.length > 2 ? digitos.slice(0, 2) + '/' + digitos.slice(2) : digitos;
        });
        document.getElementById('cvc').addEventListener('input', event => {
            event.target.value = soloDigitos(event.target.value).slice(0, 3);
        });
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
