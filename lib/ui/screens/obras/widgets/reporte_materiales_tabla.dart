import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';

class ReporteMaterialesTabla extends StatelessWidget {
  final Map<String, dynamic> datos;
  const ReporteMaterialesTabla({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    final materiales = datos['materiales'] as List;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gris.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3. Resumen de Materiales Utilizados en el Periodo',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textoNegro,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              // Ancho mínimo cómodo por tarjeta de material
              const double anchoMin = 260;
              const double gap = 8;

              int cols = ((constraints.maxWidth + gap) / (anchoMin + gap)).floor();
              if (cols < 1) cols = 1;

              final double anchoTarjeta =
                  (constraints.maxWidth - (gap * (cols - 1))) / cols;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: materiales.map<Widget>((m) {
                  return SizedBox(
                    width: anchoTarjeta,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grisfondo,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.gris.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              m['material'],
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textoNegro,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${m['cantidad']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.naranja,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            m['unidad'],
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textoGris,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}