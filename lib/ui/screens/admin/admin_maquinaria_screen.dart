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
  List<Map<String, dynamic>> _asignaciones = [];
  List<Map<String, dynamic>> _mantenimientos = [];
  List<Map<String, dynamic>> _obras = [];

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  Future<void> _cargarTodo() async {
    setState(() => _cargando = true);
    
    final resMaq = await ApiService.get('maquinaria.php');
    final resAsig = await ApiService.get('asignar_maquinaria.php');
    final resMant = await ApiService.get('mantenimiento_maquinaria.php');
    final resObras = await ApiService.get('obras.php');

    if (resMaq['estado'] == true) _maquinaria = List<Map<String, dynamic>>.from(resMaq['data']);
    if (resAsig['estado'] == true) _asignaciones = List<Map<String, dynamic>>.from(resAsig['data']);
    if (resMant['estado'] == true) _mantenimientos = List<Map<String, dynamic>>.from(resMant['data']);
    if (resObras['estado'] == true) _obras = List<Map<String, dynamic>>.from(resObras['obras']);

    setState(() => _cargando = false);
  }

  // --- MODALES ---
  Future<void> _abrirModalMaquinaria({Map<String, dynamic>? maquina}) async {
    final esEdicion = maquina != null;
    final codigoCtrl = TextEditingController(text: maquina?['codigo']);
    final nombreCtrl = TextEditingController(text: maquina?['nombre']);
    final tipoCtrl = TextEditingController(text: maquina?['tipo_equipo']);
    final marcaCtrl = TextEditingController(text: maquina?['marca']);
    final modeloCtrl = TextEditingController(text: maquina?['modelo']);
    final tDiaCtrl = TextEditingController(text: maquina?['tarifa_renta_dia']?.toString());
    final cCombCtrl = TextEditingController(text: maquina?['costo_combustible_unitario']?.toString());

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
                    Row(children: [
                      Expanded(child: TextFormField(controller: codigoCtrl, decoration: const InputDecoration(labelText: 'Código *', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Req' : null)),
                      const SizedBox(width: 10),
                      Expanded(child: TextFormField(controller: tipoCtrl, decoration: const InputDecoration(labelText: 'Tipo *', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Req' : null)),
                    ]),
                    const SizedBox(height: 12),
                    TextFormField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre del Equipo *', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Req' : null),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: TextFormField(controller: marcaCtrl, decoration: const InputDecoration(labelText: 'Marca', border: OutlineInputBorder()))),
                      const SizedBox(width: 10),
                      Expanded(child: TextFormField(controller: modeloCtrl, decoration: const InputDecoration(labelText: 'Modelo', border: OutlineInputBorder()))),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
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
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: TextFormField(controller: tDiaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Renta/Día', border: OutlineInputBorder()))),
                      const SizedBox(width: 10),
                      Expanded(child: TextFormField(controller: cCombCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Costo Combustible/L', border: OutlineInputBorder()))),
                    ]),
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
                  'costo_combustible_unitario': cCombCtrl.text,
                };

                final res = await ApiService.post('maquinaria.php', body);
                if (!mounted) return;

                if (res['estado'] == true) {
                  Navigator.pop(ctx);
                  _cargarTodo();
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

  Future<void> _abrirModalAsignar() async {
    int? idObraSel;
    int? idMaqSel;
    bool guardando = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          title: const Text('Asignar Maquinaria a Obra'),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Selecciona la Obra *', border: OutlineInputBorder()),
                  items: _obras.map((o) => DropdownMenuItem(value: o['id_obra'] as int, child: Text(o['nombre']))).toList(),
                  onChanged: (v) => setModal(() => idObraSel = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Selecciona la Máquina *', border: OutlineInputBorder()),
                  items: _maquinaria.map((m) => DropdownMenuItem(value: m['id_maquinaria'] as int, child: Text('${m['codigo']} - ${m['nombre']}'))).toList(),
                  onChanged: (v) => setModal(() => idMaqSel = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: guardando ? null : () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
              onPressed: guardando ? null : () async {
                if (idObraSel == null || idMaqSel == null) return;
                setModal(() => guardando = true);

                final res = await ApiService.post('asignar_maquinaria.php', {
                  'id_obra': idObraSel,
                  'id_maquinaria': idMaqSel,
                });

                if (!mounted) return;
                Navigator.pop(ctx);
                if (res['estado'] == true) {
                  _cargarTodo();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Asignada correctamente')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['mensaje']), backgroundColor: AppColors.estadoRojo));
                }
              },
              child: guardando ? const CircularProgressIndicator(color: Colors.white) : const Text('Asignar'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _abrirModalMantenimiento() async {
    int? idMaqSel;
    String tipoSel = 'PREVENTIVO';
    final descCtrl = TextEditingController();
    final costoCtrl = TextEditingController();
    bool guardando = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          title: const Text('Registrar Mantenimiento'),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Máquina *', border: OutlineInputBorder()),
                  items: _maquinaria.map((m) => DropdownMenuItem(value: m['id_maquinaria'] as int, child: Text('${m['codigo']} - ${m['nombre']}'))).toList(),
                  onChanged: (v) => setModal(() => idMaqSel = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: tipoSel,
                  decoration: const InputDecoration(labelText: 'Tipo *', border: OutlineInputBorder()),
                  items: ['PREVENTIVO', 'CORRECTIVO', 'REVISION', 'REPARACION'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setModal(() => tipoSel = v!),
                ),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción *', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: costoCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Costo (Opcional)', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: guardando ? null : () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
              onPressed: guardando ? null : () async {
                if (idMaqSel == null || descCtrl.text.isEmpty) return;
                setModal(() => guardando = true);

                final res = await ApiService.post('mantenimiento_maquinaria.php', {
                  'id_maquinaria': idMaqSel,
                  'tipo_mantenimiento': tipoSel,
                  'descripcion': descCtrl.text.trim(),
                  'costo': costoCtrl.text,
                });

                if (!mounted) return;
                Navigator.pop(ctx);
                if (res['estado'] == true) {
                  _cargarTodo();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mantenimiento registrado')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['mensaje']), backgroundColor: AppColors.estadoRojo));
                }
              },
              child: guardando ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar'),
            )
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
            IconButton(icon: const Icon(Icons.refresh, color: AppColors.textoGris), onPressed: _cargarTodo),
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
                _buildAsignaciones(),
                _buildMantenimientos(),
              ],
            ),
      ),
    );
  }

  Widget _buildCatalogo() {
    if (_maquinaria.isEmpty) return const Center(child: Text('No hay maquinaria registrada'));
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 350, crossAxisSpacing: 16, mainAxisSpacing: 16, mainAxisExtent: 220),
      itemCount: _maquinaria.length,
      itemBuilder: (context, i) {
        final m = _maquinaria[i];
        final operativa = m['estado_equipo'] == 'OPERATIVA';
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.bordeSuave)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.naranja.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: Text(m['codigo'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.naranja, fontSize: 12))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: operativa ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
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
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => _abrirModalMaquinaria(maquina: m)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAsignaciones() {
    // El botón está afuera de la validación, para que SIEMPRE se vea
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _abrirModalAsignar,
            icon: const Icon(Icons.add_link),
            label: const Text('Nueva Asignación'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
          ),
        ),
        Expanded(
          child: _asignaciones.isEmpty
              ? const Center(child: Text('No hay máquinas asignadas actualmente'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _asignaciones.length,
                  itemBuilder: (context, i) {
                    final a = _asignaciones[i];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.precision_manufacturing, color: Colors.white)),
                        title: Text('${a['codigo_maquinaria']} - ${a['nombre_maquinaria']}'),
                        subtitle: Text('Asignada a: ${a['nombre_obra']} (${a['codigo_obra']})\nFecha: ${a['fecha_asignacion']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle, color: AppColors.estadoRojo),
                          onPressed: () async {
                            final res = await ApiService.delete('asignar_maquinaria.php?id=${a['id_obra_maquinaria']}');
                            if (res['estado'] == true) _cargarTodo();
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMantenimientos() {
    // El botón está afuera de la validación, para que SIEMPRE se vea
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _abrirModalMantenimiento,
            icon: const Icon(Icons.build),
            label: const Text('Registrar Mantenimiento'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
          ),
        ),
        Expanded(
          child: _mantenimientos.isEmpty
              ? const Center(child: Text('No hay mantenimientos registrados'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _mantenimientos.length,
                  itemBuilder: (context, i) {
                    final m = _mantenimientos[i];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: AppColors.estadoAmarillo, child: Icon(Icons.build, color: Colors.white)),
                        title: Text('${m['codigo_maquinaria']} - ${m['tipo_mantenimiento']}'),
                        subtitle: Text('${m['descripcion']}\nCosto: \$${m['costo'] ?? 0} | Fecha: ${m['fecha_inicio']}'),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}