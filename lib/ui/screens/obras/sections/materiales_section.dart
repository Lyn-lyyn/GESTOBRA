import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';

class MaterialesSection extends StatelessWidget {
  final Map<String, dynamic> obra;

  const MaterialesSection({super.key, required this.obra});

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
                  'Inventario de Materiales',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Movimiento', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
                Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.gris),
                SizedBox(height: 12),
                Text(
                  'Control de entradas y salidas',
                  style: TextStyle(fontSize: 14, color: AppColors.gris),
                ),
                SizedBox(height: 4),
                Text(
                  'Aquí se mostrará el inventario de materiales.',
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