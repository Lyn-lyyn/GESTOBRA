import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';

class ReporteEvidenciasGrid extends StatelessWidget {
  final Map<String, dynamic> datos;
  const ReporteEvidenciasGrid({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    final evidencias = datos['evidencias'] as List;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gris, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '5. Evidencias Gráficas Representativas',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textoNegro,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              const double anchoMin = 130;
              const double gap = 8;

              int cols =
                  ((constraints.maxWidth + gap) / (anchoMin + gap)).floor();
              if (cols < 1) cols = 1;
              if (cols > 5) cols = 5;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: gap,
                  mainAxisSpacing: gap,
                  childAspectRatio: 4 / 3.2,
                ),
                itemCount: evidencias.length,
                itemBuilder: (context, index) {
                  final ev = evidencias[index];
                  final url = ev is Map ? ev['url'] : ev;
                  final titulo = ev is Map ? (ev['titulo'] ?? '') : '';

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gris, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.grisfondo,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: AppColors.gris,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 3,
                            horizontal: 4,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1A1F36),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(6),
                            ),
                          ),
                          child: Text(
                            titulo,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}