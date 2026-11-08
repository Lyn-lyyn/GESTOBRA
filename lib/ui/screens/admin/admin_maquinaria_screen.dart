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
    if (!mounted) return;
    setState(() => _cargando = true);
    
    try {
      final resMaq = await ApiService.get('maquinaria.php');
      final resAsig = await ApiService.get('asignar_maquinaria.php');
      final resMant = await ApiService.get('mantenimiento_maquinaria.php');
      final resObras = await ApiService.get('obras.php');

      if (resMaq['estado'] == true) _maquinaria = List<Map<String, dynamic>>.from(resMaq['data']);
      if (resAsig['estado'] == true) _asignaciones = List<Map<String, dynamic>>.from(resAsig['data']);
      if (resMant['estado'] == true) _mantenimientos = List<Map<String, dynamic>>.from(resMant['data']);
      if (resObras['estado'] == true) _obras = List<Map<String, dynamic>>.from(resObras['obras']);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error de red: $e'), backgroundColor: AppColors.estadoRojo));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // ────────────────────────────────────────────────────────
  // MODAL: CREAR / EDITAR MAQUINARIA
  // ────────────────────────────────────────────────────────
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

                try {
                  final res = await ApiService.post('maquinaria.php', body);
                  if (!mounted) return;

                  if (res != null && res['estado'] == true) {
                    Navigator.pop(ctx);
                    _cargarTodo();
                  } else {
                    setModal(() => guardando = false);
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(res?['mensaje'] ?? 'Error'), backgroundColor: AppColors.estadoRojo));
                  }
                } catch (e) {
                  setModal(() => guardando = false);
                  if (mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.estadoRojo));
                }
              },
              child: guardando ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // MODAL: ASIGNAR MAQUINARIA
  // ────────────────────────────────────────────────────────
  Future<void> _abrirModalAsignar() async {
    int? idObraSel;
    int? idMaqSel;
    bool guardando = false;

    // Filtramos para que solo muestre máquinas operativas disponibles
    final maquinasDisponibles = _maquinaria.where((m) => m['estado_equipo'] == 'OPERATIVA').toList();

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
                  items: maquinasDisponibles.map((m) => DropdownMenuItem(value: m['id_maquinaria'] as int, child: Text('${m['codigo']} - ${m['nombre']}'))).toList(),
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

                try {
                  final res = await ApiService.post('asignar_maquinaria.php', {
                    'id_obra': idObraSel,
                    'id_maquinaria': idMaqSel,
                  });

                  if (!mounted) return;
                  Navigator.pop(ctx);
                  if (res != null && res['estado'] == true) {
                    _cargarTodo();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Asignada correctamente')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res?['mensaje'] ?? 'Error'), backgroundColor: AppColors.estadoRojo));
                  }
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.estadoRojo));
                }
              },
              child: guardando ? const CircularProgressIndicator(color: Colors.white) : const Text('Asignar'),
            )
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // MODAL: REGISTRAR MANTENIMIENTO (Y CAMBIO AUTOMÁTICO)
  // ────────────────────────────────────────────────────────
  Future<void> _abrirModalMantenimiento({Map<String, dynamic>? maquina}) async {
    int? idMaqSel = maquina != null ? maquina['id_maquinaria'] : null;
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
                  value: idMaqSel,
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

                try {
                  // 1. Guardar el mantenimiento
                  final res = await ApiService.post('mantenimiento_maquinaria.php', {
                    'id_maquinaria': idMaqSel,
                    'tipo_mantenimiento': tipoSel,
                    'descripcion': descCtrl.text.trim(),
                    'costo': costoCtrl.text,
                  });

                  if (!mounted) return;

                  if (res != null && res['estado'] == true) {
                    // 2. 👇 ACTUALIZAR EL ESTADO DE LA MÁQUINA A MANTENIMIENTO 👇
                    final maquinaInfo = _maquinaria.firstWhere((m) => m['id_maquinaria'] == idMaqSel);
                    
                    await ApiService.post('maquinaria.php', {
                      'id_maquinaria': idMaqSel,
                      'codigo': maquinaInfo['codigo'],
                      'nombre': maquinaInfo['nombre'],
                      'tipo_equipo': maquinaInfo['tipo_equipo'],
                      'marca': maquinaInfo['marca'] ?? '',
                      'modelo': maquinaInfo['modelo'] ?? '',
                      'propiedad': maquinaInfo['propiedad'],
                      'estado_equipo': 'MANTENIMIENTO', // 👈 Forzamos el estado
                      'tarifa_renta_dia': maquinaInfo['tarifa_renta_dia'] ?? '0',
                      'costo_combustible_unitario': maquinaInfo['costo_combustible_unitario'] ?? '0',
                    });

                    Navigator.pop(ctx);
                    _cargarTodo();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mantenimiento registrado. Equipo en taller.')));
                  } else {
                    setModal(() => guardando = false);
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(res?['mensaje'] ?? 'Error'), backgroundColor: AppColors.estadoRojo));
                  }
                } catch (e) {
                  if (mounted) {
                    setModal(() => guardando = false);
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.estadoRojo));
                  }
                }
              },
              child: guardando ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar'),
            )
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // MODAL: ELIMINAR MAQUINARIA
  // ────────────────────────────────────────────────────────
  Future<void> _confirmarEliminarMaquinaria(Map<String, dynamic> maquina) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar Equipo?'),
        content: Text('¿Estás seguro de dar de baja "${maquina['nombre']}" del catálogo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.estadoRojo),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        final res = await ApiService.delete('maquinaria.php?id=${maquina['id_maquinaria']}');
        if (res != null && res['estado'] == true) {
          _cargarTodo();
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Equipo eliminado')));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: AppColors.estadoRojo));
      }
    }
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

  // ────────────────────────────────────────────────────────
  // VISTA 1: CATÁLOGO (CON MENÚ DE OPCIONES)
  // ────────────────────────────────────────────────────────
  Widget _buildCatalogo() {
    if (_maquinaria.isEmpty) return const Center(child: Text('No hay maquinaria registrada'));
    
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350, 
        crossAxisSpacing: 16, 
        mainAxisSpacing: 16, 
        mainAxisExtent: 220
      ),
      itemCount: _maquinaria.length,
      itemBuilder: (context, i) {
        final m = _maquinaria[i];
        final operativa = m['estado_equipo'] == 'OPERATIVA';
        final enMantenimiento = m['estado_equipo'] == 'MANTENIMIENTO';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.blanco, 
            borderRadius: BorderRadius.circular(16), 
            border: Border.all(color: AppColors.bordeSuave),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
            ]
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
                    child: Text(m['codigo'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.naranja, fontSize: 12))
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: operativa 
                          ? Colors.green.withValues(alpha: 0.1) 
                          : (enMantenimiento ? Colors.orange.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1)), 
                      borderRadius: BorderRadius.circular(6)
                    ),
                    child: Text(
                      m['estado_equipo'], 
                      style: TextStyle(
                        color: operativa 
                            ? Colors.green 
                            : (enMantenimiento ? Colors.orange[800] : Colors.red), 
                        fontSize: 10, 
                        fontWeight: FontWeight.bold
                      )
                    ),
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
                  
                  // 👇 MENÚ DE ACCIONES 👇
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.textoGris),
                    onSelected: (value) {
                      if (value == 'editar') {
                        _abrirModalMaquinaria(maquina: m);
                      } else if (value == 'mantenimiento') {
                        _abrirModalMantenimiento(maquina: m);
                      } else if (value == 'eliminar') {
                        _confirmarEliminarMaquinaria(m);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'editar',
                        child: Row(children: [Icon(Icons.edit, size: 18, color: Colors.blue), SizedBox(width: 8), Text('Editar Datos')]),
                      ),
                      const PopupMenuItem(
                        value: 'mantenimiento',
                        child: Row(children: [Icon(Icons.build, size: 18, color: Colors.orange), SizedBox(width: 8), Text('A Mantenimiento')]),
                      ),
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: Row(children: [Icon(Icons.delete, size: 18, color: AppColors.estadoRojo), SizedBox(width: 8), Text('Eliminar Equipo')]),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────
  // VISTA 2: ASIGNADAS (DISEÑO MÓVIL MEJORADO)
  // ────────────────────────────────────────────────────────
  Widget _buildAsignaciones() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _abrirModalAsignar,
              icon: const Icon(Icons.add_link),
              label: const Text('Nueva Asignación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.naranja,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        Expanded(
          child: _asignaciones.isEmpty
              ? const Center(child: Text('No hay máquinas asignadas actualmente'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  itemCount: _asignaciones.length,
                  itemBuilder: (context, i) {
                    final a = _asignaciones[i];
                    return Card(
                      color: AppColors.blanco, // Fondo blanco
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.bordeSuave),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.precision_manufacturing, color: Colors.blue, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${a['codigo_maquinaria']}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.naranja, fontSize: 12)),
                                      Text(a['nombre_maquinaria'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.estadoRojo),
                                  tooltip: 'Retirar asignación',
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('¿Retirar máquina?'),
                                        content: Text('¿Estás seguro de retirar "${a['nombre_maquinaria']}" de la obra "${a['nombre_obra']}"?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.estadoRojo),
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: const Text('Retirar'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      final res = await ApiService.delete('asignar_maquinaria.php?id=${a['id_obra_maquinaria']}');
                                      if (res != null && res['estado'] == true) _cargarTodo();
                                    }
                                  },
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              children: [
                                const Icon(Icons.business_center, size: 16, color: AppColors.textoGris),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text('${a['nombre_obra']} (${a['codigo_obra']})', style: const TextStyle(fontSize: 13, color: AppColors.textoGris), overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textoGris),
                                const SizedBox(width: 6),
                                Text('Asignada: ${a['fecha_asignacion']}', style: const TextStyle(fontSize: 13, color: AppColors.textoGris)),
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

  // ────────────────────────────────────────────────────────
  // VISTA 3: MANTENIMIENTOS (DISEÑO MÓVIL MEJORADO)
  // ────────────────────────────────────────────────────────
  Widget _buildMantenimientos() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _abrirModalMantenimiento(),
              icon: const Icon(Icons.build),
              label: const Text('Registrar Mantenimiento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.naranja,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        Expanded(
          child: _mantenimientos.isEmpty
              ? const Center(child: Text('No hay mantenimientos registrados'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  itemCount: _mantenimientos.length,
                  itemBuilder: (context, i) {
                    final m = _mantenimientos[i];
                    return Card(
                      color: AppColors.blanco, // Fondo blanco
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.bordeSuave),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                  child: Icon(
                                    m['tipo_mantenimiento'] == 'PREVENTIVO' ? Icons.handyman : Icons.build_circle, 
                                    color: Colors.orange[800], 
                                    size: 24
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${m['codigo_maquinaria']}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.naranja, fontSize: 12)),
                                      Text(m['tipo_mantenimiento'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: m['estado'] == 'COMPLETADO' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    m['estado'] ?? 'EN_PROCESO',
                                    style: TextStyle(
                                      color: m['estado'] == 'COMPLETADO' ? Colors.green : Colors.orange[800],
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Text(m['descripcion'], style: const TextStyle(fontSize: 13, color: AppColors.textoNegro), maxLines: 3, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.attach_money, size: 16, color: AppColors.textoGris),
                                    const SizedBox(width: 4),
                                    Text('Costo: \$${m['costo'] ?? 0}', style: const TextStyle(fontSize: 12, color: AppColors.textoGris)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textoGris),
                                    const SizedBox(width: 4),
                                    Text(m['fecha_inicio'] ?? '--', style: const TextStyle(fontSize: 12, color: AppColors.textoGris)),
                                  ],
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
}