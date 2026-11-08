import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://gestobra67.alwaysdata.net';

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final token = await AuthService.obtenerToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await AuthService.obtenerToken();
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> uploadFile(
    String endpoint, {
    required Map<String, String> fields,
    required Uint8List bytes,
    required String fileName,
    String fileField = 'archivo',
  }) async {
    final token = await AuthService.obtenerToken();
    final request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/$endpoint'))
          ..headers['Authorization'] = 'Bearer $token'
          ..fields.addAll(fields)
          ..files.add(
            http.MultipartFile.fromBytes(fileField, bytes, filename: fileName),
          );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw const FormatException('Respuesta inesperada del servidor');
  }

  // 👇 MÉTODO QUE FALTABA 👇
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final token = await AuthService.obtenerToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }
}
