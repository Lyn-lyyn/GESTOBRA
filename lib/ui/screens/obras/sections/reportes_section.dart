import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';
import 'package:gestobra/servicios/reporte_pdf_service.dart';
import 'package:gestobra/ui/screens/obras/widgets/reporte_header.dart';
import 'package:gestobra/ui/screens/obras/widgets/reporte_balance_avance.dart';
import 'package:gestobra/ui/screens/obras/widgets/reporte_actividades_tabla.dart';
import 'package:gestobra/ui/screens/obras/widgets/reporte_materiales_tabla.dart';
import 'package:gestobra/ui/screens/obras/widgets/reporte_incidencias_paros.dart';
import 'package:gestobra/ui/screens/obras/widgets/reporte_evidencias_grid.dart';
import 'package:gestobra/ui/screens/obras/widgets/reporte_firmas.dart';

class ReportesSection extends StatefulWidget {
  final Map<String, dynamic> obra;
  final String tipoReporteInicial;
  final DateTimeRange? rangoPersonalizado; // <-- NUEVO

  const ReportesSection({
    super.key,
    required this.obra,
    this.tipoReporteInicial = 'Semanal',
    this.rangoPersonalizado, // <-- NUEVO
  });

  @override
  State<ReportesSection> createState() => _ReportesSectionState();
}

class _ReportesSectionState extends State<ReportesSection> {
  late String _tipoReporte;
  bool _exportando = false;
  bool _cargando = true;
  String? _error;
  Map<String, dynamic>? _datosReporte;

  @override
  void initState() {
    super.initState();
    _tipoReporte = widget.tipoReporteInicial;
    _cargarDatos();
  }

  @override
  void didUpdateWidget(covariant ReportesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tipoReporteInicial != widget.tipoReporteInicial ||
        oldWidget.rangoPersonalizado != widget.rangoPersonalizado) {
      _tipoReporte = widget.tipoReporteInicial;
      _cargarDatos();
    }
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    int idObra = int.tryParse(widget.obra['id_obra']?.toString() ?? '1') ?? 1;

    // 1. CALCULAMOS LAS FECHAS
    DateTime hoy = DateTime.now();
    DateTime inicio;

    if (_tipoReporte == 'Personalizado' && widget.rangoPersonalizado != null) {
      inicio = widget.rangoPersonalizado!.start;
      hoy = widget.rangoPersonalizado!.end;
    } else if (_tipoReporte == 'Diario') {
      inicio = hoy;
    } else if (_tipoReporte == 'Semanal') {
      inicio = hoy.subtract(const Duration(days: 7));
    } else if (_tipoReporte == 'Quincenal') {
      inicio = hoy.subtract(const Duration(days: 15));
    } else {
      inicio = DateTime(2020, 1, 1); // Acumulado
    }

    String fInicio = inicio.toIso8601String().split('T')[0];
    String fFin = hoy.toIso8601String().split('T')[0];

