import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/ui/screens/auth/login_screen.dart';
import 'package:gestobra/servicios/api_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Map<String, dynamic>? _perfil;
  bool _cargando = true;
  bool _guardando = false;
  String? _error;

  Map<String, String> get _datosUsuario {
    final perfil = _perfil ?? const <String, dynamic>{};
    final fechaNacimiento = _texto(perfil['fecha_nacimiento']);
    final nombre = [
          perfil['nombre'],
          perfil['apellido_paterno'],
          perfil['apellido_materno'],
        ]
        .map((parte) => _texto(parte, fallback: ''))
        .where((parte) => parte.isNotEmpty)
        .join(' ');

    return {
      'nombre': nombre.isEmpty ? 'Usuario' : nombre,
      'puesto': _texto(perfil['rol']),
      'idEmpleado': '#${_texto(perfil['id_usuario'])}',
      'especialidad': _texto(perfil['especialidad']),
      'vigencia': _formatearFecha(_texto(perfil['creado_en'])),
      'edad': _calcularEdad(fechaNacimiento),
      'fechaNacimiento': _formatearFecha(fechaNacimiento),
      'curp': _texto(perfil['curp']),
      'telefono': _texto(perfil['telefono']),
      'correo': _texto(perfil['correo']),
      'direccion': _texto(perfil['direccion']),
      'tipoSangre': _texto(perfil['tipo_sangre']),
      'alergias': _texto(perfil['alergias']),
      'padecimientos': _texto(perfil['padecimientos']),
      'contactoEmergencia': _texto(perfil['contacto_emergencia']),
      'telEmergencia': _texto(perfil['tel_emergencia']),
    };
  }

  String _texto(dynamic valor, {String fallback = 'No registrado'}) {
    final texto = valor?.toString().trim() ?? '';
    return texto.isEmpty || texto.toLowerCase() == 'null' ? fallback : texto;
  }

  String _formatearFecha(String fecha) {
    if (fecha.isEmpty || fecha == 'No registrado') return 'No registrada';
    final date = DateTime.tryParse(fecha);
    if (date == null) return fecha;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _calcularEdad(String fechaNacimiento) {
    final nacimiento = DateTime.tryParse(fechaNacimiento);
    if (nacimiento == null) return 'No registrada';
    final hoy = DateTime.now();
    var edad = hoy.year - nacimiento.year;
    if (hoy.month < nacimiento.month ||
        (hoy.month == nacimiento.month && hoy.day < nacimiento.day)) {
      edad--;
    }
    return '$edad años';
  }

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<bool> _cargarPerfil() async {
    if (mounted) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }
    try {
      final respuesta = await ApiService.get('perfil.php');
      if (respuesta['estado'] != true || respuesta['data'] is! Map) {
        throw Exception('No se recibió el perfil');
      }
      if (!mounted) return false;
      setState(() {
        _perfil = Map<String, dynamic>.from(respuesta['data'] as Map);
        _cargando = false;
      });
      return true;
    } catch (_) {
      if (!mounted) return false;
      setState(() {
        _error =
            'No se pudo cargar el perfil. Revisa tu conexión e inténtalo de nuevo.';
        _cargando = false;
      });
      return false;
    }
  }

  Future<void> _editarPerfil() async {
    final perfil = _perfil;
    if (perfil == null || _guardando) return;
    final cambios = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _EditarPerfilDialog(perfil: perfil),
    );
    if (cambios == null || !mounted) return;

    setState(() => _guardando = true);
    try {
      final respuesta = await ApiService.post('actualizar_perfil.php', cambios);
      if (respuesta['estado'] != true) {
        throw Exception(
          respuesta['mensaje']?.toString() ?? 'No se pudo guardar',
        );
      }
      final recargado = await _cargarPerfil();
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            recargado
                ? 'Perfil actualizado correctamente'
                : 'Cambios guardados, pero no se pudo recargar el perfil.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo actualizar el perfil. Inténtalo de nuevo.'),
        ),
      );
    }
  }

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  void _cambiarFoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('La edición de la foto aún no está conectada.'),
      ),
    );
  }

  ImageProvider? _fotoPerfil() {
    final foto = _perfil?['foto_url']?.toString().trim() ?? '';
    if (foto.isEmpty || foto.toLowerCase() == 'null') return null;
    final uri = Uri.tryParse(foto);
    if (uri == null) return null;
    final url =
        uri.hasScheme
            ? uri.toString()
            : Uri.parse(ApiService.baseUrl).resolve(foto).toString();
    return NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    final desktop = _isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      body: SafeArea(
        child:
            _cargando
                ? const Center(
                  child: CircularProgressIndicator(color: AppColors.naranja),
                )
                : _error != null
                ? _buildError()
                : LayoutBuilder(
                  builder: (context, constraints) {
                    final double pad = (constraints.maxWidth * 0.02).clamp(
                      16.0,
                      32.0,
                    );
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(pad),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1400),
                          child:
                              desktop
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

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: AppColors.textoGris,
            ),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _cargarPerfil,
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar de nuevo'),
            ),
          ],
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
        SizedBox(width: 380, child: _buildCredencialFisica()),
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
                          _buildInfoRow(
                            Icons.person_outline,
                            'Edad',
                            _datosUsuario['edad']!,
                          ),
                          _buildInfoRow(
                            Icons.cake_outlined,
                            'Fecha de Nacimiento',
                            _datosUsuario['fechaNacimiento']!,
                          ),
                          _buildInfoRow(
                            Icons.badge_outlined,
                            'CURP',
                            _datosUsuario['curp']!,
                          ),
                          _buildInfoRow(
                            Icons.home_outlined,
                            'Dirección',
                            _datosUsuario['direccion']!,
                          ),
                        ]),
                        const SizedBox(height: 24),
                        _buildDesktopSectionCard('Datos de Contacto', [
                          _buildInfoRow(
                            Icons.phone_outlined,
                            'Teléfono',
                            _datosUsuario['telefono']!,
                          ),
                          _buildInfoRow(
                            Icons.email_outlined,
                            'Correo Electrónico',
                            _datosUsuario['correo']!,
                          ),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        _buildDesktopSectionCard(
                          'Información Médica (Emergencias)',
                          [
                            _buildInfoRow(
                              Icons.bloodtype_outlined,
                              'Tipo de Sangre',
                              _datosUsuario['tipoSangre']!,
                              isImportant: true,
                            ),
                            _buildInfoRow(
                              Icons.warning_amber_outlined,
                              'Alergias',
                              _datosUsuario['alergias']!,
                              isImportant: true,
                            ),
                            _buildInfoRow(
                              Icons.medical_services_outlined,
                              'Padecimientos',
                              _datosUsuario['padecimientos']!,
                            ),
                            const Divider(height: 20, color: Colors.black12),
                            _buildInfoRow(
                              Icons.contact_emergency_outlined,
                              'Contacto de Emergencia',
                              _datosUsuario['contactoEmergencia']!,
                              isImportant: true,
                            ),
                            _buildInfoRow(
                              Icons.phone_in_talk_outlined,
                              'Tel. Emergencia',
                              _datosUsuario['telEmergencia']!,
                              isImportant: true,
                            ),
                          ],
                        ),
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
              Text(
                'Mi Perfil',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Gestiona tu información personal y de contacto',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          OutlinedButton.icon(
            onPressed: _guardando ? null : _editarPerfil,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(_guardando ? 'Guardando...' : 'Editar Perfil'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.naranja,
              side: const BorderSide(color: AppColors.naranja),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.naranja,
            ),
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
            border: Border.all(
              color: AppColors.estadoRojo.withOpacity(0.3),
              width: 1.2,
            ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
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
    final foto = _fotoPerfil();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bordeSuave, width: 1.5),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
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
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.grisfondo,
                        backgroundImage: foto,
                        child:
                            foto == null
                                ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppColors.naranja,
                                )
                                : null,
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
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
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
                    color: AppColors.blanco,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.bordeSuave.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildFilaCredencial(
                        'ID de usuario',
                        _datosUsuario['idEmpleado']!,
                      ),
                      const Divider(height: 16, color: AppColors.gris),
                      _buildFilaCredencial(
                        'Especialidad',
                        _datosUsuario['especialidad']!,
                      ),
                      const Divider(height: 16, color: AppColors.gris),
                      _buildFilaCredencial(
                        'Registrado',
                        _datosUsuario['vigencia']!,
                      ),
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
                Text(
                  '*ID-${_perfil?["id_usuario"] ?? "--"}-GESTOBRA*',
                  style: const TextStyle(
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
          style: const TextStyle(
            fontSize: 11,
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

  Widget _buildPanelInformacion() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bordeSuave, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Información del Personal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoNegro,
                ),
              ),
              OutlinedButton.icon(
                onPressed: _guardando ? null : _editarPerfil,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: Text(
                  _guardando ? 'Guardando...' : 'Editar',
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.naranja,
                  side: const BorderSide(color: AppColors.naranja),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSubtitulo('Datos Generales'),
          const SizedBox(height: 10),
          _buildInfoCard([
            _buildInfoRow(Icons.person_outline, 'Edad', _datosUsuario['edad']!),
            _buildInfoRow(
              Icons.cake_outlined,
              'Fecha de Nacimiento',
              _datosUsuario['fechaNacimiento']!,
            ),
            _buildInfoRow(Icons.badge_outlined, 'CURP', _datosUsuario['curp']!),
            _buildInfoRow(
              Icons.home_outlined,
              'Dirección',
              _datosUsuario['direccion']!,
            ),
          ]),
          const SizedBox(height: 20),
          _buildSubtitulo('Datos de Contacto'),
          const SizedBox(height: 10),
          _buildInfoCard([
            _buildInfoRow(
              Icons.phone_outlined,
              'Teléfono',
              _datosUsuario['telefono']!,
            ),
            _buildInfoRow(
              Icons.email_outlined,
              'Correo Electrónico',
              _datosUsuario['correo']!,
            ),
          ]),
          const SizedBox(height: 20),
          _buildSubtitulo('Información Médica (Emergencias)'),
          const SizedBox(height: 10),
          _buildInfoCard([
            _buildInfoRow(
              Icons.bloodtype_outlined,
              'Tipo de Sangre',
              _datosUsuario['tipoSangre']!,
              isImportant: true,
            ),
            _buildInfoRow(
              Icons.warning_amber_outlined,
              'Alergias',
              _datosUsuario['alergias']!,
              isImportant: true,
            ),
            _buildInfoRow(
              Icons.medical_services_outlined,
              'Padecimientos',
              _datosUsuario['padecimientos']!,
            ),
            const Divider(height: 20, color: AppColors.gris),
            _buildInfoRow(
              Icons.contact_emergency_outlined,
              'Contacto de Emergencia',
              '${_datosUsuario['contactoEmergencia']} - ${_datosUsuario['telEmergencia']}',
              isImportant: true,
            ),
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
        border: Border.all(color: AppColors.bordeSuave.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String valor, {
    bool isImportant = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: isImportant ? AppColors.estadoRojo : AppColors.textoGris,
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textoGris,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valor,
              style: TextStyle(
                fontSize: 13,
                color:
                    isImportant ? AppColors.estadoRojo : AppColors.textoNegro,
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
        border: Border.all(
          color: AppColors.estadoRojo.withValues(alpha: 0.4),
          width: 1.2,
        ),
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

class _EditarPerfilDialog extends StatefulWidget {
  final Map<String, dynamic> perfil;

  const _EditarPerfilDialog({required this.perfil});

  @override
  State<_EditarPerfilDialog> createState() => _EditarPerfilDialogState();
}

class _EditarPerfilDialogState extends State<_EditarPerfilDialog> {
  late final TextEditingController _fechaController;
  late final TextEditingController _curpController;
  late final TextEditingController _direccionController;
  late final TextEditingController _especialidadController;
  late final TextEditingController _tipoSangreController;
  late final TextEditingController _alergiasController;
  late final TextEditingController _padecimientosController;
  late final TextEditingController _contactoController;
  late final TextEditingController _telefonoEmergenciaController;

  @override
  void initState() {
    super.initState();
    _fechaController = TextEditingController(text: _valor('fecha_nacimiento'));
    _curpController = TextEditingController(text: _valor('curp'));
    _direccionController = TextEditingController(text: _valor('direccion'));
    _especialidadController = TextEditingController(
      text: _valor('especialidad'),
    );
    _tipoSangreController = TextEditingController(text: _valor('tipo_sangre'));
    _alergiasController = TextEditingController(text: _valor('alergias'));
    _padecimientosController = TextEditingController(
      text: _valor('padecimientos'),
    );
    _contactoController = TextEditingController(
      text: _valor('contacto_emergencia'),
    );
    _telefonoEmergenciaController = TextEditingController(
      text: _valor('tel_emergencia'),
    );
  }

  String _valor(String key) {
    final value = widget.perfil[key]?.toString() ?? '';
    return value == 'null' ? '' : value;
  }

  Future<void> _seleccionarFecha() async {
    final initial =
        DateTime.tryParse(_fechaController.text) ?? DateTime(2000, 1, 1);
    final fecha = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(DateTime.now()) ? DateTime.now() : initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      locale: const Locale('es', 'MX'),
    );
    if (fecha == null) return;
    setState(() {
      _fechaController.text =
          '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
    });
  }

  void _guardar() {
    Navigator.of(context).pop({
      'fecha_nacimiento': _fechaController.text.trim(),
      'curp': _curpController.text.trim(),
      'direccion': _direccionController.text.trim(),
      'especialidad': _especialidadController.text.trim(),
      'tipo_sangre': _tipoSangreController.text.trim(),
      'alergias': _alergiasController.text.trim(),
      'padecimientos': _padecimientosController.text.trim(),
      'contacto_emergencia': _contactoController.text.trim(),
      'tel_emergencia': _telefonoEmergenciaController.text.trim(),
    });
  }

  Widget _campo(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: maxLines > 1,
          filled: true,
          fillColor: AppColors.blanco,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.bordeSuave),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.naranja, width: 1.5),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _curpController.dispose();
    _direccionController.dispose();
    _especialidadController.dispose();
    _tipoSangreController.dispose();
    _alergiasController.dispose();
    _padecimientosController.dispose();
    _contactoController.dispose();
    _telefonoEmergenciaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.grisfondo,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Editar perfil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Actualiza tus datos personales y de emergencia.',
                style: TextStyle(color: AppColors.textoGris),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _fechaController,
                readOnly: true,
                onTap: _seleccionarFecha,
                decoration: InputDecoration(
                  labelText: 'Fecha de nacimiento',
                  hintText: 'Selecciona una fecha',
                  suffixIcon: IconButton(
                    onPressed: _seleccionarFecha,
                    icon: const Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.naranja,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.blanco,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _campo('CURP', _curpController),
              _campo('Dirección', _direccionController, maxLines: 2),
              _campo('Especialidad', _especialidadController),
              _campo('Tipo de sangre', _tipoSangreController),
              _campo('Alergias', _alergiasController, maxLines: 2),
              _campo('Padecimientos', _padecimientosController, maxLines: 2),
              _campo('Contacto de emergencia', _contactoController),
              _campo(
                'Teléfono de emergencia',
                _telefonoEmergenciaController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.naranja,
                      foregroundColor: AppColors.blanco,
                    ),
                    child: const Text('Guardar cambios'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
