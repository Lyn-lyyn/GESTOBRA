import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _apellidoPaternoController = TextEditingController();
  final _apellidoMaternoController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();

  bool _isLoading = false;

  void _handleRegister() async {
    if (_nombreController.text.trim().isEmpty ||
        _apellidoPaternoController.text.trim().isEmpty ||
        _correoController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmarPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos obligatorios'),
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmarPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
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
        content: Text('Registro completado correctamente'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: AppColors.naranja,
        foregroundColor: AppColors.blanco,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.blanco,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Crear una cuenta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textoNegro,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ingresa tus datos para registrarte en GestObra',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textoGris,
                      ),
                    ),
                    const SizedBox(height: 24),

                    CustomTextField(
                      label: 'Nombre *',
                      hint: 'Escribe tu nombre',
                      icon: Icons.person_outline,
                      controller: _nombreController,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Apellido paterno *',
                      hint: 'Escribe tu apellido paterno',
                      icon: Icons.person_outline,
                      controller: _apellidoPaternoController,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Apellido materno',
                      hint: 'Escribe tu apellido materno',
                      icon: Icons.person_outline,
                      controller: _apellidoMaternoController,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Correo electrónico *',
                      hint: 'ejemplo@empresa.com',
                      icon: Icons.email_outlined,
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Teléfono',
                      hint: '10 dígitos',
                      icon: Icons.phone_outlined,
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Contraseña *',
                      hint: 'Crea una contraseña',
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Confirmar contraseña *',
                      hint: 'Repite tu contraseña',
                      icon: Icons.lock_reset_outlined,
                      controller: _confirmarPasswordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
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
                          : const Text('CREAR CUENTA'),
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