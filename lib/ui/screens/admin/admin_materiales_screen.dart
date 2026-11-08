import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';

class AdminMaterialesScreen extends StatefulWidget {
  const AdminMaterialesScreen({super.key});
  @override
  State<AdminMaterialesScreen> createState() => _AdminMaterialesScreenState();
}

class _AdminMaterialesScreenState extends State<AdminMaterialesScreen> {
  bool _cargando = true;
  List<Map<String, dynamic>> _materiales = [];
  List<Map<String, dynamic>> _obras = [];
  Map<String, dynamic>? _obraSeleccionada;

  List<Map<String, dynamic>> _stockObra = [];
  List<Map<String, dynamic>> _movimientosObra = [];

  @override
  void initState() {
    super.initState();
    _cargarCatalogos();
  }

  Future<void> _cargarCatalogos() async {
    setState(() => _cargando = true);
    final resMat = await ApiService.get('materiales_admin.php');
    final resObras = await ApiService.get('obras.php');

    if (resMat['estado'] == true) _materiales = List<Map<String, dynamic>>.from(resMat['data']);
    if (resObras['estado'] == true) _obras = List<Map<String, dynamic>>.from(resObras['obras']);

    setState(() => _cargando = false);
  }

  Future<void> _cargarStockObra(int idObra) async {
    setState(() => _cargando = true);
    final res = await ApiService.get('materiales_admin.php?id_obra=$idObra');
    if (res['estado'] == true) {
      setState(() {
        _stockObra = List<Map<String, dynamic>>.from(res['stock'] ?? []);
        _movimientosObra = List<Map<String, dynamic>>.from(res['movimientos'] ?? []);
      });
    }
    setState(() => _cargando = false);
  }

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
          actions: [IconButton(icon: const Icon(Icons.refresh, color: AppColors.textoGris), onPressed: _cargarCatalogos)],
          bottom: const TabBar(
            labelColor: AppColors.naranja,
            unselectedLabelColor: AppColors.textoGris,
            indicatorColor: AppColors.naranja,
            tabs: [Tab(text: 'Catálogo'), Tab(text: 'Stock por Obra')],
          ),
        ),
        body: _cargando
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // TAB 1: Catálogo
                  _materiales.isEmpty
                      ? const Center(child: Text('No hay materiales'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _materiales.length,
                          itemBuilder: (context, i) {
                            final m = _materiales[i];
                            return Card(
                              color: AppColors.blanco,
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.bordeSuave)),
                              child: ListTile(
                                leading: CircleAvatar(backgroundColor: AppColors.naranja.withValues(alpha: 0.1), child: const Icon(Icons.inventory, color: AppColors.naranja)),
                                title: Text(m['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${m['tipo_material'] ?? 'General'} | Unidad: ${m['unidad_medida']}'),
                                trailing: Text('\$${m['costo_referencia'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.estadoVerde)),
                              ),
                            );
                          },
                        ),
                  // TAB 2: Stock por Obra
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: DropdownButtonFormField<int>(
                          decoration: const InputDecoration(labelText: 'Seleccionar Obra', border: OutlineInputBorder()),
                          items: _obras.map((o) => DropdownMenuItem(value: o['id_obra'] as int, child: Text(o['nombre']))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              final obra = _obras.firstWhere((o) => o['id_obra'] == val);
                              setState(() => _obraSeleccionada = obra);
                              _cargarStockObra(val);
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: _obraSeleccionada == null
                            ? const Center(child: Text('Selecciona una obra para ver su stock'))
                            : _stockObra.isEmpty
                                ? const Center(child: Text('Esta obra no tiene materiales registrados'))
                                : ListView(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    children: [
                                      const Text('Stock Actual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 8),
                                      ..._stockObra.map((s) => Card(
                                        color: AppColors.blanco,
                                        margin: const EdgeInsets.only(bottom: 8),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.bordeSuave)),
                                        child: ListTile(
                                          title: Text('${s['material']} (${s['unidad_medida']})'),
                                          trailing: Text('${s['existencia']} / Min: ${s['stock_minimo']}', style: TextStyle(color: (double.tryParse(s['existencia'].toString()) ?? 0) < (double.tryParse(s['stock_minimo'].toString()) ?? 0) ? AppColors.estadoRojo : Colors.green, fontWeight: FontWeight.bold)),
                                        ),
                                      )),
                                      const SizedBox(height: 16),
                                      const Text('Últimos Movimientos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 8),
                                      ..._movimientosObra.map((m) => Card(
                                        color: AppColors.blanco,
                                        margin: const EdgeInsets.only(bottom: 8),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.bordeSuave)),
                                        child: ListTile(
                                          leading: Icon(m['tipo_movimiento'] == 'ENTRADA' ? Icons.arrow_downward : Icons.arrow_upward, color: m['tipo_movimiento'] == 'ENTRADA' ? Colors.green : Colors.red),
                                          title: Text('${m['material']} - ${m['tipo_movimiento']}'),
                                          subtitle: Text('Cantidad: ${m['cantidad']} | Fecha: ${m['fecha_movimiento']}'),
                                        ),
                                      )),
                                    ],
                                  ),
                      ),
                    ],
                  )
                ],
              ),
      ),
    );
  }
}