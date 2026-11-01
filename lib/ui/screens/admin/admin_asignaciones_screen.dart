import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';

class AdminAsignacionesScreen extends StatefulWidget {
  const AdminAsignacionesScreen({super.key});

  @override
  State<AdminAsignacionesScreen> createState() => _AdminAsignacionesScreenState();
}

class _AdminAsignacionesScreenState extends State<AdminAsignacionesScreen> {
  bool _cargando = true;
  List<Map<String, dynamic>> _asignaciones = [];
  List<Map<String, dynamic>> _obras = [];
  List<Map<String, dynamic>> _usuarios = [];

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  Future<void> _cargarTodo() async {
    setState(() => _cargando = true);
    try {
      // Cargamos las asignaciones, obras y usuarios en paralelo
      final resAsig = await ApiService.get('asignaciones.php');
      final resObras = await ApiService.get('obras.php');
      final resUsers = await ApiService.get('listar_usuarios.php');

      if (resAsig['estado'] == true && resObras['estado'] == true && resUsers['estado'] == true) {
        setState(() {
          _asignaciones = List<Map<String, dynamic>>.from(resAsig['data']);
          _obras = List<Map<String, dynamic>>.from(resObras['obras']);
          _usuarios = List<Map<String, dynamic>>.from(resUsers['usuarios']).where((u) => u['activo'] == 1).toList();
          _cargando = false;
        });
      } else {
        setState(() => _cargando = false);
        _showError('Error al cargar datos del servidor');
      }
    } catch (e) {
      setState(() => _cargando = false);
      _showError('Error de red: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.estadoRojo));
  }

  Future<void> _abrirModalNuevaAsignacion() async {
    int? idObraSel;
    int? idUsuarioSel;
    String tipoAsignacionSel = 'SUPERVISOR';
    bool guardando = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          title: const Text('Asignar Personal a Obra'),
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
                  decoration: const InputDecoration(labelText: 'Selecciona al Usuario *', border: OutlineInputBorder()),
                  items: _usuarios.map((u) {
                    final nombre = '${u['nombre']} ${u['apellido_paterno']}';
                    return DropdownMenuItem(value: u['id_usuario'] as int, child: Text(nombre));
                  }).toList(),
                  onChanged: (v) => setModal(() => idUsuarioSel = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: tipoAsignacionSel,
                  decoration: const InputDecoration(labelText: 'Rol en esta obra *', border: OutlineInputBorder()),
                  items: ['COORDINADOR', 'SUPERVISOR', 'CAPTURISTA', 'CONSULTA'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) => setModal(() => tipoAsignacionSel = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: guardando ? null : () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
              onPressed: guardando ? null : () async {
                if (idObraSel == null || idUsuarioSel == null) {
                  _showError('Selecciona obra y usuario');
                  return;
                }
                setModal(() => guardando = true);

                final body = {
                  'id_obra': idObraSel,
                  'id_usuario': idUsuarioSel,
                  'tipo_asignacion': tipoAsignacionSel,
                };

                final res = await ApiService.post('asignaciones.php', body);
                if (!mounted) return;

                if (res['estado'] == true) {
                  Navigator.pop(ctx);
                  _cargarTodo();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['mensaje'])));
                } else {
                  setModal(() => guardando = false);
                  _showError(res['mensaje'] ?? 'Error');
                }
              },
              child: guardando ? const CircularProgressIndicator(color: Colors.white) : const Text('Asignar'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _eliminarAsignacion(int id) async {
    final res = await ApiService.delete('asignaciones.php?id=$id');
    if (res['estado'] == true) {
      _cargarTodo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: AppBar(
        title: const Text('Asignación de Obras', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.blanco,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: AppColors.textoGris), onPressed: _cargarTodo),
          IconButton(
            icon: const Icon(Icons.add_link, color: AppColors.naranja, size: 26),
            tooltip: 'Nueva Asignación',
            onPressed: _abrirModalNuevaAsignacion,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _asignaciones.isEmpty
                  ? const Center(child: Text('No hay asignaciones registradas'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _asignaciones.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final a = _asignaciones[i];
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.blanco,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.bordeSuave),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.naranja.withValues(alpha: 0.1),
                              child: const Icon(Icons.link, color: AppColors.naranja),
                            ),
                            title: Text('${a['nombre_obra']} (${a['codigo_obra']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            subtitle: Text('Usuario: ${a['nombre_usuario']} ${a['apellido_usuario']} (@${a['username']})'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                                  child: Text(a['tipo_asignacion'], style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.estadoRojo),
                                  tooltip: 'Quitar de la obra',
                                  onPressed: () => _eliminarAsignacion(a['id_obra_usuario']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}