import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/ui/screens/obras/obra_detail_screen.dart';
import 'package:gestobra/servicios/api_service.dart';

class AdminObrasScreen extends StatefulWidget {
  const AdminObrasScreen({super.key});

  @override
  State<AdminObrasScreen> createState() => _AdminObrasScreenState();
}

class _AdminObrasScreenState extends State<AdminObrasScreen> {
  bool _cargando = true;
  List<Map<String, dynamic>> _obras = [];

  @override
  void initState() {
    super.initState();
    _cargarObras();
  }

  Future<void> _cargarObras() async {
    if (!mounted) return;
    setState(() => _cargando = true);
    try {
      final resObras = await ApiService.get('obras.php');
      final resAsignaciones = await ApiService.get('asignaciones.php');

      if (resObras['estado'] == true) {
        Map<String, List<String>> asignacionesPorObra = {};
        
        if (resAsignaciones['estado'] == true) {
          for (var asig in resAsignaciones['data']) {
            String codigoObra = asig['codigo_obra'];
            String nombreUsuario = '${asig['nombre_usuario']} ${asig['apellido_usuario']}';
            String rol = asig['tipo_asignacion'];
            String textoAsignacion = '$nombreUsuario ($rol)';
            
            asignacionesPorObra.putIfAbsent(codigoObra, () => []).add(textoAsignacion);
          }
        }

        setState(() {
          _obras = List<Map<String, dynamic>>.from(resObras['obras']).map((o) {
            String codigo = o['codigo'];
            List<String> asignados = asignacionesPorObra[codigo] ?? [];
            String residenteTexto = asignados.isNotEmpty ? asignados.join(', ') : 'Sin asignar';
            bool sinAsignar = asignados.isEmpty;

            return {
              'id_obra': o['id_obra'],
              'codigo': codigo,
              'titulo': o['nombre'],
              'cliente': o['nombre_cliente'] ?? 'Sin cliente',
              'id_cliente': o['id_cliente'],
              'ubicacion': o['ubicacion'],
              'descripcion': o['descripcion'] ?? '',
              'fechaInicio': o['fecha_inicio'] ?? '--',
              'fechaTermino': o['fecha_fin_estimada'] ?? '--',
              'residente': residenteTexto,
              'sinAsignar': sinAsignar,
              'estado_real': o['estado_nombre'] ?? 'PLANIFICADA',
            };
          }).toList();
          _cargando = false;
        });
      } else {
        setState(() => _cargando = false);
        _showError(resObras['mensaje'] ?? 'Error al cargar');
      }
    } catch (e) {
      setState(() => _cargando = false);
      _showError('Error de red: $e');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.estadoRojo));
  }

  // ────────────────────────────────────────────────────────
  // MODAL: ASIGNAR PERSONAL
  // ────────────────────────────────────────────────────────
  void _asignarResidente(int index) async {
    final resUsers = await ApiService.get('listar_usuarios.php');
    if (resUsers['estado'] != true) return;
    List<Map<String, dynamic>> usuarios = List<Map<String, dynamic>>.from(resUsers['usuarios']);

    int? usuarioSeleccionado;
    String rolSeleccionado = 'SUPERVISOR';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Asignar Personal a Obra'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Selecciona un empleado', border: OutlineInputBorder()),
                    items: usuarios.map((u) => DropdownMenuItem(
                      value: u['id_usuario'] as int,
                      child: Text('${u['nombre']} ${u['apellido_paterno']}'),
                    )).toList(),
                    onChanged: (val) => setModalState(() => usuarioSeleccionado = val),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: rolSeleccionado,
                    decoration: const InputDecoration(labelText: 'Rol', border: OutlineInputBorder()),
                    items: ['SUPERVISOR', 'COORDINADOR', 'CAPTURISTA'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) => setModalState(() => rolSeleccionado = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    if (usuarioSeleccionado == null) return;
                    
                    final res = await ApiService.post('asignaciones.php', {
                      'id_obra': _obras[index]['id_obra'],
                      'id_usuario': usuarioSeleccionado,
                      'tipo_asignacion': rolSeleccionado,
                    });

                    if (res['estado'] == true) {
                      Navigator.pop(context);
                      _cargarObras(); 
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Asignado con éxito')));
                    } else {
                      _showError(res['mensaje'] ?? 'Error al asignar');
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
                  child: const Text('Asignar'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────
  // MODAL: NUEVA OBRA
  // ────────────────────────────────────────────────────────
  void _abrirModalNuevaObra() async {
    final resClientes = await ApiService.get('clientes.php');
    final resFases = await ApiService.get('catalogos.php?tabla=catalogo_fases');

    if (resClientes['estado'] != true || resFases['estado'] != true) {
      _showError('No se pudieron cargar los datos necesarios');
      return;
    }
    
    List<Map<String, dynamic>> clientes = List<Map<String, dynamic>>.from(resClientes['data']);
    List<Map<String, dynamic>> catalogoFases = List<Map<String, dynamic>>.from(resFases['data']);

    final formKey = GlobalKey<FormState>();
    final tituloCtrl = TextEditingController();
    final ubicacionCtrl = TextEditingController();
    final descripcionCtrl = TextEditingController();
    final fechaInicioCtrl = TextEditingController();
    final fechaFinCtrl = TextEditingController();
    
    int? clienteSeleccionado;
    bool guardando = false;
    final Set<String> fasesSeleccionadas = {};

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
              );
              if (fecha != null) {
                setModalState(() {
                  if (esInicio) {
                    fechaInicioCtrl.text = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
                  } else {
                    fechaFinCtrl.text = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
                  }
                });
              }
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
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(labelText: 'Cliente *', border: OutlineInputBorder()),
                          items: clientes.map((c) => DropdownMenuItem(value: c['id_cliente'] as int, child: Text(c['nombre']))).toList(),
                          onChanged: (v) => setModalState(() => clienteSeleccionado = v),
                          validator: (v) => v == null ? 'Selecciona un cliente' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: ubicacionCtrl,
                          decoration: const InputDecoration(labelText: 'Ubicación de la obra *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on_outlined)),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descripcionCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(labelText: 'Descripción de la obra', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
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
                        const Text('Fases que abarcará la obra *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.bordeSuave),
                          ),
                          child: catalogoFases.isEmpty 
                            ? const Text('No hay fases en el catálogo.', style: TextStyle(color: AppColors.estadoRojo, fontSize: 12))
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: catalogoFases.map((fase) {
                                  final nombreFase = fase['nombre'] as String;
                                  final isSelected = fasesSeleccionadas.contains(nombreFase);
                                  return FilterChip(
                                    label: Text(nombreFase, style: const TextStyle(fontSize: 12)),
                                    selected: isSelected,
                                    selectedColor: AppColors.naranja.withValues(alpha: 0.2),
                                    checkmarkColor: AppColors.naranja,
                                    side: BorderSide(color: isSelected ? AppColors.naranja : AppColors.bordeSuave),
                                    onSelected: (selected) {
                                      setModalState(() {
                                        if (selected) {
                                          fasesSeleccionadas.add(nombreFase);
                                        } else {
                                          fasesSeleccionadas.remove(nombreFase);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: guardando ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: AppColors.textoGris)),
                ),
                ElevatedButton(
                  onPressed: guardando ? null : () async {
                    if (!formKey.currentState!.validate()) return;
                    if (fasesSeleccionadas.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona al menos una fase')));
                      return;
                    }
                    setModalState(() => guardando = true);

                    final body = {
                      'codigo': 'OBR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                      'nombre': tituloCtrl.text.trim(),
                      'id_cliente': clienteSeleccionado,
                      'ubicacion': ubicacionCtrl.text.trim(),
                      'descripcion': descripcionCtrl.text.trim(),
                      'fecha_inicio': fechaInicioCtrl.text,
                      'fecha_fin': fechaFinCtrl.text,
                      'fases': fasesSeleccionadas.toList(),
                    };

                    final res = await ApiService.post('obras.php', body);
                    
                    if (!context.mounted) return;

                    if (res['estado'] == true) {
                      Navigator.pop(context);
                      _cargarObras();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Obra registrada correctamente')));
                    } else {
                      setModalState(() => guardando = false);
                      _showError(res['mensaje'] ?? 'Error');
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
                  child: guardando ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────
  // MODAL: EDITAR OBRA
  // ────────────────────────────────────────────────────────
  void _editarObra(int index) async {
    final obra = _obras[index];
    
    final resClientes = await ApiService.get('clientes.php');
    final resCatalogo = await ApiService.get('catalogos.php?tabla=catalogo_fases');
    final resFasesObra = await ApiService.get('fases_obra.php?id_obra=${obra['id_obra']}');

    if (resClientes['estado'] != true || resCatalogo['estado'] != true) {
      _showError('Error al cargar datos necesarios');
      return;
    }

    List<Map<String, dynamic>> clientes = List<Map<String, dynamic>>.from(resClientes['data']);
    List<Map<String, dynamic>> catalogoFases = List<Map<String, dynamic>>.from(resCatalogo['data']);
    
    Set<String> fasesSeleccionadas = {};
    if (resFasesObra['estado'] == true && resFasesObra['data'] != null) {
      for (var f in resFasesObra['data']) {
        fasesSeleccionadas.add(f['nombre']);
      }
    }

    final formKey = GlobalKey<FormState>();
    final tituloCtrl = TextEditingController(text: obra['titulo']);
    final ubicacionCtrl = TextEditingController(text: obra['ubicacion']);
    final descripcionCtrl = TextEditingController(text: obra['descripcion']);
    final fechaInicioCtrl = TextEditingController(text: obra['fechaInicio'] == '--' ? '' : obra['fechaInicio']);
    final fechaFinCtrl = TextEditingController(text: obra['fechaTermino'] == '--' ? '' : obra['fechaTermino']);
    
    int? clienteSeleccionado = obra['id_cliente'];
    bool guardando = false;

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
              );
              if (fecha != null) {
                setModalState(() {
                  if (esInicio) {
                    fechaInicioCtrl.text = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
                  } else {
                    fechaFinCtrl.text = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
                  }
                });
              }
            }

            return AlertDialog(
              title: const Text('Editar Obra'),
              content: SizedBox(
                width: 520,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: tituloCtrl,
                          decoration: const InputDecoration(labelText: 'Nombre de la Obra *', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: clienteSeleccionado,
                          decoration: const InputDecoration(labelText: 'Cliente *', border: OutlineInputBorder()),
                          items: clientes.map((c) => DropdownMenuItem(value: c['id_cliente'] as int, child: Text(c['nombre']))).toList(),
                          onChanged: (v) => setModalState(() => clienteSeleccionado = v),
                          validator: (v) => v == null ? 'Selecciona un cliente' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: ubicacionCtrl,
                          decoration: const InputDecoration(labelText: 'Ubicación *', border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descripcionCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: fechaInicioCtrl,
                                readOnly: true,
                                onTap: () => seleccionarFecha(true),
                                decoration: const InputDecoration(labelText: 'Inicio *', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: fechaFinCtrl,
                                readOnly: true,
                                onTap: () => seleccionarFecha(false),
                                decoration: const InputDecoration(labelText: 'Término *', border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Fases de la Obra *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.bordeSuave),
                          ),
                          child: catalogoFases.isEmpty
                              ? const Text('No hay fases en el catálogo.', style: TextStyle(color: AppColors.estadoRojo, fontSize: 12))
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: catalogoFases.map((fase) {
                                    final nombreFase = fase['nombre'] as String;
                                    final isSelected = fasesSeleccionadas.contains(nombreFase);
                                    return FilterChip(
                                      label: Text(nombreFase, style: const TextStyle(fontSize: 12)),
                                      selected: isSelected,
                                      selectedColor: AppColors.naranja.withValues(alpha: 0.2),
                                      checkmarkColor: AppColors.naranja,
                                      side: BorderSide(color: isSelected ? AppColors.naranja : AppColors.bordeSuave),
                                      onSelected: (selected) {
                                        setModalState(() {
                                          if (selected) {
                                            fasesSeleccionadas.add(nombreFase);
                                          } else {
                                            fasesSeleccionadas.remove(nombreFase);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: guardando ? null : () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: guardando ? null : () async {
                    if (!formKey.currentState!.validate()) return;
                    if (fasesSeleccionadas.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona al menos una fase')));
                      return;
                    }
                    setModalState(() => guardando = true);

                    final res = await ApiService.put('obras.php', {
                      'id_obra': obra['id_obra'],
                      'nombre': tituloCtrl.text.trim(),
                      'id_cliente': clienteSeleccionado,
                      'ubicacion': ubicacionCtrl.text.trim(),
                      'descripcion': descripcionCtrl.text.trim(),
                      'fecha_inicio': fechaInicioCtrl.text,
                      'fecha_fin': fechaFinCtrl.text,
                      'fases': fasesSeleccionadas.toList(),
                    });

                    if (!context.mounted) return;
                    if (res['estado'] == true) {
                      Navigator.pop(context);
                      _cargarObras();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Obra actualizada')));
                    } else {
                      setModalState(() => guardando = false);
                      _showError(res['mensaje'] ?? 'Error');
                    }
                  },
                  child: guardando ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar Cambios'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────
  // MODAL: CAMBIAR ESTADO
  // ────────────────────────────────────────────────────────
  void _cambiarEstado(int index) async {
    final obra = _obras[index];
    String estadoActual = obra['estado_real'];

    final estados = [
      {'id': 1, 'nombre': 'PLANIFICADA'},
      {'id': 2, 'nombre': 'EN_EJECUCION'},
      {'id': 3, 'nombre': 'SUSPENDIDA'},
      {'id': 4, 'nombre': 'FINALIZADA'},
      {'id': 5, 'nombre': 'CANCELADA'},
    ];

    int? nuevoEstadoId;
    for (var e in estados) {
      if (e['nombre'] == estadoActual) nuevoEstadoId = e['id'] as int;
    }
    nuevoEstadoId ??= 1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            bool guardando = false;

            return AlertDialog(
              title: const Text('Cambiar Estado de Obra'),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: estados.map((e) {
                      return RadioListTile<int>(
                        title: Text(e['nombre'] as String),
                        value: e['id'] as int,
                        groupValue: nuevoEstadoId,
                        onChanged: guardando ? null : (val) {
                          setModalState(() => nuevoEstadoId = val);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: guardando ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: guardando ? null : () async {
                    setModalState(() => guardando = true);

                    try {
                      final res = await ApiService.post('obras.php', {
                        'accion': 'cambiar_estado',
                        'id_obra': obra['id_obra'],
                        'id_estado_obra': nuevoEstadoId,
                      });

                      if (res != null && res['estado'] == true) {
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        await _cargarObras();
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Estado actualizado correctamente'),
                              backgroundColor: AppColors.estadoVerde,
                            ),
                          );
                        }
                      } else {
                        if (!context.mounted) return;
                        setModalState(() => guardando = false);
                        _showError(res?['mensaje'] ?? 'El servidor rechazó la solicitud');
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      setModalState(() => guardando = false);
                      _showError('Error crítico: $e');
                      debugPrint('❌ Error en _cambiarEstado: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.naranja,
                    minimumSize: const Size(120, 40),
                  ),
                  child: guardando 
                      ? const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        ) 
                      : const Text('Guardar'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────
  // MODAL: CANCELAR OBRA
  // ────────────────────────────────────────────────────────
  void _cancelarObra(int index) async {
    final obra = _obras[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cancelar Obra?'),
        content: Text('¿Estás seguro de cancelar la obra "${obra['titulo']}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Volver')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.estadoRojo),
            onPressed: () async {
              Navigator.pop(context);
              try {
                final res = await ApiService.post('obras.php', {
                  'accion': 'cambiar_estado',
                  'id_obra': obra['id_obra'],
                  'id_estado_obra': 5,
                });
                if (res != null && res['estado'] == true) {
                  await _cargarObras();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Obra cancelada correctamente')));
                  }
                }
              } catch (e) {
                _showError('Error al cancelar: $e');
              }
            },
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // UI PRINCIPAL
  // ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: AppBar(
        title: const Text('Gestión Global de Obras', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.blanco,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textoGris),
            onPressed: _cargarObras,
          ),
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
          child: _cargando 
            ? const Center(child: CircularProgressIndicator())
            : _obras.isEmpty 
              ? const Center(child: Text('No hay obras registradas aún'))
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 380,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 300,
                  ),
                  itemCount: _obras.length,
                  itemBuilder: (context, index) {
                    final obra = _obras[index];
                    final estado = obra['estado_real'];
                    final sinAsignar = obra['sinAsignar'] == true;

                    Color colorEstado = Colors.orange;
                    if (estado == 'EN_EJECUCION') colorEstado = AppColors.estadoVerde;
                    if (estado == 'FINALIZADA') colorEstado = Colors.blue;
                    if (estado == 'CANCELADA') colorEstado = AppColors.estadoRojo;
                    if (estado == 'SUSPENDIDA') colorEstado = Colors.purple;

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.blanco,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.bordeSuave, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: AppColors.bordeSuave, width: 1.2)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(obra['codigo'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.naranja)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: colorEstado.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: colorEstado, width: 0.5),
                                  ),
                                  child: Text(
                                    estado.replaceAll('_', ' '), 
                                    style: TextStyle(fontSize: 10, color: colorEstado, fontWeight: FontWeight.bold)
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(obra['titulo'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text(obra['cliente'] ?? 'Cliente no definido', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: AppColors.textoGris), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 10),
                                  _buildIconRow(Icons.location_on_outlined, obra['ubicacion']),
                                  const SizedBox(height: 6),
                                  _buildIconRow(Icons.description_outlined, obra['descripcion'], maxLines: 2),
                                  const SizedBox(height: 6),
                                  _buildIconRow(Icons.calendar_today_outlined, '${obra['fechaInicio']} al ${obra['fechaTermino']}'),
                                  const Spacer(),
                                  
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline, size: 14, color: sinAsignar ? AppColors.estadoRojo : Colors.green[700]),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          obra['residente'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11, 
                                            fontWeight: sinAsignar ? FontWeight.normal : FontWeight.bold,
                                            color: sinAsignar ? AppColors.estadoRojo : Colors.green[800]
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.gris),
                          SizedBox(
                            height: 48,
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _asignarResidente(index),
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
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ObraDetailScreen(obra: obra))),
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
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, color: AppColors.textoGris, size: 18),
                                  onSelected: (value) {
                                    if (value == 'editar') _editarObra(index);
                                    if (value == 'estado') _cambiarEstado(index);
                                    if (value == 'cancelar') _cancelarObra(index);
                                  },
                                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'editar',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 18, color: Colors.blue),
                                          SizedBox(width: 8),
                                          Text('Editar Datos'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'estado',
                                      child: Row(
                                        children: [
                                          Icon(Icons.sync_alt, size: 18, color: AppColors.naranja),
                                          SizedBox(width: 8),
                                          Text('Cambiar Estado'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'cancelar',
                                      child: Row(
                                        children: [
                                          Icon(Icons.cancel, size: 18, color: AppColors.estadoRojo),
                                          SizedBox(width: 8),
                                          Text('Cancelar Obra'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

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