import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  void _mostrarCredencialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.gris, width: 1.5),
        ),
        backgroundColor: AppColors.blanco,
        contentPadding: EdgeInsets.zero,
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Cabecera tipo Credencial de Ingeniería Civil ───
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                decoration: const BoxDecoration(
                  color: AppColors.textoNegro,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(19),
                    topRight: Radius.circular(19),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.engineering, color: AppColors.naranja, size: 26),
                        SizedBox(width: 8),
                        Text(
                          'GESTOBRA ID',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.naranja,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'OFICIAL',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Cuerpo de la credencial ───
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Foto con marco industrial
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.naranja, width: 3),
                      ),
                      child: const CircleAvatar(
                        radius: 42,
                        backgroundColor: AppColors.grisfondo,
                        child: Icon(Icons.person, size: 50, color: AppColors.naranja),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Tilín Martínez',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textoNegro,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ing. Residente de Obra',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.naranja,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tarjeta contenedora de datos
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.grisfondo,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gris, width: 1.2),
                      ),
                      child: Column(
                        children: [
                          _buildDatoModalFila('ID Empleado', '#892173'),
                          const Divider(height: 16, color: AppColors.gris),
                          _buildDatoModalFila('Especialidad', 'Construcción Civil'),
                          const Divider(height: 16, color: AppColors.gris),
                          _buildDatoModalFila('Vigencia', '2026 - 2027'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Código de barras simulado corporativo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        24,
                        (index) => Container(
                          width: index % 3 == 0 ? 3 : (index % 2 == 0 ? 2 : 4),
                          height: 28,
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          color: AppColors.textoNegro,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '*892173-GESTOBRA-CIVIL*',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.textoGris,
                        fontFamily: 'monospace',
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.naranja,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cerrar Credencial',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatoModalFila(String label, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textoGris,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textoNegro,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double pad = (constraints.maxWidth * 0.02).clamp(16.0, 24.0);

          return SingleChildScrollView(
            padding: EdgeInsets.all(pad),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─── Contenedor Principal del Perfil ───
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.grisfondo,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.gris,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ─── Cabecera de foto y nombre ───
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.naranja,
                                      width: 3,
                                    ),
                                  ),
                                  child: const CircleAvatar(
                                    radius: 50,
                                    backgroundColor: AppColors.blanco,
                                    child: Icon(
                                      Icons.person,
                                      size: 56,
                                      color: AppColors.naranja,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Tilín Martínez',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textoNegro,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Ing. Residente de Obra',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.naranja,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onTap: () {
                                    // Acción para cambiar foto
                                  },
                                  child: const Text(
                                    'Cambiar foto de perfil',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textoGris,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ─── Título de sección ───
                          const Text(
                            'Mi Perfil',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textoNegro,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ─── Opciones Principales (Mis Datos y Cerrar Sesión) ───
                          _buildOpcionItem(
                            icon: Icons.badge_outlined,
                            titulo: 'Mis Datos',
                            subtitulo: 'Ver credencial e información de empleado',
                            onTap: () => _mostrarCredencialDialog(context),
                          ),
                          const SizedBox(height: 12),
                          _buildOpcionItem(
                            icon: Icons.logout,
                            titulo: 'Cerrar Sesión',
                            subtitulo: 'Salir del sistema de forma segura',
                            esRojo: true,
                            onTap: () {
                              // Acción cerrar sesión
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOpcionItem({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
    bool esRojo = false,
  }) {
    final colorItem = esRojo ? AppColors.estadoRojo : AppColors.textoNegro;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gris,
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorItem.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: colorItem, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorItem,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitulo,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textoGris,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 13,
                  color: AppColors.textoGris,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}