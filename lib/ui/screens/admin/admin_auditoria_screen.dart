import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';

class AdminAuditoriaScreen extends StatefulWidget {
  const AdminAuditoriaScreen({super.key});

  @override
  State<AdminAuditoriaScreen> createState() => _AdminAuditoriaScreenState();
}

class _AdminAuditoriaScreenState extends State<AdminAuditoriaScreen> {
  bool _cargando = true;
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _cargarLogs();
  }

  Future<void> _cargarLogs() async {
    setState(() => _cargando = true);
    final res = await ApiService.get('auditoria.php');
    if (res['estado'] == true) {
      setState(() {
        _logs = List<Map<String, dynamic>>.from(res['data']);
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
    }
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
          IconButton(icon: const Icon(Icons.refresh, color: AppColors.textoGris), onPressed: _cargarLogs),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _logs.isEmpty
                  ? const Center(child: Text('No hay registros de auditoría'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _logs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final log = _logs[i];
                        final nombre = log['nombre_usuario'] != null 
                            ? '${log['nombre_usuario']} ${log['apellido_usuario']}' 
                            : 'Sistema / Desconocido';
                        
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.blanco,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.bordeSuave),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _colorAccion(log['accion']).withValues(alpha: 0.15),
                              child: Icon(Icons.history, color: _colorAccion(log['accion'])),
                            ),
                            title: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: _colorAccion(log['accion']).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                  child: Text(log['accion'], style: TextStyle(color: _colorAccion(log['accion']), fontSize: 10, fontWeight: FontWeight.bold)),
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
      ),
    );
  }
}