import 'package:flutter/material.dart';
import 'package:gestobra/ui/screens/admin/widgets/admin_modal_field_theme.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';

class AdminMaterialesScreen extends StatefulWidget {
  const AdminMaterialesScreen({super.key});
  @override
  State<AdminMaterialesScreen> createState() => _AdminMaterialesScreenState();
}

class _AdminMaterialesScreenState extends State<AdminMaterialesScreen> {
  bool _cargando = true;
  String? _error;

  // Catálogo
  List<Map<String, dynamic>> _materiales = [];
  List<Map<String, dynamic>> _tiposMaterial = [];
  List<Map<String, dynamic>> _proveedores = [];
  String _busquedaCatalogo = '';

  // Unidades estándar
  final List<String> _unidadesMedida = [
    'Pieza', 'Bulto', 'Metro', 'Metro cuadrado', 'Metro cúbico', 
    'Kilogramo', 'Tonelada', 'Litro', 'Cubeta', 'Viaje', 'Rollo', 'Caja'
  ];

  // Obras / plan
  List<Map<String, dynamic>> _obras = [];
  Map<String, dynamic>? _obraSeleccionada;
  String _busquedaObra = '';
  List<Map<String, dynamic>> _planObra = [];
  bool _cargandoPlan = false;

  @override
  void initState() {
    super.initState();
    _cargarCatalogos();
  }

  // ─────────────────────────────────────────────
  // CARGA
  // ─────────────────────────────────────────────
  Future<void> _cargarCatalogos() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final results = await Future.wait([
        ApiService.get('materiales_admin.php'),
        ApiService.get('obras.php'),
        ApiService.get('proveedores.php'),
        ApiService.get('tipos_material.php'),
      ]);

