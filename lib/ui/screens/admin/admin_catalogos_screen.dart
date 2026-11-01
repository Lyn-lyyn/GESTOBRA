import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';

class AdminCatalogosScreen extends StatefulWidget {
  const AdminCatalogosScreen({super.key});

  @override
  State<AdminCatalogosScreen> createState() => _AdminCatalogosScreenState();
}

class _AdminCatalogosScreenState extends State<AdminCatalogosScreen> {
  // Mapa de tablas para el selector
  final Map<String, String> _catalogosDisponibles = {
    'tipos_material': 'Tipos de Material',
    'tipos_incidencia': 'Tipos de Incidencia',
    'prioridades_incidencia': 'Prioridades de Incidencia',
    'estados_obra': 'Estados de Obra',
    'estados_actividad': 'Estados de Actividad',
    'tipos_movimiento_material': 'Tipos de Movimiento',
  };

  String _tablaSeleccionada = 'tipos_material';
  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _cargarCatalogos();
  }

  Future<void> _cargarCatalogos() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final res = await ApiService.get('catalogos.php?tabla=$_tablaSeleccionada');
      if (res['estado'] == true) {
        setState(() {
          _items = List<Map<String, dynamic>>.from(res['data']);
          _cargando = false;
        });
      } else {
        setState(() { _error = res['mensaje'] ?? 'Error al cargar'; _cargando = false; });
      }
    } catch (e) {
      setState(() { _error = 'Error de red: $e'; _cargando = false; });
    }
  }

  // Obtener el nombre de la llave primaria dependiendo de la tabla
  String get _pkActual {
    switch (_tablaSeleccionada) {
      case 'tipos_material': return 'id_tipo_material';
      case 'tipos_incidencia': return 'id_tipo_incidencia';
      case 'prioridades_incidencia': return 'id_prioridad';
      case 'estados_obra': return 'id_estado_obra';
      case 'estados_actividad': return 'id_estado_actividad';
      case 'tipos_movimiento_material': return 'id_tipo_movimiento';
      default: return 'id';
    }
  }

  Future<void> _abrirModal({Map<String, dynamic>? item}) async {
    final esEdicion = item != null;
    
    final nombreCtrl = TextEditingController(text: item?['nombre']);
    final descCtrl = TextEditingController(text: item?['descripcion']);
    
    // Campos especiales para ciertas tablas
    final nivelCtrl = TextEditingController(text: item?['nivel']?.toString() ?? '1');
    final ordenCtrl = TextEditingController(text: item?['orden_visual']?.toString() ?? '0');

    bool guardando = false;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          title: Text('${esEdicion ? 'Editar' : 'Nuevo'} elemento'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre *', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    if (_tablaSeleccionada != 'prioridades_incidencia' && _tablaSeleccionada != 'estados_obra') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
                      ),
                    ],
                    if (_tablaSeleccionada == 'prioridades_incidencia') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nivelCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Nivel (Ej. 1, 2, 3...) *', border: OutlineInputBorder()),
                        validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                    ],
                    if (_tablaSeleccionada == 'estados_obra') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: ordenCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Orden visual (1, 2, 3...) *', border: OutlineInputBorder()),
                        validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                    ],
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
                  if (esEdicion) _pkActual: item![_pkActual],
                  'nombre': nombreCtrl.text.trim(),
                  'descripcion': descCtrl.text.trim(),
                  'nivel': nivelCtrl.text,
                  'orden_visual': ordenCtrl.text,
                };

                final res = await ApiService.post('catalogos.php?tabla=$_tablaSeleccionada', body);
                if (!mounted) return;

                if (res['estado'] == true) {
                  Navigator.pop(ctx);
                  _cargarCatalogos();
                } else {
                  setModal(() => guardando = false);
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(res['mensaje'] ?? 'Error'), backgroundColor: AppColors.estadoRojo));
                }
              },
              child: guardando
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _eliminar(Map<String, dynamic> item) async {
    final res = await ApiService.delete('catalogos.php?tabla=$_tablaSeleccionada&id=${item[_pkActual]}');
    if (res['estado'] == true) {
      _cargarCatalogos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: AppBar(
        title: const Text('Catálogos del Sistema', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.blanco,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: AppColors.textoGris), onPressed: _cargarCatalogos),
          IconButton(icon: const Icon(Icons.add, color: AppColors.naranja, size: 28), onPressed: () => _abrirModal()),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              // Selector de Catálogo
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.blanco,
                child: DropdownButtonFormField<String>(
                  value: _tablaSeleccionada,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Selecciona el catálogo a gestionar',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.list_alt, color: AppColors.naranja),
                  ),
                  items: _catalogosDisponibles.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _tablaSeleccionada = val);
                      _cargarCatalogos();
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              
              // Lista de Items
              Expanded(
                child: _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.estadoRojo)))
                        : _items.isEmpty
                            ? const Center(child: Text('No hay registros en este catálogo'))
                            : ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: _items.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, i) {
                                  final item = _items[i];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.blanco,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.bordeSuave),
                                    ),
                                    child: ListTile(
                                      title: Text(item['nombre'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text(item['descripcion'] ?? 'Sin descripción'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (item['nivel'] != null)
                                            Container(
                                              margin: const EdgeInsets.only(right: 8),
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                              child: Text('Nivel ${item['nivel']}', style: const TextStyle(color: Colors.blue, fontSize: 12)),
                                            ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _abrirModal(item: item),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: AppColors.estadoRojo),
                                            onPressed: () => _eliminar(item),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}