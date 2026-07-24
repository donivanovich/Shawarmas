<?php
// asi se conecta a la base de datos
$servername = "localhost";
$username = "root"; // este es el usuario por defecto de WAMP
$password = ""; // esta es la contraseña por defecto de WAMP (vacía)
$dbname = "shawarmas";

// Crear conexión con la base de datos
$conn = new mysqli($servername, $username, $password, $dbname);

// Verificar la conexión
if ($conn->connect_error) {
    die("Conexión fallida: " . $conn->connect_error);
}

// Procesar el formulario cuando se envía
$mensaje = "";
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Recoger y sanitizar los datos del formulario
    $nombre = htmlspecialchars($_POST['nombre']);
    $apellido1 = htmlspecialchars($_POST['apellido1']);
    $apellido2 = htmlspecialchars($_POST['apellido2']);
    $mail = htmlspecialchars($_POST['mail']);
    $passw = password_hash($_POST['passw'], PASSWORD_DEFAULT); // Encriptar la contraseña
    
    // Preparar la consulta SQL
    $sql = "INSERT INTO clientes (nombre, apellido1, apellido2, mail, passw) 
            VALUES (?, ?, ?, ?, ?)";
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssss", $nombre, $apellido1, $apellido2, $mail, $passw);
    
    // Ejecutar la consulta
    if ($stmt->execute()) {
        $mensaje = "Registro exitoso. ¡Bienvenido/a, $nombre!";
    } else {
        $mensaje = "Error: " . $sql . "<br>" . $conn->error;
    }
    
    $stmt->close();
}

$conn->close();
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>REGISTRO</title>
    <style>
        <?php include "registro.css"; ?>
    </style>
</head>
<body>
    <h1>Registro de Clientes</h1>
    <?php if (!empty($mensaje)): ?>
        <div class="mensaje <?php echo strpos($mensaje, 'Error') === false ? 'exito' : 'error'; ?>">
            <?php echo $mensaje; ?>
        </div>
    <?php endif; ?>
    <form action="registro.php" method="post">
        <div class="form-group">
            <label for="nombre">Nombre:</label>
            <input type="text" id="nombre" name="nombre" required>
        </div>
        
        <div class="form-group">
            <label for="apellido1">Primer Apellido:</label>
            <input type="text" id="apellido1" name="apellido1" required>
        </div>
        
        <div class="form-group">
            <label for="apellido2">Segundo Apellido:</label>
            <input type="text" id="apellido2" name="apellido2">
        </div>
        
        <div class="form-group">
            <label for="mail">Correo Electrónico:</label>
            <input type="email" id="mail" name="mail" required>
        </div>
        
        <div class="form-group">
            <label for="passw">Contraseña:</label>
            <input type="password" id="passw" name="passw" required>
        </div>
        
        <div class="form-group botones">
            <input type="submit" value="Registrarse">
            <a href="index.php" class="volver-btn">Volver</a>
        </div>
    </form>
</body>
</html>