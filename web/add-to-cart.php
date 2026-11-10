<?php
session_start();
require_once __DIR__ . '/database-connection.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    exit('Método no permitido.');
}
validar_csrf();
$id_producto = filter_input(INPUT_POST, 'id_producto', FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
$cantidad = filter_input(INPUT_POST, 'cantidad', FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
$id_variante = filter_input(INPUT_POST, 'id_variante', FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
if (!$id_producto || !$cantidad || !$id_variante) {
    http_response_code(400);
    exit('Producto, talla o cantidad no válidos.');
}
$stmt = $conn->prepare('SELECT v.stock FROM producto_variantes v WHERE v.id_variante = ? AND v.fk_producto = ?');
$stmt->bind_param('ii', $id_variante, $id_producto);
$stmt->execute();
$variante = $stmt->get_result()->fetch_assoc();
$stmt->close();
if (!$variante) {
    http_response_code(400);
    exit('La talla seleccionada no es válida.');
}
if (!isset($_SESSION['carrito'])) {
    $_SESSION['carrito'] = [];
}

if (!isset($_SESSION['carrito'][$id_producto]) || !is_array($_SESSION['carrito'][$id_producto])) {
    $_SESSION['carrito'][$id_producto] = [];
}
$cantidadEnCarrito = (int) ($_SESSION['carrito'][$id_producto][$id_variante] ?? 0);
$cantidadDisponible = max(0, (int) $variante['stock'] - $cantidadEnCarrito);
if ($cantidadDisponible < 1) {
    http_response_code(400);
    exit('El producto ya no tiene unidades disponibles.');
}
$cantidadAAgregar = min($cantidad, $cantidadDisponible);
if (isset($_SESSION['carrito'][$id_producto][$id_variante])) {
    $_SESSION['carrito'][$id_producto][$id_variante] += $cantidadAAgregar;
} else {
    $_SESSION['carrito'][$id_producto][$id_variante] = $cantidadAAgregar;
}

header("Location: cart-summary.php");
exit();
?>
