import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> probarConexion() async {
  final url = Uri.parse('https://tu-dominio.alwaysdata.net/api/obtener_roles.php');
  
  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Respuesta recibida: ${data['datos']}');
    } else {
      print('Error en la petición: ${response.statusCode}');
    }
  } catch (e) {
    print('Excepción al conectar: $e');
  }
}