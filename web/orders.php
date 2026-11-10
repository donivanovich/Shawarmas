<?php
declare(strict_types=1);
session_start();
require_once __DIR__ . '/database-connection.php';

if (empty($_SESSION['id_user'])) {
    header('Location: login.php?redirect=orders.php');
    exit;
}

$userId = (int) $_SESSION['id_user'];
$cartCount = 0;
foreach ($_SESSION['carrito'] ?? [] as $sizes) {
    foreach ((array) $sizes as $quantity) {
        $cartCount += max(0, (int) $quantity);
    }
}

$stmt = $conn->prepare('SELECT p.id_pedido, p.fecha_pedido, p.fecha_entrega, p.entregado, p.pais, p.ciudad, p.calle, p.postal,
        COALESCE(SUM(pr.precio * pp.cantidad), 0) AS total, COALESCE(SUM(pp.cantidad), 0) AS unidades
    FROM pedidos p
    LEFT JOIN productos_pedidos pp ON pp.fk_pedido = p.id_pedido
    LEFT JOIN producto_variantes v ON v.id_variante = pp.fk_variante
    LEFT JOIN productos pr ON pr.id_producto = v.fk_producto
    WHERE p.fk_id_user = ?
    GROUP BY p.id_pedido, p.fecha_pedido, p.fecha_entrega, p.entregado, p.pais, p.ciudad, p.calle, p.postal
    ORDER BY p.fecha_pedido DESC');
$stmt->bind_param('i', $userId);
$stmt->execute();
$pedidos = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
$stmt->close();

$lineasPorPedido = [];
if ($pedidos) {
    $stmtLineas = $conn->prepare('SELECT pp.fk_pedido, pr.marca, pr.modelo, pr.precio, pp.cantidad,
            COALESCE(v.imagen, pr.imagen) AS imagen, t.talla, co.color
        FROM productos_pedidos pp
        INNER JOIN producto_variantes v ON v.id_variante = pp.fk_variante
        INNER JOIN productos pr ON pr.id_producto = v.fk_producto
        INNER JOIN tallas t ON t.id_talla = v.fk_talla
        INNER JOIN colores co ON co.id_color = v.fk_color
        INNER JOIN pedidos p ON p.id_pedido = pp.fk_pedido
        WHERE p.fk_id_user = ?
        ORDER BY pp.fk_pedido DESC, pr.marca, pr.modelo');
    $stmtLineas->bind_param('i', $userId);
    $stmtLineas->execute();
    foreach ($stmtLineas->get_result()->fetch_all(MYSQLI_ASSOC) as $linea) {
        $lineasPorPedido[(int) $linea['fk_pedido']][] = $linea;
    }
    $stmtLineas->close();
}
$conn->close();
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Tus pedidos | Shawarmas</title>
    <link rel="icon" href="<?= escapar(imagen_url('/brand/favicon.ico')) ?>" type="image/x-icon">
    <link rel="stylesheet" href="alternative.css?v=20261110-4">
    <link rel="stylesheet" href="orders.css?v=20261110-2">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
</head>
<body>
    <header class="alternative-header">
        <a class="alternative-brand" href="index.php" aria-label="Shawarmas, inicio"><img src="<?= escapar(imagen_url('/brand/logo.png')) ?>" alt="Shawarmas"></a>
        <button class="menu-toggle" type="button" aria-expanded="false" aria-controls="alternative-nav"><i class="bi bi-list"></i><span>Menú</span></button>
        <nav id="alternative-nav" aria-label="Navegación principal"><a href="index.php">Inicio</a><a href="products.php">Colección</a><a href="index.php#categorias">Categorías</a></nav>
        <div class="alternative-actions">
            <a href="products.php?buscar=" aria-label="Buscar productos"><i class="bi bi-search"></i></a>
            <button class="user-trigger" type="button" aria-expanded="false" aria-controls="perfil" aria-label="Abrir perfil"><i class="bi bi-person"></i></button>
            <a class="cart-link" href="cart-summary.php" aria-label="Ver carrito"><i class="bi bi-bag"></i><span><?= $cartCount ?></span></a>
            <div id="perfil" class="user-panel"><strong><?= escapar((string) $_SESSION['nombre_completo']) ?></strong><span><?= escapar((string) $_SESSION['mail']) ?></span><a href="account.php">Cuenta</a><a href="logout.php">Cerrar sesión</a></div>
        </div>
    </header>
    <main class="orders-shell">
        <a class="page-return" href="account.php"><i class="bi bi-arrow-left"></i> Volver a mi cuenta</a>
        <div class="orders-heading">
            <p class="eyebrow">SHAWARMAS / CUENTA</p>
            <h1>Tus pedidos</h1>
            <p>Consulta el estado y el resumen de tus compras.</p>
        </div>
        <?php if (!$pedidos): ?>
            <section class="orders-empty">
                <i class="bi bi-bag"></i>
                <h2>Aún no tienes pedidos</h2>
                <p>Cuando completes una compra, aparecerá aquí.</p>
                <a href="products.php">Explorar productos <i class="bi bi-arrow-right"></i></a>
            </section>
        <?php else: ?>
            <div class="orders-list">
                <?php foreach ($pedidos as $pedido): ?>
                    <?php $orderId = (int) $pedido['id_pedido']; ?>
                    <article class="order-card">
                        <header class="order-header">
                            <div><p class="order-reference">PEDIDO #<?= $orderId ?></p><h2><?= escapar(date('d/m/Y', strtotime((string) $pedido['fecha_pedido']))) ?></h2></div>
                            <span class="order-status <?= (int) $pedido['entregado'] === 1 ? 'is-delivered' : 'is-pending' ?>"><?= (int) $pedido['entregado'] === 1 ? 'Entregado' : 'En preparación' ?></span>
                        </header>
                        <div class="order-content">
                            <div class="order-items">
                                <?php foreach ($lineasPorPedido[$orderId] ?? [] as $linea): ?>
                                    <div class="order-item">
                                        <div class="order-item-image"><img src="<?= escapar(imagen_url((string) ($linea['imagen'] ?? ''))) ?>" alt="<?= escapar($linea['marca'] . ' ' . $linea['modelo']) ?>" loading="lazy"></div>
                                        <div class="order-item-info"><strong><?= escapar($linea['marca'] . ' ' . $linea['modelo']) ?></strong><span>Talla <?= escapar((string) $linea['talla']) ?> · <?= escapar((string) $linea['color']) ?> · Cantidad <?= (int) $linea['cantidad'] ?></span></div>
                                        <b><?= number_format((float) $linea['precio'] * (int) $linea['cantidad'], 2, ',', '.') ?> €</b>
                                    </div>
                                <?php endforeach; ?>
                            </div>
                            <aside class="order-summary">
                                <div><span>Productos</span><strong><?= (int) $pedido['unidades'] ?></strong></div>
                                <div><span>Entrega</span><strong><?= $pedido['fecha_entrega'] ? escapar(date('d/m/Y', strtotime((string) $pedido['fecha_entrega']))) : 'Pendiente de confirmar' ?></strong></div>
                                <div><span>Dirección</span><strong><?= escapar($pedido['calle'] . ', ' . $pedido['ciudad'] . ', ' . $pedido['postal'] . ' ' . $pedido['pais']) ?></strong></div>
                                <div class="order-total"><span>Total</span><strong><?= number_format((float) $pedido['total'], 2, ',', '.') ?> €</strong></div>
                            </aside>
                        </div>
                    </article>
                <?php endforeach; ?>
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
