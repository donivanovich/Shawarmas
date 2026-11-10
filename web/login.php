<?php
declare(strict_types=1);
session_start([
    'cookie_httponly' => true,
    'cookie_samesite' => 'Lax',
    'cookie_secure' => !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off'
]);
require_once __DIR__ . '/database-connection.php';

$mensaje = '';
$cartCount = 0;
foreach ($_SESSION['carrito'] ?? [] as $sizes) {
    foreach ((array) $sizes as $quantity) {
        $cartCount += max(0, (int) $quantity);
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    validar_csrf();
    $email = trim((string) ($_POST['usuario'] ?? ''));
    $password = (string) ($_POST['password'] ?? '');
    $stmt = $conn->prepare('SELECT id_user, nombre, apellido1, apellido2, mail, passw FROM clientes WHERE mail = ? LIMIT 1');
    $stmt->bind_param('s', $email);
    $stmt->execute();
    $cliente = $stmt->get_result()->fetch_assoc();
    $stmt->close();

    if ($cliente && verify_password_shared($password, (string) $cliente['passw'])) {
        session_regenerate_id(true);
        $_SESSION['id_user'] = (int) $cliente['id_user'];
        $_SESSION['nombre'] = (string) $cliente['nombre'];
        $_SESSION['apellido1'] = (string) $cliente['apellido1'];
        $_SESSION['apellido2'] = (string) ($cliente['apellido2'] ?? '');
        $_SESSION['mail'] = (string) $cliente['mail'];
        $_SESSION['nombre_completo'] = trim($_SESSION['nombre'] . ' ' . $_SESSION['apellido1'] . ' ' . $_SESSION['apellido2']);
        header('Location: index.php');
        exit;
    }

    $mensaje = 'Usuario o contraseña incorrectos.';
}

$conn->close();
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar sesión</title>
    <link rel="icon" href="assets/img/favicon/favicon.ico?v=20261110-1" type="image/x-icon">
    <link rel="stylesheet" href="alternative.css?v=20261110-1">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        <?php include "register.css"; ?>
    </style>
</head>
<body>
    <header class="alternative-header">
        <a class="alternative-brand" href="index.php" aria-label="Shawarmas, inicio"><img src="assets/img/logo-shawarmas.png?v=20261110-2" alt="Shawarmas" style="transform: scale(1.5);"></a>
        <button class="menu-toggle" type="button" aria-expanded="false" aria-controls="alternative-nav"><i class="bi bi-list"></i><span>Menú</span></button>
        <nav id="alternative-nav" aria-label="Navegación principal"><a href="index.php">Inicio</a><a href="products.php">Colección</a><a href="index.php#categorias">Categorías</a></nav>
        <div class="alternative-actions"><a href="products.php?buscar=" aria-label="Buscar productos"><i class="bi bi-search"></i></a><button class="user-trigger" type="button" aria-expanded="false" aria-controls="perfil" aria-label="Abrir perfil"><i class="bi bi-person"></i></button><a class="cart-link" href="cart-summary.php" aria-label="Ver carrito"><i class="bi bi-bag"></i><span><?= $cartCount ?></span></a><div id="perfil" class="user-panel"><strong>Tu perfil</strong><a href="login.php">Iniciar sesión</a><a href="register.php">Crear cuenta</a></div></div>
    </header>
    <main class="registro-shell">
        <a class="registro-logo" href="index.php"><img src="assets/img/logo-shawarmas.png?v=20261110-2" alt="Shawarmas"></a>
        <section class="registro-card">
            <div class="registro-heading">
                <p class="eyebrow">SHAWARMAS</p>
                <h1>Iniciar sesión</h1>
                <p>Accede a tu cuenta para continuar.</p>
            </div>
            <?php if ($mensaje !== ''): ?><div class="mensaje error"><?= escapar($mensaje) ?></div><?php endif; ?>
            <form action="login.php" method="post">
                <input type="hidden" name="token_csrf" value="<?= escapar(token_csrf()) ?>">
                <div class="form-group">
                    <label for="usuario">Correo electrónico</label>
                    <input type="email" id="usuario" name="usuario" autocomplete="email" required>
                </div>
                <div class="form-group">
                    <label for="password">Contraseña</label>
                    <input type="password" id="password" name="password" autocomplete="current-password" required>
                </div>
                <div class="form-group botones">
                    <button type="submit">Iniciar sesión</button>
                    <a href="register.php" class="volver-btn">Crear una cuenta</a>
                </div>
            </form>
        </section>
        <p class="registro-footer">Tus datos se mantienen protegidos.</p>
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
