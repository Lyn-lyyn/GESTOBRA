import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

/// Tabla de actividades con su periodo representado como barras alineadas.
class PipelineActividadesSection extends StatefulWidget {
  final List<Map<String, dynamic>> actividades;
  final List<Map<String, dynamic>> fases;
  final String faseSeleccionada;

  const PipelineActividadesSection({
    super.key,
    required this.actividades,
    required this.fases,
    required this.faseSeleccionada,
  });

  @override
  State<PipelineActividadesSection> createState() =>
      _PipelineActividadesSectionState();
}

class _PipelineActividadesSectionState
    extends State<PipelineActividadesSection> {
  static const double _detailsWidth = 800;
  static const double _timelineWidth = 760;
  static const double _tableWidth = _detailsWidth + _timelineWidth + 1;
  static const double _rowHeight = 58;
  final ScrollController _horizontalController =
      ScrollController(keepScrollOffset: false);
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _horizontalController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _actividadesFiltradas {
    if (widget.faseSeleccionada == 'Todas las fases') {
      return widget.actividades.where(_coincideBusqueda).toList();
    }
    return widget.actividades.where((actividad) {
      return _faseComparable(actividad['fase'] as String? ?? '') ==
              _faseComparable(widget.faseSeleccionada) &&
          _coincideBusqueda(actividad);
    }).toList();
  }

  bool _coincideBusqueda(Map<String, dynamic> actividad) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;
    return [
      actividad['titulo'],
      actividad['fase'],
      actividad['responsable'],
      actividad['estado'],
    ].whereType<String>().any((value) => value.toLowerCase().contains(query));
  }

  String _faseComparable(String fase) => fase.trim().toUpperCase();

  DateTime _fecha(Map<String, dynamic> actividad, String key) {
    final value = actividad[key];
    if (value is DateTime) return value;

    final schedule = actividad['programado'] as String? ?? '';
    final dates = RegExp(r'(\d{4})/(\d{2})/(\d{2})').allMatches(schedule);
    if (dates.length >= 2) {
      final match = key == 'fechaInicio' ? dates.first : dates.last;
      return DateTime(
        int.parse(match[1]!),
        int.parse(match[2]!),
        int.parse(match[3]!),
      );
    }
    return DateTime.now();
  }

  String _fechaCorta(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

  List<MapEntry<String, List<Map<String, dynamic>>>> get _grupos {
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final actividad in _actividadesFiltradas) {
      final fase = actividad['fase'] as String? ?? 'SIN FASE';
      groups.putIfAbsent(fase, () => []).add(actividad);
    }
    return groups.entries.toList();
  }

  DateTime get _inicioCronograma {
    final activities = _actividadesFiltradas;
    if (activities.isEmpty) return DateTime.now();
    final first = activities
        .map((a) => _fecha(a, 'fechaInicio'))
        .reduce((a, b) => a.isBefore(b) ? a : b);
    return DateTime(first.year, first.month, first.day);
  }

  DateTime get _finCronograma {
    final activities = _actividadesFiltradas;
    if (activities.isEmpty) return DateTime.now().add(const Duration(days: 14));
    final last = activities
        .map((a) => _fecha(a, 'fechaFin'))
        .reduce((a, b) => a.isAfter(b) ? a : b);
    return DateTime(last.year, last.month, last.day).add(const Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    final groups = _grupos;
    final activities = _actividadesFiltradas;
    final start = _inicioCronograma;
    final end = _finCronograma;
    final totalDays = math.max(1, end.difference(start).inDays).toInt();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordeSuave),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPhaseCards(),
          const SizedBox(height: 16),
          _buildToolbar(activities.length),
          if (activities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(28),
              child: Center(child: Text('No hay actividades en esta fase.')),
            )
          else
            Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              trackVisibility: true,
              scrollbarOrientation: ScrollbarOrientation.bottom,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: _tableWidth,
                  child: Column(
                    children: [
                      _buildHeader(start, totalDays),
                      for (final group in groups) ...[
                        _buildPhaseRow(group.key, group.value),
                        for (var i = 0; i < group.value.length; i++)
                          _buildActivityRow(
                            group.value[i],
                            i + 1,
                            start,
                            totalDays,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Icon(Icons.swipe, size: 16, color: AppColors.gris),
                SizedBox(width: 6),
                Text('Desliza horizontalmente para consultar el cronograma',
                    style: TextStyle(fontSize: 11, color: AppColors.gris)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: LayoutBuilder(builder: (context, constraints) {
        final cards = widget.fases.map(_buildPhaseCard).toList();
        if (constraints.maxWidth < 720) {
          const gap = 8.0;
          final cardWidth = (constraints.maxWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: cards
                .map((card) => SizedBox(width: cardWidth, child: card))
                .toList(),
          );
        }
        return Row(children: [
          for (var index = 0; index < cards.length; index++)
            Expanded(child: Padding(
              padding: EdgeInsets.only(right: index == cards.length - 1 ? 0 : 10),
              child: cards[index],
            )),
        ]);
      }),
    );
  }

  Widget _buildPhaseCard(Map<String, dynamic> phase) {
    final percent = ((phase['porcentaje'] as num?)?.toDouble() ?? 0)
        .clamp(0.0, 100.0).toDouble();
    final color = percent >= 100
        ? Colors.green.shade600
        : percent > 0
            ? AppColors.naranja
            : Colors.blueGrey.shade300;
    final icon = switch ((phase['nombre'] as String).toLowerCase()) {
      'preliminares' => Icons.format_list_bulleted,
      'cimentación' => Icons.foundation,
      'estructura' => Icons.apartment,
      _ => Icons.home_work_outlined,
    };

    return Container(
      height: 112,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.bordeSuave.withOpacity(.35)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 7),
          Expanded(child: Text((phase['nombre'] as String).toUpperCase(),
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color))),
        ]),
        const Spacer(),
        Row(children: [
          SizedBox(
            width: 46,
            height: 46,
            child: CircularProgressIndicator(
              value: percent / 100,
              strokeWidth: 5,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${percent.round()}%', style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text('${phase['concluidas']} de ${phase['total']} actividades',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 9, color: AppColors.gris)),
          ])),
        ]),
      ]),
    );
  }

  Widget _buildToolbar(int activityCount) {
    Widget title() => const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.view_timeline_outlined, color: AppColors.naranja, size: 21),
          SizedBox(width: 9),
          Flexible(child: Text('Pipeline de actividades de obra',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
        ]);

    Widget searchField() => TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            hintText: 'Buscar actividad...',
            hintStyle: const TextStyle(fontSize: 12, color: AppColors.gris),
            prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.gris),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

    return LayoutBuilder(builder: (context, constraints) {
      final countLabel = Text('$activityCount actividades',
          style: const TextStyle(color: AppColors.gris, fontSize: 11));
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
        child: constraints.maxWidth < 680
            ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [Expanded(child: title()), countLabel]),
                const SizedBox(height: 10),
                searchField(),
              ])
            : Row(children: [
                Expanded(child: title()),
                SizedBox(width: 270, child: searchField()),
                const SizedBox(width: 12),
                countLabel,
              ]),
      );
    });
  }

  Widget _buildHeader(DateTime start, int totalDays) {
    const labelStyle = TextStyle(
        fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gris);
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.bordeSuave.withOpacity(.35)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _detailsWidth,
            child: Row(children: [
              _headerCell('FASE / ACTIVIDAD', 260, labelStyle),
              _headerCell('INICIO', 78, labelStyle),
              _headerCell('FIN', 78, labelStyle),
              _headerCell('DURACIÓN', 80, labelStyle),
              _headerCell('RESPONSABLE', 145, labelStyle),
              _headerCell('ESTADO', 159, labelStyle),
            ]),
          ),
          Container(width: 1, height: 58, color: AppColors.gris.withOpacity(.5)),
          SizedBox(
            width: _timelineWidth,
            child: Row(children: _dateTicks(start, totalDays)),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, double width, TextStyle style) => Container(
        width: width,
        height: 58,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.bordeSuave.withOpacity(.2))),
        ),
        child: Text(text, style: style, overflow: TextOverflow.ellipsis),
      );

  List<Widget> _dateTicks(DateTime start, int totalDays) {
    final count = 7;
    return List.generate(count, (index) {
      final dayOffset = (totalDays * index / (count - 1)).round();
      final date = start.add(Duration(days: dayOffset));
      return Expanded(
        child: Container(
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: AppColors.bordeSuave.withOpacity(.2))),
          ),
          child: Text(
            '${_fechaCorta(date)}\n${date.year}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppColors.gris),
          ),
        ),
      );
    });
  }

  Widget _buildPhaseRow(String phase, List<Map<String, dynamic>> activities) {
    final completed = activities
        .where((activity) => _estadoActividad(activity) == 'COMPLETADA')
        .length;
    final percent = activities.isEmpty ? 0 : (completed * 100 / activities.length).round();
    final color = percent == 100
        ? Colors.green.shade700
        : percent > 0
            ? AppColors.naranja
            : Colors.blueGrey.shade700;
    final tint = percent == 100
        ? Colors.green.withOpacity(.08)
        : percent > 0
            ? AppColors.naranja.withOpacity(.1)
            : Colors.blueGrey.withOpacity(.08);

    return Container(
      height: 38,
      color: tint,
      child: Row(children: [
        SizedBox(
          width: _detailsWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              Icon(Icons.keyboard_arrow_down, color: color, size: 20),
              const SizedBox(width: 6),
              Text(phase, style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(width: 8),
              Text('(${activities.length} actividades)',
                  style: const TextStyle(color: AppColors.gris, fontSize: 11)),
            ]),
          ),
        ),
        Container(width: 1, height: 38, color: AppColors.gris.withOpacity(.3)),
        SizedBox(
          width: _timelineWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('$percent% ($completed/${activities.length})',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            ),
          ),
        ),
      ]),
    );
  }

  String _estadoActividad(Map<String, dynamic> activity) {
    final state = (activity['estado'] as String? ?? '').toLowerCase();
    final progress = (activity['avance'] as num?)?.toDouble() ?? 0;
    if (state.contains('concluida') || state.contains('completada') || progress >= 1) {
      return 'COMPLETADA';
    }
    if (state.contains('progreso') || progress > 0) return 'EN PROGRESO';
    return 'PENDIENTE';
  }

  Widget _buildActivityRow(
    Map<String, dynamic> activity,
    int number,
    DateTime timelineStart,
    int totalDays,
  ) {
    final start = _fecha(activity, 'fechaInicio');
    final finish = _fecha(activity, 'fechaFin');
    final startOffset = start.difference(timelineStart).inDays;
    final duration = math.max(1, finish.difference(start).inDays + 1).toInt();
    final progress =
        ((activity['avance'] as num?)?.toDouble() ?? 0).clamp(0.0, 1.0).toDouble();
    final state = activity['estado'] as String? ?? 'Pendiente';
    final status = _estadoActividad(activity);
    final statusColor = switch (status) {
      'COMPLETADA' => Colors.green.shade700,
      'EN PROGRESO' => AppColors.naranja,
      _ => Colors.blueGrey.shade700,
    };

    return Container(
      height: _rowHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.bordeSuave.withOpacity(.22))),
      ),
      child: Row(children: [
        SizedBox(
          width: _detailsWidth,
          child: Row(children: [
            _dataCell(
              SizedBox(
                width: 260,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(children: [
                    SizedBox(width: 24, child: Text('$number.',
                        style: const TextStyle(fontSize: 11, color: AppColors.gris))),
                    Expanded(child: Text(activity['titulo'] as String? ?? '',
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500))),
                  ]),
                ),
              ),
            ),
            _textDataCell(_fechaCorta(start), 78),
            _textDataCell(_fechaCorta(finish), 78),
            _textDataCell('$duration ${duration == 1 ? 'día' : 'días'}', 80),
            _textDataCell(activity['responsable'] as String? ?? '—', 145),
            _dataCell(SizedBox(
              width: 159,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                          color: statusColor)),
                ),
              ),
            )),
          ]),
        ),
        Container(width: 1, height: _rowHeight,
            color: AppColors.gris.withOpacity(.5)),
        SizedBox(
          width: _timelineWidth,
          child: LayoutBuilder(builder: (context, constraints) {
            final left = (startOffset / totalDays * constraints.maxWidth)
                .clamp(0.0, constraints.maxWidth)
                .toDouble();
            final barWidth = (duration / totalDays * constraints.maxWidth)
                .clamp(14.0, constraints.maxWidth - left)
                .toDouble();
            return Stack(fit: StackFit.expand, children: [
              Row(children: List.generate(7, (_) => Expanded(
                child: Container(decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: AppColors.bordeSuave.withOpacity(.15))),
                )),
              ))),
              Positioned(
                left: left,
                top: 17,
                width: barWidth,
                height: 24,
                child: Tooltip(
                  message: '${_fechaCorta(start)} - ${_fechaCorta(finish)} · $state',
                  child: Container(
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(.16),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: statusColor.withOpacity(.65)),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${_fechaCorta(start)}–${_fechaCorta(finish)}',
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: statusColor,
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
              ),
            ]);
          }),
        ),
      ]),
    );
  }

  Widget _dataCell(Widget child) => Container(
        height: _rowHeight,
        foregroundDecoration: BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.bordeSuave.withOpacity(.16))),
        ),
        child: child,
      );

  Widget _textDataCell(String text, double width) => _dataCell(SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: AppColors.gris)),
          ),
        ),
      ));
}
