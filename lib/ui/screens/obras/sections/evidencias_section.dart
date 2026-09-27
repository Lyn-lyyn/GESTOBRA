import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';

class EvidenciasSection extends StatelessWidget {
  final Map<String, dynamic> obra;

  const EvidenciasSection({super.key, required this.obra});

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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Evidencias Fotográficas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt, size: 14),
                  label: const Text('Subir Evidencia', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.naranja,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
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
                Icon(Icons.photo_library_outlined, size: 48, color: AppColors.gris),
                SizedBox(height: 12),
                Text(
                  'Galería de evidencias',
                  style: TextStyle(fontSize: 14, color: AppColors.gris),
                ),
                SizedBox(height: 4),
                Text(
                  'Aquí se mostrarán las fotografías y archivos adjuntos.',
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