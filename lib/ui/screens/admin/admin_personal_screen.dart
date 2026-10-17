import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';

class AdminPersonalScreen extends StatefulWidget {
  const AdminPersonalScreen({super.key});

  @override
  State<AdminPersonalScreen> createState() => _AdminPersonalScreenState();
}

class _AdminPersonalScreenState extends State<AdminPersonalScreen> {
  final List<Map<String, dynamic>> personal = [
    {'nombre': 'Ing. Carlos Márquez', 'puesto': 'Residente', 'obras': 2, 'estado': 'Activo', 'email': 'carlos@gestobra.com'},
    {'nombre': 'Ing. Laura Sánchez', 'puesto': 'Residente', 'obras': 1, 'estado': 'Activo', 'email': 'laura@gestobra.com'},
    {'nombre': 'Ing. Patricia Ríos', 'puesto': 'Residente', 'obras': 0, 'estado': 'Disponible', 'email': 'patricia@gestobra.com'},
    {'nombre': 'Arq. Sofía Méndez', 'puesto': 'Supervisora', 'obras': 1, 'estado': 'Activo', 'email': 'sofia@gestobra.com'},
    {'nombre': 'Juan Pérez', 'puesto': 'Maestro de Obra', 'obras': 1, 'estado': 'Inactivo', 'email': 'juan@gestobra.com'},
    {'nombre': 'Ing. Roberto Díaz', 'puesto': 'Residente', 'obras': 0, 'estado': 'Disponible', 'email': 'roberto@gestobra.com'},
  ];

  void _vincularAObra(int index) {
    // Simulación de vincular
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Vincular a ${personal[index]['nombre']}'),
          content: const Text('Selecciona la obra a la que deseas asignar a este empleado.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textoGris)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  personal[index]['obras'] = personal[index]['obras'] + 1;
                  personal[index]['estado'] = 'Activo';
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Empleado vinculado con éxito')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
              child: const Text('Vincular'),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      appBar: AppBar(
        title: const Text('Directorio de Personal', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.blanco,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          // Aumentamos el límite para igualar a las demás pantallas
          constraints: const BoxConstraints(maxWidth: 1400),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                padding: const EdgeInsets.all(20),
                // Usamos el mismo comportamiento dinámico que en Obras
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400, // Ancho máximo de cada tarjeta
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 150, // Altura ajustada para el contenido
                ),
                itemCount: personal.length,
                itemBuilder: (context, index) {
                  final p = personal[index];
                  final isDisponible = p['estado'] == 'Disponible';
                  final isInactivo = p['estado'] == 'Inactivo';
                  
                  // Colores dinámicos según estado
                  Color colorEstado = isDisponible ? Colors.green[700]! : (isInactivo ? AppColors.estadoRojo : AppColors.naranja);
                  Color bgEstado = isDisponible ? Colors.green.withValues(alpha: 0.15) : (isInactivo ? AppColors.estadoRojo.withValues(alpha: 0.15) : AppColors.naranja.withValues(alpha: 0.15));

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.grisfondo,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gris, width: 1.2),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {}, // Opcional: abrir perfil del empleado
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // ─── Avatar ───
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: colorEstado, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.blanco,
                                  child: Text(
                                    p['nombre'].substring(4, 6), // Toma las iniciales del nombre (ej. "Ca" de Carlos)
                                    style: TextStyle(color: colorEstado, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // ─── Información ───
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      p['nombre'], 
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textoNegro),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      p['puesto'], 
                                      style: const TextStyle(fontSize: 12, color: AppColors.textoGris),
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Fila de estado y obras
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: bgEstado,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            p['estado'],
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorEstado),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.assignment_outlined, size: 12, color: AppColors.textoGris),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${p['obras']} obras',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textoGris),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // ─── Botón de Acción ───
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () => _vincularAObra(index),
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.blanco,
                                      side: const BorderSide(color: AppColors.gris, width: 1),
                                      padding: const EdgeInsets.all(10),
                                    ),
                                    icon: const Icon(Icons.link, color: AppColors.naranja, size: 20),
                                    tooltip: 'Vincular a Obra',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}