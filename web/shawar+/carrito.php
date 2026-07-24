<?php
// 1. Conectar a la base de datos
$host = "localhost";
$user = "root";
$pass = "";
$db = "shawarmas"; // Cambia por el nombre de tu base de datos

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    die("Error de conexión: " . $conn->connect_error);
}

// 2. Recibir el ID del producto
$id = isset($_GET['id']) ? intval($_GET['id']) : 0;

$sql = "SELECT * FROM productos WHERE id_producto = $id";
$result = $conn->query($sql);

if ($result && $result->num_rows > 0) {
    $producto = $result->fetch_assoc();
} else {
    die("Producto no encontrado");
}

$conn->close();
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="carrito.css?v=1.1"> <!-- Incrementa la versión -->
    <title><?php echo htmlspecialchars($producto['marca'] . ' ' . $producto['modelo']); ?></title>
</head>
<body>
    <div class="cM">
        <div class="caja1">
            <div class="cont-izq">
                <div class="caja-img">
                    <img src="<?php echo htmlspecialchars($producto['imagen']); ?>" alt="Imagen del producto" style="max-width: 100%; max-height: 100%; border-radius: 16px;">
                </div>
                <div class="caja-nom">
                    <h2><?php echo htmlspecialchars($producto['marca'] . ' ' . $producto['modelo']); ?></h2>
                </div>
                <div class="caja-valoracion">
                    <div class="precio-contador">
                        <div class="precio">
                            <p><strong>Precio:</strong> €<?php echo number_format($producto['precio'], 2); ?></p>
                        </div>
                        <div class="contador">
                            <button class="btn-menos" disabled>-</button>
                            <span class="cantidad">1</span>
                            <button class="btn-mas">+</button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="cont-der">
                <div class="caja-info">
                    <p><strong>Stock disponible:</strong> <?php echo htmlspecialchars($producto['stock']); ?> unidades</p>
                    <p class="unidades-seleccionadas">Unidades seleccionadas: <span>1</span></p>
                    <p class="precio-total">Precio total: <span>€<?php echo number_format($producto['precio'], 2); ?></span></p>
                </div>
                <div class="caja-boton">
                    <button class="boton-vistoso">AÑADIR AL CARRITO</button>
                </div>
                <form id="form-carrito" action="añadir_al_carrito.php" method="POST" style="display: none;">
                    <input type="hidden" name="id_producto" value="<?php echo $producto['id_producto']; ?>">
                    <input type="hidden" name="cantidad" id="cantidad-hidden" value="1">
                </form>
            </div>
        </div>
    </div>

    <script>

        document.addEventListener('DOMContentLoaded', function() {
        // Tu código de contador (btnMenos, btnMas, etc.) ya está bien

        const botonAñadir = document.querySelector('.boton-vistoso');
        const cantidadHidden = document.getElementById('cantidad-hidden');

        botonAñadir.addEventListener('click', function() {
            cantidadHidden.value = currentValue; // currentValue es tu variable de cantidad
            document.getElementById('form-carrito').submit();
            });
        });

        document.addEventListener('DOMContentLoaded', function() {
        const btnMenos = document.querySelector('.btn-menos');
        const btnMas = document.querySelector('.btn-mas');
        const cantidad = document.querySelector('.cantidad');
        const unidadesSeleccionadas = document.querySelector('.unidades-seleccionadas span');
        const precioTotalElement = document.querySelector('.precio-total span');
        const stockDisponible = <?php echo $producto['stock']; ?>;
        const precioUnitario = <?php echo $producto['precio']; ?>;
        let currentValue = 1;

        const btnAñadir = document.querySelector('.boton-vistoso');
        const cantidadHidden = document.getElementById('cantidad-hidden');
        const formCarrito = document.getElementById('form-carrito');

        function actualizarContador() {
            cantidad.textContent = currentValue;
            unidadesSeleccionadas.textContent = currentValue;
            btnMenos.disabled = currentValue <= 1;
            btnMas.disabled = currentValue >= stockDisponible;

            const precioTotal = (precioUnitario * currentValue).toFixed(2);
            precioTotalElement.textContent = '€' + precioTotal;
        }

        btnMas.addEventListener('click', function() {
            if (currentValue < stockDisponible) {
                currentValue++;
                actualizarContador();
            }
        });

        btnMenos.addEventListener('click', function() {
            if (currentValue > 1) {
                currentValue--;
                actualizarContador();
            }
        });

        btnAñadir.addEventListener('click', function() {
            cantidadHidden.value = currentValue;
            formCarrito.submit();
        });

        actualizarContador();
    });

        document.addEventListener('DOMContentLoaded', function() {
            const btnMenos = document.querySelector('.btn-menos');
            const btnMas = document.querySelector('.btn-mas');
            const cantidad = document.querySelector('.cantidad');
            const unidadesSeleccionadas = document.querySelector('.unidades-seleccionadas span');
            const precioTotalElement = document.querySelector('.precio-total span');
            const stockDisponible = <?php echo $producto['stock']; ?>;
            const precioUnitario = <?php echo $producto['precio']; ?>;
            let currentValue = 1;

            function actualizarContador() {
                cantidad.textContent = currentValue;
                unidadesSeleccionadas.textContent = currentValue;
                btnMenos.disabled = currentValue <= 1;
                btnMas.disabled = currentValue >= stockDisponible;
                
                // Calcular y mostrar el precio total
                const precioTotal = (precioUnitario * currentValue).toFixed(2);
                precioTotalElement.textContent = '€' + precioTotal;
            }

            btnMas.addEventListener('click', function() {
                if (currentValue < stockDisponible) {
                    currentValue++;
                    actualizarContador();
                }
            });

            btnMenos.addEventListener('click', function() {
                if (currentValue > 1) {
                    currentValue--;
                    actualizarContador();
                }
            });

            actualizarContador(); // Inicializar
        });
    </script>
</body>
</html>