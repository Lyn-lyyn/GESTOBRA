import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../servicios/api_service.dart';
import '../widgets/nueva_evidencia_modal.dart';

class EvidenciasSection extends StatefulWidget {
  final Map<String, dynamic> obra;

  const EvidenciasSection({super.key, required this.obra});

  @override
  State<EvidenciasSection> createState() => _EvidenciasSectionState();
}

class _EvidenciasSectionState extends State<EvidenciasSection> {
  String _faseSeleccionada = 'Todas las fases';
  final List<Map<String, dynamic>> _evidencias = [];
  List<Map<String, dynamic>> _fases = [];
  List<Map<String, dynamic>> _actividades = [];
  bool _cargando = true;
  String? _error;

  int get _obraId =>
      int.tryParse(widget.obra['id_obra']?.toString() ?? '') ?? 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    if (_obraId <= 0) {
      setState(() {
        _cargando = false;
        _error = 'Esta obra de muestra no tiene un ID de la base de datos.';
      });
      return;
    }
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final respuestas = await Future.wait([
        ApiService.get('fases_obra.php?id_obra=$_obraId'),
        ApiService.get('actividades.php?id_obra=$_obraId'),
        ApiService.get('evidencias.php?id_obra=$_obraId'),
      ]);
      for (final respuesta in respuestas) {
        if (respuesta['estado'] != true) {
          throw Exception(
            respuesta['mensaje'] ?? 'No se pudieron cargar las evidencias',
          );
        }
      }
      final fases = List<Map<String, dynamic>>.from(
        respuestas[0]['data'] as List,
      );
      final fasesPorId = <String, String>{
        for (final fase in fases)
          fase['id_fase'].toString(): fase['nombre'].toString(),
      };
      final actividades =
          List<Map<String, dynamic>>.from(respuestas[1]['data'] as List)
              .map(
                (actividad) => {
                  ...actividad,
                  'fase':
                      fasesPorId[actividad['id_fase'].toString()] ?? 'Sin fase',
                },
              )
              .toList();
      final evidencias =
          List<Map<String, dynamic>>.from(respuestas[2]['data'] as List).map((
            evidencia,
          ) {
            final ruta = evidencia['archivo_url']?.toString() ?? '';
            return {
              'codigo': evidencia['codigo'] ?? 'EV',
              'fase': evidencia['fase'] ?? 'Sin fase',
              'actividad': evidencia['actividad'] ?? 'Sin actividad',
              'descripcion': evidencia['descripcion'] ?? '',
              'fecha':
                  evidencia['fecha_captura']?.toString().split(' ').first ?? '',
              'responsable':
                  evidencia['responsable_nombre'] ?? 'Sin responsable',
              'imagenUrl':
                  ruta.isEmpty
                      ? null
                      : Uri.parse(ApiService.baseUrl).resolve(ruta).toString(),
              'color': const Color(0xFF9EAD91),
            };
          }).toList();
      if (!mounted) return;
      setState(() {
        _fases = fases;
        _actividades = actividades;
        _evidencias
          ..clear()
          ..addAll(evidencias);
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<Map<String, dynamic>> get _evidenciasFiltradas {
    if (_faseSeleccionada == 'Todas las fases') return _evidencias;
    return _evidencias
        .where((evidencia) => evidencia['fase'] == _faseSeleccionada)
        .toList();
  }

  Future<void> _abrirModal() async {
    if (_obraId <= 0 || _actividades.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _obraId <= 0
                ? 'Abre una obra cargada desde la base de datos para subir evidencia.'
                : 'Esta obra aún no tiene actividades disponibles.',
          ),
        ),
      );
      return;
    }
    final evidencia = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => NuevaEvidenciaModal(
            obraId: _obraId,
            actividadesDisponibles: _actividades,
          ),
    );
    if (evidencia == null || !mounted) return;
    _faseSeleccionada = 'Todas las fases';
    await _cargarDatos();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evidencia guardada correctamente')),
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
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 620;
              final title = const Text(
                'Evidencias fotográficas georreferenciadas y foliadas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              );
              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildFaseDropdown(),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: _abrirModal,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'Subir evidencia',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.naranja,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 10), actions],
                );
              }
              return Row(children: [Expanded(child: title), actions]);
            },
          ),
          const SizedBox(height: 12),
          if (_cargando)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textoGris),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _cargarDatos,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          else if (_evidenciasFiltradas.isEmpty)
            _buildEmptyState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 430 ? 2 : 1;
                final cardWidth =
                    (constraints.maxWidth - (columns - 1) * 12) / columns;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      _evidenciasFiltradas
                          .map(
                            (evidencia) => SizedBox(
                              width: cardWidth,
                              child: _buildEvidenceCard(evidencia),
                            ),
                          )
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
      ..._fases.map((fase) => fase['nombre'].toString()),
    ];
    final dropdownWidth =
        (MediaQuery.of(context).size.width - 96).clamp(180.0, 220.0).toDouble();
    return SizedBox(
      width: dropdownWidth,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.noseleccionado,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _faseSeleccionada,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppColors.gris,
            ),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textoNegro,
              fontWeight: FontWeight.bold,
            ),
            items: fases
                .map((fase) => DropdownMenuItem(
                      value: fase,
                      child: Text(fase, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _faseSeleccionada = value);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEvidenceCard(Map<String, dynamic> evidencia) {
    final color = evidencia['color'] as Color;
    final imagenUrl = evidencia['imagenUrl'] as String?;
    return Container(
      height: 288,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordeSuave),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imagenUrl != null)
                  Image.network(
                    imagenUrl,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            _imagePlaceholder(color),
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.naranja,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
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
                  Expanded(
                    child: Text(
                      evidencia['fecha'].toString(),
                      style: const TextStyle(fontSize: 9),
                    ),
                  ),
                  const Icon(Icons.person_outline, size: 12),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      evidencia['responsable'].toString(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 9),
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

  Widget _imagePlaceholder(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(.75), color.withOpacity(.98)],
        ),
      ),
      child: Icon(
        Icons.construction,
        size: 58,
        color: Colors.white.withOpacity(.45),
      ),
    );
  }

  Widget _imageBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.naranja,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordeSuave),
      ),
      child: const Column(
        children: [
          Icon(Icons.photo_library_outlined, size: 44, color: AppColors.gris),
          SizedBox(height: 10),
          Text(
            'No hay evidencias para esta fase',
            style: TextStyle(fontSize: 14, color: AppColors.gris),
          ),
        ],
      ),
    );
  }
}
