<?php
declare(strict_types=1);
session_start();
require_once __DIR__ . '/database-connection.php';

if (empty($_SESSION['id_user'])) {
    header('Location: login.php');
    exit;
}

$envio = $_SESSION['envio'] ?? null;
if (!is_array($envio)) {
    header('Location: checkout.php');
    exit;
}

$carrito = $_SESSION['carrito'] ?? [];
$cartCount = 0;
$productosDetalle = [];
$total = 0.0;
foreach ($carrito as $idProducto => $tallasProducto) {
    if (!is_array($tallasProducto)) {
        continue;
    }
    foreach ($tallasProducto as $idVariante => $cantidad) {
        $cartCount += max(0, (int) $cantidad);
        $idProducto = (int) $idProducto;
        $idVariante = (int) $idVariante;
        $stmt = $conn->prepare('SELECT p.id_producto, p.marca, p.modelo, p.precio, p.imagen, v.stock, v.id_variante, t.talla, co.color
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

if (!$productosDetalle) {
    header('Location: cart-summary.php');
    exit;
}

$mensaje = '';
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
            $conn->begin_transaction();
            $tienda = 1;
            $userId = (int) $_SESSION['id_user'];
            $pais = (string) $envio['pais'];
            $ciudad = (string) $envio['ciudad'];
            $calle = (string) $envio['calle'];
            $postal = (string) $envio['postal'];
            $stmtPedido = $conn->prepare('INSERT INTO pedidos (fecha_entrega, pais, ciudad, calle, postal, fk_id_user, fk_tienda) VALUES (DATE_ADD(NOW(), INTERVAL 3 DAY), ?, ?, ?, ?, ?, ?)');
            $stmtPedido->bind_param('ssssii', $pais, $ciudad, $calle, $postal, $userId, $tienda);
            $stmtPedido->execute();
            $idPedido = $conn->insert_id;
            $stmtLinea = $conn->prepare('INSERT INTO productos_pedidos (fk_variante, fk_pedido, cantidad) VALUES (?, ?, ?)');
            $stmtStock = $conn->prepare('UPDATE producto_variantes SET stock = stock - ? WHERE id_variante = ? AND stock >= ?');
            foreach ($productosDetalle as $producto) {
                $cantidad = (int) $producto['cantidad'];
                $idVariante = (int) $producto['id_variante'];
                $stmtStock->bind_param('iii', $cantidad, $idVariante, $cantidad);
                $stmtStock->execute();
                if ($stmtStock->affected_rows !== 1) {
                    throw new RuntimeException('Stock no disponible.');
                }
                $stmtLinea->bind_param('iii', $idVariante, $idPedido, $cantidad);
                $stmtLinea->execute();
            }
            $conn->commit();
            unset($_SESSION['carrito'], $_SESSION['envio']);
            header('Location: cart-summary.php?pedido=ok');
            exit;
        } catch (mysqli_sql_exception|RuntimeException) {
            $conn->rollback();
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
        <div class="alternative-actions"><a href="products.php?buscar=" aria-label="Buscar productos"><i class="bi bi-search"></i></a><button class="user-trigger" type="button" aria-expanded="false" aria-controls="perfil" aria-label="Abrir perfil"><i class="bi bi-person"></i></button><a class="cart-link" href="cart-summary.php" aria-label="Ver carrito"><i class="bi bi-bag"></i><span><?= $cartCount ?></span></a><div id="perfil" class="user-panel"><strong><?= escapar((string) $_SESSION['nombre_completo']) ?></strong><span><?= escapar((string) $_SESSION['mail']) ?></span><a href="logout.php">Cerrar sesión</a></div></div>
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
                    <img src="<?= escapar((string) $producto['imagen']) ?>" alt="<?= escapar($producto['marca'] . ' ' . $producto['modelo']) ?>">
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
