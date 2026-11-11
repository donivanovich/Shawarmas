<?php
declare(strict_types=1);
require_once __DIR__ . '/api-client.php';
start_store_session();
$mensaje = "";
$cartCount = 0;
foreach ($_SESSION['carrito'] ?? [] as $sizes) {
    foreach ((array) $sizes as $quantity) {
        $cartCount += max(0, (int) $quantity);
    }
}
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    validar_csrf();
    $nombre = trim((string) ($_POST['nombre'] ?? ''));
    $apellido1 = trim((string) ($_POST['apellido1'] ?? ''));
    $apellido2 = trim((string) ($_POST['apellido2'] ?? ''));
    $mail = filter_var(trim((string) ($_POST['mail'] ?? '')), FILTER_VALIDATE_EMAIL);
    $passwPlano = (string) ($_POST['passw'] ?? '');

    if ($nombre === '' || $apellido1 === '' || $mail === false || strlen($passwPlano) < 8) {
        $mensaje = 'Completa los datos correctamente. La contraseña debe tener al menos 8 caracteres.';
    } else {
        try {
            api_request('POST', '/auth/register', ['nombre' => $nombre, 'apellido1' => $apellido1, 'apellido2' => $apellido2 ?: null, 'email' => $mail, 'password' => $passwPlano], false);
            $mensaje = 'Registro realizado correctamente.';
        } catch (ApiClientException) {
            $mensaje = 'No se pudo completar el registro. Comprueba que el correo no esté registrado.';
        }
    }
}

?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Crear cuenta</title>
    <link rel="icon" href="<?= escapar(imagen_url('/brand/favicon.ico')) ?>" type="image/x-icon">
    <link rel="stylesheet" href="alternative.css?v=20261110-4">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        <?php include "register.css"; ?>
    </style>
</head>
<body>
    <header class="alternative-header">
        <a class="alternative-brand" href="index.php" aria-label="Shawarmas, inicio"><img src="<?= escapar(imagen_url('/brand/logo.png')) ?>" alt="Shawarmas"></a>
        <button class="menu-toggle" type="button" aria-expanded="false" aria-controls="alternative-nav"><i class="bi bi-list"></i><span>Menú</span></button>
        <nav id="alternative-nav" aria-label="Navegación principal"><a href="index.php">Inicio</a><a href="products.php">Colección</a><a href="index.php#categorias">Categorías</a></nav>
        <div class="alternative-actions"><a href="products.php?buscar=" aria-label="Buscar productos"><i class="bi bi-search"></i></a><button class="user-trigger" type="button" aria-expanded="false" aria-controls="perfil" aria-label="Abrir perfil"><i class="bi bi-person"></i></button><a class="cart-link" href="cart-summary.php" aria-label="Ver carrito"><i class="bi bi-bag"></i><span><?= $cartCount ?></span></a><div id="perfil" class="user-panel"><?php if (!empty($_SESSION['id_user'])): ?><strong><?= escapar((string) $_SESSION['nombre_completo']) ?></strong><span><?= escapar((string) $_SESSION['mail']) ?></span><a href="account.php">Cuenta</a><a href="logout.php">Cerrar sesión</a><?php else: ?><strong>Tu perfil</strong><span>Inicia sesión para ver tus datos y comprar.</span><a class="profile-login-button" href="login.php">Iniciar sesión</a><a href="register.php">Crear cuenta</a><?php endif; ?></div></div>
    </header>
    <main class="registro-shell">
        <a class="registro-logo" href="index.php"><img src="<?= escapar(imagen_url('/brand/logo.png')) ?>" alt="Shawarmas"></a>
        <section class="registro-card">
            <div class="registro-heading">
                <p class="eyebrow">SHAWARMAS</p>
                <h1>Crear tu cuenta</h1>
                <p>Regístrate para comprar tus productos favoritos.</p>
            </div>
            <?php if (!empty($mensaje)): ?>
                <div class="mensaje <?php echo strpos($mensaje, 'correctamente') !== false ? 'exito' : 'error'; ?>">
                    <?php echo escapar($mensaje); ?>
                </div>
            <?php endif; ?>
            <form action="register.php" method="post">
        <input type="hidden" name="token_csrf" value="<?php echo escapar(token_csrf()); ?>">
        <div class="form-group">
            <label for="nombre">Nombre</label>
            <input type="text" id="nombre" name="nombre" required>
        </div>
        
        <div class="form-group">
            <label for="apellido1">Primer apellido</label>
            <input type="text" id="apellido1" name="apellido1" required>
        </div>
        
        <div class="form-group">
            <label for="apellido2">Segundo apellido <span>(opcional)</span></label>
            <input type="text" id="apellido2" name="apellido2">
        </div>
        
        <div class="form-group">
            <label for="mail">Correo electrónico</label>
            <input type="email" id="mail" name="mail" required>
        </div>
        
        <div class="form-group">
            <label for="passw">Contraseña <span>(mínimo 8 caracteres)</span></label>
            <input type="password" id="passw" name="passw" required>
        </div>
        
        <div class="form-group botones">
            <button type="submit">Crear cuenta</button>
            <a href="login.php" class="volver-btn">Ya tengo una cuenta</a>
        </div>
            </form>
        </section>
        <p class="registro-footer">Al registrarte podrás realizar pedidos de forma segura.</p>
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
