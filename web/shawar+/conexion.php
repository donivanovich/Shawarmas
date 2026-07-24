<?php
$servername = "localhost";
$username = "root";      // Usuario por defecto de WAMP
$password = "";       // Contraseña vacía por defecto
$dbname = "shawarmas";  // Nombre de tu base de datos

// Crear conexión
$conn = new mysqli($servername, $username, $password, $dbname);

// Verificar conexión
if ($conn->connect_error) {
    die("Conexión fallida: " . $conn->connect_error);
}

// Configurar charset (importante para acentos y ñ)
$conn->set_charset("utf8mb4");

// Opcional: Mensaje de éxito (solo para desarrollo)
// echo "Conexión exitosa";
?>