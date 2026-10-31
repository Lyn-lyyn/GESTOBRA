import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../config/theme/app_colors.dart';
import '../../widgets/custom_textfield.dart';
import '../dashboard/main_scaffold.dart';
import '../admin/admin_main_scaffold.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../servicios/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // Detectar si es pantalla de escritorio (>= 900px)
  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  Future<void> _handleLogin() async {
    final usuario = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (usuario.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa tus credenciales')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('https://gestobra67.alwaysdata.net/login.php');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({'usuario': usuario, 'password': password}),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      final data = jsonDecode(response.body);

    if (data['estado'] == true) {
  final user = data['usuario'] as Map<String, dynamic>;
  final token = data['token'] as String?;
  
  if (token != null) await AuthService.guardarSesion(token, user);

  final rol = (user['rol'] ?? '').toString();

  // RUTEO:
  if (rol == 'ADMINISTRADOR') {
    // El admin va directo al panel de administración
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminMainScaffold()),
    );
  } else {
    // El DESARROLLADOR y todos los demás van a la App Normal
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScaffold()),
    );
  }
} else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['mensaje'] ?? 'Credenciales incorrectas'),
            backgroundColor: AppColors.estadoRojo,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: AppColors.estadoRojo,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      body: Stack(
        children: [
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Image.asset(
                'assets/images/login_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.38)),
          ),
          SafeArea(
            child:
                _isDesktop(context)
                    // ============ VISTA DE ESCRITORIO ============
                    ? Row(
                      children: [
                        // Columna IZQUIERDA: Panel de branding
                        Expanded(flex: 1, child: _buildBrandingPanel()),
                        // Columna DERECHA: Formulario
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48.0,
                              ),
                              child: _buildLoginForm(),
                            ),
                          ),
                        ),
                      ],
                    )
                    // ============ VISTA DE MÓVIL ============
                    : Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo arriba del formulario
                            Image.asset(
                              'assets/images/logo_gestobra.png',
                              height: 72,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'GestObra',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textoNegro,
                              ),
                            ),
                            const SizedBox(height: 40),
                            _buildLoginForm(),
                          ],
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PANEL DE BRANDING (Solo Escritorio)
  // ============================================================
  Widget _buildBrandingPanel() {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo grande
            Row(
              children: [
                Image.asset(
                  'assets/images/logo_gestobra.png',
                  height: 50,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                        Icons.construction,
                        color: Colors.white,
                        size: 50,
                      ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'GestObra',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Gestiona tus obras\nciviles de forma\ninteligente.',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Supervisa avances, materiales, bitácoras y evidencias desde una sola plataforma.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            // Estadísticas decorativas
            Row(
              children: [
                _buildBrandStat('7', 'Obras activas'),
                const SizedBox(width: 32),
                _buildBrandStat('16', 'Registradas'),
                const SizedBox(width: 32),
                _buildBrandStat('98%', 'Eficiencia'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandStat(String valor, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          valor,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  // ============================================================
  // FORMULARIO DE LOGIN (Compartido entre móvil y escritorio)
  // ============================================================
  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Bienvenido',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ingresa tus credenciales para acceder a la plataforma',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textoGris, fontSize: 14),
          ),
          const SizedBox(height: 24),

          CustomTextField(
            label: 'Usuario o Correo electrónico',
            hint: 'ejemplo@empresa.com',
            icon: Icons.email_outlined,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            focusNode: _emailFocusNode,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _passwordFocusNode.requestFocus(),
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: 'Contraseña',
            hint: '********',
            icon: Icons.lock_outline,
            isPassword: true,
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (!_isLoading) _handleLogin();
            },
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(color: AppColors.naranja),
              ),
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.naranja,
              foregroundColor: AppColors.blanco,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.blanco,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text('INICIAR SESIÓN'),
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            },
            child: const Text(
              '¿No tienes una cuenta? Regístrate',
              style: TextStyle(
                color: AppColors.naranja,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
