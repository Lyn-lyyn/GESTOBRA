import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// IMPORTA TUS ARCHIVOS (Asegúrate de que las rutas sean correctas)
import 'config/theme/app_theme.dart';
import 'ui/screens/auth/login_screen.dart';

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GestObra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'MX'),
      ],
      home: const LoginScreen(),
    );
  }
}

// ============================================================
// FUNCIÓN DE PRUEBA (Puedes dejarla aquí temporalmente o borrarla)
// ============================================================
Future<void> probarConexion() async {
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