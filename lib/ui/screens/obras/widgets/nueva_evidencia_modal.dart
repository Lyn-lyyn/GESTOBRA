import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:image_picker/image_picker.dart';
import 'package:gestobra/servicios/api_service.dart';
import '../../../../config/theme/app_colors.dart';

class NuevaEvidenciaModal extends StatefulWidget {
  final int obraId;
  final List<Map<String, dynamic>> actividadesDisponibles;

  const NuevaEvidenciaModal({
    super.key,
    required this.obraId,
    required this.actividadesDisponibles,
  });

  @override
  State<NuevaEvidenciaModal> createState() => _NuevaEvidenciaModalState();
}

class _NuevaEvidenciaModalState extends State<NuevaEvidenciaModal> {
  final ImagePicker _imagePicker = ImagePicker();
  final _fechaController = TextEditingController();
  final _etiquetaController = TextEditingController();
  final _descripcionController = TextEditingController();
  DateTime? _fechaSeleccionada;
  String? _faseSeleccionada;
  Map<String, dynamic>? _actividadSeleccionada;
  Uint8List? _imagenBytes;
  String? _nombreImagen;
  bool _guardando = false;

  List<String> get _fasesDisponibles =>
      widget.actividadesDisponibles
          .map((actividad) => actividad['fase']?.toString() ?? '')
          .where((fase) => fase.isNotEmpty)
          .toSet()
          .toList();

