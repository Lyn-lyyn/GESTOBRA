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
        {'actividad': 'Limpieza y desmonte del terreno', 'fase': 'Preliminares', 'responsable': 'Cuadrilla 1 - Don Pedro', 'avance': 100},
        {'actividad': 'Trazo y nivelación topográfica', 'fase': 'Preliminares', 'responsable': 'Topógrafo Miguel', 'avance': 100},
      ],
      'materiales': [
        {'material': 'Cemento Gris Portland CPC 30R', 'cantidad': 10, 'unidad': 'Bultos'},
      ],
      'incidencias': [],
      // SE QUITÓ LA IMAGEN DE "Firmas"
      'evidencias': [
        {'url': 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=400&h=300&fit=crop', 'titulo': 'Demolición'},
        {'url': 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&h=300&fit=crop', 'titulo': 'Excavación'},
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
        {'actividad': 'Limpieza y desmonte del terreno', 'fase': 'Preliminares', 'responsable': 'Cuadrilla 1 - Don Pedro', 'avance': 100},
        {'actividad': 'Armado de acero en zapatas y dados', 'fase': 'Cimentación', 'responsable': 'Fierrero Juan y ayudante', 'avance': 85},
      ],
      'materiales': [
        {'material': 'Cemento Gris Portland CPC 30R', 'cantidad': 40, 'unidad': 'Bultos'},
        {'material': 'Varilla Corrugada 3/8" (Grado 42)', 'cantidad': 250, 'unidad': 'kg'},
      ],
      'incidencias': [
        {'tipo': 'Clima', 'descripcion': 'Lluvia intensa durante la mañana', 'fecha': '07/09/2026', 'estado': 'Resuelta'},
      ],
      // SE QUITÓ LA IMAGEN DE "Firmas"
      'evidencias': [
        {'url': 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=400&h=300&fit=crop', 'titulo': 'Demolición'},
        {'url': 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&h=300&fit=crop', 'titulo': 'Excavación'},
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
              padding: EdgeInsets.only(
                left: pad,
                right: pad,
                bottom: pad,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── 1. MARCO INDEPENDIENTE PARA LA BARRA SUPERIOR ───
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

                  // ─── 2. MARCO DEL REPORTE ───
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
                        ReporteIncidenciasParos(datos: _datosReporte),
                        SizedBox(height: pad * 0.75),
                        ReporteEvidenciasGrid(datos: _datosReporte),
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