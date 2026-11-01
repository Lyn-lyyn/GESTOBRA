import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/ui/screens/auth/login_screen.dart';
import 'package:gestobra/servicios/api_service.dart';
import 'package:gestobra/servicios/auth_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _cargando = true;
  Map<String, dynamic> _datos = {};

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    setState(() => _cargando = true);
    final res = await ApiService.get('perfil.php');
    
    if (res['estado'] == true) {
      setState(() {
        _datos = res['data'];
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
    }
  }

  bool _isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 900;

  void _cambiarFoto() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funcionalidad para subir foto próximamente...')));
  }

  Future<void> _cerrarSesion() async {
    await AuthService.cerrarSesion();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }

  // Función auxiliar para calcular la edad
  String _calcularEdad(String? fechaNac) {
    if (fechaNac == null || fechaNac.isEmpty) return 'No registrada';
    try {
      final fecha = DateTime.parse(fechaNac);
      final hoy = DateTime.now();
      int edad = hoy.year - fecha.year;
      if (hoy.month < fecha.month || (hoy.month == fecha.month && hoy.day < fecha.day)) {
        edad--;
      }
      return '$edad años';
    } catch (_) {
      return 'No registrada';
    }
  }

  // Función para formatear fecha visualmente
  String _formatFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) return 'No registrada';
    try {
      final f = DateTime.parse(fecha);
      return '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
    } catch (_) { return 'No registrada'; }
  }

  void _abrirModalEditar() async {
    final formKey = GlobalKey<FormState>();
    final fechaCtrl = TextEditingController(text: _datos['fecha_nacimiento']);
    final curpCtrl = TextEditingController(text: _datos['curp']);
    final dirCtrl = TextEditingController(text: _datos['direccion']);
    final espCtrl = TextEditingController(text: _datos['especialidad']);
    final sangreCtrl = TextEditingController(text: _datos['tipo_sangre']);
    final alergiasCtrl = TextEditingController(text: _datos['alergias']);
    final padecimientosCtrl = TextEditingController(text: _datos['padecimientos']);
    final contactoCtrl = TextEditingController(text: _datos['contacto_emergencia']);
    final telEmergenciaCtrl = TextEditingController(text: _datos['tel_emergencia']);

    bool guardando = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          title: const Text('Editar Mi Perfil'),
          content: SizedBox(
            width: 550,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: fechaCtrl,
                          readOnly: true,
                          decoration: const InputDecoration(labelText: 'Fecha de Nacimiento', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                          onTap: () async {
                            final picked = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime.now());
                            if (picked != null) {
                              fechaCtrl.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: TextFormField(controller: sangreCtrl, decoration: const InputDecoration(labelText: 'Tipo de Sangre', border: OutlineInputBorder()))),
                    ]),
                    const SizedBox(height: 12),
                    TextFormField(controller: curpCtrl, decoration: const InputDecoration(labelText: 'CURP', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextFormField(controller: dirCtrl, decoration: const InputDecoration(labelText: 'Dirección', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextFormField(controller: espCtrl, decoration: const InputDecoration(labelText: 'Especialidad', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextFormField(controller: alergiasCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Alergias', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextFormField(controller: padecimientosCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Padecimientos', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: TextFormField(controller: contactoCtrl, decoration: const InputDecoration(labelText: 'Contacto de Emergencia', border: OutlineInputBorder()))),
                      const SizedBox(width: 10),
                      Expanded(child: TextFormField(controller: telEmergenciaCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Tel. de Emergencia', border: OutlineInputBorder()))),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: guardando ? null : () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
              onPressed: guardando ? null : () async {
                setModal(() => guardando = true);
                
                final body = {
                  'fecha_nacimiento': fechaCtrl.text,
                  'curp': curpCtrl.text.trim(),
                  'direccion': dirCtrl.text.trim(),
                  'especialidad': espCtrl.text.trim(),
                  'tipo_sangre': sangreCtrl.text.trim(),
                  'alergias': alergiasCtrl.text.trim(),
                  'padecimientos': padecimientosCtrl.text.trim(),
                  'contacto_emergencia': contactoCtrl.text.trim(),
                  'tel_emergencia': telEmergenciaCtrl.text.trim(),
                };

                final res = await ApiService.post('actualizar_perfil.php', body);
                
                if (!mounted) return;
                Navigator.pop(ctx);
                if (res['estado'] == true) {
                  _cargarPerfil(); // Recargar datos
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['mensaje'] ?? 'Error'), backgroundColor: AppColors.estadoRojo));
                }
              },
              child: guardando ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Scaffold(backgroundColor: AppColors.grisfondo, body: Center(child: CircularProgressIndicator(color: AppColors.naranja)));
    
    final nombre = '${_datos['nombre']} ${_datos['apellido_paterno']} ${_datos['apellido_materno'] ?? ''}'.trim();
    final desktop = _isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double pad = (constraints.maxWidth * 0.02).clamp(16.0, 32.0);
            return SingleChildScrollView(
              padding: EdgeInsets.all(pad),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: desktop ? _buildDesktopLayout(nombre) : _buildMobileLayout(nombre),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGETS ESCRITORIO ---
  Widget _buildDesktopLayout(String nombre) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 380, child: _buildCredencialFisica(nombre)),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDesktopHeaderInfo(),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildDesktopSectionCard('Datos Generales', [
                          _buildInfoRow(Icons.person_outline, 'Nombre Completo', nombre),
                          _buildInfoRow(Icons.cake_outlined, 'Fecha de Nacimiento', _formatFecha(_datos['fecha_nacimiento'])),
                          _buildInfoRow(Icons.badge_outlined, 'CURP', _datos['curp'] ?? 'No registrado'),
                          _buildInfoRow(Icons.home_outlined, 'Dirección', _datos['direccion'] ?? 'No registrada'),
                        ]),
                        const SizedBox(height: 24),
                        _buildDesktopSectionCard('Datos de Contacto', [
                          _buildInfoRow(Icons.phone_outlined, 'Teléfono', _datos['telefono'] ?? 'No registrado'),
                          _buildInfoRow(Icons.email_outlined, 'Correo Electrónico', _datos['correo'] ?? 'No registrado'),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        _buildDesktopSectionCard('Información Médica (Emergencias)', [
                          _buildInfoRow(Icons.bloodtype_outlined, 'Tipo de Sangre', _datos['tipo_sangre'] ?? 'No registrado', isImportant: true),
                          _buildInfoRow(Icons.warning_amber_outlined, 'Alergias', _datos['alergias'] ?? 'No registradas', isImportant: true),
                          _buildInfoRow(Icons.medical_services_outlined, 'Padecimientos', _datos['padecimientos'] ?? 'No registrados'),
                          const Divider(height: 20, color: Colors.black12),
                          _buildInfoRow(Icons.contact_emergency_outlined, 'Contacto de Emergencia', _datos['contacto_emergencia'] ?? 'No registrado', isImportant: true),
                          _buildInfoRow(Icons.phone_in_talk_outlined, 'Tel. Emergencia', _datos['tel_emergencia'] ?? 'No registrado', isImportant: true),
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

  Widget _buildDesktopHeaderInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mi Perfil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              SizedBox(height: 4),
              Text('Gestiona tu información personal y de contacto', style: TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          OutlinedButton.icon(
            onPressed: _abrirModalEditar,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Editar Perfil'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.naranja, side: const BorderSide(color: AppColors.naranja), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSectionCard(String titulo, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.naranja)),
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
          decoration: BoxDecoration(color: AppColors.estadoRojo.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.estadoRojo.withOpacity(0.3), width: 1.2)),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _cerrarSesion,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: AppColors.estadoRojo, size: 20),
                    SizedBox(width: 10),
                    Text('CERRAR SESIÓN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.estadoRojo, letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS MÓVIL ---
  Widget _buildMobileLayout(String nombre) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCredencialFisica(nombre),
        const SizedBox(height: 20),
        _buildPanelInformacion(nombre),
        const SizedBox(height: 20),
        _buildOpcionCerrarSesion(),
      ],
    );
  }

  Widget _buildCredencialFisica(String nombre) {
    return Container(
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.bordeSuave, width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: const BoxDecoration(color: AppColors.textoNegro, borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.engineering, color: AppColors.naranja, size: 22),
                    SizedBox(width: 8),
                    Text('GESTOBRA ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.naranja, borderRadius: BorderRadius.circular(20)),
                  child: const Text('OFICIAL', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0)),
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
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.naranja, width: 3)),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.grisfondo,
                        backgroundImage: _datos['foto_url'] != null && _datos['foto_url'].toString().isNotEmpty ? NetworkImage(_datos['foto_url']) : null,
                        child: _datos['foto_url'] == null || _datos['foto_url'].toString().isEmpty ? const Icon(Icons.person, size: 60, color: AppColors.naranja) : null,
                      ),
                    ),
                    InkWell(
                      onTap: _cambiarFoto,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.naranja, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(nombre, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textoNegro)),
                const SizedBox(height: 4),
                Text(_datos['rol']?.toString().replaceAll('_', ' ') ?? 'Usuario', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.naranja, letterSpacing: 0.5)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.bordeSuave.withValues(alpha: 0.4))),
                  child: Column(
                    children: [
                      _buildFilaCredencial('ID Empleado', '#${_datos['id_usuario']}'),
                      const Divider(height: 16, color: AppColors.gris),
                      _buildFilaCredencial('Especialidad', _datos['especialidad'] ?? 'No registrada'),
                      const Divider(height: 16, color: AppColors.gris),
                      _buildFilaCredencial('Edad', _calcularEdad(_datos['fecha_nacimiento'])),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(28, (index) => Container(width: index % 3 == 0 ? 3 : (index % 2 == 0 ? 2 : 4), height: 32, margin: const EdgeInsets.symmetric(horizontal: 1.2), color: AppColors.textoNegro))),
                const SizedBox(height: 6),
                Text('*${_datos['id_usuario'].toString().padLeft(6, '0')}-GESTOBRA-CIVIL*', style: const TextStyle(fontSize: 9, color: AppColors.textoGris, fontFamily: 'monospace', letterSpacing: 1.5)),
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

  Widget _buildPanelInformacion(String nombre) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.bordeSuave, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Información del Personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textoNegro)),
              OutlinedButton.icon(
                onPressed: _abrirModalEditar,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Editar', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.naranja, side: const BorderSide(color: AppColors.naranja), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSubtitulo('Datos Generales'),
          const SizedBox(height: 10),
          _buildInfoCard([
            _buildInfoRow(Icons.person_outline, 'Nombre', nombre),
            _buildInfoRow(Icons.cake_outlined, 'Fecha Nac.', _formatFecha(_datos['fecha_nacimiento'])),
            _buildInfoRow(Icons.badge_outlined, 'CURP', _datos['curp'] ?? 'No registrado'),
            _buildInfoRow(Icons.home_outlined, 'Dirección', _datos['direccion'] ?? 'No registrada'),
          ]),
          const SizedBox(height: 20),
          _buildSubtitulo('Datos de Contacto'),
          const SizedBox(height: 10),
          _buildInfoCard([
            _buildInfoRow(Icons.phone_outlined, 'Teléfono', _datos['telefono'] ?? 'No registrado'),
            _buildInfoRow(Icons.email_outlined, 'Correo', _datos['correo'] ?? 'No registrado'),
          ]),
          const SizedBox(height: 20),
          _buildSubtitulo('Información Médica'),
          const SizedBox(height: 10),
          _buildInfoCard([
            _buildInfoRow(Icons.bloodtype_outlined, 'Tipo de Sangre', _datos['tipo_sangre'] ?? 'No registrado', isImportant: true),
            _buildInfoRow(Icons.warning_amber_outlined, 'Alergias', _datos['alergias'] ?? 'No registradas', isImportant: true),
            _buildInfoRow(Icons.medical_services_outlined, 'Padecimientos', _datos['padecimientos'] ?? 'No registrados'),
            const Divider(height: 20, color: AppColors.gris),
            _buildInfoRow(Icons.contact_emergency_outlined, 'Contacto', _datos['contacto_emergencia'] ?? 'No registrado', isImportant: true),
            _buildInfoRow(Icons.phone_in_talk_outlined, 'Tel. Emergencia', _datos['tel_emergencia'] ?? 'No registrado', isImportant: true),
          ]),
        ],
      ),
    );
  }

  Widget _buildSubtitulo(String texto) => Text(texto, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.naranja));

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.bordeSuave.withValues(alpha: 0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
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
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textoGris, fontWeight: FontWeight.w500))),
          Expanded(flex: 3, child: Text(valor, style: TextStyle(fontSize: 13, color: isImportant ? AppColors.estadoRojo : AppColors.textoNegro, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildOpcionCerrarSesion() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.estadoRojo.withValues(alpha: 0.4), width: 1.2)),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: _cerrarSesion,
          borderRadius: BorderRadius.circular(14),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: AppColors.estadoRojo, size: 20),
                SizedBox(width: 10),
                Text('CERRAR SESIÓN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.estadoRojo, letterSpacing: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}