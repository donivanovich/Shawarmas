<?php
session_start();

// Recibir datos del producto
$id_producto = intval($_POST['id_producto']);
$cantidad = intval($_POST['cantidad']);

if (!isset($_SESSION['carrito'])) {
    $_SESSION['carrito'] = [];
}

// Verificar si el producto ya está en el carrito
if (isset($_SESSION['carrito'][$id_producto])) {
    $_SESSION['carrito'][$id_producto] += $cantidad;
} else {
    $_SESSION['carrito'][$id_producto] = $cantidad;
}

header("Location: proceso_carrito.php");
exit();
?>