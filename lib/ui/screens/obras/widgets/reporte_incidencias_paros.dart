import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';

class ReporteIncidenciasParos extends StatelessWidget {
  final Map<String, dynamic> datos;
  const ReporteIncidenciasParos({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    final incidencias = (datos['incidencias'] as List?) ?? [];

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
            '4. Incidencias / Paros Registrados en el Periodo',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textoNegro,
            ),
          ),
          const SizedBox(height: 12),
          if (incidencias.isEmpty)
            const Text(
              'Sin incidencias ni paros registrados en el periodo.',
              style: TextStyle(fontSize: 11, color: AppColors.textoGris),
            )
          else
            ...incidencias.map<Widget>((i) {
              final resuelta = i['estado'] == 'Resuelta';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.grisfondo,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: resuelta
                        ? AppColors.estadoVerde.withValues(alpha: 0.5)
                        : AppColors.estadoAmarillo.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      resuelta
                          ? Icons.check_circle_outline
                          : Icons.warning_amber_outlined,
                      size: 16,
                      color: resuelta
                          ? AppColors.estadoVerde
                          : AppColors.estadoAmarillo,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: [
                          Text(
                            '[${i['tipo']}] ${i['descripcion']}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textoNegro,
                            ),
                          ),
                          Text(
                            '• Fecha: ${i['fecha'] ?? '—'} • Estado: ${i['estado'] ?? '—'}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textoGris,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}