import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../widgets/custom_textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _correoController = TextEditingController();
  bool _isLoading = false;

  void _handleRecovery() async {
    if (_correoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe tu correo electrónico'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Si el correo está registrado, recibirás instrucciones para recuperar tu contraseña',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _correoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        backgroundColor: AppColors.naranja,
        foregroundColor: AppColors.blanco,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.blanco,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.lock_reset_outlined,
                      size: 70,
                      color: AppColors.naranja,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '¿Olvidaste tu contraseña?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textoNegro,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Escribe el correo asociado a tu cuenta y te enviaremos instrucciones para recuperar el acceso.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textoGris,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    CustomTextField(
                      label: 'Correo electrónico',
                      hint: 'ejemplo@empresa.com',
                      icon: Icons.email_outlined,
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleRecovery,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.naranja,
                        foregroundColor: AppColors.blanco,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: AppColors.blanco,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('ENVIAR INSTRUCCIONES'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Volver al inicio de sesión',
                        style: TextStyle(
                          color: AppColors.naranja,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}