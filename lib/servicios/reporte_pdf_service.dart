import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportePdfService {
  static Future<pw.MemoryImage?> _cargarImagenDesdeUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return pw.MemoryImage(response.bodyBytes);
      }
    } catch (_) {}
    return null;
  }

  static Future<pw.MemoryImage?> _cargarImagenAsset(String ruta) async {
    try {
      final data = await rootBundle.load(ruta);
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  static Future<void> generarYCompartir({
    required Map<String, dynamic> obra,
    required Map<String, dynamic> datos,
  }) async {
    final doc = pw.Document();

    final estiloCuerpo = const pw.TextStyle(fontSize: 9);
    final estiloSub = pw.TextStyle(
      fontSize: 8,
      color: PdfColors.grey700,
    );

    // ─── Cargar imágenes ───
    final logo = await _cargarImagenAsset('assets/images/logo_gestobra.png');

    final evidencias = (datos['evidencias'] as List?) ?? [];
    final List<pw.MemoryImage?> imagenesEvidencias = [];
    for (final ev in evidencias) {
      final url = ev is Map ? ev['url'] as String : ev as String;
      imagenesEvidencias.add(await _cargarImagenDesdeUrl(url));
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          // ─── ENCABEZADO ───
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  if (logo != null)
                    pw.Image(logo, height: 24)
                  else
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#F57C00'),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'G',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  pw.SizedBox(width: 6),
                  pw.Text(
                    'GestObra',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                      color: PdfColor.fromHex('#212121'),
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'REPORTE TÉCNICO #${datos['codigoReporte']}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                      color: PdfColor.fromHex('#212121'),
                    ),
                  ),
                  pw.Text('Periodo: ${datos['periodo']}',
                      style: const pw.TextStyle(fontSize: 8)),
                  pw.Text('Generado el: ${datos['fechaGeneracion']}',
                      style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 8),

          // ─── DATOS DE OBRA ───
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _campo('Obra', obra['titulo'] ?? 'Obra'),
                    _campo('Cliente', datos['cliente']),
                    _campo('Ubicación', datos['ubicacion']),
                  ],
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _campo('Residente a Cargo', datos['residente']),
                    _campo('Plazo Contractual', datos['plazoContractual']),
                    _campo('Estado', datos['estado']),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 14),

          // ─── 1. AVANCE ───
          _seccion('1. Balance de Avance Físico del Periodo'),
          pw.SizedBox(height: 6),
          pw.Row(
            children: [
              _cuadro('Preliminares', '${datos['avancePreliminares']}%'),
              pw.SizedBox(width: 8),
              _cuadro('Cimentación', '${datos['avanceCimentacion']}%'),
              pw.SizedBox(width: 8),
              _cuadro('Estructura', '${datos['avanceEstructura']}%'),
              pw.SizedBox(width: 8),
              _cuadro('Albañilería', '${datos['avanceAlbanileria']}%'),
            ],
          ),
          pw.SizedBox(height: 14),

          // ─── 2. ACTIVIDADES ───
          _seccion('2. Actividades y Frentes de Trabajo'),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Actividad', 'Responsable', 'Avance'],
            data: (datos['actividades'] as List).map<List<String>>((a) {
              return [
                '${a['actividad']} (${a['fase']})',
                a['responsable'].toString(),
                '${a['avance']}%',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration:
                pw.BoxDecoration(color: PdfColor.fromHex('#1A1F36')),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
          ),
          pw.SizedBox(height: 14),

          // ─── 3. MATERIALES (2 columnas: Material y Cantidad) ───
          _seccion('3. Resumen de Materiales Utilizados en el Periodo'),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Material', 'Cantidad'],
            data: (datos['materiales'] as List).map<List<String>>((m) {
              return [
                m['material'].toString(),
                '${m['cantidad']} ${m['unidad']}',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration:
                pw.BoxDecoration(color: PdfColor.fromHex('#1A1F36')),
            cellStyle: const pw.TextStyle(fontSize: 8),
            columnWidths: {
              0: const pw.FlexColumnWidth(6),  // Material
              1: const pw.FlexColumnWidth(3),  // Cantidad + unidad
            },
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 14),

          // ─── 4. INCIDENCIAS ───
          _seccion('4. Incidencias / Paros Registrados en el Periodo'),
          pw.SizedBox(height: 6),
          (datos['incidencias'] as List).isEmpty
              ? pw.Text('Sin incidencias ni paros registrados.',
                  style: estiloCuerpo)
              : pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children:
                      (datos['incidencias'] as List).map<pw.Widget>((i) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6, top: 2),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            '${i['tipo']} - ${i['descripcion']}',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#212121'),
                            ),
                          ),
                          pw.SizedBox(height: 1),
                          pw.Text(
                            'Estado: ${i['estado']}     Fecha: ${i['fecha']}',
                            style: estiloSub,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
          pw.SizedBox(height: 20),

          // ─── 5. EVIDENCIAS ───
          _seccion('5. Evidencias Gráficas Representativas'),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(evidencias.length, (index) {
              final img = imagenesEvidencias[index];
              final ev = evidencias[index];
              final titulo = ev is Map ? (ev['titulo'] ?? '') : '';

              return pw.SizedBox(
                width: 110,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    if (img != null)
                      pw.Image(
                        img,
                        height: 75,
                        fit: pw.BoxFit.cover,
                      )
                    else
                      pw.Container(
                        height: 75,
                        color: PdfColors.grey300,
                        alignment: pw.Alignment.center,
                        child: pw.Text('Sin imagen',
                            style: const pw.TextStyle(fontSize: 7)),
                      ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(2),
                      color: PdfColor.fromHex('#1A1F36'),
                      child: pw.Text(
                        titulo,
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                            color: PdfColors.white, fontSize: 7),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          // ─── ESPACIO GRANDE ANTES DE FIRMAS ───
          pw.SizedBox(height: 120),

          // ─── FIRMAS ───
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _firma(datos['residente'], 'Residente de Obra / D.R.O.'),
              _firma(datos['cliente'], 'Cliente / Supervisión Externa'),
            ],
          ),

          pw.SizedBox(height: 40),

          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 6),
          pw.Center(
            child: pw.Text(
              'Generado por GestObra - ${datos['fechaGeneracion']}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'reporte_${obra['codigo'] ?? 'obra'}.pdf',
    );
  }

  static pw.Widget _seccion(String texto) {
    return pw.Text(
      texto,
      style: pw.TextStyle(
        fontSize: 11,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromHex('#212121'),
      ),
    );
  }

  static pw.Widget _campo(String etiqueta, String valor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.RichText(
        text: pw.TextSpan(
          style: const pw.TextStyle(fontSize: 9),
          children: [
            pw.TextSpan(
              text: '$etiqueta: ',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#212121'),
              ),
            ),
            pw.TextSpan(text: valor),
          ],
        ),
      ),
    );
  }

  static pw.Widget _cuadro(String titulo, String valor) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          children: [
            pw.Text(titulo, style: const pw.TextStyle(fontSize: 8)),
            pw.SizedBox(height: 4),
            pw.Text(
              valor,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#F57C00'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _firma(String nombre, String cargo) {
    return pw.Column(
      children: [
        pw.Container(width: 180, height: 1, color: PdfColors.grey600),
        pw.SizedBox(height: 14),
        pw.Text(
          nombre,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#212121'),
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(cargo, style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }
}