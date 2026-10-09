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

  const ReportesSection({super.key, required this.obra});

  @override
  State<ReportesSection> createState() => _ReportesSectionState();
}

class _ReportesSectionState extends State<ReportesSection> {
  String _tipoReporte = 'semanal';
  bool _exportando = false;

  final Map<String, Map<String, dynamic>> _datosPorTipo = {
    'semanal': {
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
        {'actividad': 'Trazo y nivelación topográfica', 'fase': 'Preliminares', 'responsable': 'Topógrafo Miguel', 'avance': 100},
        {'actividad': 'Excavación para zapatas y contratrabes', 'fase': 'Cimentación', 'responsable': 'Cuadrilla 2 - Operador Retro', 'avance': 100},
        {'actividad': "Plantilla de concreto pobre f'c = 100 kg/cm²", 'fase': 'Cimentación', 'responsable': 'Cuadrilla Albañilería 1', 'avance': 100},
        {'actividad': 'Armado de acero en zapatas y dados', 'fase': 'Cimentación', 'responsable': 'Fierrero Juan y ayudante', 'avance': 85},
        {'actividad': "Colado de zapatas y contratrabes f'c = 250 kg/cm²", 'fase': 'Cimentación', 'responsable': 'Cuadrilla Colados', 'avance': 30},
        {'actividad': 'Relleno y compactación con tepetate', 'fase': 'Cimentación', 'responsable': 'Cuadrilla 2', 'avance': 0},
        {'actividad': 'Cimbrado y colado de columnas planta baja', 'fase': 'Estructura', 'responsable': 'Maestro José Luis', 'avance': 0},
        {'actividad': 'Losa de entrepiso vigueta y bovedilla', 'fase': 'Estructura', 'responsable': 'Cuadrilla Especializada', 'avance': 0},
        {'actividad': 'Muros de block hueco 15x20x40 cm', 'fase': 'Albañilería', 'responsable': 'Cuadrilla Albañilería 2', 'avance': 0},
      ],
      'materiales': [
        {'material': 'Cemento Gris Portland CPC 30R', 'cantidad': 40, 'unidad': 'Bultos'},
        {'material': 'Varilla Corrugada 3/8" (Grado 42)', 'cantidad': 250, 'unidad': 'kg'},
        {'material': 'Alambre recocido calibre 16', 'cantidad': 15, 'unidad': 'kg'},
      ],
      'incidencias': [
        {'tipo': 'Material', 'descripcion': 'Retraso en suministro de acero de refuerzo', 'fecha': '05/09/2026', 'estado': 'En atención'},
        {'tipo': 'Clima', 'descripcion': 'Lluvia intensa durante la mañana', 'fecha': '07/09/2026', 'estado': 'Resuelta'},
      ],
      'evidencias': [
        {'url': 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=400&h=300&fit=crop', 'titulo': 'Demolición'},
        {'url': 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&h=300&fit=crop', 'titulo': 'Excavación'},
        {'url': 'https://images.unsplash.com/photo-1590644365607-1c5a0d7a0e4c?w=400&h=300&fit=crop', 'titulo': 'Firmas'},
        {'url': 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400&h=300&fit=crop', 'titulo': 'Control Calidad'},
      ],
    },
    'quincenal': {
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
      'actividades': [
        {'actividad': 'Limpieza y desmonte del terreno', 'fase': 'Preliminares', 'responsable': 'Cuadrilla 1 - Don Pedro', 'avance': 100},
        {'actividad': 'Trazo y nivelación topográfica', 'fase': 'Preliminares', 'responsable': 'Topógrafo Miguel', 'avance': 100},
        {'actividad': 'Excavación para zapatas y contratrabes', 'fase': 'Cimentación', 'responsable': 'Cuadrilla 2 - Operador Retro', 'avance': 100},
        {'actividad': "Plantilla de concreto pobre f'c = 100 kg/cm²", 'fase': 'Cimentación', 'responsable': 'Cuadrilla Albañilería 1', 'avance': 100},
        {'actividad': 'Armado de acero en zapatas y dados', 'fase': 'Cimentación', 'responsable': 'Fierrero Juan y ayudante', 'avance': 100},
        {'actividad': "Colado de zapatas y contratrabes f'c = 250 kg/cm²", 'fase': 'Cimentación', 'responsable': 'Cuadrilla Colados', 'avance': 70},
        {'actividad': 'Relleno y compactación con tepetate', 'fase': 'Cimentación', 'responsable': 'Cuadrilla 2', 'avance': 40},
        {'actividad': 'Cimbrado y colado de columnas planta baja', 'fase': 'Estructura', 'responsable': 'Maestro José Luis', 'avance': 25},
        {'actividad': 'Losa de entrepiso vigueta y bovedilla', 'fase': 'Estructura', 'responsable': 'Cuadrilla Especializada', 'avance': 10},
        {'actividad': 'Muros de block hueco 15x20x40 cm', 'fase': 'Albañilería', 'responsable': 'Cuadrilla Albañilería 2', 'avance': 5},
      ],
      'materiales': [
        {'material': 'Cemento Gris Portland CPC 30R', 'cantidad': 85, 'unidad': 'Bultos'},
        {'material': 'Varilla Corrugada 3/8" (Grado 42)', 'cantidad': 480, 'unidad': 'kg'},
        {'material': 'Alambre recocido calibre 16', 'cantidad': 32, 'unidad': 'kg'},
      ],
      'incidencias': [
        {'tipo': 'Material', 'descripcion': 'Retraso en suministro de acero de refuerzo', 'fecha': '05/09/2026', 'estado': 'Resuelta'},
        {'tipo': 'Clima', 'descripcion': 'Lluvia intensa durante la mañana', 'fecha': '07/09/2026', 'estado': 'Resuelta'},
        {'tipo': 'Equipo', 'descripcion': 'Falla en revolvedora', 'fecha': '11/09/2026', 'estado': 'Resuelta'},
      ],
      'evidencias': [
        {'url': 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=400&h=300&fit=crop', 'titulo': 'Demolición'},
        {'url': 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&h=300&fit=crop', 'titulo': 'Excavación'},
        {'url': 'https://images.unsplash.com/photo-1590644365607-1c5a0d7a0e4c?w=400&h=300&fit=crop', 'titulo': 'Firmas'},
        {'url': 'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=400&h=300&fit=crop', 'titulo': 'Control Calidad'},
      ],
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
              child: Container(
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
                    _buildBarraSuperior(pad),
                    SizedBox(height: pad * 0.75),
                    _buildSelectorPeriodo(pad),
                    SizedBox(height: pad * 0.75),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarraSuperior(double pad) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: pad,
      runSpacing: pad * 0.5,
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

  Widget _buildSelectorPeriodo(double pad) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gris, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _botonPeriodo('Semanal', 'semanal'),
          const SizedBox(width: 4),
          _botonPeriodo('Quincenal', 'quincenal'),
        ],
      ),
    );
  }

  Widget _botonPeriodo(String texto, String valor) {
    final bool activo = _tipoReporte == valor;
    return GestureDetector(
      onTap: () => setState(() => _tipoReporte = valor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: activo ? AppColors.naranja : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: activo ? Colors.white : AppColors.textoGris,
          ),
        ),
      ),
    );
  }
}