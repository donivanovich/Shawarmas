<?php
    session_start();

    $mysqli = new mysqli('localhost', 'root', '', 'shawarmas');
    if ($mysqli->connect_errno) {
        die('Error de conexión: ' . $mysqli->connect_error);
    }

    $errorLogin = '';

    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['usuario'], $_POST['password'])) {
        $email = $mysqli->real_escape_string($_POST['usuario']);
        $pass = $_POST['password'];

        $result = $mysqli->query("SELECT nombre, apellido1, apellido2, mail, passw FROM clientes WHERE mail = '$email' LIMIT 1");
        if ($result && $result->num_rows === 1) {
            $row = $result->fetch_assoc();
            if (password_verify($pass, $row['passw'])) {
                $_SESSION['nombre_completo'] = $row['nombre'] . ' ' . $row['apellido1'] . ' ' . $row['apellido2'];
                $_SESSION['nombre'] = $row['nombre'];
                $_SESSION['apellido1'] = $row['apellido1'];
                $_SESSION['apellido2'] = $row['apellido2'];
                $_SESSION['mail'] = $row['mail'];
            } else {
                $errorLogin = 'Usuario o contraseña incorrectos.';
            }
        } else {
            $errorLogin = 'Usuario o contraseña incorrectos.';
        }
    }
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>SHAWARMAS</title>
    <link rel="stylesheet" href="contenedores.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
    <header>
        <div class="encabezado-izq">
            <div class="icono-menu-contenedor" id="menu-toggle">
                <i class="bi bi-list"></i>
            </div>
            <img src="assets/img/grafitti diseño 1.png" class="logo-izquierda" alt="Logo">
        </div>
        <div class="encabezado-centro">
            <img src="assets/img/logo.png" class="logocentro" alt="">
        </div>
        <div class="encabezado-der">
            <div class="iconos">
                <i class="bi bi-globe" id="planet-icon"></i>

                <div class="idiomas" id="planet-images">
                    <img src="assets/img/Spain.jpg" class="bandera" alt="img1">
                    <img src="assets/img/USA.jpg" class="bandera" alt="img2">
                </div>

                <?php if (isset($_SESSION['nombre_completo'])): ?>
                    <i class="bi bi-person-circle" id="logged-user-icon"></i>
                    <div class="menu-usuario-logueado" id="user-logged-dropdown">
                        <p><strong>Nombre:</strong> <?= htmlspecialchars($_SESSION['nombre']) ?></p>
                        <p><strong>Apellido 1:</strong> <?= htmlspecialchars($_SESSION['apellido1']) ?></p>
                        <p><strong>Apellido 2:</strong> <?= htmlspecialchars($_SESSION['apellido2']) ?></p>
                        <p><strong>Email:</strong> <?= htmlspecialchars($_SESSION['mail']) ?></p>

                        <form method="post" action="logout.php">
                            <button type="submit" class="boton-cerrar-sesion">Cerrar sesión</button>
                        </form>
                    </div>
                <?php else: ?>
                    <i class="bi bi-person" id="user-icon"></i>
                    <div class="formulario-login" id="user-dropdown">
                        <?php if (!empty($errorLogin)): ?>
                            <p style="color: red; font-weight: bold;"><?= htmlspecialchars($errorLogin) ?></p>
                        <?php endif; ?>

                        <form method="post" action="">
                            <label for="usuario">Usuario</label>
                            <input type="text" id="usuario" name="usuario" placeholder="Ingresa tu usuario" required>

                            <label for="password">Contraseña</label>
                            <input type="password" id="password" name="password" placeholder="Ingresa tu contraseña" required>

                            <button type="submit">Iniciar sesión</button>
                        </form>

                        <p class="texto-registro">
                            Si no tienes cuenta puedes <a href="registro.php">registrarte</a>
                        </p>
                    </div>
                <?php endif; ?>
            </div>
        </div>
    </header>

    <nav id="side-menu" class="menu-lateral">
        <div class="menu-lateral-cabecera">
            <span>Menú</span>
            <i class="bi bi-x-lg" id="close-menu" style="cursor: pointer;"></i>
        </div>
        <ul>
            <li><a href="productos.php"><i class="bi bi-box-seam"></i> Productos</a></li>
            <li><a href="proceso_carrito.php"><i class="bi bi-cart3"></i> Carrito</a></li>
        </ul>
    </nav>

    <div class="zona1">
        <div class="zona1-izq">
            <img src="assets/img/grafitti diseño 1.png" alt="Lateral Izquierda" class="imagen-lateral">
        </div>
        <div class="zona1-cen">
            <div class="carrusel">
                <img src="assets/img/jordan1.jpg" class="imagen-carrusel activo" alt="Imagen 1">
                <img src="assets/img/airForceN.png" class="imagen-carrusel" alt="Imagen 2">
                <img src="assets/img/jordan 4 retro.png" class="imagen-carrusel" alt="Imagen 3">
            </div>
        </div>
        <div class="zona1-der">
            <img src="assets/img/grafitti diseño 1.png" alt="Lateral Derecha" class="imagen-lateral-2">
        </div>
    </div>

    <div class="zona2">
        <div class="zona2-izq">
            <img src="assets/img/lateralesgr.png" class="laterales-log" alt="">
        </div>
        <div class="zona2-cen">
            <iframe width="840" height="560" 
                src="https://www.youtube.com/embed/VnE7m8JI7MY?loop=1&playlist=VnE7m8JI7MY&autoplay=1&mute=1"
                class="b-r"
                title="YouTube video player"
                frameborder="0"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowfullscreen>
            </iframe>
        </div>
        <div class="zona2-der">
            <img src="assets/img/lateralesgr.png" class="laterales-log-2" alt="">
        </div>
    </div>

    <div class="zona3">
        <div class="zona3-izq">
            <iframe
                src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3036.8988045264624!2d-3.7080890846034046!3d40.41010177936464!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0xd4227b4b928f457%3A0xbc9ba0e7c5081e76!2sGhetto%20Shop%20Streetwear!5e0!3m2!1ses!2ses!4v1681234567890"
                width="600"
                class="maps"
                height="450"
                style="border:0;"
                allowfullscreen=""
                loading="lazy"
                referrerpolicy="no-referrer-when-downgrade">
            </iframe>
        </div>
        <div class="zona3-der">
            <footer class="footer-ultramoderno">
                <div class="footer-content">
                <h2 class="footer-title">SHAWAR+</h2>

                <ul class="footer-links">
                    <li class="margin"><a href="#">Privacidad</a></li>
                    <li class="margin"><a href="#">Términos</a></li>
                    <li class="margin"><a href="#">Ayuda</a></li>
                    <li class="margin"><a href="#">Contacto</a></li>
                </ul>

                <div class="footer-social">
                    <a href="#"><i class="bi bi-instagram"></i></a>
                    <a href="#"><i class="bi bi-twitter"></i></a>
                    <a href="#"><i class="bi bi-tiktok"></i></a>
                </div>

                <p class="footer-copy">©Shawar+. Todos los derechos reservados.</p>
                </div>
            </footer>
        </div>
    </div>

    <script>

        // desplegable bandera idiomas
        document.getElementById('planet-icon').addEventListener('click', function () {
            const images = document.getElementById('planet-images');
            images.classList.toggle('show');
        });


        // desplegable inicio de sesion
        const userIcon = document.getElementById('user-icon');
        if (userIcon) {
            userIcon.addEventListener('click', function () {
                const dropdown = document.getElementById('user-dropdown');
                dropdown.classList.toggle('show');
            });
        }

        //desplegable sesion iniciada
        const loggedUserIcon = document.getElementById('logged-user-icon');
        if (loggedUserIcon) {
            loggedUserIcon.addEventListener('click', function () {
                const dropdown = document.getElementById('user-logged-dropdown');
                dropdown.classList.toggle('show');
            });
        }

        // Menú lateral desplegable
        const menuToggle = document.getElementById('menu-toggle');
        const sideMenu = document.getElementById('side-menu');
        const closeMenu = document.getElementById('close-menu');

        menuToggle.addEventListener('click', () => {
            sideMenu.classList.add('show');
        });

        closeMenu.addEventListener('click', () => {
            sideMenu.classList.remove('show');
        }); 

        let indiceImagen = 0;
        const imagenes = document.querySelectorAll('.carrusel img');

        function cambiarImagen() {
            imagenes[indiceImagen].classList.remove('activo');
            indiceImagen = (indiceImagen + 1) % imagenes.length;
            imagenes[indiceImagen].classList.add('activo');
        }
        
        setInterval(cambiarImagen, 7000); 
    </script>
</body>
</html>
