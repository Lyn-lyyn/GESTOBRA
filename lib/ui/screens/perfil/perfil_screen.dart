import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/ui/screens/auth/login_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // Datos simulados del usuario
  final Map<String, String> _datosUsuario = {
    'nombre': 'Tilín Martínez Cruz',
    'puesto': 'Ing. Residente de Obra',
    'idEmpleado': '#892173',
    'especialidad': 'Construcción Civil',
    'vigencia': '2026 - 2027',
    'edad': '32 años',
    'fechaNacimiento': '15 de Marzo de 1994',
    'curp': 'MACR940315HDFRZN01',
    'telefono': '+52 271 123 4567',
    'correo': 'tilin.martinez@gestobra.com',
    'direccion': 'Av. Independencia #402, Col. Centro, Córdoba, Ver.',
    'tipoSangre': 'O+ (Positivo)',
    'alergias': 'Penicilina, Polvo',
    'padecimientos': 'Hipertensión leve controlada',
    'contactoEmergencia': 'María Cruz (Madre)',
    'telEmergencia': '+52 271 987 6543',
  };

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  void _cambiarFoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad para subir foto próximamente...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final desktop = _isDesktop(context);

    return Scaffold(
      backgroundColor: desktop ? const Color(0xFFF9F9FB) : AppColors.blanco,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double pad = (constraints.maxWidth * 0.02).clamp(16.0, 32.0);

            return SingleChildScrollView(
              padding: EdgeInsets.all(pad),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: desktop
                      ? _buildDesktopLayout()
                      : _buildMobileLayout(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // DISEÑO ESCRITORIO (2 Columnas Mejorado)
  // ============================================================
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Columna IZQUIERDA: Credencial ───
        SizedBox(
          width: 380,
          child: _buildCredencialFisica(),
        ),
        const SizedBox(width: 24),
        
        // ─── Columna DERECHA: Panel de Información ───
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDesktopHeaderInfo(),
              const SizedBox(height: 24),
              
              // Grid de 2 columnas para la información
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildDesktopSectionCard('Datos Generales', [
                          _buildInfoRow(Icons.person_outline, 'Edad', _datosUsuario['edad']!),
                          _buildInfoRow(Icons.cake_outlined, 'Fecha de Nacimiento', _datosUsuario['fechaNacimiento']!),
                          _buildInfoRow(Icons.badge_outlined, 'CURP', _datosUsuario['curp']!),
                          _buildInfoRow(Icons.home_outlined, 'Dirección', _datosUsuario['direccion']!),
                        ]),
                        const SizedBox(height: 24),
                        _buildDesktopSectionCard('Datos de Contacto', [
                          _buildInfoRow(Icons.phone_outlined, 'Teléfono', _datosUsuario['telefono']!),
                          _buildInfoRow(Icons.email_outlined, 'Correo Electrónico', _datosUsuario['correo']!),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        _buildDesktopSectionCard('Información Médica (Emergencias)', [
                          _buildInfoRow(Icons.bloodtype_outlined, 'Tipo de Sangre', _datosUsuario['tipoSangre']!, isImportant: true),
                          _buildInfoRow(Icons.warning_amber_outlined, 'Alergias', _datosUsuario['alergias']!, isImportant: true),
                          _buildInfoRow(Icons.medical_services_outlined, 'Padecimientos', _datosUsuario['padecimientos']!),
                          const Divider(height: 20, color: Colors.black12),
                          _buildInfoRow(Icons.contact_emergency_outlined, 'Contacto de Emergencia', _datosUsuario['contactoEmergencia']!, isImportant: true),
                          _buildInfoRow(Icons.phone_in_talk_outlined, 'Tel. Emergencia', _datosUsuario['telEmergencia']!, isImportant: true),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildDesktopCerrarSesion(),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Widgets exclusivos de la vista de Escritorio ───

  Widget _buildDesktopHeaderInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Mi Perfil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              SizedBox(height: 4),
              Text('Gestiona tu información personal y de contacto', style: TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Módulo de edición en desarrollo...')));
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Editar Perfil'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.naranja,
              side: const BorderSide(color: AppColors.naranja),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSectionCard(String titulo, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.naranja),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDesktopCerrarSesion() {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 250,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.estadoRojo.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.estadoRojo.withOpacity(0.3), width: 1.2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.logout, color: AppColors.estadoRojo, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'CERRAR SESIÓN',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.estadoRojo,
                        letterSpacing: 0.5,
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

  // ============================================================
  // DISEÑO MÓVIL (Sin cambios)
  // ============================================================
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCredencialFisica(),
        const SizedBox(height: 20),
        _buildPanelInformacion(),
        const SizedBox(height: 20),
        _buildOpcionCerrarSesion(),
      ],
    );
  }

  // ============================================================
  // WIDGETS COMPARTIDOS (Móvil)
  // ============================================================
  Widget _buildCredencialFisica() {
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
                    Icon(Icons.engineering, color: AppColors.naranja, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'GESTOBRA ID',
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
                    'OFICIAL',
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
                Stack(
                  alignment: Alignment.bottomRight,
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
                    InkWell(
                      onTap: _cambiarFoto,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.naranja,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _datosUsuario['nombre']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textoNegro,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _datosUsuario['puesto']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.naranja,
                    letterSpacing: 0.5,
                  ),
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
                      _buildFilaCredencial('ID Empleado', _datosUsuario['idEmpleado']!),
                      const Divider(height: 16, color: AppColors.gris),
                      _buildFilaCredencial('Especialidad', _datosUsuario['especialidad']!),
                      const Divider(height: 16, color: AppColors.gris),
                      _buildFilaCredencial('Vigencia', _datosUsuario['vigencia']!),
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
                  '*892173-GESTOBRA-CIVIL*',
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.textoGris,
                    fontFamily: 'monospace',
                    letterSpacing: 1.5,
                  ),
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
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textoGris, fontWeight: FontWeight.w500),
        ),
        Text(
          valor,
          style: const TextStyle(fontSize: 12, color: AppColors.textoNegro, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPanelInformacion() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Información del Personal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textoNegro),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Módulo de edición en desarrollo...')),
                  );
                },
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Editar', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.naranja,
                  side: const BorderSide(color: AppColors.naranja),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSubtitulo('Datos Generales'),
          const SizedBox(height: 10),
          _buildInfoCard([
            _buildInfoRow(Icons.person_outline, 'Edad', _datosUsuario['edad']!),
            _buildInfoRow(Icons.cake_outlined, 'Fecha de Nacimiento', _datosUsuario['fechaNacimiento']!),
            _buildInfoRow(Icons.badge_outlined, 'CURP', _datosUsuario['curp']!),
            _buildInfoRow(Icons.home_outlined, 'Dirección', _datosUsuario['direccion']!),
          ]),
          const SizedBox(height: 20),
          _buildSubtitulo('Datos de Contacto'),
          const SizedBox(height: 10),
          _buildInfoCard([
            _buildInfoRow(Icons.phone_outlined, 'Teléfono', _datosUsuario['telefono']!),
            _buildInfoRow(Icons.email_outlined, 'Correo Electrónico', _datosUsuario['correo']!),
          ]),
          const SizedBox(height: 20),
          _buildSubtitulo('Información Médica (Emergencias)'),
          const SizedBox(height: 10),
          _buildInfoCard([
            _buildInfoRow(Icons.bloodtype_outlined, 'Tipo de Sangre', _datosUsuario['tipoSangre']!, isImportant: true),
            _buildInfoRow(Icons.warning_amber_outlined, 'Alergias', _datosUsuario['alergias']!, isImportant: true),
            _buildInfoRow(Icons.medical_services_outlined, 'Padecimientos', _datosUsuario['padecimientos']!),
            const Divider(height: 20, color: AppColors.gris),
            _buildInfoRow(Icons.contact_emergency_outlined, 'Contacto de Emergencia', '${_datosUsuario['contactoEmergencia']} - ${_datosUsuario['telEmergencia']}', isImportant: true),
          ]),
        ],
      ),
    );
  }

  Widget _buildSubtitulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.naranja,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gris.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String valor, {bool isImportant = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: isImportant ? AppColors.estadoRojo : AppColors.textoGris),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textoGris, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valor,
              style: TextStyle(
                fontSize: 13,
                color: isImportant ? AppColors.estadoRojo : AppColors.textoNegro,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpcionCerrarSesion() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.estadoRojo.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.logout, color: AppColors.estadoRojo, size: 20),
                SizedBox(width: 10),
                Text(
                  'CERRAR SESIÓN',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.estadoRojo,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}