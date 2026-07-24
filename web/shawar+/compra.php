<?php
session_start();

$host = "localhost";
$user = "root";
$pass = "";
$db = "shawarmas";

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    die("Error de conexión: " . $conn->connect_error);
}

$mensaje = "";
$carrito = $_SESSION['carrito'] ?? [];

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($carrito)) {
    $pais = $_POST['pais'];
    $ciudad = $_POST['ciudad'];
    $calle = $_POST['calle'];
    $postal = $_POST['postal'];
    $fecha_pedido = date('Y-m-d');
    $fecha_entrega = date('Y-m-d', strtotime('+3 days'));
    $fk_id_user = 1; 
    $fk_tienda = 1;  

    // Insertar pedido
    $sql = "INSERT INTO pedidos (fecha_pedido, fecha_entrega, pais, ciudad, calle, postal, fk_id_user, fk_tienda) 
            VALUES ('$fecha_pedido', '$fecha_entrega', '$pais', '$ciudad', '$calle', '$postal', '$fk_id_user', '$fk_tienda')";

    if ($conn->query($sql) === TRUE) {
        $id_pedido = $conn->insert_id;

        // Insertar productos del carrito
        $stmt = $conn->prepare("INSERT INTO productos_pedidos (fk_producto, fk_pedido, cantidad) VALUES (?, ?, ?)");

        foreach ($carrito as $id_producto => $cantidad) {
            $stmt->bind_param("iii", $id_producto, $id_pedido, $cantidad);
            $stmt->execute();
        }

        $stmt->close();

        $mensaje = "¡Pedido realizado con éxito!";
        unset($_SESSION['carrito']);
        $carrito = [];
    } else {
        $mensaje = "Error al realizar el pedido: " . $conn->error;
    }
}

// Mostrar productos del carrito
$productos_detalle = [];
$total = 0;

if (!empty($carrito)) {
    foreach ($carrito as $id_producto => $cantidad) {
        $sql = "SELECT * FROM productos WHERE id_producto = $id_producto";
        $result = $conn->query($sql);
        if ($result && $result->num_rows > 0) {
            $producto = $result->fetch_assoc();
            $producto['cantidad'] = $cantidad;
            $producto['subtotal'] = $cantidad * $producto['precio'];
            $total += $producto['subtotal'];
            $productos_detalle[] = $producto;
        }
    }
}

$conn->close();
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Realizar Compra</title>
    <link rel="stylesheet" href="compra.css?v=2.0">
</head>
<body>
    <div class="contenedor">
        <div class="panel-izquierdo">
            <h2>Datos de Envío</h2>
            <form method="POST">
                <label>País</label>
                <input type="text" name="pais" required>

                <label>Ciudad</label>
                <input type="text" name="ciudad" required>

                <label>Calle</label>
                <input type="text" name="calle" required>

                <label>Código Postal</label>
                <input type="text" name="postal" required>

                <label>Fecha del Pedido</label>
                <input type="text" value="<?php echo date('Y-m-d'); ?>" readonly>

                <label>Fecha de Entrega</label>
                <input type="text" value="<?php echo date('Y-m-d', strtotime('+3 days')); ?>" readonly>

                <button type="submit" class="btn-compra">Realizar compra</button>
            </form>
            <?php if ($mensaje): ?>
                <p class='mensaje'><?php echo $mensaje; ?></p>
            <?php endif; ?>
        </div>

        <div class="panel-derecho">
            <h2>Productos en tu carrito</h2>
            <div class="productos">
                <?php if ($productos_detalle): ?>
                    <?php foreach ($productos_detalle as $p): ?>
                        <div class="etiqueta-producto">
                            <img src="<?php echo htmlspecialchars($p['imagen']); ?>" alt="Imagen">
                            <div>
                                <p><strong><?php echo htmlspecialchars($p['marca'] . ' ' . $p['modelo']); ?></strong></p>
                                <p>Cant: <?php echo $p['cantidad']; ?></p>
                                <p>Subtotal: €<?php echo number_format($p['subtotal'], 2); ?></p>
                            </div>
                        </div>
                    <?php endforeach; ?>
                    <div class="total">
                        <p><strong>Total: €<?php echo number_format($total, 2); ?></strong></p>
                    </div>
                <?php else: ?>
                    <p>No hay productos en el carrito.</p>
                <?php endif; ?>
            </div>
        </div>
    </div>
</body>
</html>
