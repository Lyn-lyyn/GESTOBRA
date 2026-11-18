import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';
import 'package:gestobra/ui/screens/obras/obra_detail_screen.dart';

class AdminObrasScreen extends StatefulWidget {
  const AdminObrasScreen({super.key});

  @override
  State<AdminObrasScreen> createState() => _AdminObrasScreenState();
}

class _AdminObrasScreenState extends State<AdminObrasScreen> {
  bool _cargando = true;
  List<Map<String, dynamic>> _obras = [];

  @override
  void initState() {
    super.initState();
    _cargarObras();
  }

  // ────────────────────────────────────────────────────────
  // CARGA DE DATOS
  // ────────────────────────────────────────────────────────
  Future<void> _cargarObras() async {
    if (!mounted) return;
    setState(() => _cargando = true);
    try {
      final resObras = await ApiService.get('obras.php');
      final resAsignaciones = await ApiService.get('asignaciones.php');

      if (resObras['estado'] != true) {
        setState(() => _cargando = false);
        _showError(resObras['mensaje'] ?? 'Error al cargar obras');
        return;
      }

      final Map<String, List<String>> asignacionesPorObra = {};
      if (resAsignaciones['estado'] == true) {
        for (final asig in resAsignaciones['data']) {
          final codigoObra = asig['codigo_obra']?.toString() ?? '';
          final nombreUsuario =
              '${asig['nombre_usuario'] ?? ''} ${asig['apellido_usuario'] ?? ''}'
                  .trim();
          final rol = asig['tipo_asignacion'] ?? '';
          final texto = nombreUsuario.isEmpty
              ? rol.toString()
              : '$nombreUsuario ($rol)';
          asignacionesPorObra.putIfAbsent(codigoObra, () => []).add(texto);
        }
      }

      if (!mounted) return;
      setState(() {
        _obras = List<Map<String, dynamic>>.from(resObras['obras']).map((o) {
          final codigo = o['codigo']?.toString() ?? '';
          final asignados = asignacionesPorObra[codigo] ?? [];
          return <String, dynamic>{
            'id_obra': o['id_obra'],
            'codigo': codigo,
            'titulo': o['nombre'] ?? 'Sin nombre',
            'cliente': o['nombre_cliente'] ?? 'Sin cliente',
            'id_cliente': o['id_cliente'],
            'ubicacion': o['ubicacion'] ?? 'Sin ubicación',
            'descripcion': o['descripcion'] ?? '',
            'fechaInicio': o['fecha_inicio'] ?? '--',
            'fechaTermino': o['fecha_fin_estimada'] ?? '--',
            'residente':
                asignados.isNotEmpty ? asignados.join(', ') : 'Sin asignar',
            'sinAsignar': asignados.isEmpty,
            'estado_real': o['estado_nombre'] ?? 'PLANIFICADA',
          };
        }).toList();
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      _showError('Error de red: $e');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.estadoRojo),
    );
  }

  // ────────────────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────────────────
  /// Formatea `yyyy-MM-dd` (o ya `dd/mm/yyyy`) a `dd/mm/yyyy`.
  String _formatearFecha(dynamic fecha) {
    if (fecha == null) return '--';
    final s = fecha.toString().trim();
    if (s.isEmpty || s == '--' || s == 'Sin fecha') return '--';
    // Si ya viene en dd/mm/yyyy, la devolvemos tal cual
    if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(s)) return s;
    try {
      final f = DateTime.parse(s);
      return '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
    } catch (_) {
      return s;
    }
  }

  /// `yyyy-MM-dd` para enviar al backend (formato que espera la API).
  String _formatoApi(DateTime f) =>
      '${f.year}-${f.month.toString().padLeft(2, '0')}-${f.day.toString().padLeft(2, '0')}';

