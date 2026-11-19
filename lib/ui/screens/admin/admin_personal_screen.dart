import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';
import 'package:gestobra/ui/screens/admin/widgets/admin_modal_field_theme.dart';

class AdminPersonalScreen extends StatefulWidget {
  const AdminPersonalScreen({super.key});

  @override
  State<AdminPersonalScreen> createState() => _AdminPersonalScreenState();
}

class _AdminPersonalScreenState extends State<AdminPersonalScreen> {
  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _personal = [];
  List<Map<String, dynamic>> _rolesOperativos = [];

  // Nombres de rol que NO son "personal operativo"
  static const Set<String> _rolesExcluidos = {
    'ADMINISTRADOR',
    'DESARROLLADOR',
  };

  @override
  void initState() {
    super.initState();
    _cargarPersonal();
  }

  Future<void> _cargarPersonal() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resUsers = await ApiService.get('listar_usuarios.php');
      final resAsig = await ApiService.get('asignaciones.php');

      if (resUsers['estado'] != true) {
        setState(() {
          _error = resUsers['mensaje'] ?? 'Error al cargar usuarios';
          _cargando = false;
        });
        return;
      }

      final usuariosRaw =
          List<Map<String, dynamic>>.from(resUsers['usuarios'] ?? []);
      final rolesRaw =
          List<Map<String, dynamic>>.from(resUsers['roles'] ?? []);

      // Roles operativos = todos los roles activos menos admin/dev
      _rolesOperativos = rolesRaw
          .where((r) => !_rolesExcluidos.contains(r['nombre']?.toString()))
          .toList();

      List<Map<String, dynamic>> asignaciones = [];
      if (resAsig['estado'] == true) {
        asignaciones =
            List<Map<String, dynamic>>.from(resAsig['data'] ?? []);
      }

      // Filtramos personal operativo activo
      final usuarios = usuariosRaw.where((u) {
        final rol = (u['rol'] ?? '').toString();
        final activo = u['activo'] == 1 || u['activo'] == true;
        return !_rolesExcluidos.contains(rol) && activo;
      }).toList();

      final personalMapeado = usuarios.map((u) {
        final idUser = u['id_usuario'];
        final obrasAsignadas = asignaciones
            .where((a) => a['id_usuario'] == idUser)
            .toList();
        final obrasCount = obrasAsignadas.length;

        final nombreCompleto =
            '${u['nombre'] ?? ''} ${u['apellido_paterno'] ?? ''} ${u['apellido_materno'] ?? ''}'
                .replaceAll(RegExp(r'\s+'), ' ')
                .trim();

        return <String, dynamic>{
          ...u,
          'nombre_completo': nombreCompleto,
          'obras': obrasCount,
          'obras_lista': obrasAsignadas,
          'estado': obrasCount > 0 ? 'Activo' : 'Disponible',
          'puesto': (u['rol'] ?? '')
              .toString()
              .replaceAll('_', ' ')
              .toLowerCase()
              .split(' ')
              .map((w) => w.isEmpty
                  ? w
                  : w[0].toUpperCase() + w.substring(1))
              .join(' '),
        };
      }).toList();

