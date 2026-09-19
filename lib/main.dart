import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Prueba de Conexión GestObra'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: probarConexion,
            child: const Text('Probar Conexión con AlwaysData'),
          ),
        ),
      ),
    );
  }
}

// Función para probar la conexión HTTP
Future<void> probarConexion() async {
  // Apunta al script de prueba
  final url = Uri.parse('https://gestobra.alwaysdata.net/test_conexion.php');

  try {
    print('Enviando petición a la base de datos...');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('--- RESPUESTA EXITOSA ---');
      print('Mensaje del servidor: ${data['mensaje']}');
    } else {
      print('Error en la petición: Código ${response.statusCode}');
      print('Detalle del error: ${response.body}');
    }
  } catch (e) {
    print('Excepción al conectar con la API: $e');
  }
}