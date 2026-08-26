<?php
declare(strict_types=1);

$allowedOrigin = 'https://rede.ospro.pt';
$requestOrigin = $_SERVER['HTTP_ORIGIN'] ?? '';

if ($requestOrigin === $allowedOrigin) {
    header('Access-Control-Allow-Origin: ' . $allowedOrigin);
    header('Vary: Origin');
    header('Access-Control-Allow-Methods: POST, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type');
}

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code($requestOrigin === $allowedOrigin ? 204 : 403);
    exit;
}

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');

if ($requestOrigin !== $allowedOrigin) {
    http_response_code(403);
    echo json_encode([
        'ok' => false,
        'error' => 'Origin not allowed'
    ]);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'ok' => false,
        'error' => 'Method not allowed'
    ]);
    exit;
}

$body = json_decode(file_get_contents('php://input') ?: '', true);

if (!is_array($body)) {
    http_response_code(400);
    echo json_encode([
        'ok' => false,
        'error' => 'Invalid JSON'
    ]);
    exit;
}

$allowedStatuses = ['ok', 'http-error', 'blocked', 'timeout'];

$status = $body['status'] ?? null;
$durationMs = $body['duration_ms'] ?? null;
$httpStatus = $body['http_status'] ?? null;

if (!is_string($status) || !in_array($status, $allowedStatuses, true)) {
    http_response_code(422);
    echo json_encode([
        'ok' => false,
        'error' => 'Invalid status'
    ]);
    exit;
}

if (!is_int($durationMs) || $durationMs < 0 || $durationMs > 120000) {
    http_response_code(422);
    echo json_encode([
        'ok' => false,
        'error' => 'Invalid duration'
    ]);
    exit;
}

if (
    $httpStatus !== null &&
    (!is_int($httpStatus) || $httpStatus < 100 || $httpStatus > 599)
) {
    http_response_code(422);
    echo json_encode([
        'ok' => false,
        'error' => 'Invalid HTTP status'
    ]);
    exit;
}

$clientIp = $_SERVER['REMOTE_ADDR'] ?? 'desconhecido';

if (!empty($_SERVER['HTTP_CF_CONNECTING_IP'])) {
    $clientIp = $_SERVER['HTTP_CF_CONNECTING_IP'];
}

$record = [
    'status' => $status,
    'duration_ms' => $durationMs,
    'http_status' => $httpStatus,
    'reported_ip' => isset($body['reported_ip']) && is_string($body['reported_ip'])
        ? substr($body['reported_ip'], 0, 80)
        : null,
    'observed_ip' => $clientIp,
    'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? '',
    'created_at' => gmdate('c'),
];

$storageDir = __DIR__ . DIRECTORY_SEPARATOR . 'storage';
$storageFile = $storageDir . DIRECTORY_SEPARATOR . 'results.jsonl';

if (
    !is_dir($storageDir) &&
    !mkdir($storageDir, 0750, true) &&
    !is_dir($storageDir)
) {
    http_response_code(500);
    echo json_encode([
        'ok' => false,
        'error' => 'Storage unavailable'
    ]);
    exit;
}

$line = json_encode(
    $record,
    JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE
);

if ($line === false) {
    http_response_code(500);
    echo json_encode([
        'ok' => false,
        'error' => 'Could not encode result'
    ]);
    exit;
}

/*
 * Abrir o ficheiro com bloqueio exclusivo.
 * Isto evita que dois pedidos escrevam ao mesmo tempo.
 */
$handle = fopen($storageFile, 'c+');

if ($handle === false) {
    http_response_code(500);
    echo json_encode([
        'ok' => false,
        'error' => 'Could not open storage'
    ]);
    exit;
}

if (!flock($handle, LOCK_EX)) {
    fclose($handle);

    http_response_code(500);
    echo json_encode([
        'ok' => false,
        'error' => 'Could not lock storage'
    ]);
    exit;
}

/*
 * Ler o conteúdo atual.
 */
$content = stream_get_contents($handle);

if ($content === false) {
    flock($handle, LOCK_UN);
    fclose($handle);

    http_response_code(500);
    echo json_encode([
        'ok' => false,
        'error' => 'Could not read storage'
    ]);
    exit;
}

$content = trim($content);

/*
 * Se o ficheiro estiver vazio, criar o array JSON.
 */
if ($content === '') {
    $newContent = "[\n" . $line . "\n]\n";
} else {

    /*
     * O ficheiro tem de terminar em ].
     */
    if (substr($content, -1) !== ']') {
        flock($handle, LOCK_UN);
        fclose($handle);

        http_response_code(500);
        echo json_encode([
            'ok' => false,
            'error' => 'Invalid JSON storage'
        ]);
        exit;
    }

    /*
     * Remover o ] final.
     */
    $withoutClosingBracket = substr($content, 0, -1);

    /*
     * Remover espaços depois do último conteúdo.
     */
    $withoutClosingBracket = rtrim($withoutClosingBracket);

    /*
     * Se ainda só temos [, é o primeiro registo.
     * Caso contrário, adicionar vírgula.
     */
    if ($withoutClosingBracket === '[') {
        $newContent =
            "[\n" .
            $line .
            "\n]\n";
    } else {
        $newContent =
            $withoutClosingBracket .
            ",\n" .
            $line .
            "\n]\n";
    }
}

/*
 * Voltar ao início do ficheiro e substituir o conteúdo.
 */
if (ftruncate($handle, 0) === false) {
    flock($handle, LOCK_UN);
    fclose($handle);

    http_response_code(500);
    echo json_encode([
        'ok' => false,
        'error' => 'Could not truncate storage'
    ]);
    exit;
}

rewind($handle);

$written = fwrite($handle, $newContent);

if ($written === false || $written < strlen($newContent)) {
    flock($handle, LOCK_UN);
    fclose($handle);

    http_response_code(500);
    echo json_encode([
        'ok' => false,
        'error' => 'Could not save result'
    ]);
    exit;
}

fflush($handle);
flock($handle, LOCK_UN);
fclose($handle);

echo json_encode([
    'ok' => true,
    'saved_at' => $record['created_at']
]);