      if (results[0]['estado'] == true) {
        _materiales = List<Map<String, dynamic>>.from(results[0]['data'] ?? []);
      }
      if (results[1]['estado'] == true) {
        _obras = List<Map<String, dynamic>>.from(results[1]['obras'] ?? []);
      }
      if (results[2]['estado'] == true) {
        _proveedores = List<Map<String, dynamic>>.from(results[2]['data'] ?? []);
      }
      if (results[3]['estado'] == true) {
        _tiposMaterial = List<Map<String, dynamic>>.from(results[3]['data'] ?? []);
      }
      setState(() => _cargando = false);
    } catch (e) {
      setState(() { _cargando = false; _error = 'Error de red: $e'; });
    }
  }

  Future<void> _cargarPlanObra(int idObra) async {
    setState(() { _cargandoPlan = true; _planObra = []; });
    try {
      final res = await ApiService.get('materiales_plan_obra.php?id_obra=$idObra');
      if (res['estado'] == true) {
        _planObra = List<Map<String, dynamic>>.from(res['data'] ?? []);
      }
    } catch (e) {
      _showSnack('Error al cargar el plan: $e', isError: true);
    } finally {
      setState(() => _cargandoPlan = false);
    }
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────
  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.estadoRojo : Colors.green,
    ));
  }

  List<Map<String, dynamic>> get _catalogoFiltrado {
    final q = _busquedaCatalogo.trim().toLowerCase();
    if (q.isEmpty) return _materiales;
    return _materiales.where((m) =>
      (m['nombre'] ?? '').toString().toLowerCase().contains(q) ||
      (m['tipo_material'] ?? '').toString().toLowerCase().contains(q)
    ).toList();
  }

  String _fmt(num? v) {
    if (v == null) return '0';
    final d = v.toDouble();
    return d == d.roundToDouble() ? d.toInt().toString() : d.toString();
  }

  Color _colorSemaforo(double presupuestado, double consumido) {
    if (presupuestado <= 0) return AppColors.textoGris;
    final ratio = consumido / presupuestado;
    if (ratio >= 1.0) return AppColors.estadoRojo;
    if (ratio >= 0.8) return Colors.orange;
    return Colors.green;
  }

  // ─────────────────────────────────────────────
  // WIDGETS AUXILIARES (Estilo Nueva Actividad)
  // ─────────────────────────────────────────────
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6.0),
    child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
  );

  Widget _buildTextField({
    required TextEditingController controller, 
    required String hint, 
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.naranja),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          isDense: true,
        ),
      ),
    );
  }

  // 👇 Nuevo widget unificado para Dropdowns (soluciona el doble borde)
  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.naranja),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.naranja),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.naranja, width: 1.5),
        ),
      ),
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.naranja),
      style: const TextStyle(fontSize: 13, color: Colors.black87),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }

  // ─────────────────────────────────────────────
  // MODAL: CREAR / EDITAR MATERIAL
  // ─────────────────────────────────────────────
  Future<void> _abrirModalMaterial({Map<String, dynamic>? material}) async {
    final esEdicion = material != null;
    final nombreCtrl = TextEditingController(text: material?['nombre'] ?? '');
    final descCtrl = TextEditingController(text: material?['descripcion'] ?? '');
    final costoCtrl = TextEditingController(text: material?['costo_referencia']?.toString() ?? '');
    
    String? unidadSel = material?['unidad_medida'];
    if (unidadSel != null && !_unidadesMedida.contains(unidadSel)) {
      _unidadesMedida.add(unidadSel);
    }

    int? idTipoSel = material?['id_tipo_material'] != null
        ? int.tryParse(material!['id_tipo_material'].toString())
        : null;
    bool guardando = false;
    final formKey = GlobalKey<FormState>();

    await showAdminDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppColors.grisfondo,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.naranja, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.inventory, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(esEdicion ? 'Editar Material' : 'Nuevo Material', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: guardando ? null : () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildLabel('Nombre del material *'),
                    _buildTextField(
                      controller: nombreCtrl,
                      hint: 'Ej. Bulto de cemento',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Unidad de medida *'),
                    _buildDropdown<String>(
                      value: unidadSel,
                      hint: 'Selecciona unidad',
                      items: _unidadesMedida.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (v) => setModal(() => unidadSel = v),
                      validator: (v) => v == null ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Tipo de material'),
                    _buildDropdown<int>(
                      value: idTipoSel,
                      hint: 'Selecciona tipo',
                      items: _tiposMaterial.map((t) => DropdownMenuItem<int>(
                        value: t['id_tipo_material'] as int,
                        child: Text(t['nombre']),
                      )).toList(),
                      onChanged: (v) => setModal(() => idTipoSel = v),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Costo de referencia (\$)'),
                    _buildTextField(
                      controller: costoCtrl,
                      hint: 'Ej. 150.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Descripción (opcional)'),
                    _buildTextField(
                      controller: descCtrl,
                      hint: 'Detalles del material...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Botones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: guardando ? null : () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.gris,
                            side: const BorderSide(color: AppColors.bordeSuave),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('CANCELAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: guardando ? null : () async {
                            if (!formKey.currentState!.validate()) return;
                            setModal(() => guardando = true);
                            try {
                              final body = {
                                if (esEdicion) 'id_material': material['id_material'],
                                'nombre': nombreCtrl.text.trim(),
                                'unidad_medida': unidadSel,
                                'id_tipo_material': idTipoSel,
                                'costo_referencia': costoCtrl.text.trim(),
                                'descripcion': descCtrl.text.trim(),
                              };
                              final res = await ApiService.post('materiales_admin.php', body);
                              if (!mounted) return;
                              if (res['estado'] == true) {
                                Navigator.pop(ctx);
                                _cargarCatalogos();
                                _showSnack(res['mensaje'] ?? 'Guardado');
                              } else {
                                setModal(() => guardando = false);
                                _showSnack(res['mensaje'] ?? 'Error', isError: true);
                              }
                            } catch (e) {
                              setModal(() => guardando = false);
                              _showSnack('Error: $e', isError: true);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.naranja,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: guardando 
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(esEdicion ? 'GUARDAR' : 'CREAR', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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

  Future<void> _eliminarMaterial(Map<String, dynamic> m) async {
    final ok = await showAdminDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Desactivar material?'),
        content: Text('"${m['nombre']}" se ocultará del catálogo pero no se borrará.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.estadoRojo),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final res = await ApiService.delete('materiales_admin.php?id=${m['id_material']}');
    if (res['estado'] == true) {
      _cargarCatalogos();
      _showSnack('Material desactivado');
    } else {
      _showSnack(res['mensaje'] ?? 'Error', isError: true);
    }
  }

  // ─────────────────────────────────────────────
  // MODAL: AGREGAR / EDITAR PLAN
  // ─────────────────────────────────────────────
  Future<void> _abrirModalPlan({
    required int idObra,
    Map<String, dynamic>? linea,
    bool esExtra = false,
  }) async {
    final esEdicion = linea != null;
    
    int? idMaterialSel = linea?['id_material'] != null
        ? int.tryParse(linea!['id_material'].toString())
        : null;
    int? idProveedorSel = linea?['id_proveedor_sugerido'] != null
        ? int.tryParse(linea!['id_proveedor_sugerido'].toString())
        : null;
        
    // Usamos _fmt() para quitar los .000
    final cantCtrl = TextEditingController(text: linea != null ? _fmt(linea['cantidad_presupuestada']) : '');
    final costoCtrl = TextEditingController(text: linea?['costo_unitario_presupuestado']?.toString() ?? '');
    final obsCtrl = TextEditingController(text: linea?['observaciones'] ?? '');
    final motivoExtraCtrl = TextEditingController(text: linea?['motivo_extra'] ?? '');
    final motivoEditCtrl = TextEditingController();

    bool guardando = false;
    final formKey = GlobalKey<FormState>();

    final materialesDisponibles = esEdicion
        ? _materiales
        : _materiales.where((m) => !_planObra.any(
            (p) => p['id_material'].toString() == m['id_material'].toString())).toList();

    await showAdminDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppColors.grisfondo,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.naranja, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.assignment, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            esEdicion ? 'Editar línea del plan' : (esExtra ? 'Agregar material extra' : 'Agregar material al plan'), 
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: guardando ? null : () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildLabel('Material *'),
                    _buildDropdown<int>(
                      value: idMaterialSel,
                      hint: 'Selecciona material',
                      items: materialesDisponibles.map((m) => DropdownMenuItem<int>(
                        value: m['id_material'] as int,
                        child: Text('${m['nombre']} (${m['unidad_medida']})', overflow: TextOverflow.ellipsis),
                      )).toList(),
                      onChanged: esEdicion ? null : (v) => setModal(() => idMaterialSel = v),
                      validator: (v) => v == null ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Cantidad presupuestada *'),
                    _buildTextField(
                      controller: cantCtrl,
                      hint: 'Ej. 50',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        final d = double.tryParse(v?.replaceAll(',', '.') ?? '');
                        if (d == null || d <= 0) return 'Cantidad inválida';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Costo unitario (\$)'),
                    _buildTextField(
                      controller: costoCtrl,
                      hint: 'Ej. 150.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Proveedor sugerido (opcional)'),
                    _buildDropdown<int>(
                      value: idProveedorSel,
                      hint: 'Sin proveedor',
                      items: [
                        const DropdownMenuItem<int>(value: null, child: Text('— Sin proveedor —')),
                        ..._proveedores.map((p) => DropdownMenuItem<int>(
                          value: p['id_proveedor'] as int,
                          child: Text(p['nombre']),
                        )),
                      ],
                      onChanged: (v) => setModal(() => idProveedorSel = v),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildLabel('Observaciones'),
                    _buildTextField(
                      controller: obsCtrl,
                      hint: 'Notas sobre este material...',
                      maxLines: 2,
                    ),

                    if (esExtra || (linea?['es_extra'] == 1)) ...[
                      const SizedBox(height: 16),
                      _buildLabel('Motivo del material extra *'),
                      _buildTextField(
                        controller: motivoExtraCtrl,
                        hint: '¿Por qué se requiere?',
                        maxLines: 2,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                      ),
                    ],

                    if (esEdicion) ...[
                      const SizedBox(height: 16),
                      _buildLabel('Motivo de la edición *'),
                      _buildTextField(
                        controller: motivoEditCtrl,
                        hint: 'Ej. Error de dedo, actualización de cotización...',
                        maxLines: 2,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido para auditar' : null,
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Botones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: guardando ? null : () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.gris,
                            side: const BorderSide(color: AppColors.bordeSuave),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('CANCELAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: guardando ? null : () async {
                            if (!formKey.currentState!.validate()) return;
                            setModal(() => guardando = true);
                            try {
                              final cant = double.parse(cantCtrl.text.replaceAll(',', '.'));
                              
                              String obsFinal = obsCtrl.text.trim();
                              if (esEdicion && motivoEditCtrl.text.isNotEmpty) {
                                obsFinal = "$obsFinal\n[Editado: ${motivoEditCtrl.text.trim()}]".trim();
                              }

                              Map<String, dynamic> res;
                              if (esEdicion) {
                                res = await ApiService.put('materiales_plan_obra.php', {
                                  'id_plan_material': linea!['id_plan_material'],
                                  'cantidad_presupuestada': cant,
                                  'costo_unitario_presupuestado': costoCtrl.text.trim(),
                                  'id_proveedor_sugerido': idProveedorSel,
                                  'observaciones': obsFinal,
                                  'motivo_extra': motivoExtraCtrl.text.trim(),
                                });
                              } else {
                                res = await ApiService.post('materiales_plan_obra.php', {
                                  'id_obra': idObra,
                                  'id_material': idMaterialSel,
                                  'cantidad_presupuestada': cant,
                                  'costo_unitario_presupuestado': costoCtrl.text.trim(),
                                  'id_proveedor_sugerido': idProveedorSel,
                                  'observaciones': obsFinal,
                                  'es_extra': esExtra ? true : false,
                                  'motivo_extra': motivoExtraCtrl.text.trim(),
                                });
                              }
                              if (!mounted) return;
                              if (res['estado'] == true) {
                                Navigator.pop(ctx);
                                _cargarPlanObra(idObra);
                                _showSnack(res['mensaje'] ?? 'Guardado');
                              } else {
                                setModal(() => guardando = false);
                                _showSnack(res['mensaje'] ?? 'Error', isError: true);
                              }
                            } catch (e) {
                              setModal(() => guardando = false);
                              _showSnack('Error: $e', isError: true);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.naranja,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: guardando 
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(esEdicion ? 'GUARDAR' : 'AGREGAR', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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

  Future<void> _eliminarLineaPlan(int idObra, Map<String, dynamic> linea) async {
    final ok = await showAdminDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Desactivar línea del plan?'),
        content: Text(
            'Se desactivará "${linea['material']}" del plan de esta obra. '
            'Si ya tiene movimientos, el sistema no permitirá desactivarla.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.estadoRojo),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final res = await ApiService.delete(
        'materiales_plan_obra.php?id_plan_material=${linea['id_plan_material']}');
    if (res['estado'] == true) {
      _cargarPlanObra(idObra);
      _showSnack('Línea desactivada');
    } else {
      _showSnack(res['mensaje'] ?? 'Error', isError: true);
    }
  }

  // ─────────────────────────────────────────────
  // BUILD PRINCIPAL
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.grisfondo,
        appBar: AppBar(
          title: const Text('Materiales', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.blanco,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textoGris),
              onPressed: _cargarCatalogos,
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: AppColors.naranja, size: 28),
              tooltip: 'Nuevo material',
              onPressed: () => _abrirModalMaterial(),
            ),
          ],
          bottom: const TabBar(
            labelColor: AppColors.naranja,
            unselectedLabelColor: AppColors.textoGris,
            indicatorColor: AppColors.naranja,
            tabs: [
              Tab(text: 'Catálogo', icon: Icon(Icons.inventory_2_outlined)),
              Tab(text: 'Plan por Obra', icon: Icon(Icons.assignment_outlined)),
            ],
          ),
        ),
        body: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.estadoRojo)))
                : TabBarView(
                    children: [
                      _buildCatalogoTab(),
                      _buildPlanTab(),
                    ],
                  ),
      ),
    );
  }

  // ───────────── TAB 1: CATÁLOGO ─────────────
  Widget _buildCatalogoTab() {
    final lista = _catalogoFiltrado;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (v) => setState(() => _busquedaCatalogo = v),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Buscar material...',
              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textoGris),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.bordeSuave)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.bordeSuave)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.naranja, width: 1.5)),
            ),
          ),
        ),
        Expanded(
          child: lista.isEmpty
              ? const Center(child: Text('No hay materiales en el catálogo'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: lista.length,
                  itemBuilder: (context, i) {
                    final m = lista[i];
                    return Card(
                      color: AppColors.blanco,
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.bordeSuave)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.naranja.withValues(alpha: 0.1),
                          child: const Icon(Icons.inventory, color: AppColors.naranja),
                        ),
                        title: Text(m['nombre'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${m['tipo_material'] ?? 'General'} | Unidad: ${m['unidad_medida']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('\$${m['costo_referencia'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.estadoVerde)),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: AppColors.naranja),
                              color: AppColors.grisfondo,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              onSelected: (v) {
                                if (v == 'editar') _abrirModalMaterial(material: m);
                                if (v == 'eliminar') _eliminarMaterial(m);
                              },
                              itemBuilder: (ctx) => const [
                                PopupMenuItem(
                                  value: 'editar', 
                                  child: Row(children: [
                                    Icon(Icons.edit, size: 18, color: AppColors.naranja), // 👈 Icono naranja
                                    SizedBox(width: 8), 
                                    Text('Editar')
                                  ])
                                ),
                                PopupMenuItem(
                                  value: 'eliminar', 
                                  child: Row(children: [
                                    Icon(Icons.delete, size: 18, color: AppColors.naranja),
                                    SizedBox(width: 8), 
                                    Text('Desactivar', style: TextStyle(color: AppColors.estadoRojo))
                                  ])
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ───────────── TAB 2: PLAN POR OBRA ─────────────
  Widget _buildPlanTab() {
    if (_obraSeleccionada == null) {
      final obrasFiltradas = _obras.where((o) => 
        (o['nombre'] ?? '').toString().toLowerCase().contains(_busquedaObra.toLowerCase()) ||
        (o['codigo'] ?? '').toString().toLowerCase().contains(_busquedaObra.toLowerCase())
      ).toList();

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _busquedaObra = v),
              decoration: InputDecoration(
                hintText: 'Buscar obra por nombre o código...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textoGris),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.bordeSuave)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.bordeSuave)),
              ),
            ),
          ),
          Expanded(
            child: obrasFiltradas.isEmpty
                ? const Center(child: Text('No se encontraron obras'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: obrasFiltradas.length,
                    itemBuilder: (context, i) {
                      final o = obrasFiltradas[i];
                      return Card(
                        color: AppColors.blanco,
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.bordeSuave)),
                        child: ListTile(
                          leading: const CircleAvatar(backgroundColor: AppColors.naranja, child: Icon(Icons.business, color: Colors.white)),
                          title: Text(o['nombre'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(o['codigo'] ?? ''),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            setState(() => _obraSeleccionada = o);
                            _cargarPlanObra(o['id_obra'] as int);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Container(
          color: AppColors.blanco,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.naranja),
                onPressed: () => setState(() { _obraSeleccionada = null; _planObra = []; }),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_obraSeleccionada!['nombre'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Plan de Materiales', style: const TextStyle(color: AppColors.textoGris, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _abrirModalPlan(idObra: _obraSeleccionada!['id_obra'] as int),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Agregar material'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.naranja,
                    side: const BorderSide(color: AppColors.naranja),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _abrirModalPlan(idObra: _obraSeleccionada!['id_obra'] as int, esExtra: true),
                  icon: const Icon(Icons.add_alert, size: 18),
                  label: const Text('Material extra'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.estadoRojo,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _cargandoPlan
              ? const Center(child: CircularProgressIndicator())
              : _planObra.isEmpty
                  ? const Center(child: Text('Esta obra aún no tiene plan de materiales', style: TextStyle(color: AppColors.textoGris)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _planObra.length,
                      itemBuilder: (context, i) => _buildPlanCard(_planObra[i]),
                    ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> p) {
    final presupuestado = double.tryParse(p['cantidad_presupuestada']?.toString() ?? '0') ?? 0;
    final entrada = double.tryParse(p['cantidad_entrada']?.toString() ?? '0') ?? 0;
    final consumido = double.tryParse(p['cantidad_consumida']?.toString() ?? '0') ?? 0;
    final pendiente = double.tryParse(p['pendiente_por_llegar']?.toString() ?? '0') ?? 0;
    final esExtra = (p['es_extra'] == 1 || p['es_extra'] == true);
    final color = _colorSemaforo(presupuestado, consumido);
    final unidad = p['unidad_medida'] ?? '';

    return Card(
      color: AppColors.blanco,
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: esExtra ? AppColors.estadoRojo.withValues(alpha: 0.4) : AppColors.bordeSuave, width: esExtra ? 1.2 : 1)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(child: Text(p['material'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                        if (esExtra) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.estadoRojo.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: const Text('EXTRA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.estadoRojo)),
                          ),
                        ],
                      ]),
                      Text('${p['tipo'] ?? 'General'} • Unidad: $unidad', style: const TextStyle(fontSize: 11, color: AppColors.textoGris)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.naranja),
                  color: AppColors.grisfondo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (v) {
                    final idObra = _obraSeleccionada!['id_obra'] as int;
                    if (v == 'editar') {
                      _abrirModalPlan(idObra: idObra, linea: p);
                    } else if (v == 'eliminar') {
                      _eliminarLineaPlan(idObra, p);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'editar', 
                      child: Row(children: [
                        Icon(Icons.edit, size: 18, color: AppColors.naranja), // 👈 Icono naranja
                        SizedBox(width: 8), 
                        Text('Editar')
                      ])
                    ),
                    const PopupMenuItem(
                      value: 'eliminar', 
                      child: Row(children: [
                        Icon(Icons.delete, size: 18, color: AppColors.naranja),
                        SizedBox(width: 8), 
                        Text('Desactivar', style: TextStyle(color: AppColors.estadoRojo))
                      ])
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _statChip('Presupuestado', '${_fmt(presupuestado)} $unidad', AppColors.textoNegro),
                const SizedBox(width: 6),
                _statChip('Recibido', '${_fmt(entrada)} $unidad', Colors.green),
                const SizedBox(width: 6),
                _statChip('Consumido', '${_fmt(consumido)} $unidad', color),
                const SizedBox(width: 6),
                _statChip('Pendiente', '${_fmt(pendiente)} $unidad', AppColors.naranja),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: presupuestado > 0 ? (consumido / presupuestado).clamp(0.0, 1.0) : 0,
                minHeight: 6,
                backgroundColor: AppColors.grisfondo,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            if (p['observaciones'] != null && p['observaciones'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Obs: ${p['observaciones']}', style: const TextStyle(fontSize: 11, color: AppColors.textoGris)),
            ],
            if (esExtra && p['motivo_extra'] != null && p['motivo_extra'].toString().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Motivo extra: ${p['motivo_extra']}', style: const TextStyle(fontSize: 11, color: AppColors.estadoRojo)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(6)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textoGris), overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
