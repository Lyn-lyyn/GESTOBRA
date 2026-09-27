import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';

class ReportesSection extends StatelessWidget {
  final Map<String, dynamic> obra;

  const ReportesSection({super.key, required this.obra});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grisfondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gris),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generación de Reportes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gris),
            ),
            child: Column(
              children: const [
                Icon(Icons.picture_as_pdf_outlined, size: 48, color: AppColors.gris),
                SizedBox(height: 12),
                Text(
                  'Reportes en PDF',
                  style: TextStyle(fontSize: 14, color: AppColors.gris),
                ),
                SizedBox(height: 4),
                Text(
                  'Aquí podrás generar reportes de avance, materiales y bitácora.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.gris),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}