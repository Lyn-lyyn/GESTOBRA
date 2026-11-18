import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';

class AdminAuditoriaScreen extends StatefulWidget {
  const AdminAuditoriaScreen({super.key});

  @override
  State<AdminAuditoriaScreen> createState() => _AdminAuditoriaScreenState();
}

class _AdminAuditoriaScreenState extends State<AdminAuditoriaScreen> {
  // Controladores y Estado
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _busquedaCtrl = TextEditingController();
  
  List<Map<String, dynamic>> _logs = [];
  bool _cargando = true;
  bool _cargandoMas = false;
  bool _hayMas = true;
  int _offset = 0;
  final int _limit = 20; // Registros por página

  // Filtros
  String _filtroAccion = '';
  String _filtroBusqueda = ''; // Buscará en descripción o tabla

  @override
  void initState() {
    super.initState();
    _cargarLogs(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _busquedaCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_cargandoMas && _hayMas) {
        _cargarLogs(reset: false);
      }
    }
  }

  Future<void> _cargarLogs({required bool reset}) async {
    if (!mounted) return;

    if (reset) {
      setState(() {
        _cargando = true;
        _offset = 0;
        _hayMas = true;
        _logs.clear();
      });
    } else {
      setState(() => _cargandoMas = true);
    }

    // Construir URL con parámetros
    String endpoint = 'auditoria.php?limit=$_limit&offset=$_offset';
    if (_filtroAccion.isNotEmpty) endpoint += '&accion=$_filtroAccion';
    if (_filtroBusqueda.isNotEmpty) endpoint += '&tabla=$_filtroBusqueda'; // Filtramos por tabla

    try {
      final res = await ApiService.get(endpoint);

      if (!mounted) return;

      if (res['estado'] == true) {
        final nuevosLogs = List<Map<String, dynamic>>.from(res['data']);
        final total = res['total'] ?? 0;

        setState(() {
          _logs.addAll(nuevosLogs);
          _offset += nuevosLogs.length;
          _hayMas = _offset < total;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar: $e'), backgroundColor: AppColors.estadoRojo));
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
          _cargandoMas = false;
        });
      }
    }
  }

  void _buscar() {
    _filtroBusqueda = _busquedaCtrl.text.trim();
    _cargarLogs(reset: true);
  }

  void _cambiarFiltroAccion(String? valor) {
    _filtroAccion = valor ?? '';
    _cargarLogs(reset: true);
  }

  Color _colorAccion(String accion) {
    switch (accion) {
      case 'INSERT': return Colors.green;
      case 'UPDATE': return Colors.blue;
      case 'DELETE': return AppColors.estadoRojo;
      case 'LOGIN': return Colors.purple;
      default: return AppColors.textoGris;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: AppBar(
        title: const Text('Auditoría del Sistema', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.blanco,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: AppColors.textoGris), onPressed: () => _cargarLogs(reset: true)),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // ─── Barra de Filtros ───
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.blanco,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _busquedaCtrl,
                            decoration: InputDecoration(
                              hintText: 'Buscar en la tabla (ej: obras, usuarios)...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              isDense: true,
                              filled: true,
                              fillColor: AppColors.grisfondo,
                            ),
                            onSubmitted: (_) => _buscar(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.search, color: AppColors.naranja),
                          onPressed: _buscar,
                          tooltip: 'Buscar',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Acción: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _filtroAccion.isEmpty ? null : _filtroAccion,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              isDense: true,
                              filled: true,
                              fillColor: AppColors.grisfondo,
                            ),
                            hint: const Text('Todas las acciones'),
                            items: const [
                              DropdownMenuItem(value: '', child: Text('Todas las acciones')),
                              DropdownMenuItem(value: 'LOGIN', child: Text('LOGIN')),
                              DropdownMenuItem(value: 'INSERT', child: Text('INSERT')),
                              DropdownMenuItem(value: 'UPDATE', child: Text('UPDATE')),
                              DropdownMenuItem(value: 'DELETE', child: Text('DELETE')),
                              DropdownMenuItem(value: 'LOGOUT', child: Text('LOGOUT')),
                            ],
                            onChanged: _cambiarFiltroAccion,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // ─── Lista de Logs ───
              Expanded(
                child: _cargando
                    ? const Center(child: CircularProgressIndicator())
                    : _logs.isEmpty
                        ? const Center(child: Text('No se encontraron registros'))
                        : ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _logs.length + (_hayMas ? 1 : 0),
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              // Indicador de carga al final
                              if (i == _logs.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }

                              final log = _logs[i];
                              final nombre = log['nombre_usuario'] != null 
                                  ? '${log['nombre_usuario']} ${log['apellido_usuario']}' 
                                  : 'Sistema';
                              final color = _colorAccion(log['accion']);

                              return Container(
                                decoration: BoxDecoration(
                                  color: AppColors.blanco,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.bordeSuave),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: color.withValues(alpha: 0.15),
                                    child: Icon(Icons.history, color: color),
                                  ),
                                  title: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                        child: Text(log['accion'], style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Tabla: ${log['tabla_afectada']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textoGris)),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(log['descripcion'] ?? '', style: const TextStyle(color: AppColors.textoNegro)),
                                      Text('Usuario: $nombre', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blue)),
                                      Text('Fecha: ${log['fecha']}', style: const TextStyle(fontSize: 10, color: AppColors.textoGris)),
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