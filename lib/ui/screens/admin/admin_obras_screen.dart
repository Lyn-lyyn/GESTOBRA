import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/ui/screens/obras/obra_detail_screen.dart';

class AdminObrasScreen extends StatefulWidget {
  const AdminObrasScreen({super.key});

  @override
  State<AdminObrasScreen> createState() => _AdminObrasScreenState();
}

class _AdminObrasScreenState extends State<AdminObrasScreen> {
  // Datos mock con los nuevos campos
  final List<Map<String, dynamic>> _obras = [
    {
      'codigo': 'OBRA-001', 
      'titulo': 'Edificio Corporativo', 
      'cliente': 'Inmobiliaria del Golfo',
      'ubicacion': 'Boca del Río, Veracruz',
      'descripcion': 'Edificio de oficinas de 4 niveles con estacionamiento subterráneo.',
      'fechaInicio': '01/10/2026',
      'fechaTermino': '30/04/2027',
      'residente': 'Sin asignar', 
      'estado': 'Pendiente'
    },
    {
      'codigo': 'OBRA-002', 
      'titulo': 'Vivienda 2 Plantas', 
      'cliente': 'Sr. Juan Pérez',
      'ubicacion': 'Cuitláhuac, Veracruz',
      'descripcion': 'Construcción de vivienda residencial unifamiliar de 2 plantas.',
      'fechaInicio': '15/09/2026',
      'fechaTermino': '15/01/2027',
      'residente': 'Ing. Laura Sánchez', 
      'estado': 'En Proceso'
    },
    {
      'codigo': 'OBRA-003', 
      'titulo': 'Pavimentación Municipal', 
      'cliente': 'Gobierno municipal',
      'ubicacion': 'Cuitláhuac, Veracruz',
      'descripcion': 'Pavimentación con concreto hidráulico en calle principal.',
      'fechaInicio': '01/08/2026',
      'fechaTermino': '30/11/2026',
      'residente': 'Ing. Carlos Márquez', 
      'estado': 'En Proceso'
    },
    {
      'codigo': 'OBRA-004', 
      'titulo': 'Ampliación de Bodega Industrial', 
      'cliente': 'Logística del Sureste',
      'ubicacion': 'Manzanillo, Colima',
      'descripcion': 'Ampliación de nave industrial de 500 m2 con estructura metálica.',
      'fechaInicio': '10/11/2026',
      'fechaTermino': '10/03/2027',
      'residente': 'Sin asignar', 
      'estado': 'Pendiente'
    },
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
    
    // Controladores
    final tituloCtrl = TextEditingController();
    final clienteCtrl = TextEditingController();
    final ubicacionCtrl = TextEditingController();
    final descripcionCtrl = TextEditingController();
    final fechaInicioCtrl = TextEditingController();
    final fechaFinCtrl = TextEditingController();
    final otraFaseCtrl = TextEditingController();

    DateTime? fechaInicio;
    DateTime? fechaFin;

    // Fases
    final List<String> fasesBase = [
      'Preliminares',
      'Cimentación',
      'Estructura',
      'Albañilería',
      'Instalaciones',
      'Acabados y pruebas',
    ];
    final Set<String> fasesSeleccionadas = {};
    final List<String> fasesPersonalizadas = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            
            Future<void> seleccionarFecha(bool esInicio) async {
              final fecha = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                helpText: esInicio ? 'Fecha de inicio' : 'Fecha de término',
                cancelText: 'Cancelar',
                confirmText: 'Aceptar',
              );
              if (fecha != null) {
                setModalState(() {
                  if (esInicio) {
                    fechaInicio = fecha;
                    fechaInicioCtrl.text = '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
                  } else {
                    fechaFin = fecha;
                    fechaFinCtrl.text = '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
                  }
                });
              }
            }

            void agregarOtraFase() {
              final texto = otraFaseCtrl.text.trim();
              if (texto.isEmpty) return;
              if (fasesBase.contains(texto) || fasesPersonalizadas.contains(texto)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Esa fase ya está en la lista')));
                return;
              }
              setModalState(() {
                fasesPersonalizadas.add(texto);
                fasesSeleccionadas.add(texto);
                otraFaseCtrl.clear();
              });
            }

            Widget buildChip(String fase) {
              final sel = fasesSeleccionadas.contains(fase);
              return FilterChip(
                label: Text(fase, style: const TextStyle(fontSize: 11)),
                selected: sel,
                selectedColor: AppColors.naranja.withValues(alpha: 0.2),
                checkmarkColor: AppColors.naranja,
                side: BorderSide(color: sel ? AppColors.naranja : AppColors.gris),
                onSelected: (v) {
                  setModalState(() {
                    if (v) {
                      fasesSeleccionadas.add(fase);
                    } else {
                      fasesSeleccionadas.remove(fase);
                    }
                  });
                },
              );
            }

