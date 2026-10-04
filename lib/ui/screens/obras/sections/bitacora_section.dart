import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/custom_dropdown_field.dart';

class BitacoraSection extends StatefulWidget {
  final Map<String, dynamic> obra;

  const BitacoraSection({
    super.key,
    required this.obra,
  });

  @override
  State<BitacoraSection> createState() => _BitacoraSectionState();
}

class _BitacoraSectionState extends State<BitacoraSection> {
  final List<Map<String, dynamic>> _bitacoras = [];

  void _abrirNuevaBitacora() {
    showDialog(
      context: context,
      builder: (context) {
        return _NuevaBitacoraDialog(
          onGuardar: (bitacora) {
            setState(() {
              _bitacoras.insert(0, bitacora);
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bitácora guardada correctamente'),
              ),
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
        color: AppColors.grisfondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gris),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Bitácora de obra',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
          if (_bitacoras.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.blanco,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gris),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 48,
                    color: AppColors.gris,
                  ),
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
                    style: TextStyle(
                      color: AppColors.textoGris,
                    ),
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
        border: Border.all(color: AppColors.gris),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.naranja,
              ),
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
                  color: AppColors.textoGris,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            bitacora['descripcion'],
            style: const TextStyle(
              color: AppColors.textoNegro,
              height: 1.4,
            ),
          ),
          if ((bitacora['actividades'] as List).isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Actividades ejecutadas:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textoNegro,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: (bitacora['actividades'] as List).map<Widget>((actividad) {
                return Chip(
                  label: Text(
                    actividad.toString(),
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: AppColors.grisfondo,
                  side: const BorderSide(color: AppColors.gris),
                );
              }).toList(),
            ),
          ],
          if ((bitacora['materiales'] as List).isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Materiales utilizados:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textoNegro,
              ),
            ),
            const SizedBox(height: 6),
            ...(bitacora['materiales'] as List).map<Widget>((material) {
              return _buildInfoRow(
                Icons.inventory_2_outlined,
                material['material'].toString(),
                '${material['cantidad']} unidades',
              );
            }),
          ],
          if (bitacora['clima'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.wb_sunny_outlined,
              'Clima',
              bitacora['clima'],
            ),
          ],
          if (bitacora['observaciones'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.notes_outlined,
              'Observaciones',
              bitacora['observaciones'],
            ),
          ],
          if (bitacora['hubo_retraso'] == true) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.warning_amber_outlined,
              'Retraso',
              '${bitacora['horas_retraso']} horas - ${bitacora['causa_retraso']}',
            ),
          ],
          if (bitacora['incidencias'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.warning_amber_outlined,
              'Incidencias',
              bitacora['incidencias'],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String titulo,
    String contenido,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.naranja),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppColors.textoNegro,
                fontSize: 13,
              ),
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
  final Function(Map<String, dynamic>) onGuardar;

  const _NuevaBitacoraDialog({
    required this.onGuardar,
  });

  @override
  State<_NuevaBitacoraDialog> createState() => _NuevaBitacoraDialogState();
}

class _NuevaBitacoraDialogState extends State<_NuevaBitacoraDialog> {
  final _fechaController = TextEditingController();
  final _temperaturaController = TextEditingController();
  DateTime? _fechaSeleccionada;
  String? _climaSeleccionado;
  final List<String> _actividadesDisponibles = [
  'Limpieza y desmonte del terreno',
  'Trazo y nivelación topográfica',
  'Excavación para zapatas y contratrabes',
  'Plantilla de concreto pobre',
  'Armado de acero en zapatas y dados',
  'Colado de zapatas y contratrabes',
  'Relleno y compactación con tepetate',
  'Cimbrado y colado de columnas',
  'Losa de entrepiso',
  'Muros de block',
];
  final List<Map<String, dynamic>> _materialesSeleccionados = [
    {
      'material': null,
      'cantidad': TextEditingController(),
    },
  ];

  final List<String> _materialesDisponibles = [
    'Cemento',
    'Arena',
    'Grava',
    'Varilla',
    'Block',
    'Alambre recocido',
    'Madera',
    'Pintura',
  ];
  bool _huboRetraso = false;
  final _horasRetrasoController = TextEditingController();
  final _causaRetrasoController = TextEditingController();
  final List<String> _actividadesSeleccionadas = [];
  final _personalController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _incidenciasController = TextEditingController();
  bool _evidenciaAgregada = false;
  bool _firmaAgregada = false;

