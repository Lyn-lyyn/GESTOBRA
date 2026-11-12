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
  String _vistaSeleccionada = 'Stock';
  bool _cargando = true;
  String? _error;

  // Datos
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
        ApiService.get('materiales_obra.php?id_obra=$_obraId&tipo=stock'),
        ApiService.get('materiales_obra.php?id_obra=$_obraId&tipo=consumo'),
        ApiService.get('materiales_obra.php?id_obra=$_obraId&tipo=kardex'),
        ApiService.get('maquinaria_obra.php?id_obra=$_obraId'),
        ApiService.get('materiales_admin.php'),
        ApiService.get('proveedores.php'),
        ApiService.get('maquinaria.php'),
        ApiService.get('actividades_obra.php?id_obra=$_obraId'),
      ]);

      if (results[0]['estado'] == true) _stock = List<Map<String, dynamic>>.from(results[0]['data']);
      if (results[1]['estado'] == true) _consumo = List<Map<String, dynamic>>.from(results[1]['data']);
      if (results[2]['estado'] == true) _kardex = List<Map<String, dynamic>>.from(results[2]['data']);
      if (results[3]['estado'] == true) _maquinariaObra = List<Map<String, dynamic>>.from(results[3]['data']);
      if (results[4]['estado'] == true) _catalogoMateriales = List<Map<String, dynamic>>.from(results[4]['data']);
      if (results[5]['estado'] == true) _catalogoProveedores = List<Map<String, dynamic>>.from(results[5]['data']);
      if (results[7]['estado'] == true) _listaActividadesObra = List<Map<String, dynamic>>.from(results[7]['data']);

      if (results[6]['estado'] == true) {
        final asignadas = _maquinariaObra.map((m) => m['id_maquinaria']).toSet();
        _maquinariaDisponible = List<Map<String, dynamic>>.from(results[6]['data'])
            .where((m) => !asignadas.contains(m['id_maquinaria']))
            .toList();
      }

      setState(() => _cargando = false);
    } catch (e) {
      setState(() {
        _cargando = false;
        _error = 'Error al cargar datos: $e';
      });
    }
  }

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
          if (_vistaSeleccionada == 'Stock') _buildStockView()
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
          final actions = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _movementButton(
                label: 'Entrada',
                icon: Icons.south_west,
                onPressed: () => _openMovementDialog(context, 'Entrada'),
              ),
              _movementButton(
                label: 'Salida',
                icon: Icons.north_east,
                onPressed: () => _openMovementDialog(context, 'Salida'),
              ),
            ],
          );
          if (constraints.maxWidth < 480) {
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [title, const SizedBox(height: 10), actions]);
          }
          return Row(children: [Expanded(child: title), actions]);
        },
      ),
    );
  }

  Widget _movementButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      height: 38,
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
          children: ['Stock', 'Consumo', 'Kardex', 'Maquinaria'].map((vista) {
            final selected = _vistaSeleccionada == vista;
            return InkWell(
              onTap: () => setState(() => _vistaSeleccionada = vista),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(
                  vista,
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
  // VISTA: STOCK (Con el diseño de la captura)
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
            mainAxisExtent: 190, // Un poco más alto para que quepa todo
          ),
          itemBuilder: (context, index) => _buildMaterialCard(lista[index]),
        );
      },
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> m) {
    final cantidad = double.tryParse(m['existencia']?.toString() ?? '0') ?? 0.0;
    final minimo = double.tryParse(m['stock_minimo']?.toString() ?? '0') ?? 0.0;
    final costoRef = double.tryParse(m['costo_referencia']?.toString() ?? '0') ?? 0.0;
    
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
              Text('Alerta mínima: ${_formatQuantity(minimo)} ${m['unidad_medida']}', style: const TextStyle(fontSize: 9, color: AppColors.textoGris)),
              Text('Ref: \$${costoRef.toStringAsFixed(2)}', style: const TextStyle(fontSize: 9, color: AppColors.textoGris)),
            ],
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // VISTA: CONSUMO (Con el diseño de la captura)
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

  // ────────────────────────────────────────────────────────
  // VISTA: KARDEX (Con el diseño de la captura)
  // ────────────────────────────────────────────────────────
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
              const Text('Bitácora de Movimientos y Kardex de Almacén', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${lista.length} movimientos registrados', style: const TextStyle(fontSize: 11, color: AppColors.textoGris)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.bordeSuave), borderRadius: BorderRadius.circular(12)),
          child: lista.isEmpty 
            ? const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No hay movimientos registrados', style: TextStyle(color: AppColors.textoGris))))
            : SingleChildScrollView(
                controller: _kardexScrollController,
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 44,
                  dataRowMinHeight: 58,
                  dataRowMaxHeight: 72,
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('TIPO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textoGris))),
                    DataColumn(label: Text('FECHA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textoGris))),
                    DataColumn(label: Text('MATERIAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textoGris))),
                    DataColumn(label: Text('CANTIDAD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textoGris))),
                    DataColumn(label: Text('PROVEEDOR / ACTIVIDAD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textoGris))),
                    DataColumn(label: Text('REFERENCIA / NOTAS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textoGris))),
                    DataColumn(label: Text('REGISTRADO POR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textoGris))),
                  ],
                  rows: lista.map((m) {
                    final entrada = m['tipo_movimiento'] == 'ENTRADA';
                    return DataRow(cells: [
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: entrada ? Colors.green.withValues(alpha: 0.1) : AppColors.naranja.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            m['tipo_movimiento'] == 'ENTRADA' ? 'ENTRADA' : 'SALIDA', 
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: entrada ? Colors.green : AppColors.naranja),
                          ),
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
  // VISTA: MAQUINARIA DE LA OBRA
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
  // MODAL: MOVIMIENTO DE MATERIAL
  // ────────────────────────────────────────────────────────
  Future<void> _openMovementDialog(BuildContext context, String tipo) async {
    if (_catalogoMateriales.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay materiales en el catálogo')));
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _MaterialMovementDialog(
        materiales: _catalogoMateriales,
        actividades: _listaActividadesObra,
        proveedores: _catalogoProveedores,
        tipo: tipo,
      ),
    );

    if (result == null || !mounted) return;

    final body = {
      'id_obra': _obraId,
      'id_material': result['id_material'],
      'tipo': tipo.toUpperCase(),
      'cantidad': result['cantidad'],
      'id_proveedor': result['id_proveedor'],
      'id_actividad': result['id_actividad'],
      'costo_unitario': result['costo_unitario'],
      'referencia': result['referencia'],
      'observaciones': result['observaciones'],
    };

    final res = await ApiService.post('materiales_obra.php', body);
    if (!mounted) return;

    if (res['estado'] == true) {
      _cargarTodo();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$tipo registrada correctamente'), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['mensaje'] ?? 'Error'), backgroundColor: AppColors.estadoRojo));
    }
  }

  // ────────────────────────────────────────────────────────
  // MODAL: ASIGNAR MAQUINARIA
  // ────────────────────────────────────────────────────────
  Future<void> _abrirModalAsignarMaquinaria() async {
    if (_maquinariaDisponible.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay maquinaria disponible')));
      return;
    }

    int? idSeleccionado;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          title: const Text('Asignar Maquinaria'),
          content: SizedBox(
            width: 400,
            child: DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Selecciona el equipo', border: OutlineInputBorder()),
              items: _maquinariaDisponible.map((m) => DropdownMenuItem<int>(
                value: m['id_maquinaria'] as int,
                child: Text('${m['codigo']} - ${m['nombre']}'),
              )).toList(),
              onChanged: (v) => setModal(() => idSeleccionado = v),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: idSeleccionado == null ? null : () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
              child: const Text('Asignar'),
            ),
          ],
        ),
      ),
    );

    if (confirm != true || idSeleccionado == null) return;

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
      builder: (ctx) => AlertDialog(
        title: const Text('¿Retirar maquinaria?'),
        content: Text('¿Estás seguro de retirar "${m['nombre_maquinaria']}" de esta obra?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.estadoRojo),
            child: const Text('Retirar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final res = await ApiService.delete('maquinaria_obra.php?id=${m['id_obra_maquinaria']}');
    if (!mounted) return;
    if (res['estado'] == true) {
      _cargarTodo();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maquinaria retirada')));
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

// ────────────────────────────────────────────────────────
// DIÁLOGO: REGISTRAR MOVIMIENTO
// ────────────────────────────────────────────────────────
class _MaterialMovementDialog extends StatefulWidget {
  final List<Map<String, dynamic>> materiales;
  final List<Map<String, dynamic>> actividades;
  final List<Map<String, dynamic>> proveedores;
  final String tipo;

  const _MaterialMovementDialog({required this.materiales, required this.actividades, required this.proveedores, required this.tipo});

  @override
  State<_MaterialMovementDialog> createState() => _MaterialMovementDialogState();
}

class _MaterialMovementDialogState extends State<_MaterialMovementDialog> {
  final _cantidadController = TextEditingController();
  final _costoController = TextEditingController();
  final _notasController = TextEditingController();
  int? _idMaterialSel;
  int? _idActividadSel;
  int? _idProveedorSel;

  @override
  void dispose() {
    _cantidadController.dispose();
    _costoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  void _save() {
    final cantidad = double.tryParse(_cantidadController.text.trim().replaceAll(',', '.'));
    if (_idMaterialSel == null || cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un material y una cantidad válida')));
      return;
    }
    Navigator.of(context).pop({
      'id_material': _idMaterialSel,
      'cantidad': cantidad,
      'id_actividad': widget.tipo == 'Salida' ? _idActividadSel : null,
      'id_proveedor': widget.tipo == 'Entrada' ? _idProveedorSel : null,
      'costo_unitario': double.tryParse(_costoController.text.trim()),
      'referencia': '',
      'observaciones': _notasController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final esEntrada = widget.tipo == 'Entrada';
    return AlertDialog(
      title: Row(children: [Icon(esEntrada ? Icons.south_west : Icons.north_east, color: AppColors.naranja), const SizedBox(width: 8), Expanded(child: Text('Registrar ${widget.tipo.toLowerCase()}'))]),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Material', border: OutlineInputBorder()),
                items: widget.materiales.map((m) => DropdownMenuItem<int>(value: m['id_material'] as int, child: Text(m['nombre']))).toList(),
                onChanged: (v) => setState(() => _idMaterialSel = v),
              ),
              const SizedBox(height: 12),
              TextField(controller: _cantidadController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Cantidad', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              if (esEntrada)
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Proveedor', border: OutlineInputBorder()),
                  items: widget.proveedores.map((p) => DropdownMenuItem<int>(value: p['id_proveedor'] as int, child: Text(p['nombre']))).toList(),
                  onChanged: (v) => setState(() => _idProveedorSel = v),
                )
              else
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Actividad relacionada', border: OutlineInputBorder()),
                  items: widget.actividades.map((a) => DropdownMenuItem<int>(
                    value: a['id_actividad'] as int, 
                    child: Text('${a['fase']} - ${a['nombre']}', overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (v) => setState(() => _idActividadSel = v),
                ),
              const SizedBox(height: 12),
              if (esEntrada)
                TextField(controller: _costoController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Costo unitario (opcional)', border: OutlineInputBorder())),
              TextField(controller: _notasController, maxLines: 2, decoration: const InputDecoration(labelText: 'Observaciones', border: OutlineInputBorder())),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja, foregroundColor: Colors.white), child: Text('REGISTRAR ${widget.tipo.toUpperCase()}')),
      ],
    );
  }
}