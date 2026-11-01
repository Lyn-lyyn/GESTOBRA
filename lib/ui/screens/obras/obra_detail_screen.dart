import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';
import 'sections/bitacora_section.dart';
import 'sections/materiales_section.dart';
import 'sections/evidencias_section.dart';
import 'sections/reportes_section.dart';
import 'widgets/nueva_actividad_modal.dart';
import 'sections/pipeline_actividades_section.dart';

class ObraDetailScreen extends StatefulWidget {
  final Map<String, dynamic> obra;

  const ObraDetailScreen({super.key, required this.obra});

  @override
  State<ObraDetailScreen> createState() => _ObraDetailScreenState();
}

class _ObraDetailScreenState extends State<ObraDetailScreen> {
  int _selectedTabIndex = 0;
  bool _showPipeline = false;
  String _faseSeleccionada = 'Todas las fases';
  String _tipoReporte = 'Semanal';

  bool _cargando = true;
  List<Map<String, dynamic>> _fases = [];
  List<Map<String, dynamic>> _actividades = [];

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  @override
  void initState() {
    super.initState();
    _cargarDatosObra();
  }

  Future<void> _cargarDatosObra() async {
    final idObra = widget.obra['id_obra'];
    if (idObra == null) {
      setState(() => _cargando = false);
      return;
    }

    setState(() => _cargando = true);

    final resFases = await ApiService.get('fases_obra.php?id_obra=$idObra');
    final resActs = await ApiService.get('actividades.php?id_obra=$idObra');

    if (resFases['estado'] == true && resActs['estado'] == true) {
      setState(() {
        _fases = List<Map<String, dynamic>>.from(resFases['data']);
        
        _actividades = List<Map<String, dynamic>>.from(resActs['data']).map((a) {
          // Validar que las fechas no vengan nulas
          DateTime fi = DateTime.now();
          DateTime ff = DateTime.now();
          if (a['fecha_inicio_programada'] != null) fi = DateTime.parse(a['fecha_inicio_programada']);
          if (a['fecha_fin_programada'] != null) ff = DateTime.parse(a['fecha_fin_programada']);

          final strFi = '${fi.year}/${fi.month.toString().padLeft(2, '0')}/${fi.day.toString().padLeft(2, '0')}';
          final strFf = '${ff.year}/${ff.month.toString().padLeft(2, '0')}/${ff.day.toString().padLeft(2, '0')}';

          return {
            'id_actividad': a['id_actividad'],
            'fase': a['fase_nombre'] ?? 'Sin fase', 
            'estado': a['estado_nombre'],
            'titulo': a['nombre'],
            'descripcion': a['descripcion'] ?? 'Sin descripción',
            'responsable': a['responsable_nombre'] ?? 'Sin asignar',
            'programado': 'Programado $strFi al $strFf',
            'fechaInicio': fi,
            'fechaFin': ff,
            'reporte': 'Sin reportes recientes',
            'avance': (double.tryParse(a['porcentaje_avance'].toString()) ?? 0.0) / 100.0,
            'isCompleted': a['porcentaje_avance'] == 100,
            'ponderacion': '5%',
          };
        }).toList();
        
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
      _showError('Error al cargar datos');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.estadoRojo));
  }

  // ─── Helper para formatear fechas de MySQL (YYYY-MM-DD) a visual (DD/MM/YYYY) ───
  String _formatearFecha(String? fechaStr) {
    if (fechaStr == null || fechaStr.isEmpty || fechaStr == 'Sin fecha' || fechaStr == '--') return fechaStr ?? 'Sin fecha';
    try {
      final f = DateTime.parse(fechaStr);
      return '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
    } catch (_) {
      return fechaStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: _buildAppBar(),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _isDesktop(context)
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 420,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildObraHeader(),
                            const SizedBox(height: 16),
                            _buildPipelineButton(),
                            const SizedBox(height: 12),
                            _buildTabs(),
                            if (_selectedTabIndex == 4 && !_showPipeline) ...[
                              const SizedBox(height: 16),
                              _buildSelectorTiempo(),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTabContent(),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildObraHeader(),
                      const SizedBox(height: 16),
                      _buildPipelineButton(),
                      const SizedBox(height: 12),
                      _buildTabs(),
                      if (_selectedTabIndex == 4 && !_showPipeline) ...[
                        const SizedBox(height: 16),
                        _buildSelectorTiempo(),
                      ],
                      const SizedBox(height: 16),
                      _buildTabContent(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSelectorTiempo() {
    final opciones = ['Diario', 'Semanal', 'Quincenal', 'Acumulado'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: opciones.map((opcion) {
        final isSelected = _tipoReporte == opcion;
        return GestureDetector(
          onTap: () => setState(() => _tipoReporte = opcion),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.naranja : AppColors.blanco,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? AppColors.naranja : AppColors.gris, width: 1.2),
            ),
            child: Text(
              opcion,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textoGris),
            ),
          ),
        );
      }).toList(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Image.asset('assets/images/logo_gestobra.png', height: 28,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.construction, color: AppColors.naranja, size: 28)),
          const SizedBox(width: 8),
          const Text('GestObra', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.naranja), onPressed: () {}),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildObraHeader() {
    final rawAvance = widget.obra['avance_general']?.toString() ?? '0';
    final double avanceVal = double.tryParse(rawAvance) ?? ((widget.obra['avance'] ?? 0) * 100);

    return Container(
      width: double.infinity,
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
              _buildBadge(widget.obra['codigo'] ?? 'OBRA', AppColors.naranja, isOutlined: true),
              const SizedBox(width: 8),
              _buildBadge(widget.obra['estado'] ?? 'EN EJECUCIÓN', Colors.green.shade700, isOutlined: true),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.obra['titulo'] ?? 'Sin título',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            widget.obra['cliente'] ?? 'Sin cliente',
            style: const TextStyle(fontSize: 12, color: AppColors.naranja, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            widget.obra['descripcion'] ?? 'Sin descripción',
            style: const TextStyle(fontSize: 12, color: AppColors.gris, height: 1.4),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildIconText(Icons.location_on, widget.obra['ubicacion'] ?? 'Sin ubicación'),
              _buildIconText(Icons.person, 'Ver asignaciones'),
              _buildIconText(Icons.calendar_today, 
                '${_formatearFecha(widget.obra['fechaInicio'])} al ${_formatearFecha(widget.obra['fechaTermino'])}'
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.bordeSuave),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('AVANCE GENERAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.gris)),
                    const SizedBox(height: 4),
                    Text('${avanceVal.toInt()}%', 
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.naranja)),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: avanceVal / 100,
                              backgroundColor: Colors.white,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.naranja),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text('Avance calculado automáticamente', style: TextStyle(fontSize: 11, color: AppColors.gris)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () => setState(() => _showPipeline = true),
        icon: const Icon(Icons.view_timeline_outlined, size: 19),
        label: const Text('Vista de pipeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _showPipeline ? AppColors.naranja : AppColors.noseleccionado,
          foregroundColor: _showPipeline ? Colors.white : AppColors.gris,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['ACTIVIDADES', 'BITÁCORA', 'MATERIALES', 'EVIDENCIAS', 'REPORTES'];
    return Row(
      children: List.generate(tabs.length, (index) {
        final isSelected = !_showPipeline && _selectedTabIndex == index;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: GestureDetector(
              onTap: () => setState(() { _selectedTabIndex = index; _showPipeline = false; }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.naranja : AppColors.noseleccionado,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(tabs[index], textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.gris)),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActionBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.bordeSuave)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(child: Text('Programa y control de actividades', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFaseDropdown(),
              const SizedBox(width: 8),
              _buildNuevaActividadButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFaseDropdown() {
    final fasesNombres = ['Todas las fases', ..._fases.map((f) => f['nombre'].toString())];
    
    if (!fasesNombres.contains(_faseSeleccionada)) {
      _faseSeleccionada = 'Todas las fases';
    }

    return SizedBox(
      height: 40,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: AppColors.noseleccionado, borderRadius: BorderRadius.circular(8)),
        child: DropdownButton<String>(
          value: _faseSeleccionada,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.gris),
          style: const TextStyle(fontSize: 12, color: AppColors.gris, fontWeight: FontWeight.bold),
          items: fasesNombres.map((fase) => DropdownMenuItem(value: fase, child: Text(fase))).toList(),
          onChanged: (value) => setState(() => _faseSeleccionada = value!),
        ),
      ),
    );
  }

  Widget _buildNuevaActividadButton() {
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: _abrirModalNuevaActividad,
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Nueva Actividad', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      ),
    );
  }

  void _abrirModalNuevaActividad() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return NuevaActividadModal(
          idObra: widget.obra['id_obra'],
          fasesDisponibles: _fases,
          onCrear: (nuevaActividad) {
            _cargarDatosObra();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Actividad creada correctamente'), backgroundColor: Colors.green));
          },
        );
      },
    );
  }

  Widget _buildFasesResumen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;
        if (isDesktop) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _fases.map((fase) => SizedBox(width: 200, child: _buildFaseCard(fase))).toList(),
          );
        }
        return Row(
          children: _fases.map((fase) => Expanded(child: _buildFaseCard(fase))).toList(),
        );
      },
    );
  }

  Widget _buildFaseCard(Map<String, dynamic> fase) {
    final actsFase = _actividades.where((a) => a['fase'] == fase['nombre']).toList();
    final concluidas = actsFase.where((a) => a['isCompleted'] == true).length;
    final total = actsFase.length;
    final porcentaje = total == 0 ? 0 : ((concluidas / total) * 100).round();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.bordeSuave)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$porcentaje%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: porcentaje == 100 ? Colors.green : AppColors.naranja)),
          const SizedBox(height: 4),
          Text(fase['nombre'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('$concluidas de $total concluidas', textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: AppColors.gris)),
        ],
      ),
    );
  }

  Widget _buildActividadCard(Map<String, dynamic> actividad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.bordeSuave)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildBadge(actividad['fase'], AppColors.naranja, isOutlined: true),
              const SizedBox(width: 8),
              _buildBadge(actividad['estado'], Colors.green.shade700, icon: Icons.check),
              const Spacer(),
              Text('Ponderación ${actividad['ponderacion']}', style: const TextStyle(fontSize: 10, color: AppColors.gris)),
            ],
          ),
          const SizedBox(height: 12),
          Text(actividad['titulo'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text(actividad['descripcion'], style: const TextStyle(fontSize: 12, color: AppColors.gris, height: 1.4)),
          const SizedBox(height: 12),
          _buildIconText(Icons.person, actividad['responsable']),
          const SizedBox(height: 4),
          _buildIconText(Icons.calendar_today, actividad['programado']),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.naranja.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.naranja.withOpacity(0.3))),
            child: Text('Último reporte: "${actividad['reporte']}"', style: const TextStyle(fontSize: 11, color: AppColors.naranja, fontStyle: FontStyle.italic)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Avance actual', style: TextStyle(fontSize: 10, color: AppColors.gris)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: actividad['avance'],
                                backgroundColor: Colors.grey.shade100,
                                valueColor: AlwaysStoppedAnimation<Color>(actividad['isCompleted'] ? Colors.green : AppColors.naranja),
                                minHeight: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${(actividad['avance'] * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.naranja, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                child: const Text('Editar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActividadesSection() {
    final actsFiltradas = _faseSeleccionada == 'Todas las fases' 
        ? _actividades 
        : _actividades.where((a) => a['fase'] == _faseSeleccionada).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.bordeSuave)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (actsFiltradas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('No hay actividades registradas', style: TextStyle(color: AppColors.textoGris))),
            )
          else
            ...actsFiltradas.map((actividad) => _buildActividadCard(actividad)),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color, {bool isOutlined = false, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: isOutlined ? Colors.transparent : color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: isOutlined ? Border.all(color: color) : null),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: color), const SizedBox(width: 4)],
          Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.gris),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.gris), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildTabContent() {
    if (_showPipeline) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActionBar(),
          const SizedBox(height: 16),
          PipelineActividadesSection(actividades: _actividades, fases: _fases, faseSeleccionada: _faseSeleccionada),
        ],
      );
    }

    return IndexedStack(
      index: _selectedTabIndex,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionBar(),
            const SizedBox(height: 16),
            if (_fases.isNotEmpty) _buildFasesResumen(),
            const SizedBox(height: 20),
            _buildActividadesSection(),
          ],
        ),
        BitacoraSection(obra: widget.obra),
        MaterialesSection(obra: widget.obra),
        EvidenciasSection(obra: widget.obra, fasesDisponibles: _fases),
        ReportesSection(obra: widget.obra, tipoReporteInicial: _tipoReporte),
      ],
    );
  }
}