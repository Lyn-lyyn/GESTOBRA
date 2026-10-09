import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';

class ReporteBalanceAvance extends StatelessWidget {
  final Map<String, dynamic> datos;
  const ReporteBalanceAvance({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    final fases = [
      {'nombre': 'Preliminares', 'avance': datos['avancePreliminares'] ?? 0},
      {'nombre': 'Cimentación', 'avance': datos['avanceCimentacion'] ?? 0},
      {'nombre': 'Estructura', 'avance': datos['avanceEstructura'] ?? 0},
      {'nombre': 'Albañilería', 'avance': datos['avanceAlbanileria'] ?? 0},
    ];

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
            '1. Balance de Avance Físico del Periodo',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textoNegro,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              const double anchoMin = 160;
              const double gap = 12;

              int cols =
                  ((constraints.maxWidth + gap) / (anchoMin + gap)).floor();
              if (cols < 1) cols = 1;
              if (cols > 4) cols = 4;

              final double anchoTarjeta =
                  (constraints.maxWidth - (gap * (cols - 1))) / cols;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: fases.map<Widget>((f) {
                  return SizedBox(
                    width: anchoTarjeta,
                    child: _tarjeta(
                      f['nombre'] as String,
                      f['avance'] as int,
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gris, width: 1.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (datos['avanceGeneral'] ?? 0) / 100,
                backgroundColor: Colors.grey.shade100,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.naranja),
                minHeight: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjeta(String titulo, int valor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gris, width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textoNegro,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$valor%',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.naranja,
            ),
          ),
        ],
      ),
    );
  }
}