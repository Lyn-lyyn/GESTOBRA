import 'package:flutter/material.dart';
import 'package:gestobra/ui/screens/admin/widgets/admin_modal_field_theme.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';

class AdminProveedoresScreen extends StatefulWidget {
  const AdminProveedoresScreen({super.key});

  @override
  State<AdminProveedoresScreen> createState() => _AdminProveedoresScreenState();
}

class _AdminProveedoresScreenState extends State<AdminProveedoresScreen> {
  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _proveedores = [];

  @override
  void initState() {
    super.initState();
    _cargarProveedores();
  }

  Future<void> _cargarProveedores() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final res = await ApiService.get('proveedores.php');
      if (res['estado'] == true) {
        setState(() {
          _proveedores = List<Map<String, dynamic>>.from(res['data']);
          _cargando = false;
        });
      } else {
        setState(() {
          _error = res['mensaje'] ?? 'Error al cargar';
          _cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de red: $e';
        _cargando = false;
      });
    }
  }

  Future<void> _abrirModalProveedor({Map<String, dynamic>? proveedor}) async {
    final esEdicion = proveedor != null;

    final nombreCtrl = TextEditingController(text: proveedor?['nombre']);
    final telCtrl = TextEditingController(text: proveedor?['telefono']);
    final correoCtrl = TextEditingController(text: proveedor?['correo']);
    final dirCtrl = TextEditingController(text: proveedor?['direccion']);
    final obsCtrl = TextEditingController(text: proveedor?['observaciones']);

    bool guardando = false;
    final formKey = GlobalKey<FormState>();

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
              maxWidth: 500,
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.88,
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
                            Icons.local_shipping_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            esEdicion
                                ? 'Editar proveedor'
                                : 'Nuevo proveedor',
                            style: const TextStyle(
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
                      decoration: _decoracionCampoProveedor(
                        'Nombre o Razón Social *',
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: telCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: _decoracionCampoProveedor('Teléfono'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: correoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _decoracionCampoProveedor(
                        'Correo electrónico',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: dirCtrl,
                      decoration: _decoracionCampoProveedor('Dirección'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: obsCtrl,
                      maxLines: 2,
                      decoration: _decoracionCampoProveedor(
                        'Observaciones (Ej. Materiales que surte)',
                      ),
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
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }
                                  setModal(() => guardando = true);

                                  final body = {
                                    if (esEdicion)
                                      'id_proveedor':
                                          proveedor['id_proveedor'],
                                    'nombre': nombreCtrl.text.trim(),
                                    'telefono': telCtrl.text.trim(),
                                    'correo': correoCtrl.text.trim(),
                                    'direccion': dirCtrl.text.trim(),
                                    'observaciones': obsCtrl.text.trim(),
                                  };

                                  final res = await ApiService.post(
                                    'proveedores.php',
                                    body,
                                  );
                                  if (!mounted) return;

                                  if (res['estado'] == true) {
                                    Navigator.pop(ctx);
                                    _cargarProveedores();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(res['mensaje']),
                                      ),
                                    );
                                  } else {
                                    setModal(() => guardando = false);
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          res['mensaje'] ?? 'Error',
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
                              : Text(
                                  esEdicion
                                      ? 'Guardar cambios'
                                      : 'Crear proveedor',
                                ),
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

  InputDecoration _decoracionCampoProveedor(String etiqueta) {
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
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

  Future<void> _eliminarProveedor(Map<String, dynamic> proveedor) async {
    final confirmar = await showAdminDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Proveedor'),
        content: Text(
          '¿Estás seguro de eliminar a ${proveedor['nombre']}? No se borrará de la BD, solo se ocultará.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.estadoRojo,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final res = await ApiService.delete(
      'proveedores.php?id=${proveedor['id_proveedor']}',
    );
    if (res['estado'] == true) {
      _cargarProveedores();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proveedor eliminado')),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers de tarjeta
  // ---------------------------------------------------------------------------

  String _iniciales(String? nombre) {
    if (nombre == null || nombre.trim().isEmpty) return '?';
    final partes = nombre.trim().split(RegExp(r'\s+'));
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes.first.substring(0, 1) + partes.last.substring(0, 1))
        .toUpperCase();
  }

  bool _tiene(Map<String, dynamic> p, String key) {
    final v = p[key];
    return v != null && v.toString().trim().isNotEmpty;
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

  Widget _tarjetaProveedor(Map<String, dynamic> p) {
    final nombre = (p['nombre'] ?? '').toString();
    final tieneTel = _tiene(p, 'telefono');
    final tieneCorreo = _tiene(p, 'correo');
    final tieneDir = _tiene(p, 'direccion');
    final tieneObs = _tiene(p, 'observaciones');

    return Material(
      color: AppColors.blanco,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _abrirModalProveedor(proveedor: p),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.bordeSuave),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera: avatar + nombre + menú
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.naranja,
                          AppColors.naranja.withValues(alpha: 0.75),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.naranja.withValues(alpha: 0.25),
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
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                nombre.isEmpty
                                    ? 'Sin nombre'
                                    : nombre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            if (tieneObs)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Tooltip(
                                  message:
                                      p['observaciones'].toString(),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.naranja
                                          .withValues(alpha: 0.12),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Materiales',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: AppColors.naranja,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tieneDir
                              ? p['direccion'].toString()
                              : 'Proveedor registrado',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textoGris,
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
                        _abrirModalProveedor(proveedor: p);
                      }
                      if (value == 'eliminar') {
                        _eliminarProveedor(p);
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
                        value: 'eliminar',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: AppColors.estadoRojo,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Eliminar',
                              style: TextStyle(color: AppColors.estadoRojo),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Separador sutil
              if (tieneTel || tieneCorreo) ...[
                const SizedBox(height: 14),
                Container(
                  height: 1,
                  color: AppColors.bordeSuave.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 12),
              ],

              // Metadatos con chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (tieneTel)
                    _chipMeta(
                      icon: Icons.phone_outlined,
                      text: p['telefono'].toString(),
                      color: AppColors.naranja,
                    ),
                  if (tieneCorreo)
                    _chipMeta(
                      icon: Icons.mail_outline,
                      text: p['correo'].toString(),
                      color: AppColors.textoGris,
                    ),
                ],
              ),

              // Acciones rápidas (editar)
              const SizedBox(height: 14),
              Row(
                children: [
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () =>
                        _abrirModalProveedor(proveedor: p),
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppColors.naranja,
                    ),
                    label: const Text(
                      'Editar',
                      style: TextStyle(
                        color: AppColors.naranja,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: AppBar(
        title: const Text(
          'Directorio de Proveedores',
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
            onPressed: _cargarProveedores,
          ),
          IconButton(
            icon: const Icon(
              Icons.local_shipping_outlined,
              color: AppColors.naranja,
              size: 26,
            ),
            tooltip: 'Nuevo Proveedor',
            onPressed: () => _abrirModalProveedor(),
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
                  : _proveedores.isEmpty
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
                                  Icons.local_shipping_outlined,
                                  color: AppColors.naranja,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No hay proveedores registrados',
                                style: TextStyle(
                                  color: AppColors.textoGris,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _abrirModalProveedor(),
                                icon: const Icon(
                                  Icons.local_shipping_outlined,
                                  size: 18,
                                ),
                                label:
                                    const Text('Crear primer proveedor'),
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
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: _proveedores.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) =>
                              _tarjetaProveedor(_proveedores[i]),
                        ),
        ),
      ),
    );
  }
}