      setState(() {
        _personal = personalMapeado;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error de red: $e';
        _cargando = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // CREAR personal = crear usuario (usa crear_usuario.php)
  // ---------------------------------------------------------------------------
  Future<void> _abrirModalNuevoPersonal() async {
    if (_rolesOperativos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay roles operativos disponibles'),
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final nombreCtrl = TextEditingController();
    final apPaternoCtrl = TextEditingController();
    final apMaternoCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final correoCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    int idRolSeleccionado = _rolesOperativos.first['id_rol'] as int;
    bool guardando = false;
    bool verPass = false;

    await showAdminDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          backgroundColor: AppColors.grisfondo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 520,
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.9,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.naranja,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.group_add_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Nuevo personal',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Cerrar',
                          onPressed: guardando
                              ? null
                              : () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: nombreCtrl,
                      decoration: _decoracionCampo('Nombre(s) *'),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Requerido'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: apPaternoCtrl,
                            decoration:
                                _decoracionCampo('Apellido paterno *'),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Requerido'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: apMaternoCtrl,
                            decoration:
                                _decoracionCampo('Apellido materno'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: usernameCtrl,
                      decoration: _decoracionCampo('Nombre de usuario *'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Requerido';
                        }
                        if (v.trim().length < 4) {
                          return 'Mínimo 4 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: correoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _decoracionCampo('Correo *'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Requerido';
                        }
                        final ok = RegExp(
                                r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$')
                            .hasMatch(v.trim());
                        return ok ? null : 'Correo inválido';
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: telCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: _decoracionCampo('Teléfono'),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<int>(
                      initialValue: idRolSeleccionado,
                      isExpanded: true,
                      decoration: _decoracionCampo('Rol *'),
                      items: _rolesOperativos
                          .map(
                            (r) => DropdownMenuItem<int>(
                              value: r['id_rol'] as int,
                              child: Text(
                                (r['nombre'] ?? '')
                                    .toString()
                                    .replaceAll('_', ' '),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setModal(() => idRolSeleccionado = v);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: passCtrl,
                      obscureText: !verPass,
                      decoration:
                          _decoracionCampo('Contraseña temporal *')
                              .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            verPass
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textoGris,
                            size: 20,
                          ),
                          onPressed: () =>
                              setModal(() => verPass = !verPass),
                        ),
                      ),
                      validator: (v) => v == null || v.length < 6
                          ? 'Mínimo 6 caracteres'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    OverflowBar(
                      alignment: MainAxisAlignment.end,
                      spacing: 10,
                      overflowSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: guardando
                              ? null
                              : () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textoGris,
                            side: const BorderSide(
                              color: AppColors.bordeSuave,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.naranja,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: guardando
                              ? null
                              : () async {
                                  if (!formKey.currentState!
                                      .validate()) {
                                    return;
                                  }
                                  setModal(() => guardando = true);

                                  // 👇 El body calza con crear_usuario.php
                                  final body = {
                                    'nombre': nombreCtrl.text.trim(),
                                    'username': usernameCtrl.text.trim(),
                                    'apellido_paterno':
                                        apPaternoCtrl.text.trim(),
                                    'apellido_materno':
                                        apMaternoCtrl.text.trim(),
                                    'correo': correoCtrl.text.trim(),
                                    'telefono': telCtrl.text.trim(),
                                    'password': passCtrl.text,
                                    'id_rol': idRolSeleccionado,
                                  };

                                  final res = await ApiService.post(
                                    'crear_usuario.php',
                                    body,
                                  );
                                  if (!mounted) return;

                                  if (res['estado'] == true) {
                                    Navigator.pop(ctx);
                                    _cargarPersonal();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          res['mensaje'] ??
                                              'Personal registrado',
                                        ),
                                      ),
                                    );
                                  } else {
                                    setModal(
                                        () => guardando = false);
                                    ScaffoldMessenger.of(ctx)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          res['mensaje'] ??
                                              'Error al crear',
                                        ),
                                        backgroundColor:
                                            AppColors.estadoRojo,
                                      ),
                                    );
                                  }
                                },
                          child: guardando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Registrar personal'),
                        ),
                      ],
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

  // ---------------------------------------------------------------------------
  // EDITAR personal = actualizar usuario (usa actualizar_usuario.php)
  // ---------------------------------------------------------------------------
  Future<void> _abrirModalEditarPersonal(Map<String, dynamic> p) async {
    final formKey = GlobalKey<FormState>();
    final nombreCtrl =
        TextEditingController(text: p['nombre']?.toString() ?? '');
    final apPaternoCtrl = TextEditingController(
        text: p['apellido_paterno']?.toString() ?? '');
    final apMaternoCtrl = TextEditingController(
        text: p['apellido_materno']?.toString() ?? '');
    final usernameCtrl =
        TextEditingController(text: p['username']?.toString() ?? '');
    final correoCtrl =
        TextEditingController(text: p['correo']?.toString() ?? '');
    final telCtrl =
        TextEditingController(text: p['telefono']?.toString() ?? '');
    final passCtrl = TextEditingController();

    int idRolSeleccionado = (p['id_rol'] as num?)?.toInt() ??
        (_rolesOperativos.isNotEmpty
            ? _rolesOperativos.first['id_rol'] as int
            : 0);
    bool guardando = false;
    bool verPass = false;

    await showAdminDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          backgroundColor: AppColors.grisfondo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 520,
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.9,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.naranja,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.manage_accounts_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Editar personal',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Cerrar',
                          onPressed: guardando
                              ? null
                              : () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: nombreCtrl,
                      decoration: _decoracionCampo('Nombre(s) *'),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Requerido'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: apPaternoCtrl,
                            decoration:
                                _decoracionCampo('Apellido paterno *'),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Requerido'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: apMaternoCtrl,
                            decoration:
                                _decoracionCampo('Apellido materno'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: usernameCtrl,
                      decoration: _decoracionCampo('Nombre de usuario *'),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Requerido'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: correoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _decoracionCampo('Correo *'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Requerido';
                        }
                        final ok = RegExp(
                                r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$')
                            .hasMatch(v.trim());
                        return ok ? null : 'Correo inválido';
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: telCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: _decoracionCampo('Teléfono'),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<int>(
                      initialValue: idRolSeleccionado,
                      isExpanded: true,
                      decoration: _decoracionCampo('Rol *'),
                      items: _rolesOperativos
                          .map(
                            (r) => DropdownMenuItem<int>(
                              value: r['id_rol'] as int,
                              child: Text(
                                (r['nombre'] ?? '')
                                    .toString()
                                    .replaceAll('_', ' '),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setModal(() => idRolSeleccionado = v);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: passCtrl,
                      obscureText: !verPass,
                      decoration: _decoracionCampo(
                        'Nueva contraseña (opcional)',
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            verPass
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textoGris,
                            size: 20,
                          ),
                          onPressed: () =>
                              setModal(() => verPass = !verPass),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;
                        return v.length < 6
                            ? 'Mínimo 6 caracteres'
                            : null;
                      },
                    ),
                    const SizedBox(height: 24),

                    OverflowBar(
                      alignment: MainAxisAlignment.end,
                      spacing: 10,
                      overflowSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: guardando
                              ? null
                              : () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textoGris,
                            side: const BorderSide(
                              color: AppColors.bordeSuave,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.naranja,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: guardando
                              ? null
                              : () async {
                                  if (!formKey.currentState!
                                      .validate()) {
                                    return;
                                  }
                                  setModal(() => guardando = true);

                                  final body = {
                                    'id_usuario': p['id_usuario'],
                                    'nombre': nombreCtrl.text.trim(),
                                    'username': usernameCtrl.text.trim(),
                                    'apellido_paterno':
                                        apPaternoCtrl.text.trim(),
                                    'apellido_materno':
                                        apMaternoCtrl.text.trim(),
                                    'correo': correoCtrl.text.trim(),
                                    'telefono': telCtrl.text.trim(),
                                    'id_rol': idRolSeleccionado,
                                    'password': passCtrl.text,
                                  };

                                  final res = await ApiService.post(
                                    'actualizar_usuario.php',
                                    body,
                                  );
                                  if (!mounted) return;

                                  if (res['estado'] == true) {
                                    Navigator.pop(ctx);
                                    _cargarPersonal();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          res['mensaje'] ??
                                              'Actualizado',
                                        ),
                                      ),
                                    );
                                  } else {
                                    setModal(
                                        () => guardando = false);
                                    ScaffoldMessenger.of(ctx)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          res['mensaje'] ??
                                              'Error',
                                        ),
                                        backgroundColor:
                                            AppColors.estadoRojo,
                                      ),
                                    );
                                  }
                                },
                          child: guardando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Guardar cambios'),
                        ),
                      ],
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

  InputDecoration _decoracionCampo(String etiqueta) {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.naranja),
    );
    return InputDecoration(
      labelText: etiqueta,
      labelStyle: const TextStyle(color: AppColors.textoGris, fontSize: 13),
      floatingLabelStyle: const TextStyle(color: AppColors.naranja),
      filled: true,
      fillColor: AppColors.blanco,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: borde,
      enabledBorder: borde,
      focusedBorder: borde.copyWith(
        borderSide: const BorderSide(color: AppColors.naranja, width: 1.5),
      ),
      errorBorder: borde.copyWith(
        borderSide: const BorderSide(color: AppColors.estadoRojo),
      ),
      focusedErrorBorder: borde.copyWith(
        borderSide: const BorderSide(color: AppColors.estadoRojo, width: 1.5),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers de tarjeta
  // ---------------------------------------------------------------------------
  String _iniciales(String nombre) {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return '?';
    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }
    return (partes.first.substring(0, 1) +
            partes.last.substring(0, 1))
        .toUpperCase();
  }

  Widget _chipMeta({
    required IconData icon,
    required String text,
    Color color = AppColors.textoGris,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaPersonal(Map<String, dynamic> p) {
    final disponible = p['estado'] == 'Disponible';
    final colorEstado =
        disponible ? const Color(0xFF1976D2) : AppColors.estadoVerde;
    final nombre = (p['nombre_completo'] ?? '').toString();

    return Material(
      color: AppColors.blanco,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _abrirModalEditarPersonal(p),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.bordeSuave),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorEstado,
                          colorEstado.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colorEstado.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _iniciales(nombre),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre.isEmpty ? 'Sin nombre' : nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p['puesto'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.naranja,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppColors.textoGris,
                      size: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'editar') {
                        _abrirModalEditarPersonal(p);
                      }
                      if (value == 'estado') {
                        _toggleEstado(p);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: AppColors.naranja,
                            ),
                            SizedBox(width: 10),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'estado',
                        child: Row(
                          children: [
                            Icon(
                              Icons.power_settings_new_outlined,
                              size: 20,
                              color: AppColors.estadoRojo,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Desactivar',
                              style: TextStyle(
                                color: AppColors.estadoRojo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                height: 1,
                color: AppColors.bordeSuave.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chipMeta(
                    icon: disponible
                        ? Icons.check_circle_outline
                        : Icons.work_outline,
                    text: disponible ? 'Disponible' : 'Activo en obra',
                    color: colorEstado,
                  ),
                  _chipMeta(
                    icon: Icons.assignment_outlined,
                    text: '${p['obras']} obra(s)',
                    color: AppColors.textoGris,
                  ),
                  if ((p['correo'] ?? '').toString().isNotEmpty)
                    _chipMeta(
                      icon: Icons.mail_outline,
                      text: p['correo'].toString(),
                      color: AppColors.textoGris,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleEstado(Map<String, dynamic> p) async {
    final activoActual = p['activo'] == 1 || p['activo'] == true;
    final nuevoEstado = activoActual ? 0 : 1;

    final confirmar = await showAdminDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(activoActual ? 'Desactivar personal' : 'Activar personal'),
        content: Text(
          activoActual
              ? '¿Desactivar a ${p['nombre_completo']}? No podrá iniciar sesión.'
              : '¿Reactivar a ${p['nombre_completo']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  activoActual ? AppColors.estadoRojo : AppColors.naranja,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(activoActual ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final res = await ApiService.post('actualizar_usuario.php', {
      'id_usuario': p['id_usuario'],
      'solo_estado': true,
      'activo': nuevoEstado,
    });

    if (!mounted) return;
    if (res['estado'] == true) {
      _cargarPersonal();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['mensaje'] ?? 'Estado actualizado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: AppBar(
        title: const Text(
          'Directorio de Personal',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.blanco,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textoGris),
            onPressed: _cargarPersonal,
          ),
          IconButton(
            icon: const Icon(
              Icons.group_add_outlined,
              color: AppColors.naranja,
              size: 26,
            ),
            tooltip: 'Nuevo personal',
            onPressed: _abrirModalNuevoPersonal,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.estadoRojo,
                        ),
                      ),
                    )
                  : _personal.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.naranja
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.group_outlined,
                                  color: AppColors.naranja,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No hay personal operativo registrado',
                                style: TextStyle(
                                  color: AppColors.textoGris,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _abrirModalNuevoPersonal,
                                icon: const Icon(
                                  Icons.group_add_outlined,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Registrar primer personal',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.naranja,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 420,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: 200,
                          ),
                          itemCount: _personal.length,
                          itemBuilder: (context, i) =>
                              _tarjetaPersonal(_personal[i]),
                        ),
        ),
      ),
    );
  }
}