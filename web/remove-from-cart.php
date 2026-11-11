<?php
require_once __DIR__ . '/api-client.php';
start_store_session();
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    exit('Método no permitido.');
}
validar_csrf();
$id_producto = filter_input(INPUT_POST, 'id_producto', FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
$id_variante = filter_input(INPUT_POST, 'id_variante', FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
if (isset($_SESSION['carrito'][$id_producto][$id_variante])) {
    unset($_SESSION['carrito'][$id_producto][$id_variante]);
    if (!$_SESSION['carrito'][$id_producto]) {
        unset($_SESSION['carrito'][$id_producto]);
    }
}
header("Location: cart-summary.php");
exit();
?>
