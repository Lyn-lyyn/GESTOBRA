import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';

class AdminIncidenciasScreen extends StatefulWidget {
  const AdminIncidenciasScreen({super.key});
  @override
  State<AdminIncidenciasScreen> createState() => _AdminIncidenciasScreenState();
}

class _AdminIncidenciasScreenState extends State<AdminIncidenciasScreen> {
  bool _cargando = true;
  List<Map<String, dynamic>> _incidencias = [];
  String _filtroEstado = 'ABIERTA';

  @override
  void initState() {
    super.initState();
    _cargarIncidencias();
  }

  Future<void> _cargarIncidencias() async {
    setState(() => _cargando = true);
    final res = await ApiService.get('incidencias.php');
    if (res['estado'] == true) {
      setState(() {
        _incidencias = List<Map<String, dynamic>>.from(res['data']);
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
    }
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'ABIERTA': return AppColors.estadoRojo;
      case 'EN_REVISION': return Colors.orange;
      case 'EN_ATENCION': return Colors.blue;
      case 'RESUELTA': return Colors.green;
      case 'CERRADA': return AppColors.textoGris;
      default: return AppColors.textoGris;
    }
  }

  Future<void> _cambiarEstado(Map<String, dynamic> incidencia, String nuevoEstado) async {
    final res = await ApiService.post('incidencias.php', {
      'id_incidencia': incidencia['id_incidencia'],
      'estado': nuevoEstado,
      'solucion': 'Actualizado por administrador',
    });
    if (res['estado'] == true) _cargarIncidencias();
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar por estado seleccionado
    final filtered = _filtroEstado == 'TODAS'
        ? _incidencias
        : _incidencias.where((i) => i['estado'] == _filtroEstado).toList();

    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: AppBar(
        title: const Text('Incidencias', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.blanco,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh, color: AppColors.textoGris), onPressed: _cargarIncidencias)],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Filtros de estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.blanco,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['TODAS', 'ABIERTA', 'EN_REVISION', 'EN_ATENCION', 'RESUELTA', 'CERRADA'].map((estado) {
                      final isSelected = _filtroEstado == estado;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(estado),
                          selected: isSelected,
                          selectedColor: AppColors.naranja.withValues(alpha: 0.2),
                          labelStyle: TextStyle(color: isSelected ? AppColors.naranja : AppColors.textoGris, fontWeight: FontWeight.bold),
                          onSelected: (_) => setState(() => _filtroEstado = estado),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              // Lista
              Expanded(
                child: _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? const Center(child: Text('No hay incidencias en este estado'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final inc = filtered[i];
                              final color = _colorEstado(inc['estado']);
                              final prioridadColor = inc['prioridad_nombre'] == 'CRITICA' ? Colors.red : Colors.orange;
                              
                              return Card(
                                color: AppColors.blanco,
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.bordeSuave)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('${inc['codigo_obra']} - ${inc['nombre_obra']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textoGris)),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                            child: Text(inc['estado'], style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(inc['titulo'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text(inc['descripcion'], style: const TextStyle(color: AppColors.textoGris, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const Divider(height: 24),
                                      Row(
                                        children: [
                                          Icon(Icons.report_problem, size: 16, color: prioridadColor),
                                          const SizedBox(width: 4),
                                          Text('Prioridad: ${inc['prioridad_nombre'] ?? 'N/A'}', style: TextStyle(fontSize: 11, color: prioridadColor, fontWeight: FontWeight.bold)),
                                          const Spacer(),
                                          Icon(Icons.person, size: 16, color: AppColors.textoGris),
                                          const SizedBox(width: 4),
                                          Text('${inc['reportador_nombre']} ${inc['reportador_apellido']}', style: const TextStyle(fontSize: 11, color: AppColors.textoGris)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 14, color: AppColors.textoGris),
                                          const SizedBox(width: 4),
                                          Text(inc['fecha_reporte'], style: const TextStyle(fontSize: 11, color: AppColors.textoGris)),
                                          const Spacer(),
                                          // Menú para cambiar estado
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_horiz, size: 20),
                                            onSelected: (val) => _cambiarEstado(inc, val),
                                            itemBuilder: (ctx) => ['ABIERTA', 'EN_REVISION', 'EN_ATENCION', 'RESUELTA', 'CERRADA'].map((e) => PopupMenuItem(value: e, child: Text('Marcar como $e'))).toList(),
                                          )
                                        ],
                                      )
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