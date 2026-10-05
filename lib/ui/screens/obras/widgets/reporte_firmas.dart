import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';

class ReporteFirmas extends StatelessWidget {
  final Map<String, dynamic> datos;
  const ReporteFirmas({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gris.withValues(alpha: 0.3)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double anchoMin = 200;
          const double gap = 24;

          int cols = ((constraints.maxWidth + gap) / (anchoMin + gap)).floor();
          if (cols < 1) cols = 1;
          if (cols > 2) cols = 2;

          final double anchoFirma =
              (constraints.maxWidth - (gap * (cols - 1))) / cols;

          final firma1 = _firma(
            'Ing. ${datos['residente']}',
            'Residente de Obra / D.R.O.',
            anchoFirma,
          );
          final firma2 = _firma(
            datos['cliente'],
            'Cliente / Supervisión Externa',
            anchoFirma,
          );

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [firma1, firma2],
          );
        },
      ),
    );
  }

  Widget _firma(String nombre, String cargo, double ancho) {
    return SizedBox(
      width: ancho,
      child: Column(
        children: [
          Container(height: 1, color: AppColors.gris.withValues(alpha: 0.5)),
          const SizedBox(height: 6),
          Text(
            nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textoNegro,
            ),
          ),
          Text(
            cargo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppColors.textoGris),
          ),
        ],
      ),
    );
  }
}