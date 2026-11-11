<?php
declare(strict_types=1);
require_once __DIR__ . '/api-client.php';
start_store_session();

if (empty($_SESSION['id_user'])) {
    header('Location: login.php?redirect=account.php');
    exit;
}

$userId = (int) $_SESSION['id_user'];
$cartCount = 0;
foreach ($_SESSION['carrito'] ?? [] as $sizes) {
    foreach ((array) $sizes as $quantity) {
        $cartCount += max(0, (int) $quantity);
    }
}
$mensaje = '';
$estadoMensaje = 'error';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    validar_csrf();
    $currentPassword = (string) ($_POST['current_password'] ?? '');
    $newPassword = (string) ($_POST['new_password'] ?? '');
    $confirmPassword = (string) ($_POST['confirm_password'] ?? '');

    if ($currentPassword === '') {
        $mensaje = 'La contraseña actual no es correcta.';
    } elseif (strlen($newPassword) < 8) {
        $mensaje = 'La nueva contraseña debe tener al menos 8 caracteres.';
    } elseif ($newPassword !== $confirmPassword) {
        $mensaje = 'La confirmación no coincide con la nueva contraseña.';
    } else {
        $passwordChange = api_try('PATCH', '/auth/me/password', ['currentPassword' => $currentPassword, 'newPassword' => $newPassword]);
        $mensaje = 'La contraseña se ha actualizado correctamente.';
        $mensaje = $passwordChange['_error'] ?? $mensaje;
        $estadoMensaje = isset($passwordChange['_error']) ? 'error' : 'exito';
    }
}

$profile = api_try('GET', '/auth/me');
$usuario = isset($profile['_error']) ? [
    'nombre' => $_SESSION['nombre'] ?? '', 'apellido1' => $_SESSION['apellido1'] ?? '',
    'apellido2' => $_SESSION['apellido2'] ?? '', 'mail' => $_SESSION['mail'] ?? '', 'creado_en' => null
] : $profile;

if (($profile['_status'] ?? 0) === 401) {
    $_SESSION = [];
    session_destroy();
    header('Location: login.php');
    exit;
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Mi cuenta | Shawarmas</title>
    <link rel="icon" href="<?= escapar(imagen_url('/brand/favicon.ico')) ?>" type="image/x-icon">
    <link rel="stylesheet" href="alternative.css?v=20261110-4">
    <link rel="stylesheet" href="account.css?v=20261110-1">
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
    <main class="account-shell">
        <a class="page-return" href="index.php"><i class="bi bi-arrow-left"></i> Volver a la tienda</a>
        <div class="account-heading">
            <p class="eyebrow">SHAWARMAS / PERFIL</p>
            <h1>Tu cuenta</h1>
            <p>Consulta tus datos y mantén segura tu cuenta.</p>
        </div>
        <div class="account-grid">
            <section class="account-card account-card--details">
                <div class="account-card-heading"><h2>Tus datos</h2></div>
                <dl class="account-details">
                    <div><dt>Nombre</dt><dd><?= escapar((string) $usuario['nombre']) ?></dd></div>
                    <div><dt>Primer apellido</dt><dd><?= escapar((string) $usuario['apellido1']) ?></dd></div>
                    <div><dt>Segundo apellido</dt><dd><?= escapar(trim((string) ($usuario['apellido2'] ?? '')) ?: '—') ?></dd></div>
                    <div><dt>Correo electrónico</dt><dd><?= escapar((string) $usuario['mail']) ?></dd></div>
                    <div><dt>Miembro desde</dt><dd><?= !empty($usuario['creado_en']) ? escapar(date('d/m/Y', strtotime((string) $usuario['creado_en']))) : '—' ?></dd></div>
                </dl>
                <a class="account-orders-button" href="orders.php">Tus pedidos <i class="bi bi-arrow-right"></i></a>
            </section>
            <section class="account-card">
                <div class="account-card-heading"><h2>Cambiar contraseña</h2></div>
                <p class="account-intro">Confirma tu contraseña actual antes de elegir una nueva.</p>
                <?php if ($mensaje !== ''): ?><p class="account-message <?= $estadoMensaje ?>"><?= escapar($mensaje) ?></p><?php endif; ?>
                <form class="account-form" action="account.php" method="post">
                    <input type="hidden" name="token_csrf" value="<?= escapar(token_csrf()) ?>">
                    <label for="current_password">Contraseña actual</label>
                    <input id="current_password" name="current_password" type="password" autocomplete="current-password" required>
                    <label for="new_password">Nueva contraseña <span>(mínimo 8 caracteres)</span></label>
                    <input id="new_password" name="new_password" type="password" autocomplete="new-password" minlength="8" required>
                    <label for="confirm_password">Repetir nueva contraseña</label>
                    <input id="confirm_password" name="confirm_password" type="password" autocomplete="new-password" minlength="8" required>
                    <button type="submit">Actualizar contraseña <i class="bi bi-arrow-right"></i></button>
                </form>
            </section>
        </div>
        <a class="account-logout" href="logout.php"><i class="bi bi-box-arrow-right"></i> Cerrar sesión</a>
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