    try {
      // 2. MANDAMOS LAS FECHAS AL PHP
      final dataGeneral = await ApiService.get(
          'reporte_general.php?id_obra=$idObra&periodo=$_tipoReporte&inicio=$fInicio&fin=$fFin');
      final dataMateriales = await ApiService.get('reporte_materiales.php?id_obra=$idObra&inicio=$fInicio&fin=$fFin');

      if (dataGeneral['estado'] == true && dataMateriales['estado'] == true) {
        
        // --- TRADUCCIÓN DE FASES ---
        final List fasesRaw = dataGeneral['data']['fases'] ?? [];
        
        double buscarAvance(String nombreFase) {
          for (var f in fasesRaw) {
            if (f['fase'].toString().toLowerCase() == nombreFase.toLowerCase()) {
              return double.tryParse(f['avance'].toString()) ?? 0.0;
            }
          }
          return 0.0;
        }

        // --- TRADUCCIÓN DE INCIDENCIAS ---
        final List incidenciasRaw = dataGeneral['data']['incidencias'] ?? [];
        final incidenciasFormateadas = incidenciasRaw.map((i) {
          return {
            'tipo': i['titulo'] ?? 'Incidencia',
            'descripcion': i['descripcion'] ?? '',
            'estado': i['estado'] ?? 'ABIERTA',
            'fecha': i['fecha_reporte'] ?? '',
          };
        }).toList();

        setState(() {
          _datosReporte = {
            'semana': dataGeneral['data']['info']['periodo'],
            'codigoReporte': dataGeneral['data']['info']['codigoReporte'],
            'periodo': dataGeneral['data']['info']['periodo'],
            'fechaGeneracion': dataGeneral['data']['info']['fechaGeneracion'],
            'cliente': dataGeneral['data']['info']['cliente'],
            'residente': dataGeneral['data']['info']['residente'],
            'ubicacion': dataGeneral['data']['info']['ubicacion'],
            'plazoContractual': dataGeneral['data']['info']['plazoContractual'],
            'estado': dataGeneral['data']['info']['estado'],
            'avanceGeneral': double.tryParse(dataGeneral['data']['avanceGeneral'].toString()) ?? 0.0,
            
            'avancePreliminares': buscarAvance('Preliminares').toInt(),
            'avanceCimentacion': buscarAvance('Cimentación').toInt(),
            'avanceEstructura': buscarAvance('Estructura').toInt(),
            'avanceAlbanileria': buscarAvance('Albañilería').toInt(),
            
            'actividades': dataGeneral['data']['actividades'].map((a) => {
              'actividad': a['actividad'],
              'fase': a['fase'],
              'responsable': a['responsable'] ?? 'Sin asignar',
              'avance': double.tryParse(a['porcentaje_avance'].toString()) ?? 0.0,
              'materiales_usados': a['materiales_usados'] ?? 'N/A',
            }).toList(),
            
            'incidencias': incidenciasFormateadas,
            'notasGenerales': dataGeneral['data']['notasGenerales'],
            'materiales': dataMateriales['materiales'],
            'personal': dataMateriales['personal'],
            'maquinaria': dataMateriales['maquinaria'],
            'evidencias': dataGeneral['data']['evidencias'] ?? [],
          };
          _cargando = false;
        });
      } else {
        setState(() {
          _error = 'El servidor no devolvió los datos correctamente.';
          _cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  Future<void> _exportarPdf() async {
    if (_datosReporte == null) return;
    
    setState(() => _exportando = true);
    try {
      await ReportePdfService.generarYCompartir(
        obra: widget.obra,
        datos: _datosReporte!,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar PDF: $e')),
      );
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _datosReporte == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Error: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _cargarDatos, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double pad = (constraints.maxWidth * 0.02).clamp(12.0, 32.0);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Padding(
              padding: EdgeInsets.only(left: pad, right: pad, bottom: pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.grisfondo,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gris, width: 1.2),
                    ),
                    child: _buildBarraSuperior(),
                  ),
                  SizedBox(height: pad * 0.75),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(pad),
                    decoration: BoxDecoration(
                      color: AppColors.grisfondo,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gris, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ReporteHeader(obra: widget.obra, datos: _datosReporte!),
                        SizedBox(height: pad * 0.75),
                        ReporteBalanceAvance(datos: _datosReporte!),
                        SizedBox(height: pad * 0.75),
                        ReporteActividadesTabla(datos: _datosReporte!),
                        SizedBox(height: pad * 0.75),
                        ReporteMaterialesTabla(datos: _datosReporte!),
                        SizedBox(height: pad * 0.75),
                        _buildPersonalYMaquinariaWeb(),
                        SizedBox(height: pad * 0.75),
                        ReporteIncidenciasParos(datos: _datosReporte!),
                        SizedBox(height: pad * 0.75),
                        ReporteEvidenciasGrid(datos: _datosReporte!),
                        SizedBox(height: pad * 0.75),
                        _buildNotasGeneralesWeb(),
                        SizedBox(height: pad),
                        ReporteFirmas(datos: _datosReporte!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPersonalYMaquinariaWeb() {
    final personal = _datosReporte!['personal'] as List? ?? [];
    final maquinaria = _datosReporte!['maquinaria'] as List? ?? [];

    Widget buildTabla(String titulo, List items, String key) {
      return Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gris, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.textoNegro,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              if (items.isEmpty)
                const Padding(padding: EdgeInsets.all(12), child: Text('Sin registros', style: TextStyle(fontSize: 12))),
              ...items.map((item) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.gris.withValues(alpha: 0.2))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(item[key].toString(), style: const TextStyle(fontSize: 12))),
                      Text(item['cantidad'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTabla('PERSONAL', personal, 'categoria'),
        const SizedBox(width: 16),
        buildTabla('MAQUINARIA / EQUIPO', maquinaria, 'equipo'),
      ],
    );
  }

  Widget _buildNotasGeneralesWeb() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gris, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.textoNegro,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: const Text('NOTAS GENERALES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _datosReporte!['notasGenerales'] ?? 'Sin notas.',
              style: const TextStyle(fontSize: 12, color: AppColors.textoNegro),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarraSuperior() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Reportes de obra',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ElevatedButton.icon(
          onPressed: _exportando ? null : _exportarPdf,
          icon: _exportando
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.picture_as_pdf_outlined, size: 16),
          label: Text(
            _exportando ? 'Generando...' : 'Exportar PDF',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.naranja,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}