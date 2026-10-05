import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';

class ReporteActividadesTabla extends StatelessWidget {
  final Map<String, dynamic> datos;
  const ReporteActividadesTabla({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    final actividades = datos['actividades'] as List;

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
            '2. Actividades y Frentes de Trabajo',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textoNegro,
            ),
          ),
          const SizedBox(height: 12),

          // Encabezado
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.grisfondo,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: const [
                Expanded(flex: 5, child: Text('Actividad', style: _th)),
                Expanded(flex: 3, child: Text('Responsable', style: _th)),
                Expanded(
                  flex: 2,
                  child: Text('Avance', style: _th, textAlign: TextAlign.right),
                ),
              ],
            ),
          ),

          // Filas — cada fila también con `Expanded(flex)` para repartir el ancho
          ...actividades.map<Widget>((a) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.gris.withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textoNegro,
                        ),
                        children: [
                          TextSpan(text: a['actividad']),
                          TextSpan(
                            text: '  (${a['fase']})',
                            style: const TextStyle(
                              color: AppColors.textoGris,
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      a['responsable'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textoNegro,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${a['avance']}%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textoNegro,
                      ),
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

const _th = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.bold,
  color: AppColors.textoNegro,
);