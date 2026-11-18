import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';

class AdminBitacorasScreen extends StatefulWidget {
  const AdminBitacorasScreen({super.key});
  @override
  State<AdminBitacorasScreen> createState() => _AdminBitacorasScreenState();
}

class _AdminBitacorasScreenState extends State<AdminBitacorasScreen> {
  bool _cargando = true;
  List<Map<String, dynamic>> _bitacoras = [];

  @override
  void initState() {
    super.initState();
    _cargarBitacoras();
  }

  Future<void> _cargarBitacoras() async {
    setState(() => _cargando = true);
    final res = await ApiService.get('bitacoras_admin.php');
    if (res['estado'] == true) {
      setState(() {
        _bitacoras = List<Map<String, dynamic>>.from(res['data']);
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
    }
  }

  Future<void> _verDetalleBitacora(Map<String, dynamic> bitacora) async {
    // Cargar personal de la bitácora
    final res = await ApiService.get('bitacoras_admin.php?id_bitacora=${bitacora['id_bitacora']}');
    List<Map<String, dynamic>> personal = [];
    if (res['estado'] == true && res['personal'] != null) {
      personal = List<Map<String, dynamic>>.from(res['personal']);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Bitácora del ${bitacora['fecha']}'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Obra: ${bitacora['nombre_obra']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Clima: ${bitacora['clima'] ?? 'No especificado'}'),
                const Divider(),
                const Text('Descripción de la jornada:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(bitacora['descripcion_jornada'] ?? 'Sin descripción'),
                const SizedBox(height: 12),
                const Text('Personal Presente:', style: TextStyle(fontWeight: FontWeight.bold)),
                if (personal.isEmpty) 
                  const Text('No se registró personal', style: TextStyle(color: AppColors.textoGris))
                else
                  ...personal.map((p) => Text('• ${p['nombre']} (${p['oficio']}) - ${p['estado_asistencia']}')),
              ],
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: AppBar(
        title: const Text('Bitácoras de Obra', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.blanco,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh, color: AppColors.textoGris), onPressed: _cargarBitacoras)],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _bitacoras.isEmpty
                  ? const Center(child: Text('No hay bitácoras registradas'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _bitacoras.length,
                      itemBuilder: (context, i) {
                        final b = _bitacoras[i];
                        return Card(
                          color: AppColors.blanco,
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.bordeSuave)),
                          child: ListTile(
                            onTap: () => _verDetalleBitacora(b),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.menu_book, color: Colors.blue),
                            ),
                            title: Text('${b['codigo_obra']} - ${b['nombre_obra']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text('Fecha: ${b['fecha']} | Por: ${b['creador_nombre']}', style: const TextStyle(fontSize: 12)),
                            trailing: const Icon(Icons.chevron_right, color: AppColors.textoGris),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}