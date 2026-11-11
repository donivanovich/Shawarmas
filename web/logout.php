<?php
require_once __DIR__ . '/api-client.php';
start_store_session();
if (!empty($_SESSION['api_token'])) {
    api_try('POST', '/auth/logout');
}
$_SESSION = [];
if (ini_get('session.use_cookies')) {
    $params = session_get_cookie_params();
    setcookie(session_name(), '', time() - 42000, $params['path'], $params['domain'], (bool) $params['secure'], (bool) $params['httponly']);
}
session_destroy();
header('Location: index.php');
exit();
?>
