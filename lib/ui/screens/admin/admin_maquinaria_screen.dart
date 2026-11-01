import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';

class AdminMaquinariaScreen extends StatefulWidget {
  const AdminMaquinariaScreen({super.key});

  @override
  State<AdminMaquinariaScreen> createState() => _AdminMaquinariaScreenState();
}

class _AdminMaquinariaScreenState extends State<AdminMaquinariaScreen> {
  bool _cargando = true;
  List<Map<String, dynamic>> _maquinaria = [];

  @override
  void initState() {
    super.initState();
    _cargarMaquinaria();
  }

  Future<void> _cargarMaquinaria() async {
    setState(() => _cargando = true);
    final res = await ApiService.get('maquinaria.php');
    if (res['estado'] == true) {
      setState(() {
        _maquinaria = List<Map<String, dynamic>>.from(res['data']);
        _cargando = false;
      });
    }
  }

  Future<void> _abrirModalMaquinaria({Map<String, dynamic>? maquina}) async {
    final esEdicion = maquina != null;
    
    // Controladores
    final codigoCtrl = TextEditingController(text: maquina?['codigo']);
    final nombreCtrl = TextEditingController(text: maquina?['nombre']);
    final tipoCtrl = TextEditingController(text: maquina?['tipo_equipo']);
    final marcaCtrl = TextEditingController(text: maquina?['marca']);
    final modeloCtrl = TextEditingController(text: maquina?['modelo']);
    final serieCtrl = TextEditingController(text: maquina?['numero_serie']);
    final tDiaCtrl = TextEditingController(text: maquina?['tarifa_renta_dia']?.toString());
    final tHrCtrl = TextEditingController(text: maquina?['tarifa_renta_hora']?.toString());
    final cOpCtrl = TextEditingController(text: maquina?['costo_operacion_hora']?.toString());
    final cCombCtrl = TextEditingController(text: maquina?['costo_combustible_unitario']?.toString());
    final descCtrl = TextEditingController(text: maquina?['descripcion']);

    String propiedadSel = maquina?['propiedad'] ?? 'PROPIA';
    String estadoSel = maquina?['estado_equipo'] ?? 'OPERATIVA';

    bool guardando = false;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          title: Text(esEdicion ? 'Editar Equipo' : 'Registrar Maquinaria'),
          content: SizedBox(
            width: 550,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: codigoCtrl, decoration: const InputDecoration(labelText: 'Código (Ej. MAQ-01) *', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Req' : null)),
                        const SizedBox(width: 10),
                        Expanded(child: TextFormField(controller: tipoCtrl, decoration: const InputDecoration(labelText: 'Tipo (Ej. Retro) *', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Req' : null)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre del Equipo *', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Req' : null),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: marcaCtrl, decoration: const InputDecoration(labelText: 'Marca', border: OutlineInputBorder()))),
                        const SizedBox(width: 10),
                        Expanded(child: TextFormField(controller: modeloCtrl, decoration: const InputDecoration(labelText: 'Modelo', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: propiedadSel,
                            decoration: const InputDecoration(labelText: 'Propiedad', border: OutlineInputBorder()),
                            items: ['PROPIA', 'RENTADA', 'PRESTADA'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            onChanged: (v) => setModal(() => propiedadSel = v!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: estadoSel,
                            decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
                            items: ['OPERATIVA', 'MANTENIMIENTO', 'FUERA_DE_SERVICIO'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            onChanged: (v) => setModal(() => estadoSel = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Costos (Opcionales)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: tDiaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Renta/Día', border: OutlineInputBorder()))),
                        const SizedBox(width: 10),
                        Expanded(child: TextFormField(controller: tHrCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Renta/Hora', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: cOpCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Costo Op./Hora', border: OutlineInputBorder()))),
                        const SizedBox(width: 10),
                        Expanded(child: TextFormField(controller: cCombCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Costo Combustible/L', border: OutlineInputBorder()))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: guardando ? null : () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
              onPressed: guardando ? null : () async {
                if (!formKey.currentState!.validate()) return;
                setModal(() => guardando = true);

                final body = {
                  if (esEdicion) 'id_maquinaria': maquina['id_maquinaria'],
                  'codigo': codigoCtrl.text.trim(),
                  'nombre': nombreCtrl.text.trim(),
                  'tipo_equipo': tipoCtrl.text.trim(),
                  'marca': marcaCtrl.text.trim(),
                  'modelo': modeloCtrl.text.trim(),
                  'propiedad': propiedadSel,
                  'estado_equipo': estadoSel,
                  'tarifa_renta_dia': tDiaCtrl.text,
                  'tarifa_renta_hora': tHrCtrl.text,
                  'costo_operacion_hora': cOpCtrl.text,
                  'costo_combustible_unitario': cCombCtrl.text,
                };

                final res = await ApiService.post('maquinaria.php', body);
                if (!mounted) return;

                if (res['estado'] == true) {
                  Navigator.pop(ctx);
                  _cargarMaquinaria();
                } else {
                  setModal(() => guardando = false);
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(res['mensaje'] ?? 'Error'), backgroundColor: AppColors.estadoRojo));
                }
              },
              child: guardando ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.grisfondo,
        appBar: AppBar(
          title: const Text('Gestión de Maquinaria', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.blanco,
          elevation: 0,
          actions: [
            IconButton(icon: const Icon(Icons.refresh, color: AppColors.textoGris), onPressed: _cargarMaquinaria),
            IconButton(icon: const Icon(Icons.add_circle, color: AppColors.naranja, size: 28), onPressed: () => _abrirModalMaquinaria()),
          ],
          bottom: const TabBar(
            labelColor: AppColors.naranja,
            unselectedLabelColor: AppColors.textoGris,
            indicatorColor: AppColors.naranja,
            tabs: [
              Tab(text: 'Catálogo', icon: Icon(Icons.precision_manufacturing)),
              Tab(text: 'Asignadas', icon: Icon(Icons.assignment)),
              Tab(text: 'Mantenimientos', icon: Icon(Icons.build)),
            ],
          ),
        ),
        body: _cargando 
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              children: [
                _buildCatalogo(),
                const Center(child: Text('Módulo de Asignaciones en construcción...')),
                const Center(child: Text('Módulo de Mantenimientos en construcción...')),
              ],
            ),
      ),
    );
  }

  Widget _buildCatalogo() {
    if (_maquinaria.isEmpty) return const Center(child: Text('No hay maquinaria registrada'));

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 350,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 220,
          ),
          itemCount: _maquinaria.length,
          itemBuilder: (context, i) {
            final m = _maquinaria[i];
            final operativa = m['estado_equipo'] == 'OPERATIVA';
            
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.blanco,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.bordeSuave),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.naranja.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(m['codigo'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.naranja, fontSize: 12)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: operativa ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(m['estado_equipo'], style: TextStyle(color: operativa ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(m['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${m['marca'] ?? ''} ${m['modelo'] ?? ''}', style: const TextStyle(color: AppColors.textoGris, fontSize: 12)),
                  
                  const Spacer(),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tarifa/Día: \$${m['tarifa_renta_dia'] ?? 0}', style: const TextStyle(fontSize: 11)),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                        onPressed: () => _abrirModalMaquinaria(maquina: m),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}