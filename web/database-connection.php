<?php
declare(strict_types=1);

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

$conn = new mysqli(
    getenv('DB_HOST') ?: '127.0.0.1',
    getenv('DB_USER') ?: (getenv('MYSQL_USER') ?: 'shawarmas_app'),
    getenv('DB_PASSWORD') ?: (getenv('MYSQL_PASSWORD') ?: 'cambia_esta_clave'),
    getenv('DB_NAME') ?: 'shawarmas',
    (int) (getenv('DB_PORT') ?: 3306)
);
$conn->set_charset('utf8mb4');

function imagen_url(?string $ruta): string
{
    $ruta = trim((string) $ruta);
    if ($ruta === '') {
        return '';
    }

    if (preg_match('/^https?:\/\//i', $ruta)) {
        return $ruta;
    }

    $baseUrl = rtrim((string) (getenv('IMAGE_BASE_URL') ?: 'http://localhost:3000'), '/');
    return $baseUrl . '/' . ltrim($ruta, '/') . '?v=20261110-3';
}

function escapar(string $valor): string
{
    return htmlspecialchars($valor, ENT_QUOTES, 'UTF-8');
}

function token_csrf(): string
{
    if (empty($_SESSION['token_csrf'])) {
        $_SESSION['token_csrf'] = bin2hex(random_bytes(32));
    }

    return $_SESSION['token_csrf'];
}

function validar_csrf(): void
{
    $token = $_POST['token_csrf'] ?? '';
    if (!is_string($token) || !hash_equals($_SESSION['token_csrf'] ?? '', $token)) {
        http_response_code(400);
        exit('Solicitud no válida.');
    }
}

function hash_password_shared(string $password): string
{
    $salt = random_bytes(16);
    $hash = hash_pbkdf2('sha256', $password, $salt, 120000, 32, true);

    return 'pbkdf2$' . base64_encode($salt) . '$' . base64_encode($hash);
}

function verify_password_shared(string $password, string $storedHash): bool
{
    if (str_starts_with($storedHash, 'pbkdf2$')) {
        $parts = explode('$', $storedHash);
        if (count($parts) !== 3) {
            return false;
        }

        $salt = base64_decode($parts[1], true);
        $expected = base64_decode($parts[2], true);
        if ($salt === false || $expected === false) {
            return false;
        }

        return hash_equals($expected, hash_pbkdf2('sha256', $password, $salt, 120000, strlen($expected), true));
    }

    return password_verify($password, $storedHash);
}
