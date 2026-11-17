import 'package:flutter/material.dart';
import 'package:gestobra/ui/screens/admin/widgets/admin_modal_field_theme.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';

class AdminClientesScreen extends StatefulWidget {
  const AdminClientesScreen({super.key});

  @override
  State<AdminClientesScreen> createState() => _AdminClientesScreenState();
}

class _AdminClientesScreenState extends State<AdminClientesScreen> {
  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _clientes = [];

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final res = await ApiService.get('clientes.php');
      if (res['estado'] == true) {
        setState(() {
          _clientes = List<Map<String, dynamic>>.from(res['data']);
          _cargando = false;
        });
      } else {
        setState(() { _error = res['mensaje'] ?? 'Error al cargar'; _cargando = false; });
      }
    } catch (e) {
      setState(() { _error = 'Error de red: $e'; _cargando = false; });
    }
  }

  Future<void> _abrirModalCliente({Map<String, dynamic>? cliente}) async {
    final esEdicion = cliente != null;
    
    final nombreCtrl = TextEditingController(text: cliente?['nombre']);
    final telCtrl = TextEditingController(text: cliente?['telefono']);
    final correoCtrl = TextEditingController(text: cliente?['correo']);
    final dirCtrl = TextEditingController(text: cliente?['direccion']);
    final obsCtrl = TextEditingController(text: cliente?['observaciones']);

    bool guardando = false;
    final formKey = GlobalKey<FormState>();

    await showAdminDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          backgroundColor: AppColors.grisfondo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.88,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.naranja,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            esEdicion ? 'Editar cliente' : 'Nuevo cliente',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Cerrar',
                          onPressed: guardando
                              ? null
                              : () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: nombreCtrl,
                      decoration: _decoracionCampoCliente(
                        'Nombre o Empresa *',
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: telCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: _decoracionCampoCliente('Teléfono'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: correoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _decoracionCampoCliente(
                        'Correo electrónico',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: dirCtrl,
                      decoration: _decoracionCampoCliente('Dirección'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: obsCtrl,
                      maxLines: 2,
                      decoration: _decoracionCampoCliente('Observaciones'),
                    ),
                    const SizedBox(height: 24),
                    OverflowBar(
                      alignment: MainAxisAlignment.end,
                      spacing: 10,
                      overflowSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: guardando
                              ? null
                              : () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textoGris,
                            side: const BorderSide(
                              color: AppColors.bordeSuave,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.naranja,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: guardando
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setModal(() => guardando = true);

                                  final body = {
                                    if (esEdicion)
                                      'id_cliente': cliente['id_cliente'],
                                    'nombre': nombreCtrl.text.trim(),
                                    'telefono': telCtrl.text.trim(),
                                    'correo': correoCtrl.text.trim(),
                                    'direccion': dirCtrl.text.trim(),
                                    'observaciones': obsCtrl.text.trim(),
                                  };

                                  final res = await ApiService.post(
                                    'clientes.php',
                                    body,
                                  );
                                  if (!mounted) return;

                                  if (res['estado'] == true) {
                                    Navigator.pop(ctx);
                                    _cargarClientes();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(res['mensaje'])),
                                    );
                                  } else {
                                    setModal(() => guardando = false);
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(
                                        content: Text(res['mensaje'] ?? 'Error'),
                                        backgroundColor: AppColors.estadoRojo,
                                      ),
                                    );
                                  }
                                },
                          child: guardando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  esEdicion
                                      ? 'Guardar cambios'
                                      : 'Crear cliente',
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoracionCampoCliente(String etiqueta) {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.naranja),
    );
    return InputDecoration(
      labelText: etiqueta,
      labelStyle: const TextStyle(color: AppColors.textoGris, fontSize: 13),
      floatingLabelStyle: const TextStyle(color: AppColors.naranja),
      filled: true,
      fillColor: AppColors.blanco,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: borde,
      enabledBorder: borde,
      focusedBorder: borde.copyWith(
        borderSide: const BorderSide(color: AppColors.naranja, width: 1.5),
      ),
      errorBorder: borde.copyWith(
        borderSide: const BorderSide(color: AppColors.estadoRojo),
      ),
      focusedErrorBorder: borde.copyWith(
        borderSide: const BorderSide(color: AppColors.estadoRojo, width: 1.5),
      ),
    );
  }

  Future<void> _eliminarCliente(Map<String, dynamic> cliente) async {
    final confirmar = await showAdminDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Cliente'),
        content: Text('¿Estás seguro de eliminar a ${cliente['nombre']}? No se borrará de la BD, solo se ocultará del directorio.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.estadoRojo),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final res = await ApiService.delete('clientes.php?id=${cliente['id_cliente']}');
    if (res['estado'] == true) {
      _cargarClientes();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cliente eliminado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: AppBar(
        title: const Text('Directorio de Clientes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.blanco,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textoGris),
            onPressed: _cargarClientes,
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: AppColors.naranja, size: 26),
            tooltip: 'Nuevo Cliente',
            onPressed: () => _abrirModalCliente(),
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
                  : _clientes.isEmpty
                      ? const Center(child: Text('No hay clientes registrados', style: TextStyle(color: AppColors.textoGris)))
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: _clientes.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final c = _clientes[i];
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.blanco,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.bordeSuave),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.naranja.withValues(alpha: 0.15),
                                  child: const Icon(Icons.business, color: AppColors.naranja),
                                ),
                                title: Text(c['nombre'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    if (c['telefono'] != null && c['telefono'].toString().isNotEmpty)
                                      Text('📞 ${c['telefono']}'),
                                    if (c['correo'] != null && c['correo'].toString().isNotEmpty)
                                      Text('✉️ ${c['correo']}'),
                                    if (c['direccion'] != null && c['direccion'].toString().isNotEmpty)
                                      Text('📍 ${c['direccion']}'),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, color: AppColors.naranja),
                                  onSelected: (value) {
                                    if (value == 'editar') _abrirModalCliente(cliente: c);
                                    if (value == 'eliminar') _eliminarCliente(c);
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(
                                      value: 'editar',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20, color: AppColors.naranja),
                                          SizedBox(width: 8),
                                          Text('Editar'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'eliminar',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, size: 20, color: AppColors.naranja),
                                          SizedBox(width: 8),
                                          Text('Eliminar', style: TextStyle(color: AppColors.estadoRojo)),
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
