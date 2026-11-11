<?php
declare(strict_types=1);

final class ApiClientException extends RuntimeException
{
    public function __construct(public readonly int $status, string $message)
    {
        parent::__construct($message);
    }
}

function api_request(string $method, string $path, ?array $payload = null, bool $authenticated = true): array
{
    $baseUrl = rtrim((string) (getenv('API_BASE_URL') ?: ($_SERVER['API_BASE_URL'] ?? $_ENV['API_BASE_URL'] ?? '')), '/');
    if ($baseUrl === '') {
        error_log('Shawarmas API configuration error: API_BASE_URL is not set.');
        throw new ApiClientException(503, 'The store service is temporarily unavailable. Please try again.');
    }
    if (!function_exists('curl_init')) {
        throw new ApiClientException(503, 'The store service is temporarily unavailable. Please try again.');
    }

    if ($authenticated && $path !== '/auth/refresh' && !empty($_SESSION['api_token']) && (int) ($_SESSION['api_expires_at'] ?? 0) - time() < 300) {
        try {
            $refreshed = api_request('POST', '/auth/refresh');
            $_SESSION['api_token'] = (string) ($refreshed['token'] ?? '');
            $_SESSION['api_expires_at'] = time() + (int) ($refreshed['expiresIn'] ?? 0);
            if ($_SESSION['api_token'] === '') {
                throw new ApiClientException(401, 'Your session has expired. Please sign in again.');
            }
        } catch (ApiClientException $error) {
            unset($_SESSION['api_token'], $_SESSION['api_expires_at'], $_SESSION['id_user'], $_SESSION['nombre'], $_SESSION['apellido1'], $_SESSION['apellido2'], $_SESSION['mail'], $_SESSION['nombre_completo']);
            throw new ApiClientException(401, 'Your session has expired. Please sign in again.');
        }
    }

    $headers = ['Accept: application/json'];
    if ($payload !== null) {
        $headers[] = 'Content-Type: application/json';
    }
    if ($authenticated && !empty($_SESSION['api_token'])) {
        $headers[] = 'Authorization: Bearer ' . (string) $_SESSION['api_token'];
    } elseif ($authenticated) {
        throw new ApiClientException(401, 'Sign in is required.');
    }

    $handle = curl_init($baseUrl . '/' . ltrim($path, '/'));
    curl_setopt_array($handle, [
        CURLOPT_CUSTOMREQUEST => strtoupper($method),
        CURLOPT_HTTPHEADER => $headers,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_CONNECTTIMEOUT => 3,
        CURLOPT_TIMEOUT => 12,
        CURLOPT_FOLLOWLOCATION => false,
        CURLOPT_SSL_VERIFYPEER => true,
        CURLOPT_SSL_VERIFYHOST => 2,
    ]);
    if ($payload !== null) {
        curl_setopt($handle, CURLOPT_POSTFIELDS, json_encode($payload, JSON_THROW_ON_ERROR));
    }
    $raw = curl_exec($handle);
    $status = (int) curl_getinfo($handle, CURLINFO_RESPONSE_CODE);
    if ($raw === false) {
        $message = curl_error($handle);
        curl_close($handle);
        error_log('Shawarmas API transport error: ' . $message);
        throw new ApiClientException(503, 'The store service is temporarily unavailable. Please try again.');
    }
    curl_close($handle);

    if ($status === 204 || $raw === '') {
        return [];
    }
    $decoded = json_decode($raw, true);
    if (!is_array($decoded)) {
        throw new ApiClientException(502, 'The store service returned an invalid response.');
    }
    if ($status < 200 || $status >= 300) {
        if ($status === 401) {
            unset($_SESSION['api_token'], $_SESSION['api_expires_at'], $_SESSION['id_user'], $_SESSION['nombre'], $_SESSION['apellido1'], $_SESSION['apellido2'], $_SESSION['mail'], $_SESSION['nombre_completo']);
        }
        $message = $decoded['error']['message'] ?? 'The request could not be completed.';
        throw new ApiClientException($status, is_string($message) ? $message : 'The request could not be completed.');
    }
    $GLOBALS['api_last_meta'] = $decoded['meta'] ?? [];
    return $decoded['data'] ?? [];
}

function api_try(string $method, string $path, ?array $payload = null, bool $authenticated = true): array
{
    try {
        return api_request($method, $path, $payload, $authenticated);
    } catch (ApiClientException $error) {
        return ['_error' => $error->getMessage(), '_status' => $error->status];
    } catch (Throwable $error) {
        error_log('Shawarmas API client error: ' . $error->getMessage());
        return ['_error' => 'The store service is temporarily unavailable. Please try again.', '_status' => 503];
    }
}

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
    return $baseUrl . '/' . ltrim($ruta, '/');
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
        exit('Solicitud no vÃ¡lida.');
    }
}

function start_store_session(): void
{
    if (session_status() === PHP_SESSION_ACTIVE) {
        return;
    }
    $secureCookie = filter_var(getenv('SESSION_COOKIE_SECURE') ?: (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off'), FILTER_VALIDATE_BOOLEAN);
    ini_set('session.use_strict_mode', '1');
    ini_set('session.use_only_cookies', '1');
    ini_set('session.gc_maxlifetime', '86400');
    session_start(['cookie_httponly' => true, 'cookie_samesite' => 'Lax', 'cookie_secure' => $secureCookie]);
}
