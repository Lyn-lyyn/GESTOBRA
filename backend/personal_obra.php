<?php
require_once 'auth_helper.php';

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Allow-Methods: GET, OPTIONS');
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
]);

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode([
        'estado' => false,
        'mensaje' => 'Método no permitido',
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

$idObra = isset($_GET['id_obra']) ? (int) $_GET['id_obra'] : 0;
if ($idObra <= 0) {
    http_response_code(400);
    echo json_encode([
        'estado' => false,
        'mensaje' => 'ID de obra requerido',
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $db = new Conexion();
    $conn = $db->obtenerConexion();
    if ($usuario['rol'] === 'SUPERVISOR') {
        $acceso = $conn->prepare(
            'SELECT 1 FROM obra_usuario
             WHERE id_obra = :id_obra AND id_usuario = :id_usuario AND activo = 1
             LIMIT 1',
        );
        $acceso->execute([
            ':id_obra' => $idObra,
            ':id_usuario' => (int) $usuario['id_usuario'],
        ]);
        if (!$acceso->fetchColumn()) {
            http_response_code(403);
            echo json_encode([
                'estado' => false,
                'mensaje' => 'No tienes acceso al personal de esta obra.',
            ], JSON_UNESCAPED_UNICODE);
            exit();
        }
    }

    $sql = "SELECT DISTINCT
                u.id_usuario,
                TRIM(CONCAT_WS(' ',
                    NULLIF(TRIM(u.nombre), ''),
                    NULLIF(TRIM(u.apellido_paterno), ''),
                    NULLIF(TRIM(u.apellido_materno), '')
                )) AS nombre_completo,
                ou.tipo_asignacion
            FROM obra_usuario ou
            INNER JOIN usuarios u ON u.id_usuario = ou.id_usuario
            WHERE ou.id_obra = :id_obra
              AND ou.activo = 1
              AND u.activo = 1
            ORDER BY nombre_completo ASC";
    $stmt = $conn->prepare($sql);
    $stmt->execute([':id_obra' => $idObra]);

    echo json_encode([
        'estado' => true,
        'data' => $stmt->fetchAll(),
    ], JSON_UNESCAPED_UNICODE);
} catch (Throwable $error) {
    http_response_code(500);
    echo json_encode([
        'estado' => false,
        'mensaje' => 'No se pudo cargar el personal de la obra.',
    ], JSON_UNESCAPED_UNICODE);
}
