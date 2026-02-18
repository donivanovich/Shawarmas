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
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Tienda de Zapatillas y Ropa</title>
    <link rel="stylesheet" href="productos.css" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet" />
</head>
<body>
    <!-- Encabezado -->
    <header>
        <div class="encabezado-izq">
            <div class="icono-menu-contenedor" id="menu-toggle">
                <i class="bi bi-list"></i>
            </div>
            <img src="assets/img/grafitti diseño 1.png" class="logo-izquierda" alt="Logo" />
        </div>
        <div class="encabezado-centro">
            <img src="assets/img/logo.png" class="logocentro" alt="Logo principal" />
        </div>
        <div class="encabezado-der">
            <div class="iconos">
                <i class="bi bi-globe" id="planet-icon"></i>
                <div class="idiomas" id="planet-images">
                    <img src="assets/img/Spain.jpg" class="bandera" alt="Español" />
                    <img src="assets/img/USA.jpg" class="bandera" alt="Inglés" />
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
                            <p class="fs">USUARIO</p>
                            <div class="espacio"></div>
                            <input type="text" id="usuario" name="usuario" required />
                            <div class="espacio"></div>
                            <label for="password">Contraseña</label>
                            <div class="espacio"></div>
                            <input type="password" id="password" name="password" required />
                            <div class="espacio"></div>
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

    <!-- Menú lateral -->
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

    <!-- Contenido principal -->
    <main class="contenedor-principal">
        <!-- Filtro lateral -->
        <aside class="filtro-lateral">
            <h2>Filtrar por</h2>
            <div class="filtro-categoria">
                <h3>Categoría</h3>
                <ul>
                    <li><input type="checkbox" id="zapatillas" /><label for="zapatillas"> Zapatillas</label></li>
                    <li><input type="checkbox" id="ropa" /><label for="ropa"> Ropa</label></li>
                    <li><input type="checkbox" id="accesorios" /><label for="accesorios"> Accesorios</label></li>
                </ul>
            </div>
            <div class="filtro-precio">
                <h3>Precio</h3>
                <ul>
                    <li><input type="checkbox" id="precio1" /><label for="precio1"> €0 - €50</label></li>
                    <li><input type="checkbox" id="precio2" /><label for="precio2"> €51 - €100</label></li>
                    <li><input type="checkbox" id="precio3" /><label for="precio3"> €101 - €150</label></li>
                </ul>
            </div>
        </aside>

        <div class="productos-container">
            <section class="grilla-productos">
                <a href="carrito.php?id=1" class="tarjeta-producto">
                    <img src="assets/img/airForceN.png" alt="Zapatilla 1" />
                        <div class="contenido">
                            <h3>NIKE AIR FORCE</h3>
                            <p>94.99€</p>
                        </div>
                </a>
                <a href="carrito.php?id=2" class="tarjeta-producto">
                    <img src="assets/img/jordan 4 retro.png" alt="Zapatilla 2" />
                        <div class="contenido">
                            <h3>JORDAN 4 RETRO</h3>
                            <p>94.99€</p>
                        </div>
                </a>
                <a href="carrito.php?id=3" class="tarjeta-producto">
                    <div class="espacio"></div>
                    <img src="assets/img/jordan1.jpg" alt="Zapatilla 3" />
                        <div class="espacio"></div>    
                        <div class="contenido">
                            <h3>JORDAN 1</h3>
                            <p>119.99€</p>
                        </div>
                </a>
                <a href="carrito.php?id=4" class="tarjeta-producto">
                    <img src="assets/img/campus.png" alt="Zapatilla 4" />
                        <div class="contenido">
                            <h3>ADIDAS CAMPUS</h3>
                            <p>80.99€</p>
                        </div>
                </a>
                <a href="carrito.php?id=5" class="tarjeta-producto">
                    <img src="assets/img/AdidasSamba.png" alt="Zapatilla 5" />
                        <div class="contenido">
                            <h3>ADIDAS SAMBA</h3>
                            <p>119.99€</p>
                        </div>
                </a>
                <a href="carrito.php?id=6" class="tarjeta-producto">
                    <div class="espacio"></div>
                    <img src="assets/img/SuperStar.png" alt="Zapatilla 6" />
                        <div class="contenido">
                        <div class="espacio"></div>
                        <div class="espacio"></div>
                            <h3>ADIDAS SUPERSTAR</h3>
                            <p>76.93€</p>
                        </div>
                </a>
            </section>

            <!-- Segunda sección de productos -->
            <section class="grilla-productos">
                <a href="carrito.php?id=7" class="tarjeta-producto">
                    <img src="assets/img/Baggy Zara.png" class="pantalon" alt="Zapatilla 6" 
                    style="width: 150px; height: 170px;" 
                    />
                    <div class="contenido">
                        <h3>PANTALONES BAGGY ZARA</h3>
                        <p>40.50€</p>
                    </div>
                </a>
                <a href="carrito.php?id=8" class="tarjeta-producto">
                    <img src="assets/img/baggy2 zara.png" style="width: 110px; height: 170px; alt="Zapatilla 5" />
                        <div class="contenido">
                            <h3>PANTALONES BAGGY ZARA AZULES</h3>
                            <p>35.50€</p>
                        </div>
                </a>
                <a href="carrito.php?id=8" class="tarjeta-producto">
                    <img src="assets/img/pantalones baggy3.png" style="width: 110px; height: 170px; alt="Zapatilla 5" />
                        <div class="contenido">
                            <h3>PANTALONES BAGGY DISEÑO ZARA</h3>
                            <p>35.50€</p>
                        </div>
                </a>
                <div class="tarjeta-producto">
                    <img src="assets/img/pantalon1.jpg" alt="Pantalón 1" />
                    <div class="contenido">
                        <h3>Pantalón Deportivo</h3>
                        <p>€49.99</p>
                    </div>
                </div>
                <div class="tarjeta-producto">
                    <img src="assets/img/pantalon1.jpg" alt="Pantalón 1" />
                    <div class="contenido">
                        <h3>Pantalón Deportivo</h3>
                        <p>€49.99</p>
                    </div>
                </div>
                <div class="tarjeta-producto">
                    <img src="assets/img/pantalon1.jpg" alt="Pantalón 1" />
                    <div class="contenido">
                        <h3>Pantalón Deportivo</h3>
                        <p>€49.99</p>
                    </div>
                </div>
            </section>

            <section class="grilla-productos">
                <div class="tarjeta-producto">
                    <img src="assets/img/zapatilla1.jpg" alt="Zapatilla 1" />
                    <div class="contenido">
                        <h3>Zapatilla Deportiva</h3>
                        <p>€89.99</p>
                    </div>
                </div>
                <div class="tarjeta-producto">
                    <img src="assets/img/zapatilla2.jpg" alt="Zapatilla 2" />
                    <div class="contenido">
                        <h3>Zapatilla Casual</h3>
                        <p>€74.99</p>
                    </div>
                </div>
                <div class="tarjeta-producto">
                    <img src="assets/img/camiseta1.jpg" alt="Camiseta 1" />
                    <div class="contenido">
                        <h3>Camiseta Básica</h3>
                        <p>€19.99</p>
                    </div>
                </div>
                <div class="tarjeta-producto">
                    <img src="assets/img/pantalon1.jpg" alt="Pantalón 1" />
                    <div class="contenido">
                        <h3>Pantalón Deportivo</h3>
                        <p>€49.99</p>
                    </div>
                </div>
                <div class="tarjeta-producto">
                    <img src="assets/img/pantalon1.jpg" alt="Pantalón 1" />
                    <div class="contenido">
                        <h3>Pantalón Deportivo</h3>
                        <p>€49.99</p>
                    </div>
                </div>
                <div class="tarjeta-producto">
                    <img src="assets/img/pantalon1.jpg" alt="Pantalón 1" />
                    <div class="contenido">
                        <h3>Pantalón Deportivo</h3>
                        <p>€49.99</p>
                    </div>
                </div>
            </section>
            <section class="grilla-productos">
                <div class="tarjeta-producto">
                    <img src="assets/img/zapatilla1.jpg" alt="Zapatilla 1" />
                    <div class="contenido">
                        <h3>Zapatilla Deportiva</h3>
                        <p>€89.99</p>
                    </div>
                </div>
                <div class="tarjeta-producto">
                    <img src="assets/img/zapatilla2.jpg" alt="Zapatilla 2" />
                    <div class="contenido">
                        <h3>Zapatilla Casual</h3>
                        <p>€74.99</p>
                    </div>
                </div>
                <div class="tarjeta-producto">
                    <img src="assets/img/camiseta1.jpg" alt="Camiseta 1" />
                    <div class="contenido">
                        <h3>Camiseta Básica</h3>
                        <p>€19.99</p>
                    </div>
                </div>
                <div class="tarjeta-producto">
                    <img src="assets/img/pantalon1.jpg" alt="Pantalón 1" />
                    <div class="contenido">
                        <h3>Pantalón Deportivo</h3>
                        <p>€49.99</p>
                    </div>
                </div>
                <div class="tarjeta-producto">
                    <img src="assets/img/pantalon1.jpg" alt="Pantalón 1" />
                    <div class="contenido">
                        <h3>Pantalón Deportivo</h3>
                        <p>€49.99</p>
                    </div>
                </div>
                <div class="tarjeta-producto">
                    <img src="assets/img/pantalon1.jpg" alt="Pantalón 1" />
                    <div class="contenido">
                        <h3>Pantalón Deportivo</h3>
                        <p>€49.99</p>
                    </div>
                </div>
            </section>
        </div>
    </main>

    <script>
        const menuToggle = document.getElementById('menu-toggle');
        const sideMenu = document.getElementById('side-menu');
        const closeMenu = document.getElementById('close-menu');

        menuToggle.addEventListener('click', () => {
            sideMenu.classList.add('show');
        });

        closeMenu.addEventListener('click', () => {
            sideMenu.classList.remove('show');
        });

        const planetIcon = document.getElementById('planet-icon');
        const planetImages = document.getElementById('planet-images');

        planetIcon.addEventListener('click', () => {
            planetImages.classList.toggle('show');
        });

        const userIcon = document.getElementById('user-icon');
        const loginDropdown = document.getElementById('user-dropdown');
        if (userIcon) {
            userIcon.addEventListener('click', () => {
                loginDropdown.classList.toggle('show');
            });
        }

        const loggedUserIcon = document.getElementById('logged-user-icon');
        const loggedUserDropdown = document.getElementById('user-logged-dropdown');
        if (loggedUserIcon) {
            loggedUserIcon.addEventListener('click', () => {
                loggedUserDropdown.classList.toggle('show');
            });
        }

        document.addEventListener('click', (e) => {
            if (!planetIcon.contains(e.target) && !planetImages.contains(e.target)) {
                planetImages.classList.remove('show');
            }

            if (userIcon && !userIcon.contains(e.target) && !loginDropdown.contains(e.target)) {
                loginDropdown.classList.remove('show');
            }

            if (loggedUserIcon && !loggedUserIcon.contains(e.target) && !loggedUserDropdown.contains(e.target)) {
                loggedUserDropdown.classList.remove('show');
            }
        });
    </script>
</body>
</html>
