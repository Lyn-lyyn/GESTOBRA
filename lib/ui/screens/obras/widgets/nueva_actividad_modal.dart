import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';

class NuevaActividadModal extends StatefulWidget {
  final int idObra;
  final List<Map<String, dynamic>> fasesDisponibles;
  final Function(Map<String, dynamic>) onCrear;

  const NuevaActividadModal({
    super.key,
    required this.idObra,
    required this.fasesDisponibles,
    required this.onCrear,
  });

  @override
  State<NuevaActividadModal> createState() => _NuevaActividadModalState();
}

class _NuevaActividadModalState extends State<NuevaActividadModal> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  int? _faseSeleccionadaId; // Guardamos el ID de la fase
  String? _responsableSeleccionado;
  bool _guardando = false;

  final List<String> _responsables = [
    'Cuadrilla 1 - Don Pedro',
    'Cuadrilla 2 - Operador Retro',
    'Topógrafo Miguel Narvaez',
    'Ing. Carlos Morales',
    'Maestro de obra Juan Ramírez',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(bool esInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.naranja, onPrimary: Colors.white, onSurface: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (esInicio) { _fechaInicio = picked; } else { _fechaFin = picked; }
      });
    }
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return '';
    return '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}'; // YYYY-MM-DD para MySQL
  }

  void _handleCrear() async {
    if (_faseSeleccionadaId == null || _nombreController.text.isEmpty || _fechaInicio == null || _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa fase, nombre y fechas'), backgroundColor: Colors.red));
      return;
    }

    if (_fechaFin!.isBefore(_fechaInicio!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La fecha de fin debe ser posterior al inicio'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _guardando = true);

    final body = {
      'id_obra': widget.idObra,
      'id_fase': _faseSeleccionadaId,
      'nombre': _nombreController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      'fecha_inicio_programada': _formatearFecha(_fechaInicio),
      'fecha_fin_programada': _formatearFecha(_fechaFin),
    };

    final res = await ApiService.post('actividades.php', body);

    if (!mounted) return;
    setState(() => _guardando = false);

    if (res['estado'] == true) {
      final nuevaActividad = {
        'fase': widget.fasesDisponibles.firstWhere((f) => f['id_fase'] == _faseSeleccionadaId)['nombre'],
        'estado': 'Pendiente',
        'titulo': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'responsable': _responsableSeleccionado ?? 'Sin asignar',
        'programado': 'Programado ${_formatearFecha(_fechaInicio)} al ${_formatearFecha(_fechaFin)}',
        'fechaInicio': _fechaInicio,
        'fechaFin': _fechaFin,
        'reporte': 'Sin reportes aún',
        'avance': 0.0,
        'ponderacion': '5%',
        'isCompleted': false,
      };
      widget.onCrear(nuevaActividad);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['mensaje'] ?? 'Error'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.grisfondo,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.naranja, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.edit_note, color: Colors.white, size: 24)),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Agregar nueva actividad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 24),

              _buildLabel('Fase de obra'),
              _buildDropdown(
                value: _faseSeleccionadaId,
                hint: 'Selecciona una fase',
                items: widget.fasesDisponibles.map((f) => DropdownMenuItem<int>(value: f['id_fase'] as int, child: Text(f['nombre']))).toList(),
                onChanged: (value) => setState(() => _faseSeleccionadaId = value),
              ),
              const SizedBox(height: 16),

              _buildLabel('Nombre de la actividad'),
              _buildTextField(controller: _nombreController, hint: 'Ej. Excavación para zapatas'),
              const SizedBox(height: 16),

              _buildLabel('Descripción técnica'),
              _buildTextField(controller: _descripcionController, hint: 'Describe los detalles...', maxLines: 3),
              const SizedBox(height: 16),

              _buildLabel('Responsable (Opcional)'),
              _buildDropdownString(
                value: _responsableSeleccionado,
                hint: 'Selecciona un responsable',
                items: _responsables,
                onChanged: (value) => setState(() => _responsableSeleccionado = value),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Fecha inicio'), _buildDateField(fecha: _fechaInicio, onTap: () => _seleccionarFecha(true))])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Fecha fin'), _buildDateField(fecha: _fechaFin, onTap: () => _seleccionarFecha(false))])),
                ],
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: _guardando ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.gris, side: const BorderSide(color: AppColors.bordeSuave), padding: const EdgeInsets.symmetric(horizontal: 24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('CANCELAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _guardando ? null : _handleCrear,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: _guardando ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('CREAR ACTIVIDAD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 6.0), child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)));

  Widget _buildTextField({required TextEditingController controller, required String hint, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.naranja)),
      child: TextField(
        controller: controller, maxLines: maxLines, style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), isDense: true),
      ),
    );
  }

  Widget _buildDropdown({required int? value, required String hint, required List<DropdownMenuItem<int>> items, required Function(int?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.naranja)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(value: value, isExpanded: true, hint: Text(hint, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)), icon: const Icon(Icons.arrow_drop_down, color: AppColors.naranja), style: const TextStyle(fontSize: 13, color: Colors.black87), items: items, onChanged: onChanged),
      ),
    );
  }

  Widget _buildDropdownString({required String? value, required String hint, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.naranja)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(value: value, isExpanded: true, hint: Text(hint, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)), icon: const Icon(Icons.arrow_drop_down, color: AppColors.naranja), style: const TextStyle(fontSize: 13, color: Colors.black87), items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: onChanged),
      ),
    );
  }

  Widget _buildDateField({required DateTime? fecha, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46, padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.naranja)),
        child: Row(
          children: [
            Expanded(child: Text(fecha == null ? 'dd/mm/aaaa' : _formatearFecha(fecha), style: TextStyle(fontSize: 13, color: fecha == null ? Colors.grey.shade400 : Colors.black87))),
            const Icon(Icons.calendar_today, size: 16, color: AppColors.naranja),
          ],
        ),
      ),
    );
  }
}