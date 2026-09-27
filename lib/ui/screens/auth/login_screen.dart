import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../config/theme/app_colors.dart';
import '../../widgets/custom_textfield.dart';
import '../dashboard/main_scaffold.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
//ESTE ES EL LOGIN DE LA APP
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Detectar si es pantalla de escritorio (>= 900px)
  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScaffold()),
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
            child: Container(
              color: Colors.black.withValues(alpha: 0.38),
            ),
          ),
          SafeArea(
            child: _isDesktop(context)
            // ============ VISTA DE ESCRITORIO ============
            ? Row(
                children: [
                  // Columna IZQUIERDA: Panel de branding
                  Expanded(
                    flex: 1,
                    child: _buildBrandingPanel(),
                  ),
                  // Columna DERECHA: Formulario
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 48.0),
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
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.construction, color: Colors.white, size: 50),
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
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
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
            label: 'Correo electrónico',
            hint: 'ejemplo@empresa.com',
            icon: Icons.email_outlined,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            label: 'Contraseña',
            hint: '********',
            icon: Icons.lock_outline,
            isPassword: true,
            controller: _passwordController,
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
            child: _isLoading
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
                MaterialPageRoute(
                  builder: (context) => const RegisterScreen(),
                ),
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
