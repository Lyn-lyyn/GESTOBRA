import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';

class AdminReporteMaterialesScreen extends StatefulWidget {
  const AdminReporteMaterialesScreen({super.key});

  @override
  State<AdminReporteMaterialesScreen> createState() => _AdminReporteMaterialesScreenState();
}

class _AdminReporteMaterialesScreenState extends State<AdminReporteMaterialesScreen> {
  bool _cargando = true;
  List<Map<String, dynamic>> _obras = [];
  Map<String, dynamic>? _obraSeleccionada;
  
  Map<String, dynamic>? _totales;
  List<Map<String, dynamic>> _detalle = [];
  bool _cargandoReporte = false;

  @override
  void initState() {
    super.initState();
    _cargarObras();
  }

  Future<void> _cargarObras() async {
    setState(() => _cargando = true);
    final res = await ApiService.get('obras.php');
    if (res['estado'] == true) {
      setState(() {
        _obras = List<Map<String, dynamic>>.from(res['obras'] ?? []);
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
    }
  }

  Future<void> _cargarReporte(int idObra) async {
    setState(() {
      _cargandoReporte = true;
      _totales = null;
      _detalle = [];
    });
    final res = await ApiService.get('reporte_materiales_obra.php?id_obra=$idObra');
    if (res['estado'] == true) {
      setState(() {
        _totales = res['totales'];
        _detalle = List<Map<String, dynamic>>.from(res['detalle'] ?? []);
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['mensaje'] ?? 'Error'), backgroundColor: AppColors.estadoRojo));
      }
    }
    setState(() => _cargandoReporte = false);
  }

  String _fmtMoney(num? v) {
    if (v == null) return '\$0.00';
    return '\$${v.toDouble().toStringAsFixed(2)}';
  }

  String _fmtQty(num? v) {
    if (v == null) return '0';
    final d = v.toDouble();
    return d == d.roundToDouble() ? d.toInt().toString() : d.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: AppBar(
        title: const Text('Reporte Financiero de Materiales', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.blanco,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textoGris),
            onPressed: _cargarObras,
          ),
        ],
      ),
      body: _cargando 
        ? const Center(child: CircularProgressIndicator())
        : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Seleccionar Obra para el Reporte',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: _obras.map((o) => DropdownMenuItem<int>(
                        value: o['id_obra'] as int,
                        child: Text(o['nombre'] ?? ''),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final obra = _obras.firstWhere((o) => o['id_obra'] == val);
                          setState(() => _obraSeleccionada = obra);
                          _cargarReporte(val);
                        }
                      },
                    ),
                  ),
                  
                  if (_cargandoReporte)
                    const Expanded(child: Center(child: CircularProgressIndicator()))
                  else if (_obraSeleccionada == null)
                    const Expanded(child: Center(child: Text('Selecciona una obra para ver el reporte')))
                  else if (_totales == null)
                    const Expanded(child: Center(child: Text('No se pudo cargar el reporte')))
                  else
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildResumenCard(
                                    'Presupuesto Base', 
                                    _fmtMoney(double.tryParse(_totales!['costo_presupuestado']?.toString() ?? '0')), 
                                    Colors.blue
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildResumenCard(
                                    'Costo Real (Recibido)', 
                                    _fmtMoney(double.tryParse(_totales!['costo_real_recibido']?.toString() ?? '0')), 
                                    Colors.green
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildResumenCard(
                                    'Costo de Extras', 
                                    _fmtMoney(double.tryParse(_totales!['costo_extras']?.toString() ?? '0')), 
                                    AppColors.estadoRojo
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildResumenCard(
                                    'Variación', 
                                    _fmtMoney((double.tryParse(_totales!['costo_real_recibido']?.toString() ?? '0') ?? 0) - (double.tryParse(_totales!['costo_presupuestado']?.toString() ?? '0') ?? 0)), 
                                    Colors.orange
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text('Desglose por Material', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white, 
                                borderRadius: BorderRadius.circular(12), 
                                border: Border.all(color: AppColors.bordeSuave)
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowHeight: 40,
                                  dataRowMinHeight: 50,
                                  dataRowMaxHeight: 60,
                                  columns: const [
                                    DataColumn(label: Text('MATERIAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                                    DataColumn(label: Text('PRESUPUESTADO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                                    DataColumn(label: Text('RECIBIDO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                                    DataColumn(label: Text('CONSUMIDO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                                    DataColumn(label: Text('STOCK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                                  ],
                                  rows: _detalle.map((d) {
                                    final pres = double.tryParse(d['cantidad_presupuestada']?.toString() ?? '0') ?? 0;
                                    final cons = double.tryParse(d['cantidad_consumida']?.toString() ?? '0') ?? 0;
                                    final esExtra = d['es_extra'] == 1 || d['es_extra'] == true;
                                    
                                    final excedido = cons > pres;
                                    final colorConsumo = excedido ? AppColors.estadoRojo : AppColors.textoNegro;

                                    return DataRow(cells: [
                                      DataCell(
                                        Row(
                                          children: [
                                            Text(d['material'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                            if (esExtra) ...[
                                              const SizedBox(width: 4),
                                              const Icon(Icons.warning_amber_rounded, color: AppColors.estadoRojo, size: 14),
                                            ]
                                          ],
                                        ),
                                      ),
                                      DataCell(Text('${_fmtQty(pres)} ${d['unidad_medida']}', style: const TextStyle(fontSize: 12))),
                                      DataCell(Text('${_fmtQty(double.tryParse(d['cantidad_entrada']?.toString() ?? '0'))} ${d['unidad_medida']}', style: const TextStyle(fontSize: 12, color: Colors.green))),
                                      DataCell(Text('${_fmtQty(cons)} ${d['unidad_medida']}', style: TextStyle(fontSize: 12, fontWeight: excedido ? FontWeight.bold : FontWeight.normal, color: colorConsumo))),
                                      DataCell(Text('${_fmtQty(double.tryParse(d['stock_actual']?.toString() ?? '0'))} ${d['unidad_medida']}', style: const TextStyle(fontSize: 12))),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildResumenCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordeSuave),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textoGris, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}