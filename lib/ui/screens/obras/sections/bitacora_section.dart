import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 👈 Necesario para los formateadores
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';

class BitacoraSection extends StatefulWidget {
  final Map<String, dynamic> obra;

  const BitacoraSection({super.key, required this.obra});

  @override
  State<BitacoraSection> createState() => _BitacoraSectionState();
}

class _BitacoraSectionState extends State<BitacoraSection> {
  bool _cargando = true;
  List<Map<String, dynamic>> _bitacoras = [];

  @override
  void initState() {
    super.initState();
    _cargarBitacoras();
  }

  Future<void> _cargarBitacoras() async {
    final idObra = widget.obra['id_obra'];
    if (idObra == null) return;

    setState(() => _cargando = true);
    final res = await ApiService.get('bitacoras.php?id_obra=$idObra');

    if (!mounted) return;

    if (res['estado'] == true) {
      setState(() {
        _bitacoras = List<Map<String, dynamic>>.from(res['data']).map((b) {
          return {
            'fecha': b['fecha'],
            'clima': b['clima'] ?? 'No registrado',
            'personal': b['personal_presente'].toString(),
            'descripcion': b['descripcion_jornada'] ?? 'Sin descripción',
            'observaciones': b['observaciones'] ?? '',
            'incidencias': b['incidencias'] ?? '',
            'materiales': [],
            'actividades': [],
            'fotografias': [],
            'hubo_retraso': false,
          };
        }).toList();
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
    }
  }

  void _abrirNuevaBitacora() {
    showDialog(
      context: context,
      builder: (context) {
        return _NuevaBitacoraDialog(
          idObra: widget.obra['id_obra'],
          onGuardar: (bitacora) {
            _cargarBitacoras();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bitácora guardada correctamente')),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordeSuave),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Bitácora de obra',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _abrirNuevaBitacora,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Nueva bitácora'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.naranja,
                  foregroundColor: AppColors.blanco,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_cargando)
            const Center(child: CircularProgressIndicator())
          else if (_bitacoras.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.blanco,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.bordeSuave),
              ),
              child: const Column(
                children: [
                  Icon(Icons.book_outlined, size: 48, color: AppColors.gris),
                  SizedBox(height: 12),
                  Text(
                    'No hay bitácoras registradas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoNegro,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Registra la primera jornada de esta obra.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textoGris),
                  ),
                ],
              ),
            )
          else
            Column(
              children: _bitacoras
                  .map((bitacora) => _buildBitacoraCard(bitacora))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildBitacoraCard(Map<String, dynamic> bitacora) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordeSuave),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 18, color: AppColors.naranja),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  bitacora['fecha'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textoNegro,
                  ),
                ),
              ),
              Text(
                '${bitacora['personal']} personas',
                style: const TextStyle(
                    color: AppColors.textoGris, fontSize: 12),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            bitacora['descripcion'],
            style: const TextStyle(color: AppColors.textoNegro, height: 1.4),
          ),
          if (bitacora['clima'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.wb_sunny_outlined, 'Clima', bitacora['clima']),
          ],
          if (bitacora['observaciones'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
                Icons.notes_outlined, 'Observaciones', bitacora['observaciones']),
          ],
          if (bitacora['incidencias'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
                Icons.warning_amber_outlined, 'Incidencias', bitacora['incidencias']),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String titulo, String contenido) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.naranja),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: AppColors.textoNegro, fontSize: 13),
              children: [
                TextSpan(
                  text: '$titulo: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: contenido),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NuevaBitacoraDialog extends StatefulWidget {
  final int idObra;
  final Function(Map<String, dynamic>) onGuardar;

  const _NuevaBitacoraDialog({required this.idObra, required this.onGuardar});

  @override
  State<_NuevaBitacoraDialog> createState() => _NuevaBitacoraDialogState();
}

class _NuevaBitacoraDialogState extends State<_NuevaBitacoraDialog> {
  final _fechaController = TextEditingController();
  final _temperaturaController = TextEditingController();
  DateTime? _fechaSeleccionada;
  String? _climaSeleccionado;
  bool _guardando = false;

  bool _huboRetraso = false;
  final _horasRetrasoController = TextEditingController();
  final _causaRetrasoController = TextEditingController();
  final _personalController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _incidenciasController = TextEditingController();

  // ─── Calendario con estilo naranja ───
  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
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
        _fechaSeleccionada = picked;
        _fechaController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _guardar() async {
    if (_fechaController.text.trim().isEmpty ||
        _descripcionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('La fecha y la descripción son obligatorias')),
      );
      return;
    }

    setState(() => _guardando = true);

    final body = {
      'id_obra': widget.idObra,
      'fecha': _fechaController.text.trim(),
      'clima': _climaSeleccionado ?? '',
      'temperatura': _temperaturaController.text.trim(),
      'personal_presente': int.tryParse(_personalController.text) ?? 0,
      'descripcion_jornada': _descripcionController.text.trim(),
      'observaciones': _observacionesController.text.trim(),
      'incidencias': _incidenciasController.text.trim(),
      'hubo_retraso': _huboRetraso,
      'horas_retraso': _huboRetraso
          ? (int.tryParse(_horasRetrasoController.text.trim()) ?? 0)
          : 0,
      'causa_retraso':
          _huboRetraso ? _causaRetrasoController.text.trim() : '',
    };

    final res = await ApiService.post('bitacoras.php', body);

    if (!mounted) return;
    setState(() => _guardando = false);

    if (res['estado'] == true) {
      widget.onGuardar({});
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['mensaje'] ?? 'Error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _personalController.dispose();
    _descripcionController.dispose();
    _observacionesController.dispose();
    _incidenciasController.dispose();
    _temperaturaController.dispose();
    _horasRetrasoController.dispose();
    _causaRetrasoController.dispose();
    super.dispose();
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
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text('Nueva bitácora',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              ),

              // ─── Fecha ───
              _buildLabel('Fecha de bitácora *'),
              _buildCustomTextField(
                hint: 'Selecciona una fecha',
                icon: Icons.calendar_today_outlined,
                controller: _fechaController,
                readOnly: true,
                onTap: _seleccionarFecha,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month_outlined,
                      color: AppColors.naranja),
                  onPressed: _seleccionarFecha,
                ),
              ),
              const SizedBox(height: 14),

              // FILA 1: CLIMA Y TEMPERATURA
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Clima'),
                        _buildCustomDropdownField(
                          hint: 'Selecciona',
                          icon: Icons.wb_sunny_outlined,
                          value: _climaSeleccionado,
                          items: const [
                            'Soleado',
                            'Nublado',
                            'Lluvioso',
                            'Tormenta',
                            'Viento'
                          ],
                          onChanged: (value) =>
                              setState(() => _climaSeleccionado = value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Temp. °C'),
                        _buildCustomTextField(
                          hint: '28',
                          icon: Icons.thermostat_outlined,
                          controller: _temperaturaController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // FILA 2: PERSONAL (Ocupa todo el ancho)
              _buildLabel('Personal en obra'),
              _buildCustomTextField(
                hint: 'Ej. 8',
                icon: Icons.groups_outlined,
                controller: _personalController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),

              _buildLabel('Descripción de la jornada *'),
              _buildCustomTextField(
                hint: 'Describe las actividades',
                icon: Icons.description_outlined,
                controller: _descripcionController,
                maxLines: 3,
              ),
              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.blanco,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.bordeSuave),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Observaciones'),
                    _buildCustomTextField(
                      hint: 'Escribe las observaciones',
                      icon: Icons.notes_outlined,
                      controller: _observacionesController,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Hubo retrasos o paro',
                          style: TextStyle(fontSize: 13)),
                      value: _huboRetraso,
                      activeColor: AppColors.naranja,
                      onChanged: (value) =>
                          setState(() => _huboRetraso = value ?? false),
                    ),
                    if (_huboRetraso) ...[
                      const SizedBox(height: 8),
                      _buildLabel('Horas de retraso'),
                      _buildCustomTextField(
                        hint: '0',
                        icon: Icons.timer_outlined,
                        controller: _horasRetrasoController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      _buildLabel('Causa del retraso'),
                      _buildCustomTextField(
                        hint: 'Describe la causa',
                        icon: Icons.warning_amber_outlined,
                        controller: _causaRetrasoController,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              _buildLabel('Incidencias'),
              _buildCustomTextField(
                hint: 'Describe cualquier incidencia',
                icon: Icons.warning_amber_outlined,
                controller: _incidenciasController,
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _guardando ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar',
                        style: TextStyle(color: AppColors.textoGris)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _guardando ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.naranja,
                      foregroundColor: AppColors.blanco,
                    ),
                    child: _guardando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Widgets auxiliares ───

  Widget _buildLabel(String text) => Padding(
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

  Widget _buildCustomTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.naranja),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.naranja, width: 2),
        ),
      ),
    );
  }

  Widget _buildCustomDropdownField({
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      // En Flutter reciente usa `initialValue`; `value` sigue funcionando
      // en versiones estables. Si tu SDK marca deprecación, cambia a:
      // initialValue: value,
      value: value,
      isExpanded: true,
      hint: Text(hint,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      style: const TextStyle(fontSize: 13, color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.naranja),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.naranja, width: 2),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}