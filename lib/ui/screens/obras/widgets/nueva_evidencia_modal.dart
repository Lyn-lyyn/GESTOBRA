import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';

class NuevaEvidenciaModal extends StatefulWidget {
  final List<Map<String, dynamic>> fasesDisponibles;

  const NuevaEvidenciaModal({
    super.key,
    required this.fasesDisponibles,
  });

  @override
  State<NuevaEvidenciaModal> createState() => _NuevaEvidenciaModalState();
}

class _NuevaEvidenciaModalState extends State<NuevaEvidenciaModal> {
  final _fechaController = TextEditingController();
  final _etiquetaController = TextEditingController();
  final _descripcionController = TextEditingController();
  DateTime? _fechaSeleccionada;
  String? _faseSeleccionada;
  String? _actividadSeleccionada;

  static const Map<String, List<String>> _actividadesPorFase = {
    'Preliminares': ['Limpieza y desmonte del terreno'],
    'Cimentación': [
      'Colado de zapatas y contratrabes',
      'Armado de acero en zapatas y dados',
      'Excavación para zapatas y contratrabes',
    ],
  };

  List<String> get _actividadesDisponibles {
    if (_faseSeleccionada == null) return const [];
    final actividades = _actividadesPorFase[_faseSeleccionada];
    if (actividades != null) return actividades;
    return [_faseSeleccionada!];
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _etiquetaController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'Selecciona la fecha de captura',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.naranja,
            onPrimary: Colors.white,
            onSurface: AppColors.textoNegro,
          ),
        ),
        child: child!,
      ),
    );
    if (fecha == null) return;
    setState(() {
      _fechaSeleccionada = fecha;
      _fechaController.text = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
    });
  }

  void _guardar() {
    if (_fechaSeleccionada == null ||
        _faseSeleccionada == null ||
        _actividadSeleccionada == null ||
        _etiquetaController.text.trim().isEmpty ||
        _descripcionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos para guardar la evidencia')),
      );
      return;
    }

    Navigator.of(context, rootNavigator: true).pop({
      'fase': _faseSeleccionada,
      'actividad': _actividadSeleccionada,
      'descripcion': _descripcionController.text.trim(),
      'fecha': _fechaController.text,
      'etiqueta': _etiquetaController.text.trim(),
      'imagenPath': 'assets/images/evidencia_colado_zapatas.png',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.grisfondo,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 760),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(color: AppColors.naranja, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.photo_camera_outlined, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Subir Evidencia Fotográfica', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 28)),
                ],
              ),
              const SizedBox(height: 16),
              _formBox(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 420;
                    final date = _dateField();
                    final phase = _dropdownField(
                      label: 'Fase de obra',
                      hint: 'Selecciona fase',
                      value: _faseSeleccionada,
                      items: widget.fasesDisponibles
                          .map((fase) => fase['nombre'] as String)
                          .toList(),
                      onChanged: (value) => setState(() {
                        _faseSeleccionada = value;
                        _actividadSeleccionada = null;
                      }),
                    );
                    final activity = _dropdownField(
                      label: 'Actividad Relacionada',
                      hint: _faseSeleccionada == null
                          ? 'Selecciona primero la fase'
                          : 'Selecciona actividad',
                      value: _actividadSeleccionada,
                      items: _actividadesDisponibles,
                      onChanged: (value) => setState(() => _actividadSeleccionada = value),
                    );
                    final label = _textField(label: 'Etiqueta', controller: _etiquetaController, hint: 'Ej. Colado');
                    if (compact) {
                      return Column(children: [
                        date,
                        const SizedBox(height: 12),
                        phase,
                        const SizedBox(height: 12),
                        activity,
                        const SizedBox(height: 12),
                        label,
                      ]);
                    }
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: date),
                            const SizedBox(width: 12),
                            Expanded(child: phase),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: activity),
                            const SizedBox(width: 12),
                            Expanded(child: label),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              _formBox(
                child: _textField(
                  label: 'Descripción Técnica de la Evidencia',
                  controller: _descripcionController,
                  hint: 'Describe los trabajos que se muestran en la fotografía',
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 12),
              _formBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Seleccionar Fotografía'),
                    const SizedBox(height: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 106,
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.naranja),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset('assets/images/evidencia_colado_zapatas.png', fit: BoxFit.cover),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                color: Colors.black54,
                                child: const Text(
                                  'Imagen ilustrativa de referencia',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('La evidencia se guardará con esta imagen ilustrativa de referencia.', style: TextStyle(fontSize: 10, color: AppColors.textoGris)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.naranja,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('GUARDAR EVIDENCIA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Fecha de captura'),
        const SizedBox(height: 6),
        InkWell(
          onTap: _seleccionarFecha,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.naranja), borderRadius: BorderRadius.circular(6)),
            child: Row(
              children: [
                Expanded(child: Text(_fechaController.text.isEmpty ? 'Selecciona fecha' : _fechaController.text, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11))),
                const Icon(Icons.calendar_month_outlined, size: 15, color: AppColors.textoNegro),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField({required String label, required String hint, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.naranja), borderRadius: BorderRadius.circular(6)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : null,
              isExpanded: true,
              hint: Text(hint, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
              icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.naranja),
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)))).toList(),
              onChanged: items.isEmpty ? null : onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _textField({required String label, required TextEditingController controller, required String hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11, color: Colors.black38),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.naranja)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.naranja)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.naranja, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _formBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.gris), borderRadius: BorderRadius.circular(10)),
      child: child,
    );
  }

  Widget _label(String value) => Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textoNegro));
}
