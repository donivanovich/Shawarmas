<?php
declare(strict_types=1);
session_start();
require_once __DIR__ . '/database-connection.php';

$id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
$urlRetorno = (string) ($_GET['return'] ?? '');
if (!preg_match('/^products\.php(?:\?.*)?$/', $urlRetorno)) {
    $urlRetorno = 'products.php';
}
$stmt = $conn->prepare(
    '    SELECT p.*, c.categoria
    FROM productos p
    INNER JOIN categorias c ON c.id_categoria = p.fk_categoria
    WHERE p.id_producto = ?'
);
$stmt->bind_param('i', $id);
$stmt->execute();
$result = $stmt->get_result();

if ($result && $result->num_rows > 0) {
    $producto = $result->fetch_assoc();
} else {
    http_response_code(404);
    exit('Producto no encontrado.');
}
$stmt->close();
$stmt = $conn->prepare(
    'SELECT v.id_variante, v.stock, t.talla, co.color
     FROM producto_variantes v
     INNER JOIN tallas t ON t.id_talla = v.fk_talla
     INNER JOIN colores co ON co.id_color = v.fk_color
     WHERE v.fk_producto = ?
     ORDER BY t.id_talla, co.id_color'
);
$stmt->bind_param('i', $id);
$stmt->execute();
$variantes = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
$stmt->close();
$cartCount = 0;
foreach ($_SESSION['carrito'] ?? [] as $sizes) {
    foreach ((array) $sizes as $quantity) {
        $cartCount += max(0, (int) $quantity);
    }
}
$agotado = true;
foreach ($variantes as $variante) {
    $enCarrito = (int) ($_SESSION['carrito'][$id][(int) $variante['id_variante']] ?? 0);
    if ((int) $variante['stock'] > $enCarrito) {
        $agotado = false;
        break;
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="alternative.css?v=20261110-1">
    <link rel="stylesheet" href="cart.css?v=20261110-1">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <title><?= escapar($producto['marca'] . ' ' . $producto['modelo']) ?></title>
    <link rel="icon" href="assets/img/favicon/favicon.ico?v=20261110-1" type="image/x-icon">
</head>
<body>
    <header class="alternative-header">
        <a class="alternative-brand" href="index.php" aria-label="Shawarmas, inicio"><img src="assets/img/logo-shawarmas.png?v=20261110-2" alt="Shawarmas"></a>
        <button class="menu-toggle" type="button" aria-expanded="false" aria-controls="alternative-nav"><i class="bi bi-list"></i><span>Menú</span></button>
        <nav id="alternative-nav" aria-label="Navegación principal"><a href="index.php">Inicio</a><a class="active" href="products.php">Colección</a><a href="index.php#categorias">Categorías</a></nav>
        <div class="alternative-actions"><a href="products.php?buscar=" aria-label="Buscar productos"><i class="bi bi-search"></i></a><button class="user-trigger" type="button" aria-expanded="false" aria-controls="perfil" aria-label="Abrir perfil"><i class="bi bi-person"></i></button><a class="cart-link" href="cart-summary.php" aria-label="Ver carrito"><i class="bi bi-bag"></i><span><?= $cartCount ?></span></a><div id="perfil" class="user-panel"><?php if (!empty($_SESSION['id_user'])): ?><strong><?= escapar((string) $_SESSION['nombre_completo']) ?></strong><span><?= escapar((string) $_SESSION['mail']) ?></span><a href="logout.php">Cerrar sesión</a><?php else: ?><strong>Tu perfil</strong><span>Inicia sesión para ver tus datos y comprar.</span><a class="profile-login-button" href="login.php">Iniciar sesión</a><a href="register.php">Crear cuenta</a><?php endif; ?></div></div>
    </header>

    <main class="product-page">
        <a class="page-return" href="<?= escapar($urlRetorno) ?>"><i class="bi bi-arrow-left"></i> Volver a la colección</a>
        <div class="product-layout <?= $agotado ? 'is-sold-out' : '' ?>">
            <section class="product-media" aria-label="Imagen del producto">
                <?php if ($agotado): ?><span class="diagonal-ribbon">FUERA DE STOCK</span><?php endif; ?>
                <span class="media-index">SHAWARMAS / <?= str_pad((string) $producto['id_producto'], 2, '0', STR_PAD_LEFT) ?></span>
                <img src="<?= escapar((string) $producto['imagen']) ?>" alt="<?= escapar($producto['marca'] . ' ' . $producto['modelo']) ?>">
            </section>

            <section class="product-information">
                <p class="product-kicker"><?= escapar((string) $producto['categoria']) ?> / <?= escapar((string) $producto['marca']) ?></p>
                <h1><?= escapar((string) $producto['modelo']) ?></h1>
                <p class="product-price"><?= number_format((float) $producto['precio'], 2, ',', '.') ?> €</p>
                <p class="product-intro">Una pieza pensada para acompañarte todos los días. Elige tu talla y añádela a tu selección.</p>

                        <div class="product-details">
                            <div><span>Marca</span><strong><?= escapar((string) $producto['marca']) ?></strong></div>
                            <div><span>Categoría</span><strong><?= escapar((string) $producto['categoria']) ?></strong></div>
                        </div>

                <?php if ($agotado): ?>
                    <p class="stock-message">Este producto está fuera de stock.</p>
                <?php else: ?>
                    <div class="purchase-controls">
                        <div class="size-control">
                            <label for="id_variante">Selecciona talla y color</label>
                            <select id="id_variante" name="id_variante" form="form-carrito" required>
                                <option value="">Elegir talla</option>
                                <?php foreach ($variantes as $variante): ?>
                                    <?php $enCarrito = (int) ($_SESSION['carrito'][$id][(int) $variante['id_variante']] ?? 0); $disponible = max(0, (int) $variante['stock'] - $enCarrito); ?>
                                    <option value="<?= (int) $variante['id_variante'] ?>" data-stock="<?= $disponible ?>" <?= $disponible < 1 ? 'disabled' : '' ?>>
                                        <?= escapar((string) $variante['talla']) ?> · <?= escapar((string) $variante['color']) ?><?= $disponible < 1 ? ' — Agotada' : '' ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        <div class="quantity-control" aria-label="Cantidad">
                            <button class="btn-menos" type="button" disabled aria-label="Reducir cantidad">−</button>
                            <span class="cantidad">1</span>
                            <button class="btn-mas" type="button" aria-label="Aumentar cantidad">+</button>
                        </div>
                    </div>
                    <div class="purchase-total"><span>Total</span><strong class="precio-total"><?= number_format((float) $producto['precio'], 2, ',', '.') ?> €</strong></div>
                    <button class="boton-vistoso" type="button">Añadir al carrito <i class="bi bi-arrow-up-right"></i></button>
                <?php endif; ?>
                <form id="form-carrito" action="add-to-cart.php" method="post">
                    <input type="hidden" name="token_csrf" value="<?= escapar(token_csrf()) ?>">
                    <input type="hidden" name="id_producto" value="<?= (int) $producto['id_producto'] ?>">
                    <input type="hidden" name="cantidad" id="cantidad-hidden" value="1">
                </form>
            </section>
        </div>
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
    <?php if (!$agotado): ?>
        <script>
            const btnMenos = document.querySelector('.btn-menos');
            const btnMas = document.querySelector('.btn-mas');
            const cantidad = document.querySelector('.cantidad');
            const precioTotalElement = document.querySelector('.precio-total');
            const precioUnitario = <?= json_encode((float) $producto['precio']) ?>;
            const cantidadHidden = document.getElementById('cantidad-hidden');
            const formCarrito = document.getElementById('form-carrito');
            let stockDisponible = 0;
            let currentValue = 1;
            function actualizarContador() {
                cantidad.textContent = currentValue;
                cantidadHidden.value = currentValue;
                btnMenos.disabled = currentValue <= 1;
                btnMas.disabled = currentValue >= stockDisponible;
                precioTotalElement.textContent = (precioUnitario * currentValue).toFixed(2).replace('.', ',') + ' €';
            }
            const varianteSelect = document.getElementById('id_variante');
            varianteSelect.addEventListener('change', () => {
                stockDisponible = Number(varianteSelect.selectedOptions[0]?.dataset.stock || 0);
                currentValue = stockDisponible > 0 ? 1 : 0;
                actualizarContador();
            });
            btnMas.addEventListener('click', () => { if (currentValue < stockDisponible) { currentValue++; actualizarContador(); } });
            btnMenos.addEventListener('click', () => { if (currentValue > 1) { currentValue--; actualizarContador(); } });
            document.querySelector('.boton-vistoso').addEventListener('click', () => {
                if (!varianteSelect.value) { varianteSelect.focus(); return; }
                formCarrito.submit();
            });
            actualizarContador();
        </script>
    <?php endif; ?>
</body>
</html>