  List<Map<String, dynamic>> get _actividadesDeFase =>
      widget.actividadesDisponibles
          .where((actividad) => actividad['fase'] == _faseSeleccionada)
          .toList();

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
      builder:
          (context, child) => Theme(
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
      _fechaController.text =
          '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _seleccionarImagen({ImageSource? source}) async {
    final selectedSource =
        source ??
        await showModalBottomSheet<ImageSource>(
          context: context,
          builder:
              (sheetContext) => SafeArea(
                child: Wrap(
                  children: [
                    if (_imagePicker.supportsImageSource(ImageSource.camera))
                      ListTile(
                        leading: const Icon(Icons.photo_camera_outlined),
                        title: const Text('Tomar foto'),
                        onTap:
                            () =>
                                Navigator.pop(sheetContext, ImageSource.camera),
                      ),
                    ListTile(
                      leading: const Icon(Icons.photo_library_outlined),
                      title: const Text('Elegir del dispositivo'),
                      onTap:
                          () =>
                              Navigator.pop(sheetContext, ImageSource.gallery),
                    ),
                  ],
                ),
              ),
        );
    if (selectedSource == null || !mounted) return;

    try {
      if (selectedSource == ImageSource.camera) {
        final foto = await _imagePicker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear,
          imageQuality: 85,
        );
        if (foto == null || !mounted) return;
        await _usarImagen(await foto.readAsBytes(), foto.name);
        return;
      }

      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        withData: true,
        allowMultiple: false,
      );
      if (resultado == null || resultado.files.isEmpty || !mounted) return;
      final archivo = resultado.files.single;
      if (archivo.bytes == null || archivo.bytes!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo leer la imagen seleccionada'),
          ),
        );
        return;
      }
      await _usarImagen(archivo.bytes!, archivo.name);
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.code == 'camera_access_denied'
                ? 'Permite el acceso a la cámara en los ajustes del teléfono.'
                : 'No se pudo abrir la cámara o seleccionar la imagen.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo seleccionar la imagen: $error')),
      );
    }
  }

  Future<void> _usarImagen(Uint8List bytes, String fileName) async {
    if (bytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo leer la imagen seleccionada')),
      );
      return;
    }
    if (bytes.length > 8 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La imagen debe pesar menos de 8 MB')),
      );
      return;
    }
    setState(() {
      _imagenBytes = bytes;
      _nombreImagen = fileName.trim().isEmpty ? 'foto_evidencia.jpg' : fileName;
    });
  }

  Future<void> _guardar() async {
    if (_fechaSeleccionada == null ||
        _faseSeleccionada == null ||
        _actividadSeleccionada == null ||
        _etiquetaController.text.trim().isEmpty ||
        _descripcionController.text.trim().isEmpty ||
        _imagenBytes == null ||
        _nombreImagen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa los campos y selecciona una fotografía'),
        ),
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      final respuesta = await ApiService.uploadFile(
        'evidencias.php',
        fields: {
          'id_obra': widget.obraId.toString(),
          'id_actividad': _actividadSeleccionada!['id_actividad'].toString(),
          'descripcion': _descripcionController.text.trim(),
          'etiqueta': _etiquetaController.text.trim(),
          'fecha_captura': _fechaController.text,
        },
        bytes: _imagenBytes!,
        fileName: _nombreImagen!,
      );
      if (!mounted) return;
      if (respuesta['estado'] != true) {
        throw Exception(
          respuesta['mensaje'] ?? 'No se pudo guardar la evidencia',
        );
      }
      Navigator.of(context, rootNavigator: true).pop({
        'fase': _faseSeleccionada,
        'actividad': _actividadSeleccionada!['nombre'],
        'descripcion': _descripcionController.text.trim(),
        'fecha': _fechaController.text,
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo subir la evidencia: $error')),
      );
    }
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
                    decoration: BoxDecoration(
                      color: AppColors.naranja,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.photo_camera_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Subir Evidencia Fotográfica',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _guardando ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 28),
                  ),
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
                      items: _fasesDisponibles,
                      onChanged:
                          (value) => setState(() {
                            _faseSeleccionada = value;
                            _actividadSeleccionada = null;
                          }),
                    );
                    final activity = _dropdownField(
                      label: 'Actividad Relacionada',
                      hint:
                          _faseSeleccionada == null
                              ? 'Selecciona primero la fase'
                              : 'Selecciona actividad',
                      value: _actividadSeleccionada?['nombre']?.toString(),
                      items:
                          _actividadesDeFase
                              .map(
                                (actividad) => actividad['nombre'].toString(),
                              )
                              .toList(),
                      onChanged:
                          (value) => setState(() {
                            final coincidencias =
                                _actividadesDeFase
                                    .where(
                                      (actividad) =>
                                          actividad['nombre'] == value,
                                    )
                                    .toList();
                            _actividadSeleccionada =
                                coincidencias.isEmpty
                                    ? null
                                    : coincidencias.first;
                          }),
                    );
                    final label = _textField(
                      label: 'Etiqueta',
                      controller: _etiquetaController,
                      hint: 'Ej. Colado',
                    );
                    if (compact) {
                      return Column(
                        children: [
                          date,
                          const SizedBox(height: 12),
                          phase,
                          const SizedBox(height: 12),
                          activity,
                          const SizedBox(height: 12),
                          label,
                        ],
                      );
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
                  hint:
                      'Describe los trabajos que se muestran en la fotografía',
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
                    Container(
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
                          if (_imagenBytes != null)
                            Image.memory(_imagenBytes!, fit: BoxFit.cover)
                          else
                            const Center(
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 34,
                                color: AppColors.gris,
                              ),
                            ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              color: Colors.black54,
                              child: Text(
                                _nombreImagen ?? 'Sin fotografía seleccionada',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_imagePicker.supportsImageSource(
                          ImageSource.camera,
                        ))
                          OutlinedButton.icon(
                            onPressed:
                                _guardando
                                    ? null
                                    : () => _seleccionarImagen(
                                      source: ImageSource.camera,
                                    ),
                            icon: const Icon(Icons.photo_camera_outlined),
                            label: const Text('Tomar foto'),
                          ),
                        OutlinedButton.icon(
                          onPressed:
                              _guardando
                                  ? null
                                  : () => _seleccionarImagen(
                                    source: ImageSource.gallery,
                                  ),
                          icon: const Icon(Icons.folder_open_outlined),
                          label: const Text('Elegir del dispositivo'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Se aceptan imágenes JPG, PNG o WebP de hasta 8 MB.',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textoGris,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: _guardando ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.naranja,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _guardando
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text(
                              'GUARDAR EVIDENCIA',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.naranja),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _fechaController.text.isEmpty
                        ? 'Selecciona fecha'
                        : _fechaController.text,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 15,
                  color: AppColors.textoNegro,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.naranja),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : null,
              isExpanded: true,
              hint: Text(
                hint,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: AppColors.naranja,
              ),
              items:
                  items
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: items.isEmpty ? null : onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 9,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.naranja),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.naranja),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: AppColors.naranja,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _formBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.bordeSuave),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  Widget _label(String value) => Text(
    value,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: AppColors.textoNegro,
    ),
  );
}
