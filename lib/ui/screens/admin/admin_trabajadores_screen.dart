import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';

class AdminTrabajadoresScreen extends StatefulWidget {
  const AdminTrabajadoresScreen({super.key});

  @override
  State<AdminTrabajadoresScreen> createState() => _AdminTrabajadoresScreenState();
}

class _AdminTrabajadoresScreenState extends State<AdminTrabajadoresScreen> {
  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _trabajadores = [];

  @override
  void initState() {
    super.initState();
    _cargarTrabajadores();
  }

  Future<void> _cargarTrabajadores() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final res = await ApiService.get('trabajadores.php');
      if (res['estado'] == true) {
        setState(() {
          _trabajadores = List<Map<String, dynamic>>.from(res['data']);
          _cargando = false;
        });
      } else {
        setState(() { _error = res['mensaje'] ?? 'Error al cargar'; _cargando = false; });
      }
    } catch (e) {
      setState(() { _error = 'Error de red: $e'; _cargando = false; });
    }
  }

  Future<void> _abrirModalTrabajador({Map<String, dynamic>? trabajador}) async {
    final esEdicion = trabajador != null;
    
    final nombreCtrl = TextEditingController(text: trabajador?['nombre']);
    final apPaternoCtrl = TextEditingController(text: trabajador?['apellido_paterno']);
    final apMaternoCtrl = TextEditingController(text: trabajador?['apellido_materno']);
    final oficioCtrl = TextEditingController(text: trabajador?['oficio']);
    final telCtrl = TextEditingController(text: trabajador?['telefono']);
    final correoCtrl = TextEditingController(text: trabajador?['correo']);
    final obsCtrl = TextEditingController(text: trabajador?['observaciones']);
    
    DateTime? fechaIngreso;
    final fechaCtrl = TextEditingController(text: trabajador?['fecha_ingreso']);

    if (trabajador?['fecha_ingreso'] != null && trabajador!['fecha_ingreso'].toString().isNotEmpty) {
      fechaIngreso = DateTime.tryParse(trabajador['fecha_ingreso'].toString());
    }

    bool guardando = false;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          title: Text(esEdicion ? 'Editar Trabajador' : 'Nuevo Trabajador'),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: nombreCtrl,
                            decoration: const InputDecoration(labelText: 'Nombre(s) *', border: OutlineInputBorder()),
                            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: apPaternoCtrl,
                            decoration: const InputDecoration(labelText: 'Apellido Paterno *', border: OutlineInputBorder()),
                            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: apMaternoCtrl,
                            decoration: const InputDecoration(labelText: 'Apellido Materno', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: oficioCtrl,
                            decoration: const InputDecoration(labelText: 'Oficio / Puesto *', border: OutlineInputBorder(), hintText: 'Ej. Albañil, Fierrero'),
                            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: telCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: fechaCtrl,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Fecha de Ingreso',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today, color: AppColors.naranja),
                            ),
                            onTap: () async {
                              final fecha = await showDatePicker(
                                context: ctx,
                                initialDate: fechaIngreso ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                locale: const Locale('es', 'MX'),
                              );
                              if (fecha != null) {
                                setModal(() {
                                  fechaIngreso = fecha;
                                  fechaCtrl.text = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: correoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Correo Electrónico', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: obsCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Observaciones', border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: guardando ? null : () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textoGris)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja),
              onPressed: guardando ? null : () async {
                if (!formKey.currentState!.validate()) return;
                setModal(() => guardando = true);

                final body = {
                  if (esEdicion) 'id_trabajador': trabajador['id_trabajador'],
                  'nombre': nombreCtrl.text.trim(),
                  'apellido_paterno': apPaternoCtrl.text.trim(),
                  'apellido_materno': apMaternoCtrl.text.trim(),
                  'oficio': oficioCtrl.text.trim(),
                  'telefono': telCtrl.text.trim(),
                  'correo': correoCtrl.text.trim(),
                  'fecha_ingreso': fechaCtrl.text.trim(),
                  'observaciones': obsCtrl.text.trim(),
                };

                final res = await ApiService.post('trabajadores.php', body);
                if (!mounted) return;

                if (res['estado'] == true) {
                  Navigator.pop(ctx);
                  _cargarTrabajadores();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['mensaje'])));
                } else {
                  setModal(() => guardando = false);
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(res['mensaje'] ?? 'Error'), backgroundColor: AppColors.estadoRojo));
                }
              },
              child: guardando
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(esEdicion ? 'Guardar Cambios' : 'Registrar Trabajador'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _eliminarTrabajador(Map<String, dynamic> trabajador) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dar de baja a Trabajador'),
        content: Text('¿Estás seguro de dar de baja a ${trabajador['nombre']} ${trabajador['apellido_paterno']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.estadoRojo),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Dar de baja'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final res = await ApiService.delete('trabajadores.php?id=${trabajador['id_trabajador']}');
    if (res['estado'] == true) {
      _cargarTrabajadores();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trabajador dado de baja')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: AppBar(
        title: const Text('Directorio de Trabajadores', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.blanco,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textoGris),
            onPressed: _cargarTrabajadores,
          ),
          IconButton(
            icon: const Icon(Icons.person_add, color: AppColors.naranja, size: 26),
            tooltip: 'Nuevo Trabajador',
            onPressed: () => _abrirModalTrabajador(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.estadoRojo)))
                  : _trabajadores.isEmpty
                      ? const Center(child: Text('No hay trabajadores registrados', style: TextStyle(color: AppColors.textoGris)))
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: _trabajadores.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final t = _trabajadores[i];
                            final nombreCompleto = '${t['nombre']} ${t['apellido_paterno']} ${t['apellido_materno'] ?? ''}'.trim();
                            final inicial = t['nombre'].toString().isNotEmpty ? t['nombre'][0].toUpperCase() : '?';
                            
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.blanco,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.bordeSuave),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.estadoVerde.withValues(alpha: 0.15),
                                  child: Text(inicial, style: const TextStyle(color: AppColors.estadoVerde, fontWeight: FontWeight.bold)),
                                ),
                                title: Text(nombreCompleto, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('👷 ${t['oficio']}', style: const TextStyle(color: AppColors.naranja, fontWeight: FontWeight.w600)),
                                    if (t['telefono'] != null && t['telefono'].toString().isNotEmpty)
                                      Text('📞 ${t['telefono']}'),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, color: AppColors.textoGris),
                                  onSelected: (value) {
                                    if (value == 'editar') _abrirModalTrabajador(trabajador: t);
                                    if (value == 'eliminar') _eliminarTrabajador(t);
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(
                                      value: 'editar',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20, color: Colors.blue),
                                          SizedBox(width: 8),
                                          Text('Editar'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'eliminar',
                                      child: Row(
                                        children: [
                                          Icon(Icons.person_off, size: 20, color: AppColors.estadoRojo),
                                          SizedBox(width: 8),
                                          Text('Dar de baja', style: TextStyle(color: AppColors.estadoRojo)),
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