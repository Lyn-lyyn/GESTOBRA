import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';

class NuevaActividadModal extends StatefulWidget {
  final List<Map<String, dynamic>> fasesDisponibles;
  final Function(Map<String, dynamic>) onCrear;

  const NuevaActividadModal({
    super.key,
    required this.fasesDisponibles,
    required this.onCrear,
  });

  @override
  State<NuevaActividadModal> createState() => _NuevaActividadModalState();
}

class _NuevaActividadModalState extends State<NuevaActividadModal> {
  // Controladores para los campos
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  // Fechas seleccionadas
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  // Valores de los dropdowns
  String? _faseSeleccionada;
  String? _responsableSeleccionado;

  // Lista de responsables simulada
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

  // Función para mostrar el DatePicker
  Future<void> _seleccionarFecha(bool esInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.naranja,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
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

  // Formatear fecha para mostrar
  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'dd/mm/aaaa';
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  // Función al presionar CREAR ACTIVIDAD
  void _handleCrear() {
    // Validaciones básicas
    if (_faseSeleccionada == null ||
        _nombreController.text.isEmpty ||
        _descripcionController.text.isEmpty ||
        _responsableSeleccionado == null ||
        _fechaInicio == null ||
        _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Crear el objeto de la nueva actividad
    final nuevaActividad = {
      'fase': _faseSeleccionada!.toUpperCase(),
      'estado': 'Pendiente',
      'titulo': _nombreController.text,
      'descripcion': _descripcionController.text,
      'responsable': _responsableSeleccionado,
      'programado': 'Programado ${_formatearFecha(_fechaInicio)} al ${_formatearFecha(_fechaFin)}',
      'reporte': 'Sin reportes aún',
      'avance': 0.0,
      'ponderacion': '5%',
      'isCompleted': false,
    };

    // Llamamos al callback para que la pantalla principal se entere
    widget.onCrear(nuevaActividad);
    
    // Cerramos el modal
    Navigator.pop(context);
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
              // ---- ENCABEZADO ----
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.naranja,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_note, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Agregar nueva actividad a la obra',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ---- FASE DE OBRA ----
              _buildLabel('Fase de obra'),
              _buildDropdown(
                value: _faseSeleccionada,
                hint: 'Selecciona una fase',
                items: widget.fasesDisponibles.map((f) => f['nombre'] as String).toList(),
                onChanged: (value) => setState(() => _faseSeleccionada = value),
              ),
              const SizedBox(height: 16),

              // ---- NOMBRE DE LA ACTIVIDAD ----
              _buildLabel('Nombre de la actividad'),
              _buildTextField(
                controller: _nombreController,
                hint: 'Ej. Excavación para zapatas',
              ),
              const SizedBox(height: 16),

              // ---- DESCRIPCIÓN TÉCNICA ----
              _buildLabel('Descripción técnica'),
              _buildTextField(
                controller: _descripcionController,
                hint: 'Describe los detalles técnicos...',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // ---- RESPONSABLE ----
              _buildLabel('Responsable / Cuadrilla'),
              _buildDropdown(
                value: _responsableSeleccionado,
                hint: 'Selecciona un responsable',
                items: _responsables,
                onChanged: (value) => setState(() => _responsableSeleccionado = value),
              ),
              const SizedBox(height: 16),

              // ---- FECHAS ----
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Fecha programada inicio'),
                        _buildDateField(
                          fecha: _fechaInicio,
                          onTap: () => _seleccionarFecha(true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Fecha programada fin'),
                        _buildDateField(
                          fecha: _fechaFin,
                          onTap: () => _seleccionarFecha(false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ---- BOTONES ----
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botón CANCELAR
                  SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gris,
                        side: const BorderSide(color: AppColors.gris),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'CANCELAR',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botón CREAR ACTIVIDAD
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _handleCrear,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.naranja,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'CREAR ACTIVIDAD',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
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

  // --- WIDGETS AUXILIARES ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
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

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.naranja),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.naranja),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
          onChanged: onChanged,
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
                _formatearFecha(fecha),
                style: TextStyle(
                  fontSize: 13,
                  color: fecha == null ? Colors.grey.shade400 : Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.calendar_today, size: 16, color: AppColors.naranja),
          ],
        ),
      ),
    );
  }
}