import 'package:flutter/material.dart';
import '../../../../../config/theme/app_colors.dart';

class ReportePersonalIncidencias extends StatelessWidget {
  final Map<String, dynamic> datos;
  const ReportePersonalIncidencias({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    final personal = datos['personal'] as List;
    final incidencias = datos['incidencias'] as List;

    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 700;
        final izquierda = _bloque(
          '4. PERSONAL EN SITIO',
          personal.map<Widget>((p) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      p['puesto'],
                      style: const TextStyle(fontSize: 11, color: AppColors.textoNegro),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.naranja.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${p['cantidad']}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.naranja,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );

        final derecha = _bloque(
          'INCIDENCIAS DEL PERIODO',
          incidencias.isEmpty
              ? [const Text('Sin incidencias', style: TextStyle(fontSize: 11))]
              : incidencias.map<Widget>((i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          i['estado'] == 'Resuelta'
                              ? Icons.check_circle_outline
                              : Icons.warning_amber_outlined,
                          size: 14,
                          color: i['estado'] == 'Resuelta'
                              ? AppColors.estadoVerde
                              : AppColors.estadoAmarillo,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '[${i['tipo']}] ${i['descripcion']}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
        );

        if (esMovil) {
          return Column(
            children: [izquierda, const SizedBox(height: 12), derecha],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: izquierda),
            const SizedBox(width: 12),
            Expanded(child: derecha),
          ],
        );
      },
    );
  }

  Widget _bloque(String titulo, List<Widget> hijos) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gris.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1F36),
            ),
          ),
          const SizedBox(height: 10),
          ...hijos,
        ],
      ),
    );
  }
}