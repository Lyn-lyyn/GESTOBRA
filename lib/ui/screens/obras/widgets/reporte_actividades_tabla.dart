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
        border: Border.all(color: AppColors.bordeSuave, width: 1),
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

          // ─── CONTENEDOR QUE DA EL BORDE A TODA LA TABLA ───
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.bordeSuave, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5), // Un poco menor que el borde
              child: Column(
                children: [
                  // Encabezado de la tabla
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.blanco,
                      border: Border(
                        bottom: BorderSide(color: AppColors.bordeSuave, width: 1.2),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Expanded(flex: 4, child: Text('Actividad', style: _th)),
                        Expanded(flex: 3, child: Text('Materiales', style: _th)),
                        Expanded(flex: 3, child: Text('Responsable', style: _th)),
                        Expanded(
                          flex: 1,
                          child: Text('Avance', style: _th, textAlign: TextAlign.right),
                        ),
                      ],
                    ),
                  ),
                  
                  // Filas
                  ...actividades.map<Widget>((a) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.bordeSuave.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Columna Actividad
                          Expanded(
                            flex: 4,
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
                          // Columna Materiales
                          Expanded(
                            flex: 3,
                            child: Text(
                              a['materiales_usados'] ?? '-',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textoGris,
                              ),
                            ),
                          ),
                          // Columna Responsable
                          Expanded(
                            flex: 3,
                            child: Text(
                              a['responsable'] ?? '-',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textoNegro,
                              ),
                            ),
                          ),
                          // Columna Avance
                          Expanded(
                            flex: 1,
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
            ),
          ),
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