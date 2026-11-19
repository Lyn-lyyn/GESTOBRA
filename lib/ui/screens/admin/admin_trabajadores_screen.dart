import 'package:flutter/material.dart';
import 'package:gestobra/ui/screens/admin/widgets/admin_modal_field_theme.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';

class AdminTrabajadoresScreen extends StatefulWidget {
  const AdminTrabajadoresScreen({super.key});

  @override
  State<AdminTrabajadoresScreen> createState() =>
      _AdminTrabajadoresScreenState();
}

class _AdminTrabajadoresScreenState extends State<AdminTrabajadoresScreen> {
  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _trabajadores = [];

  @override
  void initState() {
    super.initState();
    _cargarTrabajadores();
  }

  Future<void> _cargarTrabajadores() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final res = await ApiService.get('trabajadores.php');
      if (res['estado'] == true) {
        setState(() {
          _trabajadores = List<Map<String, dynamic>>.from(res['data']);
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

  Future<void> _abrirModalTrabajador({Map<String, dynamic>? trabajador}) async {
    final esEdicion = trabajador != null;

    final nombreCtrl = TextEditingController(text: trabajador?['nombre']);
    final apPaternoCtrl =
        TextEditingController(text: trabajador?['apellido_paterno']);
    final apMaternoCtrl =
        TextEditingController(text: trabajador?['apellido_materno']);
    final oficioCtrl = TextEditingController(text: trabajador?['oficio']);
    final telCtrl = TextEditingController(text: trabajador?['telefono']);
    final correoCtrl = TextEditingController(text: trabajador?['correo']);
    final obsCtrl = TextEditingController(text: trabajador?['observaciones']);

    DateTime? fechaIngreso;
    final fechaCtrl =
        TextEditingController(text: trabajador?['fecha_ingreso']);

    if (trabajador?['fecha_ingreso'] != null &&
        trabajador!['fecha_ingreso'].toString().isNotEmpty) {
      fechaIngreso =
          DateTime.tryParse(trabajador['fecha_ingreso'].toString());
    }

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
                    // Header del modal
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.naranja,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            esEdicion
                                ? 'Editar trabajador'
                                : 'Nuevo trabajador',
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

                    // Nombre + Apellido paterno
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: nombreCtrl,
                            decoration: _decoracionCampoTrabajador(
                              'Nombre(s) *',
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Requerido'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: apPaternoCtrl,
                            decoration: _decoracionCampoTrabajador(
                              'Apellido paterno *',
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Requerido'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Apellido materno + Oficio
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: apMaternoCtrl,
                            decoration: _decoracionCampoTrabajador(
                              'Apellido materno',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: oficioCtrl,
                            decoration: _decoracionCampoTrabajador(
                              'Oficio / Puesto *',
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Requerido'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Teléfono + Fecha ingreso
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: telCtrl,
                            keyboardType: TextInputType.phone,
                            decoration:
                                _decoracionCampoTrabajador('Teléfono'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: fechaCtrl,
                            readOnly: true,
                            decoration: _decoracionCampoTrabajador(
                              'Fecha de ingreso',
                            ).copyWith(
                              suffixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.naranja,
                                size: 18,
                              ),
                            ),
                            onTap: () async {
                              final fecha = await showDatePicker(
                                context: ctx,
                                initialDate: fechaIngreso ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                locale: const Locale('es', 'MX'),
                              );
                              if (fecha != null) {
                                setModal(() {
                                  fechaIngreso = fecha;
                                  fechaCtrl.text =
                                      '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: correoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _decoracionCampoTrabajador(
                        'Correo electrónico',
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: obsCtrl,
                      maxLines: 2,
                      decoration:
                          _decoracionCampoTrabajador('Observaciones'),
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
                                      'id_trabajador':
                                          trabajador['id_trabajador'],
                                    'nombre': nombreCtrl.text.trim(),
                                    'apellido_paterno':
                                        apPaternoCtrl.text.trim(),
                                    'apellido_materno':
                                        apMaternoCtrl.text.trim(),
                                    'oficio': oficioCtrl.text.trim(),
                                    'telefono': telCtrl.text.trim(),
                                    'correo': correoCtrl.text.trim(),
                                    'fecha_ingreso':
                                        fechaCtrl.text.trim(),
                                    'observaciones': obsCtrl.text.trim(),
                                  };

                                  final res = await ApiService.post(
                                    'trabajadores.php',
                                    body,
                                  );
                                  if (!mounted) return;

                                  if (res['estado'] == true) {
                                    Navigator.pop(ctx);
                                    _cargarTrabajadores();
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
                                      : 'Registrar trabajador',
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

  InputDecoration _decoracionCampoTrabajador(String etiqueta) {
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

  Future<void> _eliminarTrabajador(Map<String, dynamic> trabajador) async {
    final confirmar = await showAdminDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dar de baja a Trabajador'),
        content: Text(
          '¿Estás seguro de dar de baja a ${trabajador['nombre']} ${trabajador['apellido_paterno']}?',
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
            child: const Text('Dar de baja'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final res = await ApiService.delete(
      'trabajadores.php?id=${trabajador['id_trabajador']}',
    );
    if (res['estado'] == true) {
      _cargarTrabajadores();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trabajador dado de baja')),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers de tarjeta
  // ---------------------------------------------------------------------------

  String _iniciales(Map<String, dynamic> t) {
    final nombre = (t['nombre'] ?? '').toString().trim();
    final apellido = (t['apellido_paterno'] ?? '').toString().trim();
    if (nombre.isEmpty && apellido.isEmpty) return '?';
    final n = nombre.isNotEmpty ? nombre.substring(0, 1) : '';
    final a = apellido.isNotEmpty ? apellido.substring(0, 1) : '';
    return (n + a).toUpperCase();
  }

  String _nombreCompleto(Map<String, dynamic> t) {
    return '${t['nombre'] ?? ''} ${t['apellido_paterno'] ?? ''} ${t['apellido_materno'] ?? ''}'
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool _tiene(Map<String, dynamic> t, String key) {
    final v = t[key];
    return v != null && v.toString().trim().isNotEmpty;
  }

  /// Formatea una fecha ISO (yyyy-MM-dd) a "dd MMM yyyy" legible.
  String _formatearFecha(String raw) {
    try {
      final fecha = DateTime.parse(raw);
      const meses = [
        'ene', 'feb', 'mar', 'abr', 'may', 'jun',
        'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
      ];
      return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
    } catch (_) {
      return raw;
    }
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

  Widget _tarjetaTrabajador(Map<String, dynamic> t) {
    final nombreCompleto = _nombreCompleto(t);
    final oficio = (t['oficio'] ?? '').toString();
    final tieneTel = _tiene(t, 'telefono');
    final tieneCorreo = _tiene(t, 'correo');
    final tieneFecha = _tiene(t, 'fecha_ingreso');
    final tieneObs = _tiene(t, 'observaciones');

    return Material(
      color: AppColors.blanco,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _abrirModalTrabajador(trabajador: t),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.bordeSuave),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera: avatar verde + nombre + menú
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.estadoVerde,
                          AppColors.estadoVerde.withValues(alpha: 0.75),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.estadoVerde
                              .withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _iniciales(t),
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
                                nombreCompleto.isEmpty
                                    ? 'Sin nombre'
                                    : nombreCompleto,
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
                                  message: t['observaciones'].toString(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
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
                                      'Nota',
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
                        // Oficio destacado debajo del nombre
                        if (oficio.isNotEmpty)
                          Row(
                            children: [
                              const Icon(
                                Icons.construction_outlined,
                                size: 14,
                                color: AppColors.naranja,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  oficio,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.naranja,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
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
                        _abrirModalTrabajador(trabajador: t);
                      }
                      if (value == 'eliminar') {
                        _eliminarTrabajador(t);
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
                              Icons.person_off_outlined,
                              size: 20,
                              color: AppColors.estadoRojo,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Dar de baja',
                              style:
                                  TextStyle(color: AppColors.estadoRojo),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Separador
              if (tieneTel || tieneCorreo || tieneFecha) ...[
                const SizedBox(height: 14),
                Container(
                  height: 1,
                  color: AppColors.bordeSuave.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 12),
              ],

              // Chips de metadatos
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (tieneTel)
                    _chipMeta(
                      icon: Icons.phone_outlined,
                      text: t['telefono'].toString(),
                      color: AppColors.naranja,
                    ),
                  if (tieneCorreo)
                    _chipMeta(
                      icon: Icons.mail_outline,
                      text: t['correo'].toString(),
                      color: AppColors.textoGris,
                    ),
                  if (tieneFecha)
                    _chipMeta(
                      icon: Icons.calendar_today_outlined,
                      text:
                          'Ingreso: ${_formatearFecha(t['fecha_ingreso'].toString())}',
                      color: AppColors.estadoVerde,
                    ),
                ],
              ),

              // Acciones rápidas
              const SizedBox(height: 14),
              Row(
                children: [
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () =>
                        _abrirModalTrabajador(trabajador: t),
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
          'Directorio de Trabajadores',
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
            onPressed: _cargarTrabajadores,
          ),
          IconButton(
            icon: const Icon(
              Icons.person_add,
              color: AppColors.naranja,
              size: 26,
            ),
            tooltip: 'Nuevo Trabajador',
            onPressed: () => _abrirModalTrabajador(),
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
                  : _trabajadores.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.estadoVerde
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.engineering_outlined,
                                  color: AppColors.estadoVerde,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No hay trabajadores registrados',
                                style: TextStyle(
                                  color: AppColors.textoGris,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _abrirModalTrabajador(),
                                icon: const Icon(
                                  Icons.person_add_alt_1,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Registrar primer trabajador',
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
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: _trabajadores.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) =>
                              _tarjetaTrabajador(_trabajadores[i]),
                        ),
        ),
      ),
    );
  }
}