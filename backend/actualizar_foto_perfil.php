<?php
require_once 'auth_helper.php';

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Content-Type: application/json; charset=UTF-8');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$usuario = requireAuth([
    'ADMINISTRADOR',
    'DESARROLLADOR',
    'COORDINADOR_OBRAS',
    'SUPERVISOR',
    'CAPTURISTA',
    'CONSULTA',
]);

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'estado' => false,
        'mensaje' => 'Método no permitido',
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

if (!isset($_FILES['archivo'])) {
    http_response_code(400);
    echo json_encode([
        'estado' => false,
        'mensaje' => 'Selecciona una fotografía.',
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

$archivo = $_FILES['archivo'];
if ($archivo['error'] !== UPLOAD_ERR_OK) {
    http_response_code(400);
    echo json_encode([
        'estado' => false,
        'mensaje' => 'No se pudo recibir la fotografía.',
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

$limiteBytes = 8 * 1024 * 1024;
if ($archivo['size'] <= 0 || $archivo['size'] > $limiteBytes) {
    http_response_code(400);
    echo json_encode([
        'estado' => false,
        'mensaje' => 'La imagen debe pesar menos de 8 MB.',
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

$tiposPermitidos = [
    'image/jpeg' => 'jpg',
    'image/png' => 'png',
    'image/webp' => 'webp',
];
$finfo = new finfo(FILEINFO_MIME_TYPE);
$mime = $finfo->file($archivo['tmp_name']);
if (!isset($tiposPermitidos[$mime])) {
    http_response_code(415);
    echo json_encode([
        'estado' => false,
        'mensaje' => 'Formato no permitido. Usa JPG, PNG o WebP.',
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

$directorio = __DIR__ . '/uploads/perfiles';
if (!is_dir($directorio) && !mkdir($directorio, 0755, true) && !is_dir($directorio)) {
    http_response_code(500);
    echo json_encode([
        'estado' => false,
        'mensaje' => 'No se pudo preparar la carpeta de fotografías.',
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

$nombreArchivo = bin2hex(random_bytes(16)) . '.' . $tiposPermitidos[$mime];
$rutaDestino = $directorio . '/' . $nombreArchivo;
$fotoUrl = '/uploads/perfiles/' . $nombreArchivo;

if (!move_uploaded_file($archivo['tmp_name'], $rutaDestino)) {
    http_response_code(500);
    echo json_encode([
        'estado' => false,
        'mensaje' => 'No se pudo guardar la fotografía.',
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $db = new Conexion();
    $conn = $db->obtenerConexion();
    $stmt = $conn->prepare(
        'UPDATE usuarios SET foto_url = :foto_url WHERE id_usuario = :id_usuario'
    );
    $stmt->execute([
        ':foto_url' => $fotoUrl,
        ':id_usuario' => (int) $usuario['id_usuario'],
    ]);

    echo json_encode([
        'estado' => true,
        'mensaje' => 'Foto de perfil actualizada correctamente.',
        'foto_url' => $fotoUrl,
    ], JSON_UNESCAPED_UNICODE);
} catch (Throwable $error) {
    if (is_file($rutaDestino)) {
        unlink($rutaDestino);
    }
    http_response_code(500);
    echo json_encode([
        'estado' => false,
        'mensaje' => 'No se pudo actualizar la foto de perfil.',
    ], JSON_UNESCAPED_UNICODE);
}
