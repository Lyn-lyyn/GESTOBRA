import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/ui/screens/obras/obra_detail_screen.dart';

class AdminObrasScreen extends StatefulWidget {
  const AdminObrasScreen({super.key});

  @override
  State<AdminObrasScreen> createState() => _AdminObrasScreenState();
}

class _AdminObrasScreenState extends State<AdminObrasScreen> {
  // Datos mock
  final List<Map<String, dynamic>> _obras = [
    {'codigo': 'OBRA-001', 'titulo': 'Edificio Corporativo', 'residente': 'Sin asignar', 'estado': 'Pendiente'},
    {'codigo': 'OBRA-002', 'titulo': 'Vivienda 2 Plantas', 'residente': 'Ing. Laura Sánchez', 'estado': 'En Proceso'},
    {'codigo': 'OBRA-003', 'titulo': 'Pavimentación Municipal', 'residente': 'Ing. Carlos Márquez', 'estado': 'En Proceso'},
    {'codigo': 'OBRA-004', 'titulo': 'Ampliación de Bodega Industrial', 'residente': 'Sin asignar', 'estado': 'Pendiente'},
  ];

  final List<String> _residentesDisponibles = [
    'Ing. Carlos Márquez',
    'Ing. Laura Sánchez',
    'Ing. Patricia Ríos',
    'Ing. Roberto Díaz',
  ];

  void _asignarResidente(int index) {
    String? seleccionado = _obras[index]['residente'] == 'Sin asignar' ? null : _obras[index]['residente'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Asignar Residente'),
          content: StatefulBuilder(
            builder: (context, setModalState) {
              return DropdownButtonFormField<String>(
                value: seleccionado,
                decoration: const InputDecoration(
                  labelText: 'Selecciona un empleado',
                  border: OutlineInputBorder(),
                ),
                items: _residentesDisponibles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (val) => setModalState(() => seleccionado = val),
              );
            }
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textoGris)),
            ),
            ElevatedButton(
              onPressed: () {
                if (seleccionado != null) {
                  setState(() {
                    _obras[index]['residente'] = seleccionado;
                    if (_obras[index]['estado'] == 'Pendiente') _obras[index]['estado'] = 'En Proceso';
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Residente asignado con éxito')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
              child: const Text('Asignar'),
            ),
          ],
        );
      },
    );
  }

  void _abrirModalNuevaObra() {
    final formKey = GlobalKey<FormState>();
    final tituloCtrl = TextEditingController();
    final clienteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar Nueva Obra'),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: tituloCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre de la Obra', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: clienteCtrl,
                    decoration: const InputDecoration(labelText: 'Cliente', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textoGris)),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    _obras.add({
                      'codigo': 'OBRA-00${_obras.length + 1}',
                      'titulo': tituloCtrl.text,
                      'residente': 'Sin asignar',
                      'estado': 'Pendiente',
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Obra registrada correctamente')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      appBar: AppBar(
        title: const Text('Gestión Global de Obras', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.blanco,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.naranja, size: 28),
            tooltip: 'Nueva Obra',
            onPressed: _abrirModalNuevaObra,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          // Aumentamos el límite para aprovechar pantallas grandes
          constraints: const BoxConstraints(maxWidth: 1400),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                padding: const EdgeInsets.all(20),
                // Aquí está la magia: definimos un ancho máximo por tarjeta (380px)
                // Flutter calculará automáticamente cuántas columnas caben
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 380, 
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 210, // Altura fija ideal para el contenido
                ),
                itemCount: _obras.length,
                itemBuilder: (context, index) {
                  final obra = _obras[index];
                  final sinAsignar = obra['residente'] == 'Sin asignar';
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.blanco,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gris, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Cabecera Tarjeta ───
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.grisfondo,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                            border: const Border(bottom: BorderSide(color: AppColors.gris, width: 1.2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(obra['codigo'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.naranja)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: obra['estado'] == 'Pendiente' ? AppColors.estadoAmarillo.withValues(alpha: 0.15) : AppColors.estadoVerde.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: obra['estado'] == 'Pendiente' ? AppColors.estadoAmarillo : AppColors.estadoVerde,
                                    width: 0.5,
                                  )
                                ),
                                child: Text(
                                  obra['estado'], 
                                  style: TextStyle(
                                    fontSize: 10, 
                                    color: obra['estado'] == 'Pendiente' ? Colors.orange[800] : Colors.green[800], 
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // ─── Cuerpo Tarjeta ───
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  obra['titulo'], 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textoNegro), 
                                  maxLines: 2, 
                                  overflow: TextOverflow.ellipsis
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 16, color: AppColors.textoGris),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        sinAsignar ? 'Sin residente asignado' : obra['residente'],
                                        style: TextStyle(
                                          fontSize: 13, 
                                          fontWeight: FontWeight.w600, 
                                          color: sinAsignar ? AppColors.estadoRojo : AppColors.textoNegro
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // ─── Botones de Acción (Estilo unificado) ───
                        const Divider(height: 1, color: AppColors.gris),
                        SizedBox(
                          height: 48,
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _asignarResidente(index),
                                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15)),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person_add, size: 16, color: AppColors.naranja),
                                      SizedBox(width: 6),
                                      Text('Asignar', style: TextStyle(color: AppColors.naranja, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                              Container(width: 1, height: 24, color: AppColors.gris),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => ObraDetailScreen(obra: obra)));
                                  },
                                  borderRadius: const BorderRadius.only(bottomRight: Radius.circular(15)),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.visibility, size: 16, color: AppColors.textoGris),
                                      SizedBox(width: 6),
                                      Text('Detalle', style: TextStyle(color: AppColors.textoGris, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
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