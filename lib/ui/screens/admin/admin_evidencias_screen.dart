import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';

class AdminEvidenciasScreen extends StatefulWidget {
  const AdminEvidenciasScreen({super.key});
  @override
  State<AdminEvidenciasScreen> createState() => _AdminEvidenciasScreenState();
}

class _AdminEvidenciasScreenState extends State<AdminEvidenciasScreen> {
  bool _cargando = true;
  List<Map<String, dynamic>> _evidencias = [];

  @override
  void initState() {
    super.initState();
    _cargarEvidencias();
  }

  Future<void> _cargarEvidencias() async {
    setState(() => _cargando = true);
    final res = await ApiService.get('evidencias_admin.php');
    if (res['estado'] == true) {
      setState(() {
        _evidencias = List<Map<String, dynamic>>.from(res['data']);
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
    }
  }

  void _verFotoGrande(Map<String, dynamic> ev) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(
                ev['archivo_url'] ?? '',
                errorBuilder: (_, __, ___) => const Center(child: Text('No se pudo cargar la imagen', style: TextStyle(color: Colors.white))),
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 8, right: 8,
              child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
            ),
            Positioned(
              bottom: 8, left: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black54,
                child: Text('${ev['descripcion'] ?? 'Sin descripción'}\nObra: ${ev['nombre_obra']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: AppBar(
        title: const Text('Evidencias Fotográficas', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.blanco,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh, color: AppColors.textoGris), onPressed: _cargarEvidencias)],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _evidencias.isEmpty
                  ? const Center(child: Text('No hay evidencias subidas'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.9,
                      ),
                      itemCount: _evidencias.length,
                      itemBuilder: (context, i) {
                        final ev = _evidencias[i];
                        return GestureDetector(
                          onTap: () => _verFotoGrande(ev),
                          child: Container(
                            decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.bordeSuave)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                                    child: Image.network(
                                      ev['archivo_url'] ?? '',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 40, color: AppColors.textoGris)),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(ev['nombre_obra'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      Text(ev['fecha_captura'] ?? '', style: const TextStyle(fontSize: 10, color: AppColors.textoGris)),
                                    ],
                                  ),
                                )
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