  /// Convierte `yyyy-MM-dd` de la API a `DateTime?` para `initialDate`.
  DateTime? _parseApiDate(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty || s == '--') return null;
    return DateTime.tryParse(s);
  }

  // ────────────────────────────────────────────────────────
  // MODAL: ASIGNAR PERSONAL
  // ────────────────────────────────────────────────────────
  Future<void> _asignarResidente(int index) async {
    final resUsers = await ApiService.get('listar_usuarios.php');
    if (!mounted) return;
    if (resUsers['estado'] != true) {
      _showError(resUsers['mensaje'] ?? 'No se pudieron cargar los usuarios');
      return;
    }
    final usuarios =
        List<Map<String, dynamic>>.from(resUsers['usuarios'] ?? []);

    int? usuarioSeleccionado;
    String rolSeleccionado = 'SUPERVISOR';
    bool guardando = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return AlertDialog(
              title: const Text('Asignar Personal a Obra'),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Selecciona un empleado',
                          border: OutlineInputBorder(),
                        ),
                        items: usuarios
                            .map((u) => DropdownMenuItem<int>(
                                  value: u['id_usuario'] as int,
                                  child: Text(
                                      '${u['nombre'] ?? ''} ${u['apellido_paterno'] ?? ''}'
                                          .trim()),
                                ))
                            .toList(),
                        onChanged: guardando
                            ? null
                            : (val) =>
                                setModalState(() => usuarioSeleccionado = val),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: rolSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Rol',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          'SUPERVISOR',
                          'COORDINADOR',
                          'CAPTURISTA'
                        ]
                            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: guardando
                            ? null
                            : (val) => setModalState(
                                () => rolSeleccionado = val ?? 'SUPERVISOR'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: guardando ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: guardando
                      ? null
                      : () async {
                          if (usuarioSeleccionado == null) return;
                          setModalState(() => guardando = true);
                          final res = await ApiService.post('asignaciones.php', {
                            'id_obra': _obras[index]['id_obra'],
                            'id_usuario': usuarioSeleccionado,
                            'tipo_asignacion': rolSeleccionado,
                          });
                          if (!ctx.mounted) return;
                          if (res['estado'] == true) {
                            Navigator.pop(ctx);
                            await _cargarObras();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Asignado con éxito'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            setModalState(() => guardando = false);
                            _showError(res['mensaje'] ?? 'Error al asignar');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.naranja),
                  child: guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Asignar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────
  // MODAL: NUEVA OBRA (responsive + guardando + validaciones)
  // ────────────────────────────────────────────────────────
  Future<void> _abrirModalNuevaObra() async {
    final resClientes = await ApiService.get('clientes.php');
    final resFases =
        await ApiService.get('catalogos.php?tabla=catalogo_fases');

    if (!mounted) return;
    if (resClientes['estado'] != true || resFases['estado'] != true) {
      _showError('No se pudieron cargar los datos necesarios');
      return;
    }

    final clientes =
        List<Map<String, dynamic>>.from(resClientes['data'] ?? []);
    final catalogoFases =
        List<Map<String, dynamic>>.from(resFases['data'] ?? []);

    final formKey = GlobalKey<FormState>();
    final tituloCtrl = TextEditingController();
    final ubicacionCtrl = TextEditingController();
    final descripcionCtrl = TextEditingController();
    final fechaInicioCtrl = TextEditingController();
    final fechaFinCtrl = TextEditingController();

    int? clienteSeleccionado;
    bool guardando = false;
    final Set<String> fasesSeleccionadas = {};

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> seleccionarFecha(bool esInicio) async {
              final inicial =
                  _parseApiDate(esInicio ? fechaInicioCtrl.text : fechaFinCtrl.text) ??
                      DateTime.now();
              final fecha = await showDatePicker(
                context: ctx,
                initialDate: inicial,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                helpText: esInicio ? 'Fecha de inicio' : 'Fecha de término',
                cancelText: 'Cancelar',
                confirmText: 'Aceptar',
              );
              if (fecha != null) {
                setModalState(() {
                  if (esInicio) {
                    fechaInicioCtrl.text = _formatoApi(fecha);
                  } else {
                    fechaFinCtrl.text = _formatoApi(fecha);
                  }
                });
              }
            }

            // Responsive del modal (mejor del Archivo 1)
            final mq = MediaQuery.of(ctx);
            final esMovil = mq.size.width < 700;
            final anchoModal = esMovil ? mq.size.width * 0.9 : 520.0;

            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: esMovil ? 12 : 40,
                vertical: esMovil ? 24 : 40,
              ),
              title: const Text('Registrar Nueva Obra'),
              content: SizedBox(
                width: anchoModal,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: tituloCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nombre de la Obra *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Requerido'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: 'Cliente *',
                            border: OutlineInputBorder(),
                          ),
                          items: clientes
                              .map((c) => DropdownMenuItem<int>(
                                    value: c['id_cliente'] as int,
                                    child: Text(c['nombre']?.toString() ?? ''),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setModalState(() => clienteSeleccionado = v),
                          validator: (v) =>
                              v == null ? 'Selecciona un cliente' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: ubicacionCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Ubicación de la obra *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Requerido'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descripcionCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Descripción de la obra',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: fechaInicioCtrl,
                                readOnly: true,
                                onTap: () => seleccionarFecha(true),
                                decoration: const InputDecoration(
                                  labelText: 'Fecha de inicio *',
                                  border: OutlineInputBorder(),
                                  prefixIcon:
                                      Icon(Icons.calendar_today_outlined),
                                ),
                                validator: (v) =>
                                    (v == null || v.isEmpty)
                                        ? 'Requerido'
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: fechaFinCtrl,
                                readOnly: true,
                                onTap: () => seleccionarFecha(false),
                                decoration: const InputDecoration(
                                  labelText: 'Fecha de término *',
                                  border: OutlineInputBorder(),
                                  prefixIcon:
                                      Icon(Icons.event_available_outlined),
                                ),
                                validator: (v) =>
                                    (v == null || v.isEmpty)
                                        ? 'Requerido'
                                        : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Fases que abarcará la obra *',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.bordeSuave),
                          ),
                          child: catalogoFases.isEmpty
                              ? const Text(
                                  'No hay fases en el catálogo.',
                                  style: TextStyle(
                                      color: AppColors.estadoRojo,
                                      fontSize: 12),
                                )
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: catalogoFases.map((fase) {
                                    final nombreFase =
                                        fase['nombre']?.toString() ?? '';
                                    if (nombreFase.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    final isSelected = fasesSeleccionadas
                                        .contains(nombreFase);
                                    return FilterChip(
                                      label: Text(nombreFase,
                                          style:
                                              const TextStyle(fontSize: 12)),
                                      selected: isSelected,
                                      selectedColor: AppColors.naranja
                                          .withValues(alpha: 0.2),
                                      checkmarkColor: AppColors.naranja,
                                      side: BorderSide(
                                          color: isSelected
                                              ? AppColors.naranja
                                              : AppColors.bordeSuave),
                                      onSelected: (selected) {
                                        setModalState(() {
                                          if (selected) {
                                            fasesSeleccionadas.add(nombreFase);
                                          } else {
                                            fasesSeleccionadas
                                                .remove(nombreFase);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      guardando ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancelar',
                      style: TextStyle(color: AppColors.textoGris)),
                ),
                ElevatedButton(
                  onPressed: guardando
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          if (fasesSeleccionadas.isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Selecciona al menos una fase')),
                            );
                            return;
                          }
                          // Validación: fin >= inicio
                          final ini = _parseApiDate(fechaInicioCtrl.text);
                          final fin = _parseApiDate(fechaFinCtrl.text);
                          if (ini != null && fin != null && fin.isBefore(ini)) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'La fecha de término no puede ser anterior a la de inicio')),
                            );
                            return;
                          }
                          setModalState(() => guardando = true);

                          final body = {
                            'codigo':
                                'OBR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                            'nombre': tituloCtrl.text.trim(),
                            'id_cliente': clienteSeleccionado,
                            'ubicacion': ubicacionCtrl.text.trim(),
                            'descripcion': descripcionCtrl.text.trim(),
                            'fecha_inicio': fechaInicioCtrl.text,
                            'fecha_fin': fechaFinCtrl.text,
                            'fases': fasesSeleccionadas.toList(),
                          };

                          final res =
                              await ApiService.post('obras.php', body);

                          if (!ctx.mounted) return;

                          if (res['estado'] == true) {
                            Navigator.pop(ctx);
                            await _cargarObras();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Obra registrada correctamente'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            setModalState(() => guardando = false);
                            _showError(res['mensaje'] ?? 'Error');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.naranja),
                  child: guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────
  // MODAL: EDITAR OBRA
  // ────────────────────────────────────────────────────────
  Future<void> _editarObra(int index) async {
    final obra = _obras[index];

    final resClientes = await ApiService.get('clientes.php');
    final resCatalogo =
        await ApiService.get('catalogos.php?tabla=catalogo_fases');
    final resFasesObra =
        await ApiService.get('fases_obra.php?id_obra=${obra['id_obra']}');

    if (!mounted) return;
    if (resClientes['estado'] != true || resCatalogo['estado'] != true) {
      _showError('Error al cargar datos necesarios');
      return;
    }

    final clientes =
        List<Map<String, dynamic>>.from(resClientes['data'] ?? []);
    final catalogoFases =
        List<Map<String, dynamic>>.from(resCatalogo['data'] ?? []);

    final Set<String> fasesSeleccionadas = {};
    if (resFasesObra['estado'] == true && resFasesObra['data'] != null) {
      for (final f in resFasesObra['data']) {
        final nombre = f['nombre']?.toString();
        if (nombre != null && nombre.isNotEmpty) {
          fasesSeleccionadas.add(nombre);
        }
      }
    }

    final formKey = GlobalKey<FormState>();
    final tituloCtrl =
        TextEditingController(text: obra['titulo']?.toString() ?? '');
    final ubicacionCtrl =
        TextEditingController(text: obra['ubicacion']?.toString() ?? '');
    final descripcionCtrl =
        TextEditingController(text: obra['descripcion']?.toString() ?? '');
    final fechaInicioCtrl = TextEditingController(
        text: obra['fechaInicio'] == '--'
            ? ''
            : obra['fechaInicio']?.toString() ?? '');
    final fechaFinCtrl = TextEditingController(
        text: obra['fechaTermino'] == '--'
            ? ''
            : obra['fechaTermino']?.toString() ?? '');

    // Normaliza el cliente seleccionado: si el id no existe en la lista,
    // lo dejamos en null para evitar crash del Dropdown.
    int? clienteSeleccionado = obra['id_cliente'] as int?;
    if (clienteSeleccionado != null &&
        !clientes.any((c) => c['id_cliente'] == clienteSeleccionado)) {
      clienteSeleccionado = null;
    }

    bool guardando = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> seleccionarFecha(bool esInicio) async {
              final inicial = _parseApiDate(
                      esInicio ? fechaInicioCtrl.text : fechaFinCtrl.text) ??
                  DateTime.now();
              final fecha = await showDatePicker(
                context: ctx,
                initialDate: inicial,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                helpText: esInicio ? 'Fecha de inicio' : 'Fecha de término',
              );
              if (fecha != null) {
                setModalState(() {
                  if (esInicio) {
                    fechaInicioCtrl.text = _formatoApi(fecha);
                  } else {
                    fechaFinCtrl.text = _formatoApi(fecha);
                  }
                });
              }
            }

            final mq = MediaQuery.of(ctx);
            final esMovil = mq.size.width < 700;
            final anchoModal = esMovil ? mq.size.width * 0.9 : 520.0;

            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: esMovil ? 12 : 40,
                vertical: esMovil ? 24 : 40,
              ),
              title: const Text('Editar Obra'),
              content: SizedBox(
                width: anchoModal,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: tituloCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nombre de la Obra *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Requerido'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: clienteSeleccionado,
                          decoration: const InputDecoration(
                            labelText: 'Cliente *',
                            border: OutlineInputBorder(),
                          ),
                          items: clientes
                              .map((c) => DropdownMenuItem<int>(
                                    value: c['id_cliente'] as int,
                                    child: Text(c['nombre']?.toString() ?? ''),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setModalState(() => clienteSeleccionado = v),
                          validator: (v) =>
                              v == null ? 'Selecciona un cliente' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: ubicacionCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Ubicación *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Requerido'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descripcionCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: fechaInicioCtrl,
                                readOnly: true,
                                onTap: () => seleccionarFecha(true),
                                decoration: const InputDecoration(
                                  labelText: 'Inicio *',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: fechaFinCtrl,
                                readOnly: true,
                                onTap: () => seleccionarFecha(false),
                                decoration: const InputDecoration(
                                  labelText: 'Término *',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Fases de la Obra *',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.bordeSuave),
                          ),
                          child: catalogoFases.isEmpty
                              ? const Text(
                                  'No hay fases en el catálogo.',
                                  style: TextStyle(
                                      color: AppColors.estadoRojo,
                                      fontSize: 12),
                                )
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: catalogoFases.map((fase) {
                                    final nombreFase =
                                        fase['nombre']?.toString() ?? '';
                                    if (nombreFase.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    final isSelected = fasesSeleccionadas
                                        .contains(nombreFase);
                                    return FilterChip(
                                      label: Text(nombreFase,
                                          style:
                                              const TextStyle(fontSize: 12)),
                                      selected: isSelected,
                                      selectedColor: AppColors.naranja
                                          .withValues(alpha: 0.2),
                                      checkmarkColor: AppColors.naranja,
                                      side: BorderSide(
                                          color: isSelected
                                              ? AppColors.naranja
                                              : AppColors.bordeSuave),
                                      onSelected: (selected) {
                                        setModalState(() {
                                          if (selected) {
                                            fasesSeleccionadas.add(nombreFase);
                                          } else {
                                            fasesSeleccionadas
                                                .remove(nombreFase);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: guardando ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: guardando
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          if (fasesSeleccionadas.isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Selecciona al menos una fase')),
                            );
                            return;
                          }
                          setModalState(() => guardando = true);

                          final res = await ApiService.put('obras.php', {
                            'id_obra': obra['id_obra'],
                            'nombre': tituloCtrl.text.trim(),
                            'id_cliente': clienteSeleccionado,
                            'ubicacion': ubicacionCtrl.text.trim(),
                            'descripcion': descripcionCtrl.text.trim(),
                            'fecha_inicio': fechaInicioCtrl.text,
                            'fecha_fin': fechaFinCtrl.text,
                            'fases': fasesSeleccionadas.toList(),
                          });

                          if (!ctx.mounted) return;
                          if (res['estado'] == true) {
                            Navigator.pop(ctx);
                            await _cargarObras();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Obra actualizada'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            setModalState(() => guardando = false);
                            _showError(res['mensaje'] ?? 'Error');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.naranja),
                  child: guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Guardar Cambios'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────
  // MODAL: CAMBIAR ESTADO
  // ────────────────────────────────────────────────────────
  Future<void> _cambiarEstado(int index) async {
    final obra = _obras[index];
    final estadoActual = obra['estado_real']?.toString() ?? 'PLANIFICADA';

    const estados = [
      {'id': 1, 'nombre': 'PLANIFICADA'},
      {'id': 2, 'nombre': 'EN_EJECUCION'},
      {'id': 3, 'nombre': 'SUSPENDIDA'},
      {'id': 4, 'nombre': 'FINALIZADA'},
      {'id': 5, 'nombre': 'CANCELADA'},
    ];

    int? nuevoEstadoId;
    for (final e in estados) {
      if (e['nombre'] == estadoActual) {
        nuevoEstadoId = e['id'] as int;
      }
    }
    nuevoEstadoId ??= 1;

    // ⚠️ `guardando` FUERA del builder para que no se reinicie en cada rebuild
    bool guardando = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return AlertDialog(
              title: const Text('Cambiar Estado de Obra'),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: estados.map((e) {
                      return RadioListTile<int>(
                        title: Text(e['nombre'] as String),
                        value: e['id'] as int,
                        groupValue: nuevoEstadoId,
                        onChanged: guardando
                            ? null
                            : (val) =>
                                setModalState(() => nuevoEstadoId = val),
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: guardando ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: guardando
                      ? null
                      : () async {
                          setModalState(() => guardando = true);
                          try {
                            final res =
                                await ApiService.post('obras.php', {
                              'accion': 'cambiar_estado',
                              'id_obra': obra['id_obra'],
                              'id_estado_obra': nuevoEstadoId,
                            });

                            if (!ctx.mounted) return;

                            if (res != null && res['estado'] == true) {
                              Navigator.pop(ctx);
                              await _cargarObras();
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Estado actualizado correctamente'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              setModalState(() => guardando = false);
                              _showError(res?['mensaje'] ??
                                  'El servidor rechazó la solicitud');
                            }
                          } catch (e) {
                            if (!ctx.mounted) return;
                            setModalState(() => guardando = false);
                            _showError('Error crítico: $e');
                            debugPrint('❌ Error en _cambiarEstado: $e');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.naranja,
                    minimumSize: const Size(120, 40),
                  ),
                  child: guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────
  // MODAL: CANCELAR OBRA
  // ────────────────────────────────────────────────────────
  Future<void> _cancelarObra(int index) async {
    final obra = _obras[index];
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cancelar Obra?'),
        content: Text(
            '¿Estás seguro de cancelar la obra "${obra['titulo']}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Volver')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.estadoRojo),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final res = await ApiService.post('obras.php', {
                  'accion': 'cambiar_estado',
                  'id_obra': obra['id_obra'],
                  'id_estado_obra': 5,
                });
                if (!mounted) return;
                if (res != null && res['estado'] == true) {
                  await _cargarObras();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Obra cancelada correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  _showError(res?['mensaje'] ?? 'No se pudo cancelar');
                }
              } catch (e) {
                _showError('Error al cancelar: $e');
              }
            },
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // UI PRINCIPAL
  // ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: AppBar(
        title: const Text(
          'Gestión Global de Obras',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.blanco,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textoGris),
            tooltip: 'Recargar',
            onPressed: _cargarObras,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle,
                color: AppColors.naranja, size: 28),
            tooltip: 'Nueva Obra',
            onPressed: _abrirModalNuevaObra,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _obras.isEmpty
                  ? const Center(child: Text('No hay obras registradas aún'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 380,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 300,
                      ),
                      itemCount: _obras.length,
                      itemBuilder: (context, index) {
                        final obra = _obras[index];
                        final estado = obra['estado_real']?.toString() ?? '';
                        final sinAsignar = obra['sinAsignar'] == true;

                        Color colorEstado = Colors.orange;
                        if (estado == 'EN_EJECUCION') {
                          colorEstado = AppColors.estadoVerde;
                        }
                        if (estado == 'FINALIZADA') {
                          colorEstado = Colors.blue;
                        }
                        if (estado == 'CANCELADA') {
                          colorEstado = AppColors.estadoRojo;
                        }
                        if (estado == 'SUSPENDIDA') {
                          colorEstado = Colors.purple;
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.blanco,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.bordeSuave, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ─── Cabecera ───
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: AppColors.bordeSuave,
                                        width: 1.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      obra['codigo']?.toString() ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: AppColors.naranja),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: colorEstado
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                            color: colorEstado, width: 0.5),
                                      ),
                                      child: Text(
                                        estado.replaceAll('_', ' '),
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: colorEstado,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // ─── Cuerpo ───
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        obra['titulo']?.toString() ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        obra['cliente']?.toString() ??
                                            'Cliente no definido',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            color: AppColors.textoGris),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 10),
                                      _buildIconRow(
                                          Icons.location_on_outlined,
                                          obra['ubicacion']?.toString() ??
                                              'Sin ubicación'),
                                      if ((obra['descripcion']?.toString() ??
                                              '')
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        _buildIconRow(
                                          Icons.description_outlined,
                                          obra['descripcion'].toString(),
                                          maxLines: 2,
                                        ),
                                      ],
                                      const SizedBox(height: 6),
                                      _buildIconRow(
                                        Icons.calendar_today_outlined,
                                        '${_formatearFecha(obra['fechaInicio'])} al '
                                        '${_formatearFecha(obra['fechaTermino'])}',
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person_outline,
                                            size: 14,
                                            color: sinAsignar
                                                ? AppColors.estadoRojo
                                                : Colors.green[700],
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              obra['residente']?.toString() ??
                                                  'Sin asignar',
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: sinAsignar
                                                    ? FontWeight.normal
                                                    : FontWeight.bold,
                                                color: sinAsignar
                                                    ? AppColors.estadoRojo
                                                    : Colors.green[800],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // ─── Acciones ───
                              const Divider(
                                  height: 1, color: AppColors.gris),
                              SizedBox(
                                height: 48,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () =>
                                            _asignarResidente(index),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.person_add,
                                                size: 16,
                                                color: AppColors.naranja),
                                            SizedBox(width: 6),
                                            Text('Asignar',
                                                style: TextStyle(
                                                    color:
                                                        AppColors.naranja,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                        width: 1,
                                        height: 24,
                                        color: AppColors.gris),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ObraDetailScreen(
                                                obra: obra),
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.visibility,
                                                size: 16,
                                                color: AppColors.textoGris),
                                            SizedBox(width: 6),
                                            Text('Ver Detalle',
                                                style: TextStyle(
                                                    color:
                                                        AppColors.textoGris,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert,
                                          color: AppColors.textoGris,
                                          size: 18),
                                      onSelected: (value) {
                                        if (value == 'editar') {
                                          _editarObra(index);
                                        }
                                        if (value == 'estado') {
                                          _cambiarEstado(index);
                                        }
                                        if (value == 'cancelar') {
                                          _cancelarObra(index);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) =>
                                          const <PopupMenuEntry<String>>[
                                        PopupMenuItem<String>(
                                          value: 'editar',
                                          child: Row(children: [
                                            Icon(Icons.edit,
                                                size: 18, color: Colors.blue),
                                            SizedBox(width: 8),
                                            Text('Editar Datos'),
                                          ]),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'estado',
                                          child: Row(children: [
                                            Icon(Icons.sync_alt,
                                                size: 18,
                                                color: AppColors.naranja),
                                            SizedBox(width: 8),
                                            Text('Cambiar Estado'),
                                          ]),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'cancelar',
                                          child: Row(children: [
                                            Icon(Icons.cancel,
                                                size: 18,
                                                color: AppColors.estadoRojo),
                                            SizedBox(width: 8),
                                            Text('Cancelar Obra'),
                                          ]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildIconRow(IconData icon, String text, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textoGris),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textoGris, height: 1.3),
          ),
        ),
      ],
    );
  }
}