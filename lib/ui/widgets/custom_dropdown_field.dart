import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class CustomDropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool showLabel;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    // Validación de seguridad: Si el valor actual no está en los items (ej. se cambió la lista), lo ponemos en null
    final String? safeValue = items.contains(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textoNegro,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<String>(
          value: safeValue, // Usamos el valor validado
          isExpanded: true, // 👈 CRUCIAL: Obliga al dropdown a no salirse del contenedor
          hint: Text(hint, overflow: TextOverflow.ellipsis), // Corta el hint si es muy largo
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.naranja,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: AppColors.textoGris,
            ),
            filled: true,
            fillColor: AppColors.blanco,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), // Ajuste de padding
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.naranja,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.naranja,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.naranja,
                width: 2,
              ),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis, // Corta el texto de las opciones si es muy largo
                maxLines: 1,
                softWrap: false,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}