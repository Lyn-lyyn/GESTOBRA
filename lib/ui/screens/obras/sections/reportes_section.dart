import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
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

  const ReportesSection({
    super.key,
    required this.obra,
    this.tipoReporteInicial = 'Semanal',
  });

  @override
  State<ReportesSection> createState() => _ReportesSectionState();
}

class _ReportesSectionState extends State<ReportesSection> {
  late String _tipoReporte;
  bool _exportando = false;

  @override
  void initState() {
    super.initState();
    _tipoReporte = widget.tipoReporteInicial;
  }

  @override
  void didUpdateWidget(covariant ReportesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tipoReporteInicial != widget.tipoReporteInicial) {
      setState(() {
        _tipoReporte = widget.tipoReporteInicial;
      });
    }
  }

  final Map<String, Map<String, dynamic>> _datosPorTipo = {
    'Diario': {
      'semana': 'Día 08',
      'codigoReporte': 'OBRA-2026-042',
      'periodo': '2026-09-08',
      'fechaGeneracion': '08/09/2026',
      'cliente': 'Sr. Juan Pérez González',
      'residente': 'Ing. Carlos Morales',
      'supervisor': 'Sr. Juan Pérez González',
      'ubicacion': 'Coaztacoalcos, Veracruz',
      'plazoContractual': '2026-09-07 al 2027-02-15',
      'estado': 'ACTIVO',
      'avancePreliminares': 100,
      'avanceCimentacion': 35,
      'avanceEstructura': 10,
      'avanceAlbanileria': 0,
      'avanceGeneral': 25,
      'actividades': [
        {'actividad': 'Limpieza y desmonte del terreno', 'fase': 'Preliminares', 'responsable': 'Cuadrilla 1 - Don Pedro', 'avance': 100, 'materiales_usados': 'Herramienta menor, combustible'},
        {'actividad': 'Trazo y nivelación topográfica', 'fase': 'Preliminares', 'responsable': 'Topógrafo Miguel', 'avance': 100, 'materiales_usados': 'Cal, estacas, hilo'},
      ],
      'materiales': [
        {'material': 'Cemento Gris Portland CPC 30R', 'cantidad': 10, 'unidad': 'Bultos'},
      ],
      'incidencias': [],
      'evidencias': [
        {'url': 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=400&h=300&fit=crop', 'titulo': 'Demolición'},
        {'url': 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&h=300&fit=crop', 'titulo': 'Excavación'},
      ],
      'notasGenerales': 'SE INFORMA A LA RESIDENCIA OPERATIVA QUE SE ESPERA LA LLEGADA DE SUMINISTROS ADICIONALES PARA CONTINUAR CON LOS TRABAJOS.',
      'personal': [
        {'categoria': 'Superintendente de Construcción', 'cantidad': 1},
        {'categoria': 'Residente de Obra', 'cantidad': 1},
        {'categoria': 'Topógrafo', 'cantidad': 2},
        {'categoria': 'Ayudantes Generales', 'cantidad': 8},
      ],
      'maquinaria': [
        {'equipo': 'Retroexcavadora CAT 320', 'cantidad': 1},
        {'equipo': 'Camión de Volteo', 'cantidad': 2},
        {'equipo': 'Herramienta Menor', 'cantidad': 1},
      ],
    },
    'Semanal': {
      'semana': 'Semana 12',
      'codigoReporte': 'OBRA-2026-042',
      'periodo': '2026-09-01 al 2026-09-08',
      'fechaGeneracion': '08/09/2026',
      'cliente': 'Sr. Juan Pérez González',
      'residente': 'Ing. Carlos Morales',
      'supervisor': 'Sr. Juan Pérez González',
      'ubicacion': 'Coaztacoalcos, Veracruz',
      'plazoContractual': '2026-09-07 al 2027-02-15',
      'estado': 'ACTIVO',
      'avancePreliminares': 100,
      'avanceCimentacion': 40,
      'avanceEstructura': 12,
      'avanceAlbanileria': 0,
      'avanceGeneral': 28,
      'actividades': [
        {'actividad': 'Limpieza y desmonte del terreno', 'fase': 'Preliminares', 'responsable': 'Cuadrilla 1 - Don Pedro', 'avance': 100, 'materiales_usados': 'Herramienta menor, combustible'},
        {'actividad': 'Armado de acero en zapatas y dados', 'fase': 'Cimentación', 'responsable': 'Fierrero Juan y ayudante', 'avance': 85, 'materiales_usados': 'Varilla 3/8, alambre recocido'},
      ],
      'materiales': [
        {'material': 'Cemento Gris Portland CPC 30R', 'cantidad': 40, 'unidad': 'Bultos'},
        {'material': 'Varilla Corrugada 3/8" (Grado 42)', 'cantidad': 250, 'unidad': 'kg'},
      ],
      'incidencias': [
        {'tipo': 'Clima', 'descripcion': 'Lluvia intensa durante la mañana', 'fecha': '07/09/2026', 'estado': 'Resuelta'},
      ],
      'evidencias': [
        {'url': 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=400&h=300&fit=crop', 'titulo': 'Demolición'},
        {'url': 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&h=300&fit=crop', 'titulo': 'Excavación'},
      ],
      'notasGenerales': 'EL DÍA DE HOY SE CONTINÚA CON LA AMPLIACIÓN DE LA CIMENTACIÓN. SE SOLICITA REVISIÓN DEL ACERO COLOCADO ANTES DEL COLADO.',
      'personal': [
        {'categoria': 'Superintendente de Construcción', 'cantidad': 1},
        {'categoria': 'Residente de Obra', 'cantidad': 1},
        {'categoria': 'Ingeniero de Campo', 'cantidad': 1},
        {'categoria': 'Maestro de Obra', 'cantidad': 1},
        {'categoria': 'Albañiles', 'cantidad': 6},
        {'categoria': 'Fierreros', 'cantidad': 4},
      ],
      'maquinaria': [
        {'equipo': 'Retroexcavadora 416E', 'cantidad': 1},
        {'equipo': 'Revolvedora de 1 saco', 'cantidad': 2},
        {'equipo': 'Vibrador para concreto', 'cantidad': 2},
      ],
    },
    'Quincenal': {
      'semana': 'Quincena 1',
      'codigoReporte': 'OBRA-2026-042',
      'periodo': '2026-09-01 al 2026-09-15',
      'fechaGeneracion': '15/09/2026',
      'cliente': 'Sr. Juan Pérez González',
      'residente': 'Ing. Carlos Morales',
      'supervisor': 'Sr. Juan Pérez González',
      'ubicacion': 'Coaztacoalcos, Veracruz',
      'plazoContractual': '2026-09-07 al 2027-02-15',
      'estado': 'ACTIVO',
      'avancePreliminares': 100,
      'avanceCimentacion': 55,
      'avanceEstructura': 20,
      'avanceAlbanileria': 5,
      'avanceGeneral': 35,
      'actividades': [],
      'materiales': [],
      'incidencias': [],
      'evidencias': [],
      'notasGenerales': 'SE CONCLUYE LA PRIMERA QUINCENA CON UN AVANCE DEL 35%. SE MANTIENE EL RITMO DE TRABAJO.',
      'personal': [
        {'categoria': 'Superintendente', 'cantidad': 1},
        {'categoria': 'Cabos', 'cantidad': 2},
        {'categoria': 'Peones', 'cantidad': 10},
      ],
      'maquinaria': [
        {'equipo': 'Camión Grúa', 'cantidad': 1},
      ],
    },
    'Acumulado': {
      'semana': 'Acumulado Histórico',
      'codigoReporte': 'OBRA-2026-042',
      'periodo': 'Inicio a 2026-09-30',
      'fechaGeneracion': '30/09/2026',
      'cliente': 'Sr. Juan Pérez González',
      'residente': 'Ing. Carlos Morales',
      'supervisor': 'Sr. Juan Pérez González',
      'ubicacion': 'Coaztacoalcos, Veracruz',
      'plazoContractual': '2026-09-07 al 2027-02-15',
      'estado': 'ACTIVO',
      'avancePreliminares': 100,
      'avanceCimentacion': 100,
      'avanceEstructura': 45,
      'avanceAlbanileria': 10,
      'avanceGeneral': 65,
      'actividades': [],
      'materiales': [],
      'incidencias': [],
      'evidencias': [],
      'notasGenerales': 'RESUMEN DE ACTIVIDADES DEL MES. SE CUMPLIERON LOS OBJETIVOS PLANIFICADOS.',
      'personal': [],
      'maquinaria': [],
    },
  };

  Map<String, dynamic> get _datosReporte => _datosPorTipo[_tipoReporte]!;

  Future<void> _exportarPdf() async {
    setState(() => _exportando = true);
    try {
      await ReportePdfService.generarYCompartir(
        obra: widget.obra,
        datos: _datosReporte,
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
                        ReporteHeader(obra: widget.obra, datos: _datosReporte),
                        SizedBox(height: pad * 0.75),
                        ReporteBalanceAvance(datos: _datosReporte),
                        SizedBox(height: pad * 0.75),
                        ReporteActividadesTabla(datos: _datosReporte),
                        SizedBox(height: pad * 0.75),
                        ReporteMaterialesTabla(datos: _datosReporte),
                        
                        SizedBox(height: pad * 0.75),
                        _buildPersonalYMaquinariaWeb(),
                        SizedBox(height: pad * 0.75),

                        ReporteIncidenciasParos(datos: _datosReporte),
                        SizedBox(height: pad * 0.75),
                        ReporteEvidenciasGrid(datos: _datosReporte),
                        
                        SizedBox(height: pad * 0.75),
                        _buildNotasGeneralesWeb(),

                        SizedBox(height: pad),
                        ReporteFirmas(datos: _datosReporte),
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
    final personal = _datosReporte['personal'] as List? ?? [];
    final maquinaria = _datosReporte['maquinaria'] as List? ?? [];

    Widget buildTabla(String titulo, List items, String col1, String col2, String key) {
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
        buildTabla('PERSONAL', personal, 'Categoría', 'Cant.', 'categoria'),
        const SizedBox(width: 16),
        buildTabla('MAQUINARIA / EQUIPO', maquinaria, 'Equipo', 'Cant.', 'equipo'),
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
              _datosReporte['notasGenerales'] ?? 'Sin notas.',
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _exportando ? null : _exportarPdf,
          icon: _exportando
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.picture_as_pdf_outlined, size: 16),
          label: Text(
            _exportando ? 'Generando...' : 'Exportar PDF',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.naranja,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}