import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../widgets/nueva_evidencia_modal.dart';

class EvidenciasSection extends StatefulWidget {
  final Map<String, dynamic> obra;
  final List<Map<String, dynamic>> fasesDisponibles;

  const EvidenciasSection({
    super.key,
    required this.obra,
    required this.fasesDisponibles,
  });

  @override
  State<EvidenciasSection> createState() => _EvidenciasSectionState();
}

class _EvidenciasSectionState extends State<EvidenciasSection> {
  String _faseSeleccionada = 'Todas las fases';

  final List<Map<String, dynamic>> _evidencias = [
    {
      'codigo': 'EV 0001',
      'fase': 'Cimentación',
      'actividad': 'Colado de zapatas y contratrabes',
      'descripcion': 'Toma de cilindros de prueba para ensayo a compresión de 250 kg/cm² a los 7 y 28 días.',
      'fecha': '2026-09-22',
      'responsable': 'Arq. Sofía Méndez',
      'imagenPath': 'assets/images/evidencia_colado_zapatas.png',
      'color': const Color(0xFF9EAD91),
    },
    {
      'codigo': 'EV 0002',
      'fase': 'Cimentación',
      'actividad': 'Armado de acero en zapatas y dados',
      'descripcion': 'Armado terminado en zapata Z4 y dado D4. Separadores de concreto de 5 cm colocados.',
      'fecha': '2026-09-20',
      'responsable': 'Ing. Carlos Morales',
      'imagenPath': 'assets/images/evidencia_armado_cimentacion.png',
      'color': const Color(0xFF879293),
    },
    {
      'codigo': 'EV 0003',
      'fase': 'Cimentación',
      'actividad': 'Excavación para zapatas y contratrabes',
      'descripcion': 'Profundidad de cepa Z3 verificada a 1.60 m según especificación estructural.',
      'fecha': '2026-09-14',
      'responsable': 'Arq. Sofía Méndez',
      'imagenPath': 'assets/images/evidencia_armado_cimentacion.png',
      'color': const Color(0xFF986A58),
    },
    {
      'codigo': 'EV 0004',
      'fase': 'Preliminares',
      'actividad': 'Limpieza y desmonte del terreno',
      'descripcion': 'Terreno limpio y despal incluido al 100%, retiro de escombros concluido.',
      'fecha': '2026-09-08',
      'responsable': 'Ing. Carlos Morales',
      'color': const Color(0xFFA88A54),
    },
  ];

  List<Map<String, dynamic>> get _evidenciasFiltradas {
    if (_faseSeleccionada == 'Todas las fases') return _evidencias;
    return _evidencias
        .where((evidencia) => evidencia['fase'] == _faseSeleccionada)
        .toList();
  }

  Future<void> _abrirModal() async {
    final evidencia = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (_) => NuevaEvidenciaModal(
        fasesDisponibles: widget.fasesDisponibles,
      ),
    );
    if (evidencia == null || !mounted) return;
    final nuevaEvidencia = Map<String, dynamic>.from(evidencia);
    setState(() {
      nuevaEvidencia['codigo'] = _siguienteCodigo();
      nuevaEvidencia['responsable'] = 'Ing. Carlos Morales';
      nuevaEvidencia['color'] = const Color(0xFF9EAD91);
      _evidencias.insert(0, nuevaEvidencia);
      _faseSeleccionada = 'Todas las fases';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evidencia guardada correctamente')),
    );
  }

  String _siguienteCodigo() {
    var mayorCodigo = 0;
    for (final evidencia in _evidencias) {
      final digitos = evidencia['codigo'].toString().replaceAll(RegExp(r'\D'), '');
      final codigo = int.tryParse(digitos) ?? 0;
      if (codigo > mayorCodigo) mayorCodigo = codigo;
    }
    return 'EV ${(mayorCodigo + 1).toString().padLeft(4, '0')}';
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
                  'Evidencias Fotográficas\nGeorreferenciadas y Foliadas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.2),
                ),
              ),
              _buildFaseDropdown(),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: _abrirModal,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Subir evidencia', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.naranja,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_evidenciasFiltradas.isEmpty)
            _buildEmptyState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 430 ? 2 : 1;
                final cardWidth = (constraints.maxWidth - (columns - 1) * 12) / columns;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _evidenciasFiltradas
                      .map((evidencia) => SizedBox(
                            width: cardWidth,
                            child: _buildEvidenceCard(evidencia),
                          ))
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFaseDropdown() {
    final fases = [
      'Todas las fases',
      ...widget.fasesDisponibles.map((fase) => fase['nombre'] as String),
    ];
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.noseleccionado,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _faseSeleccionada,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.gris),
          style: const TextStyle(fontSize: 11, color: AppColors.textoNegro, fontWeight: FontWeight.bold),
          items: fases.map((fase) => DropdownMenuItem(value: fase, child: Text(fase))).toList(),
          onChanged: (value) {
            if (value != null) setState(() => _faseSeleccionada = value);
          },
        ),
      ),
    );
  }

  Widget _buildEvidenceCard(Map<String, dynamic> evidencia) {
    final color = evidencia['color'] as Color;
    final imagenPath = evidencia['imagenPath'] as String?;
    return Container(
      height: 288,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gris),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imagenPath != null)
                  Image.asset(
                    imagenPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _imagePlaceholder(color),
                  )
                else
                  _imagePlaceholder(color),
                Positioned(
                  left: 10,
                  top: 10,
                  child: _imageBadge(evidencia['codigo'].toString()),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: _imageBadge(evidencia['fase'].toString()),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 91,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 7, 10, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evidencia['actividad'].toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.naranja, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                  const SizedBox(height: 3),
                  Expanded(
                    child: Text(
                      evidencia['descripcion'].toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.gris),
          SizedBox(
            height: 43,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 12),
                const SizedBox(width: 4),
                Expanded(child: Text(evidencia['fecha'].toString(), style: const TextStyle(fontSize: 9))),
                const Icon(Icons.person_outline, size: 12),
                const SizedBox(width: 4),
                Flexible(child: Text(evidencia['responsable'].toString(), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9))),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(.75), color.withOpacity(.98)],
        ),
      ),
      child: Icon(Icons.construction, size: 58, color: Colors.white.withOpacity(.45)),
    );
  }

  Widget _imageBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: const TextStyle(color: AppColors.naranja, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gris)),
      child: const Column(
        children: [
          Icon(Icons.photo_library_outlined, size: 44, color: AppColors.gris),
          SizedBox(height: 10),
          Text('No hay evidencias para esta fase', style: TextStyle(fontSize: 14, color: AppColors.gris)),
        ],
      ),
    );
  }
}