  Future<void> _seleccionarFecha() async {
  final fecha = await showDatePicker(
    context: context,
    initialDate: _fechaSeleccionada ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
    helpText: 'Selecciona la fecha de la bitácora',
    cancelText: 'Cancelar',
    confirmText: 'Aceptar',
    locale: const Locale('es', 'MX'),
  );

  if (fecha == null) return;

  setState(() {
    _fechaSeleccionada = fecha;
    _fechaController.text =
        '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  });
}
Widget _buildActividadesField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Actividades ejecutadas en la jornada',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textoNegro,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.blanco,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.naranja),
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _actividadesDisponibles.map((actividad) {
            final seleccionada =
                _actividadesSeleccionadas.contains(actividad);

            return FilterChip(
              label: Text(
                actividad,
                style: const TextStyle(fontSize: 11),
              ),
              selected: seleccionada,
              selectedColor: AppColors.naranja.withValues(alpha: 0.2),
              checkmarkColor: AppColors.naranja,
              side: BorderSide(
                color: seleccionada
                    ? AppColors.naranja
                    : AppColors.gris,
              ),
              onSelected: (value) {
                setState(() {
                  if (value) {
                    _actividadesSeleccionadas.add(actividad);
                  } else {
                    _actividadesSeleccionadas.remove(actividad);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
    ],
  );
}
  Widget _buildMaterialesField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Materiales utilizados en la jornada',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textoNegro,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 8),
      ..._materialesSeleccionados.asMap().entries.map((entry) {
        final index = entry.key;
        final material = entry.value;
        final cantidadController =
            material['cantidad'] as TextEditingController;

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: CustomDropdownField(
                  label: 'Material',
                  showLabel: index == 0,
                  hint: 'Selecciona',
                  icon: Icons.inventory_2_outlined,
                  value: material['material'] as String?,
                  items: _materialesDisponibles,
                  onChanged: (value) {
                    setState(() {
                      material['material'] = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: CustomTextField(
                  label: 'Cantidad',
                  showLabel: index == 0,
                  hint: '0',
                  icon: Icons.numbers,
                  controller: cantidadController,
                  keyboardType: TextInputType.number,
                ),
              ),
              if (_materialesSeleccionados.length > 1) ...[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Eliminar material',
                  onPressed: () {
                    setState(() {
                      (material['cantidad'] as TextEditingController)
                          .dispose();
                      _materialesSeleccionados.removeAt(index);
                    });
                  },
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.estadoRojo,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () {
            setState(() {
              _materialesSeleccionados.add({
                'material': null,
                'cantidad': TextEditingController(),
              });
            });
          },
          icon: const Icon(Icons.add, color: AppColors.naranja),
          label: const Text(
            'Agregar material',
            style: TextStyle(color: AppColors.naranja),
          ),
        ),
      ),
    ],
  );
}
Widget _buildRetrasosField() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.blanco,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.gris),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'Observaciones relevantes de la supervisión',
          hint: 'Escribe las observaciones de la jornada',
          icon: Icons.notes_outlined,
          controller: _observacionesController,
        ),
        const SizedBox(height: 10),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Hubo retrasos o paro de actividades en el turno',
            style: TextStyle(fontSize: 13),
          ),
          value: _huboRetraso,
          activeColor: AppColors.naranja,
          onChanged: (value) {
            setState(() {
              _huboRetraso = value ?? false;
            });
          },
        ),
        if (_huboRetraso) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: CustomTextField(
                  label: 'Horas de retraso',
                  hint: '0',
                  icon: Icons.timer_outlined,
                  controller: _horasRetrasoController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: CustomTextField(
                  label: 'Causa del retraso',
                  hint: 'Describe la causa',
                  icon: Icons.warning_amber_outlined,
                  controller: _causaRetrasoController,
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}
Widget _buildEvidenciasField() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.blanco,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.gris),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evidencias fotográficas de la jornada',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textoNegro,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () {
            setState(() {
              _evidenciaAgregada = true;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.grisfondo,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.naranja),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _evidenciaAgregada
                      ? Icons.check_circle_outline
                      : Icons.cloud_upload_outlined,
                  size: 34,
                  color: AppColors.naranja,
                ),
                const SizedBox(height: 6),
                Text(
                  _evidenciaAgregada
                      ? 'Evidencia agregada'
                      : 'Toca para agregar fotografías',
                  style: const TextStyle(
                    color: AppColors.textoGris,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
Widget _buildFirmaField() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.blanco,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.gris),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Firma manuscrita',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoNegro,
                  fontSize: 14,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _firmaAgregada = false;
                });
              },
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.naranja,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            setState(() {
              _firmaAgregada = true;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.grisfondo,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gris),
            ),
            child: _firmaAgregada
                ? const Center(
                    child: Text(
                      '✓ Firma registrada',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const Center(
                    child: Text(
                      'Toca aquí para agregar firma',
                      style: TextStyle(
                        color: AppColors.textoGris,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    ),
  );
}
  void _guardar() {
    if (_fechaController.text.trim().isEmpty ||
        _descripcionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La fecha y la descripción de la jornada son obligatorias',
          ),
        ),
      );
      return;
    }

    widget.onGuardar({
      'fecha': _fechaController.text.trim(),
      'clima': _climaSeleccionado ?? '',
      'temperatura': _temperaturaController.text.trim(),
      'personal': _personalController.text.trim().isEmpty
          ? '0'
          : _personalController.text.trim(),
      'materiales': _materialesSeleccionados.map((material) {
        return {
          'material': material['material'] ?? '',
          'cantidad':
              (material['cantidad'] as TextEditingController).text.trim(),
        };
      }).where((material) => material['material'].toString().isNotEmpty).toList(),
      'actividades': List<String>.from(_actividadesSeleccionadas),
      'descripcion': _descripcionController.text.trim(),
      'observaciones': _observacionesController.text.trim(),
      'hubo_retraso': _huboRetraso,
      'horas_retraso': _horasRetrasoController.text.trim(),
      'causa_retraso': _causaRetrasoController.text.trim(),
      'incidencias': _incidenciasController.text.trim(),
      'evidencia_agregada': _evidenciaAgregada,
      'firma_agregada': _firmaAgregada,
    });

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _personalController.dispose();
    _descripcionController.dispose();
    _observacionesController.dispose();
    _incidenciasController.dispose();
    _temperaturaController.dispose();
    for (final material in _materialesSeleccionados) {
      (material['cantidad'] as TextEditingController).dispose();
    }
    _horasRetrasoController.dispose();
    _causaRetrasoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva bitácora'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Column(
            children: [
              CustomTextField(
                label: 'Fecha de bitácora *',
                hint: 'Selecciona una fecha',
                icon: Icons.calendar_today_outlined,
                controller: _fechaController,
                readOnly: true,
                onTap: _seleccionarFecha,
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.naranja,
                  ),
                  onPressed: _seleccionarFecha,
                ),
              ),
              const SizedBox(height: 14),
              CustomDropdownField(
                label: 'Condición climática',
                hint: 'Selecciona el clima',
                icon: Icons.wb_sunny_outlined,
                value: _climaSeleccionado,
                items: const [
                  'Soleado',
                  'Nublado',
                  'Lluvioso',
                  'Tormenta',
                  'Viento fuerte',
                ],
                onChanged: (value) {
                  setState(() {
                    _climaSeleccionado = value;
                  });
                },
              ),
              const SizedBox(height: 14),

              CustomTextField(
                label: 'Temperatura ambiente',
                hint: 'Ejemplo: 28 °C',
                icon: Icons.thermostat_outlined,
                controller: _temperaturaController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Personal presente',
                hint: 'Ejemplo: 8',
                icon: Icons.groups_outlined,
                controller: _personalController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              _buildMaterialesField(),
              const SizedBox(height: 14),
              _buildActividadesField(),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Descripción de la jornada *',
                hint: 'Describe las actividades realizadas',
                icon: Icons.description_outlined,
                controller: _descripcionController,
              ),
              const SizedBox(height: 14),
              _buildRetrasosField(),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Incidencias',
                hint: 'Describe cualquier incidencia',
                icon: Icons.warning_amber_outlined,
                controller: _incidenciasController,
              ),
              const SizedBox(height: 14),

              _buildEvidenciasField(),
              const SizedBox(height: 14),
              _buildFirmaField(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textoGris),
          ),
        ),
        ElevatedButton(
          onPressed: _guardar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.naranja,
            foregroundColor: AppColors.blanco,
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
