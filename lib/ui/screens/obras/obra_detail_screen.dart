import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';
import 'package:gestobra/servicios/auth_service.dart';
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
  bool _cargandoDetalle = true;
  String? _errorDetalle;
  String _rolUsuario = '';

  bool get _puedeCrearActividad => const {
    'ADMINISTRADOR',
    'DESARROLLADOR',
    'COORDINADOR_OBRAS',
    'SUPERVISOR',
  }.contains(_rolUsuario);

  bool get _puedeRegistrarAvance =>
      _puedeCrearActividad || _rolUsuario == 'CAPTURISTA';

  int get _obraId =>
      int.tryParse(widget.obra['id_obra']?.toString() ?? '') ?? 0;

  @override
  void initState() {
    super.initState();
    _fases.clear();
    _actividades.clear();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    if (_obraId <= 0) {
      setState(() {
        _cargandoDetalle = false;
        _errorDetalle = 'Esta obra no tiene un ID válido de la base de datos.';
      });
      return;
    }
    setState(() {
      _cargandoDetalle = true;
      _errorDetalle = null;
    });
    try {
      final usuario = await AuthService.obtenerUsuario();
      _rolUsuario = (usuario?['rol'] ?? '').toString();
      final respuestas = await Future.wait([
        ApiService.get('fases_obra.php?id_obra=$_obraId'),
        ApiService.get('actividades.php?id_obra=$_obraId'),
      ]);
      for (final respuesta in respuestas) {
        if (respuesta['estado'] != true) {
          throw Exception(respuesta['mensaje'] ?? 'No se pudo cargar la obra');
        }
      }
      final fasesBase = List<Map<String, dynamic>>.from(
        respuestas[0]['data'] as List,
      );
      final fasesPorId = <String, Map<String, dynamic>>{
        for (final fase in fasesBase) fase['id_fase'].toString(): fase,
      };
      final actividadesBase = List<Map<String, dynamic>>.from(
        respuestas[1]['data'] as List,
      );
      final actividades =
          actividadesBase.map((actividad) {
            final porcentaje =
                (double.tryParse(
                          actividad['porcentaje_avance']?.toString() ?? '',
                        ) ??
                        0)
                    .clamp(0, 100)
                    .toDouble();
            final inicio =
                DateTime.tryParse(
                  actividad['fecha_inicio_programada']?.toString() ?? '',
                ) ??
                DateTime.now();
            final fin =
                DateTime.tryParse(
                  actividad['fecha_fin_programada']?.toString() ?? '',
                ) ??
                inicio;
            final fase = fasesPorId[actividad['id_fase'].toString()];
            final estado =
                (actividad['estado_nombre'] ?? 'PENDIENTE').toString();
            return <String, dynamic>{
              ...actividad,
              'fase': (fase?['nombre'] ?? 'Sin fase').toString().toUpperCase(),
              'estado': estado.replaceAll('_', ' '),
              'titulo': actividad['nombre']?.toString() ?? '',
              'descripcion': actividad['descripcion']?.toString() ?? '',
              'responsable': actividad['responsable_nombre'] ?? 'Sin asignar',
              'fechaInicio': inicio,
              'fechaFin': fin,
              'programado':
                  'Programado ${_formatoFecha(inicio)} al ${_formatoFecha(fin)}',
              'reporte':
                  actividad['ultimo_reporte']?.toString().isNotEmpty == true
                      ? actividad['ultimo_reporte'].toString()
                      : 'Sin reportes de avance',
              'avance': porcentaje / 100,
              'ponderacion': '—',
              'isCompleted':
                  porcentaje >= 100 || estado.toUpperCase().contains('COMPLET'),
            };
          }).toList();
      final fases =
          fasesBase.map((fase) {
            final faseActividades =
                actividadesBase
                    .where(
                      (actividad) =>
                          actividad['id_fase'].toString() ==
                          fase['id_fase'].toString(),
                    )
                    .toList();
            final sumaAvances = faseActividades.fold<double>(
              0,
              (suma, actividad) =>
                  suma +
                  (double.tryParse(
                        actividad['porcentaje_avance']?.toString() ?? '',
                      ) ??
                      0),
            );
            final porcentaje =
                faseActividades.isEmpty
                    ? 0
                    : (sumaAvances / faseActividades.length).round();
            final concluidas =
                faseActividades
                    .where(
                      (actividad) =>
                          (double.tryParse(
                                actividad['porcentaje_avance']?.toString() ??
                                    '',
                              ) ??
                              0) >=
                          100,
                    )
                    .length;
            return <String, dynamic>{
              ...fase,
              'porcentaje': porcentaje,
              'concluidas': concluidas,
              'total': faseActividades.length,
            };
          }).toList();
      if (!mounted) return;
      setState(() {
        _fases
          ..clear()
          ..addAll(fases);
        _actividades
          ..clear()
          ..addAll(actividades);
        _cargandoDetalle = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cargandoDetalle = false;
        _errorDetalle = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _formatoFecha(DateTime fecha) =>
      '${fecha.year}/${fecha.month.toString().padLeft(2, '0')}/${fecha.day.toString().padLeft(2, '0')}';

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  final List<Map<String, dynamic>> _fases = [];
  final List<Map<String, dynamic>> _actividades = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: _buildAppBar(),
      body:
          _isDesktop(context)
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

                          // AQUÍ ESTÁN TUS BOTONES
                          if (_selectedTabIndex == 4 && !_showPipeline) ...[
                            const SizedBox(height: 16),
                            _buildSelectorTiempo(),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTabContent()),
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

                    // AQUÍ ESTÁN TUS BOTONES EN MÓVIL
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
      children:
          opciones.map((opcion) {
            final isSelected = _tipoReporte == opcion;
            return GestureDetector(
              onTap: () => setState(() => _tipoReporte = opcion),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.naranja : AppColors.blanco,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.naranja : AppColors.gris,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  opcion,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.textoGris,
                  ),
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
          Image.asset(
            'assets/images/logo_gestobra.png',
            height: 28,
            errorBuilder:
                (context, error, stackTrace) => const Icon(
                  Icons.construction,
                  color: AppColors.naranja,
                  size: 28,
                ),
          ),
          const SizedBox(width: 8),
          const Text(
            'GestObra',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.naranja,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildObraHeader() {
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
              _buildBadge(
                widget.obra['codigo']?.toString() ?? 'OBRA',
                AppColors.naranja,
                isOutlined: true,
              ),
              const SizedBox(width: 8),
              _buildBadge(
                'OBRA ${(widget.obra['estado'] ?? 'SIN ESTADO').toString().toUpperCase()}',
                Colors.green.shade700,
                isOutlined: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.obra['titulo'] ?? 'Construcción de vivienda 2 plantas',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            widget.obra['cliente'] ?? 'Cliente: Sr. Juan Pérez González',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.naranja,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.obra['descripcion']?.toString().isNotEmpty == true
                ? widget.obra['descripcion'].toString()
                : 'Sin descripción registrada para esta obra.',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.gris,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildIconText(
                Icons.location_on,
                widget.obra['ubicacion']?.toString() ??
                    'Ubicación no registrada',
              ),
              _buildIconText(
                Icons.person,
                widget.obra['residente']?.toString() ?? 'Personal asignado',
              ),
              _buildIconText(
                Icons.calendar_today,
                widget.obra['periodo']?.toString() ?? 'Fechas no registradas',
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
                    Text(
                      'AVANCE GENERAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gris,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.obra['avanceTexto']?.toString() ?? '0%',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.naranja,
                      ),
                    ),
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
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: const LinearProgressIndicator(
                              value: 0.40,
                              backgroundColor: Colors.white,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.naranja,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '4 de 10 concluidas',
                          style: TextStyle(fontSize: 11, color: AppColors.gris),
                        ),
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
        label: const Text(
          'Vista de pipeline',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _showPipeline ? AppColors.naranja : AppColors.noseleccionado,
          foregroundColor: _showPipeline ? Colors.white : AppColors.gris,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = [
      'ACTIVIDADES',
      'BITÁCORA',
      'MATERIALES',
      'EVIDENCIAS',
      'REPORTES',
    ];

    Widget buildTab(int index) {
      final isSelected = !_showPipeline && _selectedTabIndex == index;
      return GestureDetector(
        onTap:
            () => setState(() {
              _selectedTabIndex = index;
              _showPipeline = false;
            }),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.naranja : AppColors.noseleccionado,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              tabs[index],
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.gris,
              ),
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 500) {
          const spacing = 6.0;
          final tabWidth = (constraints.maxWidth - spacing * 2) / 3;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: List.generate(
              tabs.length,
              (index) => SizedBox(width: tabWidth, child: buildTab(index)),
            ),
          );
        }
        return Row(
          children: List.generate(
            tabs.length,
            (index) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: buildTab(index),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final controls = Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [_buildFaseDropdown(), _buildNuevaActividadButton()],
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.blanco,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.bordeSuave),
          ),
          child:
              compact
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Programa y control de actividades',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      controls,
                    ],
                  )
                  : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Text(
                          'Programa y control de actividades',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      controls,
                    ],
                  ),
        );
      },
    );
  }

  Widget _buildFaseDropdown() {
    return SizedBox(
      height: 40,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.noseleccionado,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<String>(
          value: _faseSeleccionada,
          underline: const SizedBox(),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: AppColors.gris,
          ),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.gris,
            fontWeight: FontWeight.bold,
          ),
          items:
              [
                    'Todas las fases',
                    'Preliminares',
                    'Cimentación',
                    'Estructura',
                    'Albañilería',
                  ]
                  .map(
                    (fase) => DropdownMenuItem(value: fase, child: Text(fase)),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _faseSeleccionada = value!),
        ),
      ),
    );
  }

  Widget _buildNuevaActividadButton() {
    if (!_puedeCrearActividad) return const SizedBox.shrink();
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: _abrirModalNuevaActividad,
        icon: const Icon(Icons.add, size: 16),
        label: const Text(
          'Nueva Actividad',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.naranja,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Future<void> _abrirModalNuevaActividad() async {
    if (_obraId <= 0 || _fases.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Se requiere una obra y sus fases cargadas para crear actividades.',
          ),
        ),
      );
      return;
    }
    final creada = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return NuevaActividadModal(
          obraId: _obraId,
          fasesDisponibles: _fases,
          onCrear: () {
            _cargarDetalle();
          },
        );
      },
    );
    if (creada == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actividad creada correctamente')),
      );
    }
  }

  Widget _buildFasesResumen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_cargandoDetalle) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (_errorDetalle != null) return _buildErrorDetalle();
        if (_fases.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Esta obra aún no tiene fases registradas.'),
            ),
          );
        }
        if (constraints.maxWidth > 900) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                _fases
                    .map(
                      (fase) =>
                          SizedBox(width: 200, child: _buildFaseCard(fase)),
                    )
                    .toList(),
          );
        }

        const spacing = 8.0;
        final columns = constraints.maxWidth < 360 ? 1 : 2;
        final cardWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children:
              _fases
                  .map(
                    (fase) =>
                        SizedBox(width: cardWidth, child: _buildFaseCard(fase)),
                  )
                  .toList(),
        );
      },
    );
  }

  Widget _buildFaseCard(Map<String, dynamic> fase) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordeSuave),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${fase['porcentaje']}%',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  fase['porcentaje'] == 100 ? Colors.green : AppColors.naranja,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            fase['nombre'],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${fase['concluidas']} de ${fase['total']} concluidas',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: AppColors.gris),
          ),
        ],
      ),
    );
  }

  Future<void> _registrarAvance(Map<String, dynamic> actividad) async {
    final idActividad =
        int.tryParse(actividad['id_actividad']?.toString() ?? '') ?? 0;
    if (idActividad <= 0) return;
    final avanceActual = ((actividad['avance'] as num?)?.toDouble() ?? 0) * 100;
    final porcentajeController = TextEditingController(
      text: avanceActual.toStringAsFixed(0),
    );
    final observacionesController = TextEditingController();
    final confirmado = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Registrar avance'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: porcentajeController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Avance (%)',
                    hintText: '0 a 100',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: observacionesController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Observaciones'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
    if (confirmado != true || !mounted) {
      porcentajeController.dispose();
      observacionesController.dispose();
      return;
    }
    final porcentaje = double.tryParse(porcentajeController.text.trim());
    porcentajeController.dispose();
    if (porcentaje == null || porcentaje < 0 || porcentaje > 100) {
      observacionesController.dispose();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El avance debe ser un número entre 0 y 100.'),
        ),
      );
      return;
    }
    try {
      final observaciones = observacionesController.text.trim();
      observacionesController.dispose();
      final respuesta = await ApiService.post('actividad_avance.php', {
        'id_actividad': idActividad,
        'porcentaje_nuevo': porcentaje,
        'observaciones': observaciones,
      });
      if (respuesta['estado'] != true) {
        throw Exception(
          respuesta['mensaje'] ?? 'No se pudo registrar el avance',
        );
      }
      await _cargarDetalle();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avance registrado correctamente')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar el avance: $error')),
      );
    }
  }

  Widget _buildActividadCard(Map<String, dynamic> actividad) {
    final estado = (actividad['estado'] ?? 'PENDIENTE').toString();
    final avance = (actividad['avance'] as num?)?.toDouble() ?? 0;
    final completada = actividad['isCompleted'] == true || avance >= 1;
    final enProgreso =
        !completada &&
        (avance > 0 || estado.toUpperCase().contains('PROGRESO'));
    final colorEstado =
        completada
            ? Colors.green.shade700
            : enProgreso
            ? AppColors.naranja
            : AppColors.gris;
    final iconoEstado =
        completada
            ? Icons.check
            : enProgreso
            ? Icons.timelapse
            : Icons.schedule;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordeSuave),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildBadge(
                actividad['fase'],
                AppColors.naranja,
                isOutlined: true,
              ),
              const SizedBox(width: 8),
              _buildBadge(estado, colorEstado, icon: iconoEstado),
              const Spacer(),
              Text(
                'Ponderación ${actividad['ponderacion']}',
                style: const TextStyle(fontSize: 10, color: AppColors.gris),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            actividad['titulo'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            actividad['descripcion'],
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.gris,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          _buildIconText(Icons.person, actividad['responsable']),
          const SizedBox(height: 4),
          _buildIconText(Icons.calendar_today, actividad['programado']),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.naranja.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.naranja.withOpacity(0.3)),
            ),
            child: Text(
              'Último reporte: "${actividad['reporte']}"',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.naranja,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Avance actual',
                      style: TextStyle(fontSize: 10, color: AppColors.gris),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: actividad['avance'],
                                backgroundColor: Colors.grey.shade100,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  actividad['isCompleted']
                                      ? Colors.green
                                      : AppColors.naranja,
                                ),
                                minHeight: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(actividad['avance'] * 100).toInt()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed:
                    _puedeRegistrarAvance
                        ? () => _registrarAvance(actividad)
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.naranja,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Registrar avance',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActividadesSection() {
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
          if (_cargandoDetalle)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_errorDetalle != null)
            _buildErrorDetalle()
          else if (_actividades.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Esta obra aún no tiene actividades.')),
            )
          else
            ..._actividades.map((actividad) => _buildActividadCard(actividad)),
        ],
      ),
    );
  }

  Widget _buildErrorDetalle() => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_errorDetalle!, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _cargarDetalle,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      ],
    ),
  );

  Widget _buildBadge(
    String text,
    Color color, {
    bool isOutlined = false,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: isOutlined ? Border.all(color: color) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
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
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 11, color: AppColors.gris),
            overflow: TextOverflow.ellipsis,
          ),
        ),
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
          if (_cargandoDetalle)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_errorDetalle != null)
            _buildErrorDetalle()
          else
            PipelineActividadesSection(
              actividades: _actividades,
              fases: _fases,
              faseSeleccionada: _faseSeleccionada,
            ),
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
            _buildFasesResumen(),
            const SizedBox(height: 20),
            _buildActividadesSection(),
          ],
        ),
        BitacoraSection(obra: widget.obra),
        MaterialesSection(obra: widget.obra),
        EvidenciasSection(obra: widget.obra),
        ReportesSection(obra: widget.obra, tipoReporteInicial: _tipoReporte),
      ],
    );
  }
}
