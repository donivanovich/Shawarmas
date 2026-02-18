<?php
session_start();
$id_producto = intval($_POST['id_producto']);
if (isset($_SESSION['carrito'][$id_producto])) {
    unset($_SESSION['carrito'][$id_producto]);
}
header("Location: proceso_carrito.php");
exit();
?>