import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';

class AdminPersonalScreen extends StatefulWidget {
  const AdminPersonalScreen({super.key});

  @override
  State<AdminPersonalScreen> createState() => _AdminPersonalScreenState();
}

class _AdminPersonalScreenState extends State<AdminPersonalScreen> {
  bool _cargando = true;
  List<Map<String, dynamic>> _personal = [];

  @override
  void initState() {
    super.initState();
    _cargarPersonal();
  }

  Future<void> _cargarPersonal() async {
    setState(() => _cargando = true);
    
    final resUsers = await ApiService.get('listar_usuarios.php');
    final resAsig = await ApiService.get('asignaciones.php');

    if (resUsers['estado'] == true) {
      List<Map<String, dynamic>> usuarios = List<Map<String, dynamic>>.from(resUsers['usuarios']);
      List<Map<String, dynamic>> asignaciones = [];
      
      if (resAsig['estado'] == true) {
        asignaciones = List<Map<String, dynamic>>.from(resAsig['data']);
      }

      // Filtramos para mostrar solo personal operativo (no al admin ni desarrollador)
      usuarios = usuarios.where((u) => 
        u['rol'] != 'ADMINISTRADOR' && 
        u['rol'] != 'DESARROLLADOR' && 
        u['activo'] == 1
      ).toList();

      setState(() {
        _personal = usuarios.map((u) {
          int idUser = u['id_usuario'];
          // Contamos en cuántas obras está asignado
          int obrasCount = asignaciones.where((a) => a['id_usuario'] == idUser).length;
          
          return {
            'id_usuario': idUser,
            'nombre': '${u['nombre']} ${u['apellido_paterno']}',
            'puesto': u['rol'].toString().replaceAll('_', ' '),
            'obras': obrasCount,
            'estado': obrasCount > 0 ? 'Activo' : 'Disponible',
            'email': u['correo'],
          };
        }).toList();
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: AppBar(
        title: const Text('Directorio de Personal', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.blanco,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: AppColors.textoGris), onPressed: _cargarPersonal),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: _cargando 
            ? const Center(child: CircularProgressIndicator())
            : _personal.isEmpty 
              ? const Center(child: Text('No hay personal registrado'))
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 150,
                  ),
                  itemCount: _personal.length,
                  itemBuilder: (context, index) {
                    final p = _personal[index];
                    final isDisponible = p['estado'] == 'Disponible';
                    
                    Color colorEstado = isDisponible ? Colors.blue[700]! : AppColors.naranja;
                    Color bgEstado = isDisponible ? Colors.blue.withValues(alpha: 0.15) : AppColors.naranja.withValues(alpha: 0.15);

                    return Container(
                      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.bordeSuave, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colorEstado, width: 2)),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.blanco,
                                child: Text(p['nombre'].toString().substring(0, 1).toUpperCase(), style: TextStyle(color: colorEstado, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(p['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textoNegro), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text(p['puesto'], style: const TextStyle(fontSize: 11, color: AppColors.textoGris)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: bgEstado, borderRadius: BorderRadius.circular(6)),
                                        child: Text(p['estado'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorEstado)),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.assignment_outlined, size: 12, color: AppColors.textoGris),
                                      const SizedBox(width: 4),
                                      Text('${p['obras']} obras', style: const TextStyle(fontSize: 11, color: AppColors.textoGris)),
                                    ],
                                  ),
                                ],
                              ),
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