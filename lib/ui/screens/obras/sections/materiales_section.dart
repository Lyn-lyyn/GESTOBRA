import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../servicios/api_service.dart';

class MaterialesSection extends StatefulWidget {
  final Map<String, dynamic> obra;

  const MaterialesSection({super.key, required this.obra});

  @override
  State<MaterialesSection> createState() => _MaterialesSectionState();
}

class _MaterialesSectionState extends State<MaterialesSection> {
  final _busquedaController = TextEditingController();
  final _kardexScrollController = ScrollController();
  String _vistaSeleccionada = 'Plan';
  bool _cargando = true;
  String? _error;

  // Datos
  List<Map<String, dynamic>> _plan = [];
  List<Map<String, dynamic>> _stock = [];
  List<Map<String, dynamic>> _consumo = [];
  List<Map<String, dynamic>> _kardex = [];
  List<Map<String, dynamic>> _maquinariaObra = [];
  List<Map<String, dynamic>> _maquinariaDisponible = [];
  List<Map<String, dynamic>> _catalogoMateriales = [];
  List<Map<String, dynamic>> _catalogoProveedores = [];
  List<Map<String, dynamic>> _listaActividadesObra = [];

  int get _obraId => int.tryParse(widget.obra['id_obra']?.toString() ?? '') ?? 0;

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _kardexScrollController.dispose();
    super.dispose();
  }

   Future<void> _cargarTodo() async {
    if (_obraId <= 0) return;
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        ApiService.get('materiales_plan_obra.php?id_obra=$_obraId'), // 0
        ApiService.get('materiales_obra.php?id_obra=$_obraId&tipo=stock'), // 1
        ApiService.get('materiales_obra.php?id_obra=$_obraId&tipo=consumo'), // 2
        ApiService.get('materiales_obra.php?id_obra=$_obraId&tipo=kardex'), // 3
        ApiService.get('maquinaria_obra.php?id_obra=$_obraId'), // 4
        ApiService.get('materiales_admin.php'), // 5
        ApiService.get('proveedores.php'), // 6
        ApiService.get('maquinaria.php'), // 7
        ApiService.get('actividades_obra.php?id_obra=$_obraId'), // 8
      ]);

      // 👇 VERIFICAMOS QUE LA PANTALLA SIGA ABIERTA ANTES DE ACTUALIZAR
      if (!mounted) return;

      if (results[0]['estado'] == true) _plan = List<Map<String, dynamic>>.from(results[0]['data']);
      if (results[1]['estado'] == true) _stock = List<Map<String, dynamic>>.from(results[1]['data']);
      if (results[2]['estado'] == true) _consumo = List<Map<String, dynamic>>.from(results[2]['data']);
      if (results[3]['estado'] == true) _kardex = List<Map<String, dynamic>>.from(results[3]['data']);
      if (results[4]['estado'] == true) _maquinariaObra = List<Map<String, dynamic>>.from(results[4]['data']);
      if (results[5]['estado'] == true) _catalogoMateriales = List<Map<String, dynamic>>.from(results[5]['data']);
      if (results[6]['estado'] == true) _catalogoProveedores = List<Map<String, dynamic>>.from(results[6]['data']);
      if (results[8]['estado'] == true) _listaActividadesObra = List<Map<String, dynamic>>.from(results[8]['data']);

      if (results[7]['estado'] == true) {
        final asignadas = _maquinariaObra.map((m) => m['id_maquinaria']).toSet();
        _maquinariaDisponible = List<Map<String, dynamic>>.from(results[7]['data'])
            .where((m) => !asignadas.contains(m['id_maquinaria']))
            .toList();
      }

      setState(() => _cargando = false);
    } catch (e) {
      // 👇 VERIFICAMOS TAMBIÉN EN EL CATCH
      if (!mounted) return;
      
      setState(() {
        _cargando = false;
        _error = 'Error al cargar datos: $e';
      });
    }
  }

  // ────────────────────────────────────────────────────────
  // FILTROS
  // ────────────────────────────────────────────────────────
  List<Map<String, dynamic>> get _stockFiltrado {
    final q = _busquedaController.text.trim().toLowerCase();
    if (q.isEmpty) return _stock;
    return _stock.where((m) => 
      m['material'].toString().toLowerCase().contains(q) ||
      (m['tipo'] ?? '').toString().toLowerCase().contains(q)
    ).toList();
  }

  List<Map<String, dynamic>> get _consumoFiltrado {
    final q = _busquedaController.text.trim().toLowerCase();
    if (q.isEmpty) return _consumo;
    return _consumo.where((c) => 
      c['actividad'].toString().toLowerCase().contains(q) ||
      c['fase'].toString().toLowerCase().contains(q)
    ).toList();
  }

  List<Map<String, dynamic>> get _kardexFiltrado {
    final q = _busquedaController.text.trim().toLowerCase();
    if (q.isEmpty) return _kardex;
    return _kardex.where((m) => 
      m['material'].toString().toLowerCase().contains(q) ||
      m['tipo_movimiento'].toString().toLowerCase().contains(q) ||
      (m['proveedor'] ?? '').toString().toLowerCase().contains(q)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: const Center(child: CircularProgressIndicator(color: AppColors.naranja)),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: AppColors.estadoRojo, size: 40),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: _cargarTodo, icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordeSuave),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          _buildSearchAndTabs(),
          const SizedBox(height: 12),
          if (_vistaSeleccionada == 'Plan') _buildPlanView()
          else if (_vistaSeleccionada == 'Stock') _buildStockView()
          else if (_vistaSeleccionada == 'Consumo') _buildConsumoView()
          else if (_vistaSeleccionada == 'Kardex') _buildKardexView()
          else _buildMaquinariaView(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordeSuave),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final title = const Text(
            'Materiales, Entradas y Consumos',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          );

          final actions = Row(
            children: [
              Expanded(
                child: _movementButton(
                  label: 'Entrada',
                  icon: Icons.south_west,
                  onPressed: () => _openMovementDialog(context, 'Entrada'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _movementButton(
                  label: 'Salida',
                  icon: Icons.north_east,
                  onPressed: () => _openMovementDialog(context, 'Salida'),
                ),
              ),
            ],
          );

          if (constraints.maxWidth < 480) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                title,
                const SizedBox(height: 10),
                actions,
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: title),
              const SizedBox(width: 12),
              SizedBox(width: 240, child: actions),
            ],
          );
        },
      ),
    );
  }

  Widget _movementButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.noseleccionado,
          foregroundColor: AppColors.textoNegro,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: AppColors.bordeSuave),
        ),
      ),
    );
  }

  Widget _buildSearchAndTabs() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordeSuave),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final search = TextField(
            controller: _busquedaController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Buscar material...',
              hintStyle: const TextStyle(fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textoGris),
              suffixIcon: _busquedaController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        _busquedaController.clear();
                        setState(() {});
                      },
                    ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.bordeSuave)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.bordeSuave)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.naranja, width: 1.5)),
            ),
          );
          
          final tabs = _buildViewSelector();

          if (constraints.maxWidth < 570) {
            return Column(
              children: [
                search, 
                const SizedBox(height: 10), 
                Align(alignment: Alignment.centerLeft, child: tabs)
              ]
            );
          }
          return Row(
            children: [
              Expanded(child: search), 
              const SizedBox(width: 10), 
              tabs
            ]
          );
        },
      ),
    );
  }

  Widget _buildViewSelector() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.bordeSuave), borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: ['Plan', 'Stock', 'Consumo', 'Kardex', 'Maquinaria'].map((vista) {
            final selected = _vistaSeleccionada == vista;
            return InkWell(
              onTap: () => setState(() => _vistaSeleccionada = vista),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Text(
                  vista,
                  softWrap: false,
                  style: TextStyle(
                    color: selected ? AppColors.naranja : AppColors.textoGris,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                    decoration: selected ? TextDecoration.underline : null,
                    decorationColor: AppColors.naranja,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // VISTA: PLAN (Lo presupuestado vs lo real)
  // ────────────────────────────────────────────────────────
  Widget _buildPlanView() {
    if (_plan.isEmpty) return _emptyState('No hay materiales presupuestados en el plan de esta obra');

    return Column(
      children: [
        ..._plan.map(_buildPlanCard),
      ],
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> p) {
    final presupuestado = double.tryParse(p['cantidad_presupuestada']?.toString() ?? '0') ?? 0;
    final entrada = double.tryParse(p['cantidad_entrada']?.toString() ?? '0') ?? 0;
    final consumido = double.tryParse(p['cantidad_consumida']?.toString() ?? '0') ?? 0;
    final pendiente = double.tryParse(p['pendiente_por_llegar']?.toString() ?? '0') ?? 0;
    final esExtra = (p['es_extra'] == 1 || p['es_extra'] == true);
    final unidad = p['unidad_medida'] ?? '';

    // Color basado en consumo vs presupuesto
    Color colorConsumo = Colors.green;
    if (presupuestado > 0) {
      final ratio = consumido / presupuestado;
      if (ratio >= 1.0) colorConsumo = AppColors.estadoRojo;
      else if (ratio >= 0.8) colorConsumo = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: esExtra ? AppColors.estadoRojo.withValues(alpha: 0.4) : AppColors.bordeSuave, width: esExtra ? 1.2 : 1),
      ),
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
                      Flexible(child: Text(p['material'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                      if (esExtra) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.estadoRojo.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                          child: const Text('EXTRA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.estadoRojo)),
                        ),
                      ],
                    ]),
                    Text('Unidad: $unidad', style: const TextStyle(fontSize: 11, color: AppColors.textoGris)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: AppColors.naranja),
                tooltip: 'Editar información del plan',
                onPressed: () => _abrirModalEditarPlan(p),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statChip('Presupuesto', '${_formatQuantity(presupuestado)} $unidad', AppColors.textoNegro),
              const SizedBox(width: 6),
              _statChip('Recibido', '${_formatQuantity(entrada)} $unidad', Colors.green),
              const SizedBox(width: 6),
              _statChip('Consumido', '${_formatQuantity(consumido)} $unidad', colorConsumo),
              const SizedBox(width: 6),
              _statChip('Pendiente', '${_formatQuantity(pendiente)} $unidad', AppColors.naranja),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: presupuestado > 0 ? (consumido / presupuestado).clamp(0.0, 1.0) : 0,
              minHeight: 6,
              backgroundColor: AppColors.grisfondo,
              valueColor: AlwaysStoppedAnimation<Color>(colorConsumo),
            ),
          ),
          if (esExtra && p['motivo_extra'] != null && p['motivo_extra'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Motivo extra: ${p['motivo_extra']}', style: const TextStyle(fontSize: 11, color: AppColors.estadoRojo)),
          ],
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // MODAL: EDITAR PLAN
  // ────────────────────────────────────────────────────────
  Future<void> _abrirModalEditarPlan(Map<String, dynamic> p) async {
    final cantCtrl = TextEditingController(text: _formatQuantity(p['cantidad_presupuestada']));
    final costoCtrl = TextEditingController(text: p['costo_unitario_presupuestado']?.toString() ?? '');
    final motivoCtrl = TextEditingController();

    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          bool guardando = false;
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: AppColors.grisfondo,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.naranja, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.assignment, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Editar material del plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: guardando ? null : () => Navigator.pop(ctx, false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text('Material: ${p['material']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 16),

                    Text('Cantidad presupuestada *', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.naranja)),
                      child: TextFormField(
                        controller: cantCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(hintText: 'Ej. 50', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14), isDense: true),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text('Costo unitario (\$)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.naranja)),
                      child: TextFormField(
                        controller: costoCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(hintText: 'Ej. 150.00', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14), isDense: true),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text('Motivo de la edición *', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.naranja)),
                      child: TextFormField(
                        controller: motivoCtrl,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(hintText: 'Ej. Se actualizó la cotización', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14), isDense: true),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: guardando ? null : () => Navigator.pop(ctx, false),
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
                            final nuevaCant = double.tryParse(cantCtrl.text.replaceAll(',', '.'));
                            if (nuevaCant == null || nuevaCant <= 0) {
                              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Cantidad inválida')));
                              return;
                            }
                            if (motivoCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Escribe el motivo de la edición')));
                              return;
                            }
                            
                            setModal(() => guardando = true);
                            
                            String obsFinal = p['observaciones'] ?? '';
                            obsFinal = "$obsFinal\n[Editado: ${motivoCtrl.text.trim()}]".trim();

                            final apiRes = await ApiService.put('materiales_plan_obra.php', {
                              'id_plan_material': p['id_plan_material'],
                              'cantidad_presupuestada': nuevaCant,
                              'costo_unitario_presupuestado': costoCtrl.text.trim(),
                              'observaciones': obsFinal,
                            });
                            
                            if (apiRes['estado'] == true) {
                              Navigator.pop(ctx, true);
                            } else {
                              setModal(() => guardando = false);
                              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(apiRes['mensaje'] ?? 'Error'), backgroundColor: AppColors.estadoRojo));
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
                              : const Text('GUARDAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
    if (res == true) _cargarTodo();
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
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

  // ────────────────────────────────────────────────────────
  // VISTA: STOCK
  // ────────────────────────────────────────────────────────
  Widget _buildStockView() {
    final lista = _stockFiltrado;
    if (lista.isEmpty) return _emptyState('No hay materiales en stock');

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1000 ? 4 : width >= 680 ? 3 : width >= 360 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lista.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 190,
          ),
          itemBuilder: (context, index) => _buildMaterialCard(lista[index]),
        );
      },
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> m) {
    final cantidad = double.tryParse(m['existencia']?.toString() ?? '0') ?? 0.0;
    final minimo = double.tryParse(m['stock_minimo']?.toString() ?? '0') ?? 0.0;
    final pendiente = double.tryParse(m['pendiente_por_llegar']?.toString() ?? '0') ?? 0.0;
    
    final critico = cantidad < minimo;
    final maximo = cantidad > 0 ? cantidad * 1.5 : 100;
    final nivel = (cantidad / maximo).clamp(0.0, 1.0);
    final colorStock = critico ? AppColors.estadoRojo : const Color(0xFF20D620);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: critico ? AppColors.estadoRojo : AppColors.gris, width: critico ? 1.2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: _codeBadge(m['tipo']?.toString() ?? 'MAT')),
              const SizedBox(width: 6),
              Flexible(child: _statusBadge(critico ? 'Stock crítico' : 'Stock normal', critico)),
            ],
          ),
          const SizedBox(height: 8),
          Text(m['material'].toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          Text('${m['tipo'] ?? 'General'}', style: const TextStyle(fontSize: 10, color: AppColors.textoGris)),
          const Divider(height: 16, color: AppColors.gris),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Existencia en Obra:', style: TextStyle(fontSize: 9, color: AppColors.textoGris)),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: _formatQuantity(cantidad), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textoNegro)),
                    TextSpan(text: ' ${m['unidad_medida']}', style: const TextStyle(fontSize: 10, color: AppColors.naranja, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: nivel, minHeight: 8, backgroundColor: Colors.white, valueColor: AlwaysStoppedAnimation<Color>(colorStock)),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mín: ${_formatQuantity(minimo)}', style: const TextStyle(fontSize: 9, color: AppColors.textoGris)),
              Text('Pendiente: ${_formatQuantity(pendiente)}', style: const TextStyle(fontSize: 9, color: AppColors.naranja, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // VISTA: CONSUMO Y KARDEX
  // ────────────────────────────────────────────────────────
  Widget _buildConsumoView() {
    final lista = _consumoFiltrado;
    if (lista.isEmpty) return _emptyState('No hay actividades con consumo registrado');

    return Column(children: lista.map(_buildConsumoCard).toList());
  }

  Widget _buildConsumoCard(Map<String, dynamic> c) {
    final materiales = List<Map<String, dynamic>>.from(c['materiales'] ?? []);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.bordeSuave)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.grisfondo, borderRadius: BorderRadius.circular(6)),
                child: Text(c['fase']?.toString().toUpperCase() ?? 'GENERAL', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textoGris)),
              ),
              Row(
                children: [
                  Text('Avance: ${(double.tryParse(c['porcentaje_avance']?.toString() ?? '0') ?? 0).toInt()}%', style: const TextStyle(fontSize: 10, color: AppColors.textoGris)),
                  const SizedBox(width: 12),
                  Text('Responsable: ${c['responsable'] ?? 'Sin asignar'}', style: const TextStyle(fontSize: 10, color: AppColors.textoNegro, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(c['actividad'].toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(c['descripcion']?.toString() ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textoGris)),
          const Divider(height: 24),
          if (materiales.isEmpty)
            const Text('No se han registrado consumos de materiales específicos para esta actividad aún.', style: TextStyle(fontSize: 10, color: AppColors.textoGris, fontStyle: FontStyle.italic))
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: materiales.map((m) => _consumedMaterialCard(m)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _consumedMaterialCard(Map<String, dynamic> m) {
    final cant = double.tryParse(m['cantidad']?.toString() ?? '0') ?? 0.0;
    return Container(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.bordeSuave)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m['nombre'].toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                const Text('Destino verificado', style: TextStyle(fontSize: 9, color: AppColors.textoGris)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(_formatQuantity(cant), style: const TextStyle(fontSize: 16, color: AppColors.naranja, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text(m['unidad'].toString(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textoGris)),
        ],
      ),
    );
  }

  Widget _buildKardexView() {
    final lista = _kardexFiltrado;
    
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: AppColors.blanco, border: Border.all(color: AppColors.bordeSuave), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(Icons.history, color: AppColors.naranja, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Bitácora de Movimientos y Kardex de Almacén', 
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text('${lista.length} movimientos', style: const TextStyle(fontSize: 11, color: AppColors.textoGris)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.bordeSuave), borderRadius: BorderRadius.circular(12)),
          child: lista.isEmpty 
            ? const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No hay movimientos registrados', style: TextStyle(color: AppColors.textoGris))))
            : Scrollbar(
                controller: _kardexScrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _kardexScrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 900),
                    child: DataTable(
                      headingRowHeight: 44,
                      dataRowMinHeight: 58,
                      dataRowMaxHeight: 72,
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text('TIPO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textoGris))),
                        DataColumn(label: Text('FECHA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textoGris))),
                        DataColumn(label: Text('MATERIAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textoGris))),
                        DataColumn(label: Text('CANTIDAD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textoGris))),
                        DataColumn(label: Text('PROVEEDOR / ACTIVIDAD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textoGris))),
                        DataColumn(label: Text('OBSERVACIONES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textoGris))),
                        DataColumn(label: Text('REGISTRADO POR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textoGris))),
                      ],
                      rows: lista.map((m) {
                        final entrada = m['tipo_movimiento'] == 'ENTRADA';
                        final esExtra = m['plan_es_extra'] == 1 || m['plan_es_extra'] == true;
                        return DataRow(cells: [
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: entrada ? Colors.green.withValues(alpha: 0.1) : AppColors.naranja.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Text(
                                    m['tipo_movimiento'] == 'ENTRADA' ? 'ENTRADA' : 'SALIDA', 
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: entrada ? Colors.green : AppColors.naranja),
                                  ),
                                ),
                                if (esExtra) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.estadoRojo),
                                ]
                              ],
                            ),
                          ),
                          DataCell(Text((m['fecha_movimiento'] ?? '').toString().split(' ')[0], style: const TextStyle(fontSize: 11))),
                          DataCell(SizedBox(width: 180, child: Text(m['material'].toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))),
                          DataCell(Text('${_formatQuantity(double.tryParse(m['cantidad']?.toString() ?? '0') ?? 0.0)} ${m['unidad_medida']}', style: const TextStyle(fontSize: 11))),
                          DataCell(SizedBox(width: 150, child: Text('${m['proveedor'] ?? m['actividad_nombre'] ?? '-'}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.textoGris)))),
                          DataCell(SizedBox(width: 150, child: Text(m['observaciones'] ?? '-', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.textoGris)))),
                          DataCell(Text(m['registrado_por_nombre'] ?? '-', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
        ),
        if (lista.isNotEmpty) const SizedBox(height: 16),
        if (lista.isNotEmpty) 
          ElevatedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exportación a PDF en desarrollo...'))),
            icon: const Icon(Icons.print_outlined, size: 16),
            label: const Text('IMPRIMIR KARDEX', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────
  // VISTA: MAQUINARIA
  // ────────────────────────────────────────────────────────
  Widget _buildMaquinariaView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.bordeSuave)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Maquinaria asignada a la obra', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _abrirModalAsignarMaquinaria,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Asignar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      ),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  const Expanded(child: Text('Maquinaria asignada a la obra', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                  ElevatedButton.icon(
                    onPressed: _abrirModalAsignarMaquinaria,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Asignar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ],
              );
            }
          ),
        ),
        const SizedBox(height: 12),
        if (_maquinariaObra.isEmpty)
          _emptyState('No hay maquinaria asignada a esta obra')
        else
          ..._maquinariaObra.map(_buildMaquinariaCard),
      ],
    );
  }

  Widget _buildMaquinariaCard(Map<String, dynamic> m) {
    final operativa = m['estado_equipo'] == 'OPERATIVA';
    final enMant = m['estado_equipo'] == 'MANTENIMIENTO';
    final colorEstado = operativa ? Colors.green : (enMant ? Colors.orange : Colors.red);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.bordeSuave)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.naranja.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.precision_manufacturing, color: AppColors.naranja),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${m['codigo_maquinaria']} - ${m['nombre_maquinaria']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                Text('${m['tipo_equipo']} | ${m['marca'] ?? ''} ${m['modelo'] ?? ''}', style: const TextStyle(fontSize: 11, color: AppColors.textoGris)),
                Text('Desde: ${m['fecha_asignacion'] ?? '-'}', style: const TextStyle(fontSize: 10, color: AppColors.textoGris)),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: colorEstado.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(m['estado_equipo'], style: TextStyle(color: colorEstado, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: AppColors.estadoRojo, size: 20),
                onPressed: () => _retirarMaquinaria(m),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // MODAL DE MOVIMIENTO
  // ────────────────────────────────────────────────────────
  Future<void> _openMovementDialog(BuildContext context, String tipo, {Map<String, dynamic>? planLinea}) async {
    if (_catalogoMateriales.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay materiales en el catálogo')));
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _MaterialMovementDialog(
        materiales: _catalogoMateriales,
        planLineas: _plan, 
        stockObra: _stock,
        actividades: _listaActividadesObra,
        proveedores: _catalogoProveedores,
        tipo: tipo,
        planLineaInicial: planLinea,
      ),
    );

    if (result == null || !mounted) return;

    final body = {
      'id_obra': _obraId,
      'id_material': result['id_material'],
      'tipo': tipo.toUpperCase(),
      'cantidad': result['cantidad'],
      'id_plan_material': result['id_plan_material'],
      'crear_extra': result['crear_extra'],
      'motivo_extra': result['motivo_extra'],
      'id_proveedor': result['id_proveedor'],
      'id_actividad': result['id_actividad'],
      'costo_unitario': result['costo_unitario'],
      'referencia': '',
      'observaciones': result['observaciones'],
    };

    final res = await ApiService.post('materiales_obra.php', body);
    if (!mounted) return;

    if (res['estado'] == true) {
      _cargarTodo();
      
      String msg = '$tipo registrada correctamente';
      if (res['excede_presupuesto'] == true) msg += ' (¡Atención! Se superó el presupuesto)';
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg), 
        backgroundColor: res['excede_presupuesto'] == true ? Colors.orange : Colors.green
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['mensaje'] ?? 'Error'), backgroundColor: AppColors.estadoRojo));
    }
  }

    Future<void> _abrirModalAsignarMaquinaria() async {
    if (_maquinariaDisponible.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay maquinaria disponible')));
      return;
    }

    int? idSeleccionado;
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          bool guardando = false;
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: AppColors.grisfondo, // Fondo gris claro igual al resto
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
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
                          child: const Icon(Icons.precision_manufacturing, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Asignar Maquinaria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: guardando ? null : () => Navigator.pop(ctx, false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Dropdown con el estilo correcto
                    const Text('Selecciona el equipo *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.naranja),
                      ),
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          border: InputBorder.none, 
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          isDense: true,
                        ),
                        value: idSeleccionado,
                        hint: const Text('Selecciona el equipo', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.naranja),
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                        isExpanded: true, // Esto evita que el texto se desborde
                        menuMaxHeight: 250,
                        items: _maquinariaDisponible.map((m) => DropdownMenuItem<int>(
                          value: m['id_maquinaria'] as int,
                          child: Text('${m['codigo']} - ${m['nombre']}', overflow: TextOverflow.ellipsis),
                        )).toList(),
                        onChanged: (v) => setModal(() => idSeleccionado = v),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: guardando ? null : () => Navigator.pop(ctx, false),
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
                          onPressed: guardando || idSeleccionado == null ? null : () async {
                            setModal(() => guardando = true);
                            Navigator.pop(ctx, true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.naranja,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('ASIGNAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );

    if (confirm != true || idSeleccionado == null) return;

    // Mostrar un indicador de carga mientras se hace la petición (opcional)
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Asignando maquinaria...'), duration: Duration(seconds: 1)));
    }

    final res = await ApiService.post('maquinaria_obra.php', {
      'id_obra': _obraId,
      'id_maquinaria': idSeleccionado,
    });

    if (!mounted) return;
    if (res['estado'] == true) {
      _cargarTodo();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maquinaria asignada'), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['mensaje'] ?? 'Error'), backgroundColor: AppColors.estadoRojo));
    }
  }

   Future<void> _retirarMaquinaria(Map<String, dynamic> m) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.grisfondo, // 👈 Fondo gris claro
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.estadoRojo, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Retirar maquinaria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx, false),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Contenido
                Text(
                  '¿Estás seguro de que deseas retirar "${m['nombre_maquinaria']}" de esta obra?',
                  style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                ),
                const SizedBox(height: 32),

                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
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
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.estadoRojo, // Botón de acción en rojo
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('RETIRAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirm != true) return;

    final res = await ApiService.delete('maquinaria_obra.php?id=${m['id_obra_maquinaria']}');
    if (!mounted) return;
    if (res['estado'] == true) {
      _cargarTodo();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maquinaria retirada'), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['mensaje'] ?? 'Error al retirar'), backgroundColor: AppColors.estadoRojo));
    }
  }

  // ────────────────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────────────────
  Widget _codeBadge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.naranja), borderRadius: BorderRadius.circular(6)),
    child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: AppColors.naranja, fontWeight: FontWeight.bold)),
  );

  Widget _statusBadge(String text, bool critical) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: critical ? const Color(0xFFFFDCDD) : const Color(0xFFB8E9BE), borderRadius: BorderRadius.circular(6)),
    child: Text(text, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: critical ? AppColors.estadoRojo : const Color(0xFF17652A), fontWeight: FontWeight.bold)),
  );

  Widget _emptyState(String message) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.bordeSuave)),
    child: Center(child: Text(message, style: const TextStyle(color: AppColors.textoGris, fontSize: 12))),
  );

  String _formatQuantity(num? value) {
    if (value == null) return '0';
    final d = value.toDouble();
    return d == d.roundToDouble() ? d.toInt().toString() : d.toStringAsFixed(1);
  }
}

class _MaterialMovementDialog extends StatefulWidget {
  final List<Map<String, dynamic>> materiales;
  final List<Map<String, dynamic>> planLineas;
  final List<Map<String, dynamic>> stockObra;
  final List<Map<String, dynamic>> actividades;
  final List<Map<String, dynamic>> proveedores;
  final String tipo;
  final Map<String, dynamic>? planLineaInicial;

  const _MaterialMovementDialog({
    required this.materiales, 
    required this.planLineas,
    required this.stockObra,
    required this.actividades, 
    required this.proveedores, 
    required this.tipo,
    this.planLineaInicial,
  });

  @override
  State<_MaterialMovementDialog> createState() => _MaterialMovementDialogState();
}

class _MaterialMovementDialogState extends State<_MaterialMovementDialog> {
  final _cantidadController = TextEditingController();
  final _notasController = TextEditingController();
  final _motivoExtraController = TextEditingController();
  
  int? _idMaterialSel;
  int? _idPlanMaterialSel;
  int? _idActividadSel;
  int? _idProveedorSel;
  bool _esExtra = false;
  double _maximoPermitido = 999999.0;

  bool get _esEntrada => widget.tipo == 'Entrada';
  bool get _vieneDelPlan => widget.planLineaInicial != null;

  @override
  void initState() {
    super.initState();
    if (_vieneDelPlan) {
      final p = widget.planLineaInicial!;
      _idMaterialSel = p['id_material'] as int;
      _idPlanMaterialSel = p['id_plan_material'] as int;
      _idProveedorSel = p['id_proveedor_sugerido'] as int?;
      
      final pendiente = double.tryParse(p['pendiente_por_llegar']?.toString() ?? '0') ?? 0.0;
      _maximoPermitido = pendiente;
      // Formateamos la cantidad inicial para que no muestre .0
      if (pendiente > 0) _cantidadController.text = _formatQuantity(pendiente);
    }
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _notasController.dispose();
    _motivoExtraController.dispose();
    super.dispose();
  }

  void _save() {
    final cantidad = double.tryParse(_cantidadController.text.trim().replaceAll(',', '.'));
    
    if (_idMaterialSel == null || cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un material y una cantidad válida')));
      return;
    }

    if (_esEntrada && !_esExtra && cantidad > _maximoPermitido) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No puedes recibir más de lo pendiente ($_maximoPermitido). Si es material extra, selecciona la opción de extra.')));
      return;
    }

    if (_esEntrada && _esExtra && _motivoExtraController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escribe el motivo del material extra')));
      return;
    }

    Navigator.of(context).pop({
      'id_material': _idMaterialSel,
      'id_plan_material': _esExtra ? null : _idPlanMaterialSel,
      'crear_extra': _esExtra,
      'motivo_extra': _esExtra ? _motivoExtraController.text.trim() : null,
      'cantidad': cantidad,
      'id_actividad': !_esEntrada ? _idActividadSel : null,
      'id_proveedor': _esEntrada ? _idProveedorSel : null,
      'costo_unitario': null,
      'observaciones': _notasController.text.trim(),
    });
  }

  Widget _buildInputWrapper({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.naranja),
      ),
      child: child,
    );
  }

  String _formatQuantity(num? value) {
    if (value == null) return '0';
    final d = value.toDouble();
    return d == d.roundToDouble() ? d.toInt().toString() : d.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    // FILTRO DE SEGURIDAD: Usamos double.tryParse para evitar el error de tipos
    final materialesConStock = widget.stockObra.where((s) => 
      (double.tryParse(s['existencia']?.toString() ?? '0') ?? 0) > 0
    ).toList();

    return Dialog(
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
                    child: Icon(_esEntrada ? Icons.south_west : Icons.north_east, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Registrar ${widget.tipo}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ENTRADAS
              if (_esEntrada) ...[
                if (!_vieneDelPlan) ...[
                  const Text('Material a ingresar *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 6),
                  _buildInputWrapper(
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                      value: _esExtra ? null : _idPlanMaterialSel,
                      hint: const Text('Selecciona material', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.naranja),
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      isExpanded: true,
                      menuMaxHeight: 250, 
                      items: [
                        ...widget.planLineas.map((p) => DropdownMenuItem<int>(
                          value: p['id_plan_material'] as int, 
                          child: Text(
                            '${p['material']} (Pend: ${_formatQuantity(double.tryParse(p['pendiente_por_llegar']?.toString() ?? '0'))})', 
                            overflow: TextOverflow.ellipsis
                          ),
                        )),
                        const DropdownMenuItem<int>(
                          value: -1, 
                          child: Text('➕ Material no contemplado...', style: TextStyle(color: AppColors.estadoRojo, fontWeight: FontWeight.bold)),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() {
                          if (v == -1) {
                            _esExtra = true;
                            _idPlanMaterialSel = null;
                            _idMaterialSel = null;
                            _maximoPermitido = 999999.0;
                          } else {
                            _esExtra = false;
                            _idPlanMaterialSel = v;
                            final p = widget.planLineas.firstWhere((e) => e['id_plan_material'] == v);
                            _idMaterialSel = p['id_material'] as int;
                            _idProveedorSel = p['id_proveedor_sugerido'] as int?;
                            
                            final pendiente = double.tryParse(p['pendiente_por_llegar']?.toString() ?? '0') ?? 0.0;
                            _maximoPermitido = pendiente;
                            // Formateamos la cantidad al seleccionar para que no muestre ceros
                            _cantidadController.text = pendiente > 0 ? _formatQuantity(pendiente) : '';
                          }
                        });
                      },
                    ),
                  ),
                ] else ...[
                  const Text('Material (Desde Plan)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 6),
                  _buildInputWrapper(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(widget.planLineaInicial!['material'] ?? '', style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                ],

                if (_esExtra) ...[
                  const Text('Selecciona el Material Extra *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 6),
                  _buildInputWrapper(
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                      value: _idMaterialSel,
                      hint: const Text('Selecciona material', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.naranja),
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      isExpanded: true,
                      menuMaxHeight: 250,
                      items: widget.materiales.map((m) => DropdownMenuItem<int>(
                        value: m['id_material'] as int, 
                        child: Text('${m['nombre']} (${m['unidad_medida']})', overflow: TextOverflow.ellipsis)
                      )).toList(),
                      onChanged: (v) => setState(() => _idMaterialSel = v),
                    ),
                  ),
                  const Text('Motivo del material extra *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 6),
                  _buildInputWrapper(
                    child: TextField(
                      controller: _motivoExtraController, 
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(hintText: '¿Por qué se requiere?', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                    ),
                  ),
                ],
              ] else ...[
                // SALIDAS
                const Text('Material a consumir *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 6),
                _buildInputWrapper(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                    value: _idMaterialSel,
                    hint: const Text('Selecciona material con stock', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.naranja),
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    isExpanded: true,
                    menuMaxHeight: 250,
                    items: materialesConStock.map((m) => DropdownMenuItem<int>(
                      value: m['id_material'] as int, 
                      child: Text(
                        '${m['material']} (Stock: ${_formatQuantity(double.tryParse(m['existencia']?.toString() ?? '0'))})', 
                        overflow: TextOverflow.ellipsis
                      )
                    )).toList(),
                    onChanged: (v) {
                      setState(() {
                        _idMaterialSel = v;
                        // Resolver la línea de plan del material para que la salida
                        // quede ligada y se refleje en la tarjeta del Plan.
                        final planMatch = widget.planLineas
                            .where((p) => p['id_material'] == v)
                            .toList();
                        _idPlanMaterialSel = planMatch.isNotEmpty
                            ? planMatch.first['id_plan_material'] as int
                            : null;
                      });
                    },
                  ),
                ),
              ],

              // CANTIDAD
              const Text('Cantidad recibida / consumida *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 6),
              _buildInputWrapper(
                child: TextField(
                  controller: _cantidadController, 
                  keyboardType: const TextInputType.numberWithOptions(decimal: true), 
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(hintText: 'Ej. 50', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                ),
              ),
              
              // PROVEEDOR / ACTIVIDAD
              if (_esEntrada) ...[
                const Text('Proveedor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 6),
                _buildInputWrapper(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                    value: _idProveedorSel,
                    hint: const Text('Selecciona proveedor', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.naranja),
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    isExpanded: true,
                    menuMaxHeight: 250,
                    items: widget.proveedores.map((p) => DropdownMenuItem<int>(value: p['id_proveedor'] as int, child: Text(p['nombre'], overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (v) => setState(() => _idProveedorSel = v),
                  ),
                ),
              ] else ...[
                const Text('Actividad relacionada (Destino) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 6),
                _buildInputWrapper(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                    value: _idActividadSel,
                    hint: const Text('Selecciona actividad', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.naranja),
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    isExpanded: true,
                    menuMaxHeight: 250,
                    items: widget.actividades.map((a) => DropdownMenuItem<int>(
                      value: a['id_actividad'] as int, 
                      child: Text('${a['fase']} - ${a['nombre']}', overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (v) => setState(() => _idActividadSel = v),
                  ),
                ),
              ],

              // OBSERVACIONES
              const Text('Observaciones', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 6),
              _buildInputWrapper(
                child: TextField(
                  controller: _notasController, 
                  maxLines: 3, 
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(hintText: 'Notas (llegó dañado, etc.)', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                ),
              ),
              const SizedBox(height: 16),

              // BOTONES
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
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
                    onPressed: _save, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.naranja, 
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ), 
                    child: Text('REGISTRAR ${widget.tipo.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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