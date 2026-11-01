import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';

class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({super.key});

  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> _roles = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final data = await ApiService.get('listar_usuarios.php');
      if (data['estado'] == true) {
        setState(() {
          _usuarios = List<Map<String, dynamic>>.from(data['usuarios']);
          _roles    = List<Map<String, dynamic>>.from(data['roles']);
          _cargando = false;
        });
      } else {
        setState(() { _error = data['mensaje'] ?? 'Error al cargar'; _cargando = false; });
      }
    } catch (e) {
      setState(() { _error = 'Error de red: $e'; _cargando = false; });
    }
  }

  Future<void> _abrirModalUsuario({Map<String, dynamic>? usuario}) async {
    final bool esEdicion = usuario != null;

    final nombreCtrl    = TextEditingController(text: usuario?['nombre']);
    final usernameCtrl  = TextEditingController(text: usuario?['username']);
    final apPaternoCtrl = TextEditingController(text: usuario?['apellido_paterno']);
    final apMaternoCtrl = TextEditingController(text: usuario?['apellido_materno']);
    final correoCtrl    = TextEditingController(text: usuario?['correo']);
    final telCtrl       = TextEditingController(text: usuario?['telefono']);
    final passCtrl      = TextEditingController();
    final passConfirm   = TextEditingController();

    int? idRolSeleccionado = usuario != null ? usuario['id_rol'] : null;
    bool guardando = false;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setModal) => AlertDialog(
          title: Text(esEdicion ? 'Editar usuario' : 'Nuevo usuario'),
          content: SizedBox(
            width: 480,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(controller: usernameCtrl, decoration: const InputDecoration(labelText: 'Nombre de usuario *', border: OutlineInputBorder()), validator: (v) => (v == null || v.isEmpty || v.contains(' ')) ? 'Requerido y sin espacios' : null),
                    const SizedBox(height: 10),
                    TextFormField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre(s) *', border: OutlineInputBorder()), validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
                    const SizedBox(height: 10),
                    TextFormField(controller: apPaternoCtrl, decoration: const InputDecoration(labelText: 'Apellido paterno *', border: OutlineInputBorder()), validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
                    const SizedBox(height: 10),
                    TextFormField(controller: apMaternoCtrl, decoration: const InputDecoration(labelText: 'Apellido materno', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextFormField(controller: correoCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Correo *', border: OutlineInputBorder()), validator: (v) => (v == null || !v.contains('@')) ? 'Correo inválido' : null),
                    const SizedBox(height: 10),
                    TextFormField(controller: telCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: idRolSeleccionado,
                      decoration: const InputDecoration(labelText: 'Rol *', border: OutlineInputBorder()),
                      items: _roles.map((r) => DropdownMenuItem<int>(value: r['id_rol'] as int, child: Text(r['nombre'].toString()))).toList(),
                      onChanged: (v) => setModal(() => idRolSeleccionado = v),
                      validator: (v) => v == null ? 'Selecciona un rol' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passCtrl,
                      obscureText: true,
                      decoration: InputDecoration(labelText: esEdicion ? 'Nueva contraseña (opcional)' : 'Contraseña *', border: const OutlineInputBorder(), helperText: esEdicion ? 'Déjalo en blanco para no cambiarla' : null),
                      validator: (v) {
                        if (!esEdicion && (v == null || v.length < 6)) return 'Mínimo 6 caracteres';
                        if (esEdicion && v!.isNotEmpty && v.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passConfirm,
                      obscureText: true,
                      decoration: InputDecoration(labelText: esEdicion ? 'Confirmar nueva contraseña' : 'Confirmar contraseña *', border: const OutlineInputBorder()),
                      validator: (v) {
                        if (!esEdicion && v != passCtrl.text) return 'No coincide';
                        if (esEdicion && passCtrl.text.isNotEmpty && v != passCtrl.text) return 'No coincide';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: guardando ? null : () => Navigator.pop(dialogCtx), child: const Text('Cancelar', style: TextStyle(color: AppColors.textoGris))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
              onPressed: guardando ? null : () async {
                if (!formKey.currentState!.validate()) return;
                setModal(() => guardando = true);

                final endpoint = esEdicion ? 'actualizar_usuario.php' : 'crear_usuario.php';
                final body = {
                  'nombre': nombreCtrl.text.trim(),
                  'username': usernameCtrl.text.trim(),
                  'apellido_paterno': apPaternoCtrl.text.trim(),
                  'apellido_materno': apMaternoCtrl.text.trim(),
                  'correo': correoCtrl.text.trim(),
                  'telefono': telCtrl.text.trim(),
                  'id_rol': idRolSeleccionado,
                  'password': passCtrl.text,
                };
                if (esEdicion) body['id_usuario'] = usuario['id_usuario'];

                final data = await ApiService.post(endpoint, body);
                if (!mounted) return;

                if (data['estado'] == true) {
                  Navigator.pop(dialogCtx);
                  _cargar();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(esEdicion ? 'Usuario actualizado' : 'Usuario creado correctamente')));
                } else {
                  setModal(() => guardando = false);
                  ScaffoldMessenger.of(dialogCtx).showSnackBar(SnackBar(content: Text(data['mensaje'] ?? 'Error'), backgroundColor: AppColors.estadoRojo));
                }
              },
              child: guardando ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(esEdicion ? 'Guardar cambios' : 'Crear'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cambiarEstadoUsuario(Map<String, dynamic> u) async {
    final bool estaActivo = (u['activo'] == 1 || u['activo'] == true);
    final accion = estaActivo ? 'desactivar' : 'activar';

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${estaActivo ? 'Desactivar' : 'Activar'} usuario'),
        content: Text('¿Estás seguro de que deseas $accion a ${u['nombre']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: estaActivo ? AppColors.estadoRojo : Colors.green),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(estaActivo ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final data = await ApiService.post('actualizar_usuario.php', {
      'id_usuario': u['id_usuario'],
      'solo_estado': true,
      'activo': estaActivo ? 0 : 1,
    });

    if (data['estado'] == true) {
      _cargar();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['mensaje'] ?? 'Error'), backgroundColor: AppColors.estadoRojo));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: AppBar(
        title: const Text('Gestión de Usuarios', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.blanco,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: AppColors.textoGris), onPressed: _cargar),
          IconButton(icon: const Icon(Icons.person_add_alt_1, color: AppColors.naranja, size: 26), tooltip: 'Nuevo usuario', onPressed: () => _abrirModalUsuario()),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(_error!, style: const TextStyle(color: AppColors.estadoRojo)), const SizedBox(height: 12), ElevatedButton(onPressed: _cargar, child: const Text('Reintentar'))]))
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _usuarios.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _buildUsuarioCard(_usuarios[i]),
                    ),
        ),
      ),
    );
  }

  Widget _buildUsuarioCard(Map<String, dynamic> u) {
    final activo = (u['activo'] == 1 || u['activo'] == true);
    final nombreCompleto = '${u['nombre']} ${u['apellido_paterno'] ?? ''}'.trim();
    final inicial = nombreCompleto.isNotEmpty ? nombreCompleto[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.bordeSuave)),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundColor: activo ? AppColors.naranja.withValues(alpha: 0.15) : AppColors.gris, child: Text(inicial, style: TextStyle(color: activo ? AppColors.naranja : AppColors.textoGris, fontWeight: FontWeight.bold))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombreCompleto, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('@${u['username']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.naranja)),
                Text(u['correo'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textoGris)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.naranja.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)), child: Text(u['rol'].toString(), style: const TextStyle(fontSize: 10, color: AppColors.naranja, fontWeight: FontWeight.bold))),
                    const SizedBox(width: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: activo ? Colors.green.withValues(alpha: 0.15) : AppColors.estadoRojo.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)), child: Text(activo ? 'Activo' : 'Inactivo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: activo ? Colors.green[800] : AppColors.estadoRojo))),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textoGris),
            onSelected: (value) {
              if (value == 'editar') _abrirModalUsuario(usuario: u);
              if (value == 'estado') _cambiarEstadoUsuario(u);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'editar', child: Row(children: [Icon(Icons.edit_outlined, size: 20, color: Colors.blue), SizedBox(width: 8), Text('Editar')])),
              PopupMenuItem<String>(
                value: 'estado',
                child: Row(
                  children: [
                    Icon(activo ? Icons.block : Icons.check_circle_outline, size: 20, color: activo ? AppColors.estadoRojo : Colors.green),
                    const SizedBox(width: 8),
                    Text(activo ? 'Desactivar' : 'Activar', style: TextStyle(color: activo ? AppColors.estadoRojo : Colors.green)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}