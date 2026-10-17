import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/ui/screens/auth/login_screen.dart';

class AdminPerfilScreen extends StatelessWidget {
  const AdminPerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            final double pad = (constraints.maxWidth * 0.02).clamp(16.0, 24.0);

            return SingleChildScrollView(
              padding: EdgeInsets.all(pad),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 380,
                              child: _buildCredencialAdmin(),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildResumenActividad(),
                                  const SizedBox(height: 20),
                                  // 🔴 AQUÍ PASAMOS EL CONTEXT
                                  _buildOpciones(context), 
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildCredencialAdmin(),
                            const SizedBox(height: 24),
                            _buildResumenActividad(),
                            const SizedBox(height: 24),
                            // 🔴 AQUÍ PASAMOS EL CONTEXT
                            _buildOpciones(context),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // TARJETA DE CREDENCIAL DEL ADMINISTRADOR
  // ============================================================
  Widget _buildCredencialAdmin() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gris, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: const BoxDecoration(
              color: AppColors.textoNegro,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: AppColors.naranja, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'GESTOBRA ADMIN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.naranja,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'SISTEMA',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.naranja, width: 3),
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.grisfondo,
                    child: Icon(Icons.person, size: 60, color: AppColors.naranja),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Administrador del Sistema',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textoNegro),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Super Administrador',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.naranja, letterSpacing: 0.5),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.grisfondo,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gris.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    children: [
                      _buildFilaCredencial('Usuario', 'admin'),
                      const Divider(height: 16, color: AppColors.gris),
                      _buildFilaCredencial('Acceso', 'Global / Total'),
                      const Divider(height: 16, color: AppColors.gris),
                      _buildFilaCredencial('Último Login', 'Hoy, 08:30 AM'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    28,
                    (index) => Container(
                      width: index % 3 == 0 ? 3 : (index % 2 == 0 ? 2 : 4),
                      height: 32,
                      margin: const EdgeInsets.symmetric(horizontal: 1.2),
                      color: AppColors.textoNegro,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '*000001-ADMIN-GESTOBRA*',
                  style: TextStyle(fontSize: 9, color: AppColors.textoGris, fontFamily: 'monospace', letterSpacing: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilaCredencial(String label, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textoGris, fontWeight: FontWeight.w500)),
        Text(valor, style: const TextStyle(fontSize: 12, color: AppColors.textoNegro, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ============================================================
  // PANEL DE RESUMEN DE ACTIVIDAD
  // ============================================================
  Widget _buildResumenActividad() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.grisfondo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gris, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de Actividad de Administración',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textoNegro),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Obras Creadas', '12', Icons.add_business, AppColors.naranja),
              _buildMiniStat('Personal Asignado', '34', Icons.assignment_ind, AppColors.estadoVerde),
              _buildMiniStat('Reportes Revisados', '86', Icons.description, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String titulo, String valor, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(valor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textoNegro)),
        Text(titulo, style: const TextStyle(fontSize: 11, color: AppColors.textoGris)),
      ],
    );
  }

  // ============================================================
  // OPCIONES (Seguridad, Configuración, Cerrar Sesión)
  // ============================================================
  // 🔴 RECIBIMOS EL CONTEXT AQUÍ
  Widget _buildOpciones(BuildContext context) {
    return Column(
      children: [
        // 🔴 SE LO PASAMOS AL ITEM
        _buildOpcionItem(
          context: context, 
          icon: Icons.security,
          titulo: 'Seguridad de la Cuenta',
          subtitulo: 'Cambiar contraseña maestra del administrador',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Módulo de seguridad en desarrollo...')));
          },
        ),
        const SizedBox(height: 12),
        _buildOpcionItem(
          context: context,
          icon: Icons.settings,
          titulo: 'Configuración Global',
          subtitulo: 'Gestión de catálogos, tarifas base y parámetros del sistema',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Módulo de configuración en desarrollo...')));
          },
        ),
        const SizedBox(height: 12),
        _buildOpcionItem(
          context: context,
          icon: Icons.logout,
          titulo: 'Cerrar Sesión',
          subtitulo: 'Salir del sistema de forma segura',
          esRojo: true,
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  // 🔴 RECIBIMOS EL CONTEXT AQUÍ TAMBIÉN
  Widget _buildOpcionItem({
    required BuildContext context, // <-- Añadido
    required IconData icon, 
    required String titulo, 
    required String subtitulo, 
    required VoidCallback onTap, 
    bool esRojo = false
  }) {
    final color = esRojo ? AppColors.estadoRojo : AppColors.textoNegro;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gris, width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
                      const SizedBox(height: 4),
                      Text(subtitulo, style: const TextStyle(fontSize: 12, color: AppColors.textoGris)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textoGris),
              ],
            ),
          ),
        ),
      ),
    );
  }
}