            return AlertDialog(
              title: const Text('Registrar Nueva Obra'),
              content: SizedBox(
                width: 520,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: tituloCtrl,
                          decoration: const InputDecoration(labelText: 'Nombre de la Obra *', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: clienteCtrl,
                          decoration: const InputDecoration(labelText: 'Cliente *', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 12),
                        
                        // Ubicación
                        TextFormField(
                          controller: ubicacionCtrl,
                          decoration: const InputDecoration(labelText: 'Ubicación de la obra *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on_outlined)),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 12),

                        // Descripción
                        TextFormField(
                          controller: descripcionCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Descripción de la obra', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description_outlined)),
                        ),
                        const SizedBox(height: 12),

                        // Fechas
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: fechaInicioCtrl,
                                readOnly: true,
                                onTap: () => seleccionarFecha(true),
                                decoration: const InputDecoration(labelText: 'Fecha de inicio *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today_outlined)),
                                validator: (v) => v!.isEmpty ? 'Requerido' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: fechaFinCtrl,
                                readOnly: true,
                                onTap: () => seleccionarFecha(false),
                                decoration: const InputDecoration(labelText: 'Fecha de término *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.event_available_outlined)),
                                validator: (v) => v!.isEmpty ? 'Requerido' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Fases
                        const Text('Fases que abarcará el trabajo *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.blanco,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.gris),
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ...fasesBase.map(buildChip),
                              ...fasesPersonalizadas.map(buildChip),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Agregar otra fase
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: otraFaseCtrl,
                                decoration: const InputDecoration(labelText: 'Otra fase (opcional)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.add_circle_outline)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: agregarOtraFase,
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
                                child: const Text('Añadir'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                      if (fechaFin != null && fechaInicio != null && fechaFin!.isBefore(fechaInicio!)) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La fecha de término no puede ser anterior a la de inicio')));
                        return;
                      }
                      if (fasesSeleccionadas.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona al menos una fase')));
                        return;
                      }

                      setState(() {
                        _obras.add({
                          'codigo': 'OBRA-00${_obras.length + 1}',
                          'titulo': tituloCtrl.text,
                          'cliente': clienteCtrl.text,
                          'ubicacion': ubicacionCtrl.text,
                          'descripcion': descripcionCtrl.text,
                          'fechaInicio': fechaInicioCtrl.text,
                          'fechaTermino': fechaFinCtrl.text,
                          'fases': fasesSeleccionadas.toList(),
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
          constraints: const BoxConstraints(maxWidth: 1400),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 380, 
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 290, // <-- Altura aumentada para albergar los nuevos datos
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
                        
                        // ─── Cuerpo Tarjeta (NUEVOS DATOS) ───
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título
                                Text(
                                  obra['titulo'], 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textoNegro), 
                                  maxLines: 1, 
                                  overflow: TextOverflow.ellipsis
                                ),
                                const SizedBox(height: 4),
                                
                                // Cliente
                                Text(
                                  obra['cliente'] ?? 'Cliente no definido', 
                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: AppColors.textoGris), 
                                  maxLines: 1, 
                                  overflow: TextOverflow.ellipsis
                                ),
                                const SizedBox(height: 10),

                                // Ubicación
                                _buildIconRow(Icons.location_on_outlined, obra['ubicacion'] ?? 'Sin ubicación'),
                                const SizedBox(height: 6),
                                
                                // Descripción
                                _buildIconRow(Icons.description_outlined, obra['descripcion'] ?? 'Sin descripción', maxLines: 2),
                                const SizedBox(height: 6),
                                
                                // Fechas
                                _buildIconRow(Icons.calendar_today_outlined, 
                                  (obra['fechaInicio'] != null && obra['fechaTermino'] != null) 
                                    ? '${obra['fechaInicio']} al ${obra['fechaTermino']}'
                                    : 'Fechas sin definir'
                                ),
                                
                                const Spacer(),
                                
                                // Residente
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 16, color: AppColors.textoGris),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        sinAsignar ? 'Sin residente asignado' : obra['residente'],
                                        style: TextStyle(
                                          fontSize: 12, 
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
                                      Text('Ver Detalle', style: TextStyle(color: AppColors.textoGris, fontWeight: FontWeight.bold, fontSize: 12)),
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

  // ─── Helper para crear las filas con ícono ───
  Widget _buildIconRow(IconData icon, String text, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textoGris),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.textoGris, height: 1.3),
          ),
        ),
      ],
    );
  }
}