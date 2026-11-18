import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';

class ReporteBalanceAvance extends StatelessWidget {
  final Map<String, dynamic> datos;

  const ReporteBalanceAvance({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    // Obtenemos la lista dinámica de fases que enviamos desde reportes_section.dart
    final List fases = datos['fases'] ?? [];
    final double avanceGeneral = (datos['avanceGeneral'] as num?)?.toDouble() ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordeSuave, width: 1),
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
          
          // ─── AQUÍ ESTÁ LA MAGIA: RECORREMOS LAS FASES DINÁMICAMENTE ───
          if (fases.isEmpty)
            const Text('No hay fases registradas para mostrar.')
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: fases.map<Widget>((fase) {
                final nombre = fase['nombre']?.toString() ?? 'Fase';
                final porcentaje = (fase['porcentaje'] as num?)?.toInt() ?? 0;

                return Container(
                  width: 130, // Ancho de cada tarjeta
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.bordeSuave),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        nombre,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textoNegro,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$porcentaje%',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.naranja,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          
          const SizedBox(height: 16),
          
          // ─── BARRA DE AVANCE GENERAL ───
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: avanceGeneral / 100,
                backgroundColor: Colors.grey.shade100,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.naranja),
                minHeight: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}