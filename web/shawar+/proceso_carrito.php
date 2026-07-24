<?php
session_start();
$carrito = $_SESSION['carrito'] ?? [];

$host = "localhost";
$user = "root";
$pass = "";
$db = "shawarmas";

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    die("Error de conexión: " . $conn->connect_error);
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Carrito de Compras</title>
    <link rel="stylesheet" href="proceso_carrito.css?v=1.2">
</head>
<body>
    <h1 style="text-align: center;">Carrito de Compras</h1>
    <div class="grid-carrito">
        <?php
        if (empty($carrito)) {
            echo "<p>No hay productos en el carrito.</p>";
        } else {
            foreach ($carrito as $id_producto => $cantidad) {
                $sql = "SELECT * FROM productos WHERE id_producto = $id_producto";
                $result = $conn->query($sql);
                if ($result && $result->num_rows > 0) {
                    $producto = $result->fetch_assoc();
                    ?>
                    <div class="producto-card">
                        <img src="<?php echo htmlspecialchars($producto['imagen']); ?>" alt="Imagen">
                        <h3><?php echo htmlspecialchars($producto['marca'] . ' ' . $producto['modelo']); ?></h3>
                        <p><strong>Precio:</strong> €<?php echo number_format($producto['precio'], 2); ?></p>
                        <p><strong>Cantidad:</strong> <?php echo $cantidad; ?></p>
                        <form method="POST" action="quitar_del_carrito.php">
                            <input type="hidden" name="id_producto" value="<?php echo $id_producto; ?>">
                            <button class="btn-quitar">Quitar</button>
                        </form>
                    </div>
                    <?php
                }
            }
        }
        $conn->close();
        ?>
    </div>
    <a href="compra.php" class="boton-compra">Ir a Compra</a>
</body>
</html>