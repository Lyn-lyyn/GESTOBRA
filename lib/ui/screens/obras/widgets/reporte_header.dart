import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';

class ReporteHeader extends StatelessWidget {
  final Map<String, dynamic> obra;
  final Map<String, dynamic> datos;

  const ReporteHeader({super.key, required this.obra, required this.datos});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gris.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Fila superior: logo IZQUIERDA + título DERECHA ───
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.naranja,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.construction,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'GestObra',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textoNegro,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'REPORTE TÉCNICO #${datos['codigoReporte']}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textoNegro,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Periodo: ${datos['periodo']}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 10, color: AppColors.textoGris),
                    ),
                    Text(
                      'Generado el: ${datos['fechaGeneracion']}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 10, color: AppColors.textoGris),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // ─── Datos en 2 columnas ───
          LayoutBuilder(
            builder: (context, constraints) {
              const double anchoMin = 320;
              const double gap = 16;

              int cols = ((constraints.maxWidth + gap) / (anchoMin + gap)).floor();
              if (cols < 1) cols = 1;
              if (cols > 2) cols = 2;

              final double anchoCol =
                  (constraints.maxWidth - (gap * (cols - 1))) / cols;

              return Wrap(
                spacing: gap,
                runSpacing: 8,
                children: [
                  // Columna IZQUIERDA: alineada a la izquierda
                  SizedBox(
                    width: anchoCol,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _dato('Obra', obra['titulo'] ?? 'Obra sin nombre',
                            TextAlign.left),
                        const SizedBox(height: 4),
                        _dato('Cliente', datos['cliente'], TextAlign.left),
                        const SizedBox(height: 4),
                        _dato('Ubicación', datos['ubicacion'], TextAlign.left),
                      ],
                    ),
                  ),
                  // Columna DERECHA: alineada a la derecha
                  SizedBox(
                    width: anchoCol,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _dato('Residente a Cargo', datos['residente'],
                            TextAlign.right),
                        const SizedBox(height: 4),
                        _dato('Plazo Contractual', datos['plazoContractual'],
                            TextAlign.right),
                        const SizedBox(height: 4),
                        Wrap(
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          children: [
                            const Text(
                              'Estado:',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textoNegro,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.estadoVerde.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                datos['estado'] ?? 'ACTIVO',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.estadoVerde,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _dato(String etiqueta, String valor, TextAlign align) {
    return RichText(
      textAlign: align,
      text: TextSpan(
        style: const TextStyle(fontSize: 11, color: AppColors.textoNegro),
        children: [
          TextSpan(
            text: '$etiqueta: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textoNegro,
            ),
          ),
          TextSpan(text: valor),
        ],
      ),
    );
  }
}