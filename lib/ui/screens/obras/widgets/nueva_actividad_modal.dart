import 'package:flutter/material.dart';
import 'package:gestobra/servicios/api_service.dart';
import '../../../../config/theme/app_colors.dart';

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
  
  // Datos del formulario
  int? _faseSeleccionadaId;
  String? _responsableSeleccionado;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
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

  // ─── Utilidades de fecha ───
  /// Formato visual para el usuario: DD/MM/YYYY
  String _formatearFechaVisual(DateTime? fecha) {
    if (fecha == null) return 'dd/mm/aaaa';
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  /// Formato para MySQL: YYYY-MM-DD
  String _formatearFechaSQL(DateTime? fecha) {
    if (fecha == null) return '';
    return '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
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
        if (esInicio) {
          _fechaInicio = picked;
        } else {
          _fechaFin = picked;
        }
      });
    }
  }

  // ─── Crear Actividad ───
  Future<void> _handleCrear() async {
    // Validaciones
    if (_faseSeleccionadaId == null ||
        _nombreController.text.trim().isEmpty ||
        _descripcionController.text.trim().isEmpty ||
        _fechaInicio == null ||
        _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos obligatorios'), backgroundColor: AppColors.estadoRojo),
      );
      return;
    }

    if (_fechaFin!.isBefore(_fechaInicio!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha de fin debe ser posterior al inicio'), backgroundColor: AppColors.estadoRojo),
      );
      return;
    }

    setState(() => _guardando = true);

    // 👇 Enviamos las fechas en formato SQL (YYYY-MM-DD) 👇
    final body = {
      'id_obra': widget.idObra,
      'id_fase': _faseSeleccionadaId,
      'nombre': _nombreController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      'fecha_inicio_programada': _formatearFechaSQL(_fechaInicio),
      'fecha_fin_programada': _formatearFechaSQL(_fechaFin),
    };

    try {
      final res = await ApiService.post('actividades.php', body);

      if (!mounted) return;
      setState(() => _guardando = false);

      if (res['estado'] == true) {
        final faseObj = widget.fasesDisponibles.firstWhere((f) => f['id_fase'] == _faseSeleccionadaId);
        
        final nuevaActividad = {
          'fase': faseObj['nombre'],
          'estado': 'PENDIENTE',
          'titulo': _nombreController.text.trim(),
          'descripcion': _descripcionController.text.trim(),
          'responsable': _responsableSeleccionado ?? 'Sin asignar',
          'programado': 'Programado ${_formatearFechaVisual(_fechaInicio)} al ${_formatearFechaVisual(_fechaFin)}',
          'fechaInicio': _fechaInicio,
          'fechaFin': _fechaFin,
          'reporte': 'Sin reportes aún',
          'avance': 0.0,
          'ponderacion': '—',
          'isCompleted': false,
        };
        
        widget.onCrear(nuevaActividad);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['mensaje'] ?? 'Error al crear la actividad'), backgroundColor: AppColors.estadoRojo),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e'), backgroundColor: AppColors.estadoRojo),
      );
    }
  }

  // ─── UI ───
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
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.naranja, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.edit_note, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Agregar nueva actividad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _guardando ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Fase
              _buildLabel('Fase de obra *'),
              _buildDropdownFase(),
              const SizedBox(height: 16),

              // Nombre
              _buildLabel('Nombre de la actividad *'),
              _buildTextField(controller: _nombreController, hint: 'Ej. Excavación para zapatas'),
              const SizedBox(height: 16),

              // Descripción
              _buildLabel('Descripción técnica *'),
              _buildTextField(controller: _descripcionController, hint: 'Describe los detalles...', maxLines: 3),
              const SizedBox(height: 16),

              // Responsable
              _buildLabel('Responsable (Opcional)'),
              _buildDropdownResponsable(),
              const SizedBox(height: 16),

              // Fechas
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Fecha inicio *'),
                        _buildDateField(fecha: _fechaInicio, onTap: () => _seleccionarFecha(true)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Fecha fin *'),
                        _buildDateField(fecha: _fechaFin, onTap: () => _seleccionarFecha(false)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: _guardando ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gris,
                        side: const BorderSide(color: AppColors.bordeSuave),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('CANCELAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _guardando ? null : _handleCrear,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.naranja,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _guardando
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('CREAR ACTIVIDAD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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

  // ─── Widgets Auxiliares ───
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6.0),
    child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
  );

  Widget _buildTextField({required TextEditingController controller, required String hint, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.naranja),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildDropdownFase() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.naranja),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _faseSeleccionadaId,
          isExpanded: true,
          hint: Text('Selecciona una fase', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.naranja),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          items: widget.fasesDisponibles
              .map((f) => DropdownMenuItem<int>(value: f['id_fase'] as int, child: Text(f['nombre'])))
              .toList(),
          onChanged: (value) => setState(() => _faseSeleccionadaId = value),
        ),
      ),
    );
  }

  Widget _buildDropdownResponsable() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.naranja),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _responsableSeleccionado,
          isExpanded: true,
          hint: Text('Selecciona un responsable', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.naranja),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          items: _responsables.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (value) => setState(() => _responsableSeleccionado = value),
        ),
      ),
    );
  }

  Widget _buildDateField({required DateTime? fecha, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.naranja),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _formatearFechaVisual(fecha),
                style: TextStyle(fontSize: 13, color: fecha == null ? Colors.grey.shade400 : Colors.black87),
              ),
            ),
            const Icon(Icons.calendar_today, size: 16, color: AppColors.naranja),
          ],
        ),
      ),
    );
  }
}