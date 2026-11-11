import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/ui/screens/auth/login_screen.dart';
import 'package:gestobra/servicios/api_service.dart';

class AdminPerfilScreen extends StatefulWidget {
  const AdminPerfilScreen({super.key});

  @override
  State<AdminPerfilScreen> createState() => _AdminPerfilScreenState();
}

class _AdminPerfilScreenState extends State<AdminPerfilScreen> {
  bool _cargando = true;
  
  // Datos del perfil
  String _nombreCompleto = 'Cargando...';
  String _rol = '...';
  String _username = '...';
  String _ultimoAcceso = '...';
  String _correo = '...';
  String _iniciales = '??';

  // Estadísticas
  int _obrasCreadas = 0;
  int _personalAsignado = 0;
  int _reportesRevisados = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;
    setState(() => _cargando = true);

    try {
      final resPerfil = await ApiService.get('perfil.php');
      final resStats = await ApiService.get('admin_stats.php');

      if (resPerfil['estado'] == true) {
        final data = resPerfil['data'];
        setState(() {
          _nombreCompleto = '${data['nombre'] ?? ''} ${data['apellido_paterno'] ?? ''}'.trim();
          _rol = data['rol'] ?? 'ADMINISTRADOR';
          // Si no hay username en la respuesta, usamos el correo antes de la @
          _username = data['correo']?.toString().split('@')[0] ?? 'admin';
          _correo = data['correo'] ?? '--';
          _ultimoAcceso = data['ultimo_acceso'] ?? '--';
          
          if (_nombreCompleto.isNotEmpty) {
            final partes = _nombreCompleto.split(' ');
            if (partes.length >= 2) {
              _iniciales = '${partes[0][0]}${partes[1][0]}'.toUpperCase();
            } else {
              _iniciales = partes[0].substring(0, 1).toUpperCase();
            }
          }
        });
      }

      if (resStats['estado'] == true) {
        setState(() {
          _obrasCreadas = resStats['obras_creadas'] ?? 0;
          _personalAsignado = resStats['personal_asignado'] ?? 0;
          _reportesRevisados = resStats['reportes_revisados'] ?? 0;
        });
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar perfil: $e'), backgroundColor: AppColors.estadoRojo),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // ────────────────────────────────────────────────────────
  // MODAL: CAMBIAR CONTRASEÑA
  // ────────────────────────────────────────────────────────
  void _abrirModalCambiarPassword() {
    final formKey = GlobalKey<FormState>();
    final actualCtrl = TextEditingController();
    final nuevaCtrl = TextEditingController();
    bool guardando = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          title: const Text('Cambiar Contraseña'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: actualCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Contraseña Actual *', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nuevaCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Nueva Contraseña *', border: OutlineInputBorder()),
                    validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: guardando ? null : () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
              onPressed: guardando ? null : () async {
                if (!formKey.currentState!.validate()) return;
                setModal(() => guardando = true);

                try {
                  final res = await ApiService.post('cambiar_password.php', {
                    'password_actual': actualCtrl.text,
                    'password_nueva': nuevaCtrl.text,
                  });

                  if (!mounted) return;
                  
                  if (res != null && res['estado'] == true) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contraseña actualizada'), backgroundColor: AppColors.estadoVerde),
                    );
                  } else {
                    setModal(() => guardando = false);
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(res?['mensaje'] ?? 'Error'), backgroundColor: AppColors.estadoRojo),
                    );
                  }
                } catch (e) {
                  setModal(() => guardando = false);
                  if (mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.estadoRojo));
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
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
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

  Widget _buildCredencialAdmin() {
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
                  child: Text(
                    _rol.replaceAll('_', ' '),
                    style: const TextStyle(
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
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.grisfondo,
                    child: Text(
                      _iniciales,
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.naranja),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _nombreCompleto,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textoNegro),
                ),
                const SizedBox(height: 4),
                Text(
                  _rol,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.naranja, letterSpacing: 0.5),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.blanco,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.bordeSuave.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    children: [
                      _buildFilaCredencial('Usuario', _username),
                      const Divider(height: 16, color: AppColors.gris),
                      _buildFilaCredencial('Correo', _correo),
                      const Divider(height: 16, color: AppColors.gris),
                      _buildFilaCredencial('Último Login', _ultimoAcceso),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Código de barras decorativo
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
        Flexible(
          child: Text(
            valor, 
            style: const TextStyle(fontSize: 12, color: AppColors.textoNegro, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildResumenActividad() {
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
          const Text(
            'Resumen de Actividad',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textoNegro),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Obras Creadas', '$_obrasCreadas', Icons.add_business, AppColors.naranja),
              _buildMiniStat('Personal Asignado', '$_personalAsignado', Icons.assignment_ind, AppColors.estadoVerde),
              _buildMiniStat('Reportes Revisados', '$_reportesRevisados', Icons.description, Colors.blue),
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
        Text(titulo, style: const TextStyle(fontSize: 11, color: AppColors.textoGris), textAlign: TextAlign.center, maxLines: 2),
      ],
    );
  }

  Widget _buildOpciones(BuildContext context) {
    return Column(
      children: [
        _buildOpcionItem(
          context: context, 
          icon: Icons.security,
          titulo: 'Seguridad de la Cuenta',
          subtitulo: 'Cambiar contraseña maestra del administrador',
          onTap: _abrirModalCambiarPassword,
        ),
        const SizedBox(height: 12),
        _buildOpcionItem(
          context: context,
          icon: Icons.settings,
          titulo: 'Configuración Global',
          subtitulo: 'Gestión de catálogos, tarifas base y parámetros del sistema',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Módulo de configuración global')));
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

  Widget _buildOpcionItem({
    required BuildContext context,
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
        border: Border.all(color: AppColors.bordeSuave, width: 1),
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