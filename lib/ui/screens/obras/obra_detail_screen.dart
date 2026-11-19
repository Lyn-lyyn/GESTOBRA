import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // ─── Estado ───
  int _selectedTabIndex = 0;
  bool _showPipeline = false;
  String _faseSeleccionada = 'Todas las fases';
  String _tipoReporte = 'Semanal';

  DateTimeRange? _rangoPersonalizado;

  bool _cargando = true;
  String? _errorDetalle;
  String _rolUsuario = '';

  final List<Map<String, dynamic>> _fases = [];
  final List<Map<String, dynamic>> _actividades = [];

  // ─── Permisos ───
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
    _cargarDetalle();
  }

  // ─── Carga de Datos ───
  Future<void> _cargarDetalle() async {
    if (_obraId <= 0) {
      setState(() {
        _cargando = false;
        _errorDetalle = 'Esta obra no tiene un ID válido.';
      });
      return;
    }

    setState(() {
      _cargando = true;
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

      final fasesBase =
          List<Map<String, dynamic>>.from(respuestas[0]['data'] as List);
      final fasesPorId = {
        for (var fase in fasesBase) fase['id_fase'].toString(): fase
      };

      final actividadesBase =
          List<Map<String, dynamic>>.from(respuestas[1]['data'] as List);

      final actividades = actividadesBase.map((actividad) {
        final porcentaje = (double.tryParse(
                    actividad['porcentaje_avance']?.toString() ?? '') ??
                0)
            .clamp(0, 100)
            .toDouble();
        final inicio = DateTime.tryParse(
                actividad['fecha_inicio_programada']?.toString() ?? '') ??
            DateTime.now();
        final fin = DateTime.tryParse(
                actividad['fecha_fin_programada']?.toString() ?? '') ??
            inicio;
        final fase = fasesPorId[actividad['id_fase'].toString()];
        final estado = (actividad['estado_nombre'] ?? 'PENDIENTE').toString();

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
          'reporte': actividad['ultimo_reporte']?.toString().isNotEmpty == true
              ? actividad['ultimo_reporte'].toString()
              : 'Sin reportes de avance',
          'avance': porcentaje / 100,
          'ponderacion': '—',
          'isCompleted':
              porcentaje >= 100 || estado.toUpperCase().contains('COMPLET'),
        };
      }).toList();

      final fases = fasesBase.map((fase) {
        final faseActividades = actividadesBase
            .where((a) =>
                a['id_fase'].toString() == fase['id_fase'].toString())
            .toList();
        final sumaAvances = faseActividades.fold<double>(
            0,
            (suma, a) =>
                suma +
                (double.tryParse(a['porcentaje_avance']?.toString() ?? '') ??
                    0));
        final porcentaje = faseActividades.isEmpty
            ? 0
            : (sumaAvances / faseActividades.length).round();
        final concluidas = faseActividades
            .where((a) =>
                (double.tryParse(a['porcentaje_avance']?.toString() ?? '') ??
                    0) >=
                100)
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
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _errorDetalle = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ─── Registrar Avance ───
  Future<void> _registrarAvance(Map<String, dynamic> actividad) async {
    final idActividad =
        int.tryParse(actividad['id_actividad']?.toString() ?? '') ?? 0;
    if (idActividad <= 0) return;

    final avanceActual = ((actividad['avance'] as num?)?.toDouble() ?? 0) * 100;
    final porcentajeController =
        TextEditingController(text: avanceActual.toStringAsFixed(0));
    final observacionesController = TextEditingController();

    final confirmado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          bool guardando = false;
          return Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: AppColors.grisfondo,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: AppColors.naranja,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.trending_up,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Registrar avance',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed:
                              guardando ? null : () => Navigator.pop(ctx, false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Actividad: ${actividad['titulo']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 16),
                    const Text('Avance (%) *',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.naranja)),
                      child: TextFormField(
                        controller: porcentajeController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                            hintText: 'Ej. 50',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            isDense: true),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Observaciones',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.naranja)),
                      child: TextFormField(
                        controller: observacionesController,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                            hintText: 'Ej. Se terminó la cimentación',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            isDense: true),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed:
                              guardando ? null : () => Navigator.pop(ctx, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.gris,
                            side: const BorderSide(color: AppColors.bordeSuave),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('CANCELAR',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: guardando
                              ? null
                              : () async {
                                  final porcentaje = double.tryParse(
                                      porcentajeController.text.trim());
                                  if (porcentaje == null ||
                                      porcentaje < 0 ||
                                      porcentaje > 100) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'El avance debe ser un número entre 0 y 100.')));
                                    return;
                                  }

                                  setModal(() => guardando = true);

                                  try {
                                    final respuesta = await ApiService.post(
                                        'actividad_avance.php', {
                                      'id_actividad': idActividad,
                                      'porcentaje_nuevo': porcentaje,
                                      'observaciones':
                                          observacionesController.text.trim(),
                                    });

                                    if (respuesta['estado'] != true) {
                                      throw Exception(respuesta['mensaje'] ??
                                          'No se pudo registrar el avance');
                                    }

                                    Navigator.pop(ctx, true);
                                  } catch (error) {
                                    setModal(() => guardando = false);
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                        SnackBar(
                                            content: Text('Error: $error'),
                                            backgroundColor:
                                                AppColors.estadoRojo));
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.naranja,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: guardando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('GUARDAR',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    porcentajeController.dispose();
    observacionesController.dispose();

    if (confirmado == true && mounted) {
      await _cargarDetalle();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Avance registrado correctamente'),
              backgroundColor: Colors.green),
        );
      }
    }
  }

  // ─── Helpers ───
  String _formatoFecha(DateTime fecha) =>
      '${fecha.year}/${fecha.month.toString().padLeft(2, '0')}/${fecha.day.toString().padLeft(2, '0')}';

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  String _formatearFecha(String? fechaStr) {
    if (fechaStr == null ||
        fechaStr.isEmpty ||
        fechaStr == 'Sin fecha' ||
        fechaStr == '--') {
      return fechaStr ?? 'Sin fecha';
    }
    try {
      final f = DateTime.parse(fechaStr);
      return '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
    } catch (_) {
      return fechaStr;
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.estadoRojo));
  }

  // ─── Build Principal ───
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
                      Expanded(child: _buildTabContent()),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  // En móvil reducimos un poco el padding general
                  padding: const EdgeInsets.all(12.0),
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

  // ─── Selector de tiempo ───
  Widget _buildSelectorTiempo() {
    final opciones = [
      'Diario',
      'Semanal',
      'Quincenal',
      'Acumulado',
      'Personalizado',
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // En móvil, hacemos que los botones ocupen el ancho disponible de forma equitativa
        final isMobile = constraints.maxWidth < 500;

        if (isMobile) {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: opciones.map((opcion) {
              final isSelected = _tipoReporte == opcion;
              return GestureDetector(
                onTap: () async {
                  await _handleSelectorTap(opcion);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.naranja : AppColors.blanco,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.naranja : AppColors.gris,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (opcion == 'Personalizado')
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.date_range,
                            size: 12,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textoGris,
                          ),
                        ),
                      Text(
                        opcion,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textoGris,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: opciones.map((opcion) {
            final isSelected = _tipoReporte == opcion;
            return GestureDetector(
              onTap: () async {
                await _handleSelectorTap(opcion);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.naranja : AppColors.blanco,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.naranja : AppColors.gris,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (opcion == 'Personalizado')
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.date_range,
                          size: 14,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textoGris,
                        ),
                      ),
                    Text(
                      opcion,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            isSelected ? Colors.white : AppColors.textoGris,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _handleSelectorTap(String opcion) async {
    if (opcion == 'Personalizado') {
      final ThemeData originalTheme = Theme.of(context);

      // ─── FORZAMOS EL CALENDARIO FLOTANTE Y EN 2 COLUMNAS ───
      final DateTimeRange? picked = await showDialog<DateTimeRange>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              // Estas medidas fuerzan la vista de 2 columnas (la de tu primera foto)
              constraints: const BoxConstraints(
                maxWidth: 560, 
                maxHeight: 640,
              ),
              child: Theme(
                data: originalTheme.copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.naranja, // Círculo naranja
                    onPrimary: Colors.white,
                    surface: Colors.white, // Fondo blanco
                    onSurface: Colors.black87, // Texto negro
                  ),
                  dialogBackgroundColor: Colors.white,
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.naranja, // Botones inferiores
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Aquí aplicamos los estilos específicos para que se vea idéntico a tu foto
                  datePickerTheme: DatePickerThemeData(
                    backgroundColor: Colors.white,
                    headerBackgroundColor: Colors.white,
                    headerForegroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    // El naranja claro para cuando seleccionas varios días
                    rangeSelectionBackgroundColor: AppColors.naranja.withOpacity(0.2),
                    todayForegroundColor: WidgetStateProperty.all(AppColors.naranja),
                    // Estilo de los textos superiores (fecha seleccionada)
                    headerHeadlineStyle: const TextStyle(
                      fontSize: 24, // Más grande como en tu foto
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    headerHelpStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Usamos el diálogo nativo pero forzado dentro de nuestro ConstrainedBox
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: DateRangePickerDialog(
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDateRange: _rangoPersonalizado,
                    currentDate: DateTime.now(),
                    helpText: 'Selecciona una fecha',
                    cancelText: 'Cancelar',
                    confirmText: 'ACEPTAR',
                    fieldStartLabelText: 'Fecha inicio',
                    fieldEndLabelText: 'Fecha fin',
                    fieldStartHintText: 'dd/mm/aaaa',
                    fieldEndHintText: 'dd/mm/aaaa',
                  ),
                ),
              ),
            ),
          );
        },
      );

      if (picked != null) {
        setState(() {
          _rangoPersonalizado = picked;
          _tipoReporte = opcion;
        });
      }
    } else {
      setState(() {
        _tipoReporte = opcion;
        _rangoPersonalizado = null;
      });
    }
  }

  // ─── Widgets de UI ───
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
            errorBuilder: (_, __, ___) => const Icon(Icons.construction,
                color: AppColors.naranja, size: 28),
          ),
          const SizedBox(width: 8),
          const Text('GestObra',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
        ],
      ),
      actions: [
        IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.naranja),
            onPressed: () {}),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildObraHeader() {
    final rawAvance = widget.obra['avance_general']?.toString() ?? '0';
    final double avanceVal =
        double.tryParse(rawAvance) ?? ((widget.obra['avance'] ?? 0) * 100);

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
              _buildBadge(widget.obra['codigo'] ?? 'OBRA', AppColors.naranja,
                  isOutlined: true),
              const SizedBox(width: 8),
              _buildBadge(widget.obra['estado'] ?? 'EN EJECUCIÓN',
                  Colors.green.shade700,
                  isOutlined: true),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.obra['titulo'] ?? 'Sin título',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 4),
          Text(widget.obra['cliente'] ?? 'Sin cliente',
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.naranja,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(widget.obra['descripcion'] ?? 'Sin descripción',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.gris, height: 1.4)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildIconText(Icons.location_on,
                  widget.obra['ubicacion'] ?? 'Sin ubicación'),
              _buildIconText(Icons.person, 'Ver asignaciones'),
              _buildIconText(
                  Icons.calendar_today,
                  '${_formatearFecha(widget.obra['fechaInicio'])} al '
                      '${_formatearFecha(widget.obra['fechaTermino'])}'),
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
                    const Text('AVANCE GENERAL',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gris)),
                    const SizedBox(height: 4),
                    Text('${avanceVal.toInt()}%',
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.naranja)),
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
                              borderRadius: BorderRadius.circular(4)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: avanceVal / 100,
                              backgroundColor: Colors.white,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.naranja),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text('Avance calculado automáticamente',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.gris)),
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
        label: const Text('Vista de pipeline',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _showPipeline ? AppColors.naranja : AppColors.noseleccionado,
          foregroundColor: _showPipeline ? Colors.white : AppColors.gris,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      'REPORTES'
    ];

    Widget buildTab(int index) {
      final isSelected = !_showPipeline && _selectedTabIndex == index;
      return GestureDetector(
        onTap: () => setState(() {
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
                  color: isSelected ? Colors.white : AppColors.gris),
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // En móvil, si la pantalla es menor a 500px, usamos 2 filas
        if (constraints.maxWidth < 500) {
          const spacing = 6.0;
          final tabWidth = (constraints.maxWidth - spacing * 2) / 3;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: List.generate(
                tabs.length,
                (index) =>
                    SizedBox(width: tabWidth, child: buildTab(index))),
          );
        }
        return Row(
          children: List.generate(
              tabs.length,
              (index) => Expanded(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: buildTab(index)))),
        );
      },
    );
  }

  // ─── Action bar responsive mejorado para móviles ───
  Widget _buildActionBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;

        // Alineamos el dropdown y el botón para que no dejen huecos
        final controls = Row(
          children: [
            Expanded(
              child: _buildFaseDropdown(),
            ),
            const SizedBox(width: 8),
            if (_puedeCrearActividad)
              Expanded(
                child: _buildNuevaActividadButton(),
              ),
          ],
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.blanco,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.bordeSuave),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Programa y control de actividades',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 340, // Ancho fijo para escritorio
                      child: controls,
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildFaseDropdown() {
    final fasesNombres = [
      'Todas las fases',
      ..._fases.map((f) => f['nombre'].toString())
    ];
    if (!fasesNombres.contains(_faseSeleccionada)) {
      _faseSeleccionada = 'Todas las fases';
    }

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: AppColors.noseleccionado,
          borderRadius: BorderRadius.circular(8)),
      child: DropdownButton<String>(
        value: _faseSeleccionada,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down,
            size: 18, color: AppColors.gris),
        style: const TextStyle(
            fontSize: 12, color: AppColors.gris, fontWeight: FontWeight.bold),
        items: fasesNombres
            .map((fase) => DropdownMenuItem(
                  value: fase,
                  child: Text(fase, overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: (value) => setState(() => _faseSeleccionada = value!),
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
        label: const Text('Nueva Actividad',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.naranja,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8))),
      ),
    );
  }

  Future<void> _abrirModalNuevaActividad() async {
    if (_obraId <= 0 || _fases.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Se requiere una obra y sus fases cargadas para crear actividades.')));
      return;
    }
    await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return NuevaActividadModal(
          idObra: widget.obra['id_obra'],
          fasesDisponibles: _fases,
          onCrear: (nuevaActividad) {
            _cargarDetalle();
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                content: Text('Actividad creada correctamente'),
                backgroundColor: Colors.green));
          },
        );
      },
    );
  }

  Widget _buildFasesResumen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_cargando) {
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

        // En escritorio mantenemos un ancho fijo o fluido
        if (constraints.maxWidth > 900) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _fases
                .map((fase) =>
                    SizedBox(width: 200, child: _buildFaseCard(fase)))
                .toList(),
          );
        }

        // En móvil, mostramos las tarjetas al 100% de ancho para que respiren mejor
        const spacing = 8.0;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _fases
              .map((fase) => SizedBox(
                  width: constraints.maxWidth, child: _buildFaseCard(fase)))
              .toList(),
        );
      },
    );
  }

  Widget _buildFaseCard(Map<String, dynamic> fase) {
    final int porcentaje;
    final int concluidas;
    final int total;

    if (fase.containsKey('porcentaje') &&
        fase.containsKey('concluidas') &&
        fase.containsKey('total')) {
      porcentaje = (fase['porcentaje'] as num?)?.toInt() ?? 0;
      concluidas = (fase['concluidas'] as num?)?.toInt() ?? 0;
      total = (fase['total'] as num?)?.toInt() ?? 0;
    } else {
      final actsFase =
          _actividades.where((a) => a['fase'] == fase['nombre']).toList();
      concluidas = actsFase.where((a) => a['isCompleted'] == true).length;
      total = actsFase.length;
      porcentaje = total == 0 ? 0 : ((concluidas / total) * 100).round();
    }

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 0), // Sin margen extra, usamos spacing
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.blanco,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.bordeSuave)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$porcentaje%',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      porcentaje == 100 ? Colors.green : AppColors.naranja)),
          const SizedBox(height: 4),
          Text(fase['nombre'],
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('$concluidas de $total concluidas',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, color: AppColors.gris)),
        ],
      ),
    );
  }

  Widget _buildActividadCard(Map<String, dynamic> actividad) {
    final estado = (actividad['estado'] ?? 'PENDIENTE').toString();
    final avance = (actividad['avance'] as num?)?.toDouble() ?? 0;
    final completada = actividad['isCompleted'] == true || avance >= 1;
    final enProgreso =
        !completada && (avance > 0 || estado.toUpperCase().contains('PROGRESO'));

    final colorEstado = completada
        ? Colors.green.shade700
        : enProgreso
            ? AppColors.naranja
            : AppColors.gris;
    final iconoEstado = completada
        ? Icons.check
        : enProgreso
            ? Icons.timelapse
            : Icons.schedule;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 450;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.bordeSuave)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                // Usamos Wrap para que los badges bajen de línea si no caben
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildBadge(actividad['fase'], AppColors.naranja,
                      isOutlined: true),
                  _buildBadge(estado, colorEstado, icon: iconoEstado),
                ],
              ),
              const SizedBox(height: 12),
              Text(actividad['titulo'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Text(actividad['descripcion'],
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.gris, height: 1.4)),
              const SizedBox(height: 12),
              _buildIconText(Icons.person, actividad['responsable']),
              const SizedBox(height: 4),
              _buildIconText(Icons.calendar_today, actividad['programado']),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.naranja.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.naranja.withValues(alpha: 0.3))),
                child: Text('Último reporte: "${actividad['reporte']}"',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.naranja,
                        fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: 16),
              // En móvil, el botón de avance baja y ocupa todo el ancho
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAvanceInfo(actividad),
                    const SizedBox(height: 12),
                    _buildBotonAvance(actividad),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(child: _buildAvanceInfo(actividad)),
                    const SizedBox(width: 16),
                    _buildBotonAvance(actividad),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  // Separamos la info de avance para no repetir código
  Widget _buildAvanceInfo(Map<String, dynamic> actividad) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Avance actual',
            style: TextStyle(fontSize: 10, color: AppColors.gris)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: actividad['avance'],
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        actividad['isCompleted'] == true
                            ? Colors.green
                            : AppColors.naranja),
                    minHeight: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('${(actividad['avance'] * 100).toInt()}%',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  // Separamos el botón para no repetir código
  Widget _buildBotonAvance(Map<String, dynamic> actividad) {
    return ElevatedButton(
      onPressed:
          _puedeRegistrarAvance ? () => _registrarAvance(actividad) : null,
      style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.naranja,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20))),
      child: const Text('Registrar avance',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActividadesSection() {
    final actsFiltradas = _faseSeleccionada == 'Todas las fases'
        ? _actividades
        : _actividades
            .where((a) =>
                a['fase'].toString().toUpperCase() ==
                _faseSeleccionada.toUpperCase())
            .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.blanco,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.bordeSuave)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_cargando)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_errorDetalle != null)
            _buildErrorDetalle()
          else if (actsFiltradas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                  child: Text('No hay actividades registradas',
                      style: TextStyle(color: AppColors.textoGris))),
            )
          else
            ...actsFiltradas
                .map((actividad) => _buildActividadCard(actividad)),
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

  Widget _buildBadge(String text, Color color,
      {bool isOutlined = false, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: isOutlined ? Border.all(color: color) : null),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4)
          ],
          Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold, color: color)),
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
            child: Text(text,
                style: const TextStyle(fontSize: 11, color: AppColors.gris),
                overflow: TextOverflow.ellipsis)),
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
          if (_cargando)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator()))
          else if (_errorDetalle != null)
            _buildErrorDetalle()
          else
            PipelineActividadesSection(
                actividades: _actividades,
                fases: _fases,
                faseSeleccionada: _faseSeleccionada),
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
        EvidenciasSection(obra: widget.obra),
        // AQUÍ PASAMOS LAS FASES REALES AL REPORTE
        ReportesSection(
          obra: widget.obra,
          tipoReporteInicial: _tipoReporte,
          rangoPersonalizado: _rangoPersonalizado,
          fasesReales: _fases,
        ),
      ],
    );
  }
}

// ============================================================================
// --- CLASE PARA EL AUTO-FORMATO DE FECHAS CON "/" ---
// ============================================================================
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) return newValue;

    text = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 8) text = text.substring(0, 8);

    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      formatted += text[i];
      if ((i == 1 || i == 3) && i != text.length - 1) {
        formatted += '/';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}