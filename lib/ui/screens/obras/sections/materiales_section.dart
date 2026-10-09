import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';

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

  final List<Map<String, dynamic>> _materiales = [
    {'codigo': 'MAT-CEM-01', 'nombre': 'Cemento Gris Portland CPC 30R', 'categoria': 'Cementos y Morteros', 'cantidad': 138.0, 'unidad': 'Bultos', 'minimo': 40.0, 'maximo': 200.0, 'referencia': 'Ref. 5245 C/U'},
    {'codigo': 'MAT-VAR-38', 'nombre': 'Varilla Corrugada 3/8” (Grado 42)', 'categoria': 'Acero y Fierro', 'cantidad': 420.0, 'unidad': 'kg', 'minimo': 100.0, 'maximo': 500.0, 'referencia': 'Ref. 726.5 C/U'},
    {'codigo': 'MAT-VAR-12', 'nombre': 'Varilla Corrugada 1/2” (Grado 42)', 'categoria': 'Acero y Fierro', 'cantidad': 310.0, 'unidad': 'kg', 'minimo': 100.0, 'maximo': 500.0, 'referencia': 'Ref. 927 C/U'},
    {'codigo': 'MAT-ARE-01', 'nombre': 'Arena de Río cribado', 'categoria': 'Áridos y Pétreos', 'cantidad': 12.0, 'unidad': 'm³', 'minimo': 3.0, 'maximo': 15.0, 'referencia': 'Ref. 540 C/U'},
    {'codigo': 'MAT-GRA-01', 'nombre': 'Grava triturada 3/4”', 'categoria': 'Áridos y Pétreos', 'cantidad': 1.0, 'unidad': 'm³', 'minimo': 4.0, 'maximo': 15.0, 'referencia': 'Ref. 820 C/U'},
    {'codigo': 'MAT-ALA-01', 'nombre': 'Alambre recocido calibre 16', 'categoria': 'Acero y Fierro', 'cantidad': 45.0, 'unidad': 'kg', 'minimo': 10.0, 'maximo': 50.0, 'referencia': 'Ref. 532 C/U'},
    {'codigo': 'MAT-TAB-01', 'nombre': 'Block hueco de concreto 15x20x40', 'categoria': 'Cementos y Morteros', 'cantidad': 850.0, 'unidad': 'piezas', 'minimo': 200.0, 'maximo': 1000.0, 'referencia': 'Ref. 8.5 C/U'},
  ];

  final List<Map<String, dynamic>> _consumos = [
    {
      'fase': 'PRELIMINARES', 'avance': 100, 'titulo': 'Limpieza y desmonte del terreno',
      'descripcion': 'Retiro de maleza, escombros y nivelación superficial del terreno con maquinaria ligera.',
      'responsable': 'Cuadrilla 1 - Don Pedro', 'materiales': [],
    },
    {
      'fase': 'PRELIMINARES', 'avance': 100, 'titulo': 'Trazo y nivelación topográfica',
      'descripcion': 'Colocación de valas de madera y tendido de hilos según planos arquitectónicos y estructurales.',
      'responsable': 'Topógrafo Miguel', 'materiales': [],
    },
    {
      'fase': 'CIMENTACIÓN', 'avance': 100, 'titulo': 'Excavación para zapatas y contratrabes',
      'descripcion': 'Excavación a cielo abierto a 1.60 m de profundidad para 12 zapatas aisladas y zanjas de liga.',
      'responsable': 'Cuadrilla 2 - Operador Retro', 'materiales': [],
    },
    {
      'fase': 'CIMENTACIÓN', 'avance': 100, 'titulo': 'Plantilla de concreto pobre f’c = 100 kg/cm²',
      'descripcion': 'Espesor de 5 cm en fondo de zapatas para recibir armado de acero.',
      'responsable': 'Cuadrilla Albañilería',
      'materiales': [
        {'nombre': 'Cemento Gris Portland CPC 30R', 'cantidad': 20.0, 'unidad': 'Bultos'},
      ],
    },
    {
      'fase': 'CIMENTACIÓN', 'avance': 85, 'titulo': 'Armado de acero en zapatas y dados',
      'descripcion': 'Corte, doblez y armado de parrillas de varilla #2 y #3 para zapatas Z1 a Z8 y bastones de dados.',
      'responsable': 'Fierro Juan y ayudante',
      'materiales': [
        {'nombre': 'Varilla Corrugada 3/8” (Grado 42)', 'cantidad': 250.0, 'unidad': 'Kg'},
        {'nombre': 'Alambre recocido calibre 16', 'cantidad': 15.0, 'unidad': 'Kg'},
      ],
    },
    {
      'fase': 'CIMENTACIÓN', 'avance': 30, 'titulo': 'Colado de zapatas y contratrabes f’c = 250 kg/cm²',
      'descripcion': 'Vaciado de concreto premezclado con vibrador de aguja en elementos de cimentación.',
      'responsable': 'Cuadrilla Colados',
      'materiales': [
        {'nombre': 'Cemento Gris Portland CPC 30R', 'cantidad': 24.0, 'unidad': 'Bultos'},
        {'nombre': 'Arena de Río cribado', 'cantidad': 3.0, 'unidad': 'm³'},
        {'nombre': 'Grava triturada 3/4”', 'cantidad': 2.0, 'unidad': 'm³'},
      ],
    },
  ];

  final List<Map<String, dynamic>> _movimientos = [
    {'tipo': 'Salida', 'fecha': '2026-09-22', 'material': 'Cemento Gris Portland CPC 30R', 'cantidad': 24.0, 'unidad': 'Bultos', 'actividad': 'Colado de zapatas y contratrabes f’c = 250 kg/cm²', 'proveedor': 'Concretos Veracruz', 'notas': 'Colado de zapatas Z1–Z8', 'registrado': 'Ing. Carlos Morales'},
    {'tipo': 'Salida', 'fecha': '2026-09-20', 'material': 'Varilla Corrugada 3/8” (Grado 42)', 'cantidad': 250.0, 'unidad': 'Kg', 'actividad': 'Armado de acero en zapatas y dados', 'proveedor': 'Aceros DIMEX', 'notas': 'Varilla y armado para zapatas', 'registrado': 'Arq. Sofía Méndez'},
    {'tipo': 'Salida', 'fecha': '2026-09-19', 'material': 'Alambre recocido calibre 16', 'cantidad': 15.0, 'unidad': 'Kg', 'actividad': 'Armado de acero en zapatas y dados', 'proveedor': 'Aceros DIMEX', 'notas': 'Amarre de parrillas y dados', 'registrado': 'Arq. Sofía Méndez'},
    {'tipo': 'Salida', 'fecha': '2026-09-17', 'material': 'Cemento Gris Portland CPC 30R', 'cantidad': 20.0, 'unidad': 'Bultos', 'actividad': 'Plantilla de concreto pobre f’c = 100 kg/cm²', 'proveedor': 'Concretos Veracruz', 'notas': 'Preparación de plantilla en terreno', 'registrado': 'Arq. Sofía Méndez'},
    {'tipo': 'Entrada', 'fecha': '2026-09-07', 'material': 'Cemento Gris Portland CPC 30R', 'cantidad': 100.0, 'unidad': 'Bultos', 'actividad': 'Compra inicial', 'proveedor': 'Materiales y Aceros del Golfo', 'notas': 'Recepción inicial de inventario', 'registrado': 'Ing. Carlos Morales'},
    {'tipo': 'Entrada', 'fecha': '2026-09-07', 'material': 'Varilla Corrugada 1/2” (Grado 42)', 'cantidad': 670.0, 'unidad': 'Kg', 'actividad': 'Compra inicial', 'proveedor': 'Aceros DIMEX', 'notas': 'Lote certificado recibido en almacén', 'registrado': 'Ing. Carlos Morales'},
  ];

  @override
  void dispose() {
    _busquedaController.dispose();
    _kardexScrollController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _materialesFiltrados {
    final query = _busquedaController.text.trim().toLowerCase();
    if (query.isEmpty) return _materiales;
    return _materiales.where((material) {
      return material['nombre'].toString().toLowerCase().contains(query) ||
          material['codigo'].toString().toLowerCase().contains(query) ||
          material['categoria'].toString().toLowerCase().contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> get _consumosFiltrados {
    final query = _busquedaController.text.trim().toLowerCase();
    if (query.isEmpty) return _consumos;
    return _consumos.where((consumo) {
      return consumo['titulo'].toString().toLowerCase().contains(query) ||
          consumo['fase'].toString().toLowerCase().contains(query) ||
          consumo['responsable'].toString().toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grisfondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gris),
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
          else _buildKardexView(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.grisfondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gris),
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 10), actions],
            );
          }
          return Row(
            children: [Expanded(child: title), actions],
          );
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
          side: const BorderSide(color: AppColors.gris),
        ),
      ),
    );
  }

  Widget _buildSearchAndTabs() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.grisfondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gris),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final search = TextField(
            controller: _busquedaController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Buscar material o actividad...',
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.gris)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.gris)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.naranja, width: 1.5)),
            ),
          );
          final tabs = _buildViewSelector();
          if (constraints.maxWidth < 570) {
            return Column(children: [search, const SizedBox(height: 8), Align(alignment: Alignment.centerRight, child: tabs)]);
          }
          return Row(children: [Expanded(child: search), const SizedBox(width: 10), tabs]);
        },
      ),
    );
  }

  Widget _buildViewSelector() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.gris), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Stock', 'Consumo', 'Kardex'].map((vista) {
          final selected = _vistaSeleccionada == vista;
          return InkWell(
            onTap: () => setState(() => _vistaSeleccionada = vista),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
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
    );
  }

  Widget _buildStockView() {
    final materiales = _materialesFiltrados;
    if (materiales.isEmpty) return _emptyState('No se encontraron materiales');
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1000 ? 4 : width >= 680 ? 3 : width >= 360 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: materiales.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 150,
          ),
          itemBuilder: (context, index) => _buildMaterialCard(materiales[index]),
        );
      },
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> material) {
    final cantidad = (material['cantidad'] as num).toDouble();
    final maximo = (material['maximo'] as num).toDouble();
    final minimo = (material['minimo'] as num).toDouble();
    final critico = cantidad < minimo;
    final nivel = (cantidad / maximo).clamp(0.0, 1.0).toDouble();
    final colorStock = critico ? AppColors.estadoRojo : const Color(0xFF20D620);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.grisfondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: critico ? AppColors.estadoRojo : AppColors.gris, width: critico ? 1.2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(child: _codeBadge(material['codigo'].toString())),
              const SizedBox(width: 6),
              Flexible(child: _statusBadge(critico ? 'Stock crítico' : 'Stock normal', critico)),
            ],
          ),
          const SizedBox(height: 5),
          Text(material['nombre'].toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text(material['categoria'].toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.textoGris)),
          const Divider(height: 10, color: AppColors.gris),
          Row(
            children: [
              const Expanded(child: Text('Existencia', style: TextStyle(fontSize: 9))),
              Text('${_formatQuantity(cantidad)} ${material['unidad']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: nivel, minHeight: 8, backgroundColor: Colors.white, valueColor: AlwaysStoppedAnimation<Color>(colorStock)),
          ),
          Align(alignment: Alignment.centerRight, child: Text(material['referencia'].toString(), style: const TextStyle(fontSize: 8, color: AppColors.textoGris))),
        ],
      ),
    );
  }

  Widget _codeBadge(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.naranja), borderRadius: BorderRadius.circular(10)),
        child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: AppColors.naranja, fontWeight: FontWeight.bold)),
      );

  Widget _statusBadge(String text, bool critical) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(color: critical ? const Color(0xFFFFDCDD) : const Color(0xFFB8E9BE), borderRadius: BorderRadius.circular(10)),
        child: Text(text, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 8, color: critical ? AppColors.estadoRojo : const Color(0xFF17652A), fontWeight: FontWeight.bold)),
      );

  Widget _buildConsumoView() {
    final consumos = _consumosFiltrados;
    if (consumos.isEmpty) return _emptyState('No se encontraron actividades');
    return Column(children: consumos.map(_buildConsumoCard).toList());
  }

  Widget _buildConsumoCard(Map<String, dynamic> consumo) {
    final materiales = consumo['materiales'] as List;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.grisfondo, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gris)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _codeBadge(consumo['fase'].toString()),
              Text('Avance: ${consumo['avance']}%', style: const TextStyle(fontSize: 9, color: AppColors.textoGris)),
              Text('Responsable: ${consumo['responsable']}', style: const TextStyle(fontSize: 9, color: AppColors.textoNegro)),
            ],
          ),
          const SizedBox(height: 6),
          Text(consumo['titulo'].toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(consumo['descripcion'].toString(), style: const TextStyle(fontSize: 10, color: AppColors.textoGris)),
          if (materiales.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 7),
              child: Text('No se han registrado consumos de materiales para esta actividad aún.', style: TextStyle(fontSize: 9, color: AppColors.textoGris, fontStyle: FontStyle.italic)),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: materiales
                    .map((item) => _consumedMaterialCard(
                          Map<String, dynamic>.from(item as Map),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _consumedMaterialCard(Map<String, dynamic> item) {
    return Container(
      constraints: const BoxConstraints(minWidth: 190, maxWidth: 290),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.gris)),
      child: Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item['nombre'].toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), const Text('Destino verificado', style: TextStyle(fontSize: 8, color: AppColors.textoGris))])),
          const SizedBox(width: 8),
          Text(_formatQuantity((item['cantidad'] as num).toDouble()), style: const TextStyle(fontSize: 13, color: AppColors.naranja, fontWeight: FontWeight.bold)),
          const SizedBox(width: 3),
          Text(item['unidad'].toString(), style: const TextStyle(fontSize: 8)),
        ],
      ),
    );
  }

  Widget _buildKardexView() {
    final query = _busquedaController.text.trim().toLowerCase();
    final movimientos = _movimientos.where((movimiento) {
      if (query.isEmpty) return true;
      return movimiento['material'].toString().toLowerCase().contains(query) ||
          movimiento['actividad'].toString().toLowerCase().contains(query) ||
          movimiento['proveedor'].toString().toLowerCase().contains(query);
    }).toList();
    if (movimientos.isEmpty) return _emptyState('No hay movimientos que coincidan');
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: AppColors.grisfondo, border: Border.all(color: AppColors.gris), borderRadius: BorderRadius.circular(12)),
          child: const Row(children: [Icon(Icons.history, color: AppColors.naranja, size: 18), SizedBox(width: 6), Text('Bitácora de Movimientos y Kardex de Almacén', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))]),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.gris), borderRadius: BorderRadius.circular(12)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;
              return Scrollbar(
                controller: _kardexScrollController,
                thumbVisibility: isMobile,
                trackVisibility: isMobile,
                thickness: isMobile ? 6 : 4,
                radius: const Radius.circular(8),
                child: SingleChildScrollView(
                  controller: _kardexScrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      headingRowHeight: 44,
                      dataRowMinHeight: 58,
                      dataRowMaxHeight: 72,
                      columnSpacing: isMobile ? 22 : 28,
                      horizontalMargin: 20,
                      columns: const [
                        DataColumn(label: Text('Tipo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Fecha', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Material', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Cantidad', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Proveedor / Actividad', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Ref. / Notas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Registrado por', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      ],
                      rows: movimientos.map((movimiento) {
                        final entrada = movimiento['tipo'] == 'Entrada';
                        return DataRow(cells: [
                          DataCell(Icon(entrada ? Icons.south_west : Icons.north_east, color: entrada ? const Color(0xFF2C9B43) : AppColors.naranja, size: 20)),
                          DataCell(Text(movimiento['fecha'].toString(), style: const TextStyle(fontSize: 11))),
                          DataCell(SizedBox(width: 180, child: Text(movimiento['material'].toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)))),
                          DataCell(Text('${_formatQuantity((movimiento['cantidad'] as num).toDouble())} ${movimiento['unidad']}', style: const TextStyle(fontSize: 11))),
                          DataCell(SizedBox(width: 190, child: Text('${movimiento['actividad']}\n${movimiento['proveedor']}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)))),
                          DataCell(SizedBox(width: 180, child: Text(movimiento['notas'].toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)))),
                          DataCell(Text(movimiento['registrado'].toString(), style: const TextStyle(fontSize: 11))),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La impresión del Kardex estará disponible al conectar el módulo de reportes.'))),
            icon: const Icon(Icons.print_outlined, size: 16),
            label: const Text('IMPRIMIR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          ),
        ),
      ],
    );
  }

  Widget _emptyState(String message) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gris)),
        child: Center(child: Text(message, style: const TextStyle(color: AppColors.textoGris, fontSize: 12))),
      );

  Future<void> _openMovementDialog(BuildContext context, String tipo) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _MaterialMovementDialog(materiales: _materiales, actividades: _consumos, tipo: tipo),
    );
    if (result == null || !mounted) return;
    final material = _materiales.firstWhere((item) => item['nombre'] == result['material']);
    final cantidad = result['cantidad'] as double;
    if (tipo == 'Salida' && cantidad > (material['cantidad'] as num).toDouble()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La cantidad de salida supera las existencias disponibles.')));
      return;
    }
    setState(() {
      final stockActual = (material['cantidad'] as num).toDouble();
      material['cantidad'] = tipo == 'Entrada' ? stockActual + cantidad : stockActual - cantidad;
      _movimientos.insert(0, {
        'tipo': tipo,
        'fecha': result['fecha'],
        'material': result['material'],
        'cantidad': cantidad,
        'unidad': result['unidad'],
        'actividad': result['actividad'],
        'proveedor': result['proveedor'],
        'notas': result['notas'],
        'registrado': 'Ing. Carlos Morales',
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$tipo registrada correctamente')));
  }

  String _formatQuantity(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);
}

class _MaterialMovementDialog extends StatefulWidget {
  final List<Map<String, dynamic>> materiales;
  final List<Map<String, dynamic>> actividades;
  final String tipo;

  const _MaterialMovementDialog({required this.materiales, required this.actividades, required this.tipo});

  @override
  State<_MaterialMovementDialog> createState() => _MaterialMovementDialogState();
}

class _MaterialMovementDialogState extends State<_MaterialMovementDialog> {
  final _cantidadController = TextEditingController();
  final _proveedorController = TextEditingController();
  final _notasController = TextEditingController();
  String? _materialSeleccionado;
  String? _actividadSeleccionada;

  @override
  void dispose() {
    _cantidadController.dispose();
    _proveedorController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  void _save() {
    final cantidad = double.tryParse(_cantidadController.text.trim().replaceAll(',', '.'));
    if (_materialSeleccionado == null || cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un material e indica una cantidad válida.')));
      return;
    }
    final material = widget.materiales.firstWhere((item) => item['nombre'] == _materialSeleccionado);
    Navigator.of(context).pop({
      'material': _materialSeleccionado,
      'cantidad': cantidad,
      'unidad': material['unidad'],
      'actividad': _actividadSeleccionada ?? (widget.tipo == 'Entrada' ? 'Compra / recepción de material' : 'Consumo de obra'),
      'proveedor': _proveedorController.text.trim().isEmpty ? 'Sin especificar' : _proveedorController.text.trim(),
      'notas': _notasController.text.trim().isEmpty ? 'Sin observaciones' : _notasController.text.trim(),
      'fecha': _today(),
    });
  }

  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final esEntrada = widget.tipo == 'Entrada';
    return AlertDialog(
      title: Row(children: [Icon(esEntrada ? Icons.south_west : Icons.north_east, color: AppColors.naranja), const SizedBox(width: 8), Expanded(child: Text('Registrar ${widget.tipo.toLowerCase()} de material'))]),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dropdown('Material', _materialSeleccionado, widget.materiales.map((item) => item['nombre'].toString()).toList(), (value) => setState(() => _materialSeleccionado = value)),
              const SizedBox(height: 12),
              TextField(controller: _cantidadController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Cantidad', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 12),
              if (esEntrada)
                TextField(controller: _proveedorController, decoration: InputDecoration(labelText: 'Proveedor', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))
              else
                _dropdown('Actividad relacionada', _actividadSeleccionada, widget.actividades.map((item) => item['titulo'].toString()).toList(), (value) => setState(() => _actividadSeleccionada = value)),
              const SizedBox(height: 12),
              TextField(controller: _notasController, maxLines: 2, decoration: InputDecoration(labelText: esEntrada ? 'Referencia / notas' : 'Destino / notas', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja, foregroundColor: Colors.black), child: Text('REGISTRAR ${widget.tipo.toUpperCase()}')),
      ],
    );
  }

  Widget _dropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
    );
  }
}
