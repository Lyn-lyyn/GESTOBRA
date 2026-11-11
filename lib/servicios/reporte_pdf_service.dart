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

    final logo = await _cargarImagenAsset('assets/images/logo_gestobra.png');

    final evidencias = (datos['evidencias'] as List?) ?? [];
    final List<pw.MemoryImage?> imagenesEvidencias = [];
    for (final ev in evidencias) {
      final url = ev is Map ? ev['url'] as String : ev as String;
      imagenesEvidencias.add(await _cargarImagenDesdeUrl(url));
    }

    // Estilos generales
    final estiloTituloSeccion = pw.TextStyle(
      fontSize: 9,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );
    final estiloCuerpo = const pw.TextStyle(fontSize: 8);
    final estiloBold = pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold);
    final colorGrisFondo = PdfColor.fromHex('#E5E7EB');
    final colorBorde = PdfColors.grey700;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        footer: (pw.Context context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Divider(color: colorBorde, height: 1),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  'Documento generado por GestObra',
                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
        build: (context) => [
          // ─── ENCABEZADO CORPORATIVO ───
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: colorBorde, width: 1),
            ),
            child: pw.Column(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Row(
                        children: [
                          if (logo != null) pw.Image(logo, height: 28),
                          pw.SizedBox(width: 10),
                          pw.Text('GestObra',
                              style: pw.TextStyle(
                                  fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.Text(
                        'REPORTE TÉCNICO #${datos['codigoReporte']}',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Periodo: ${datos['periodo']}',
                              style: estiloCuerpo),
                          pw.Text('Generado el: ${datos['fechaGeneracion']}',
                              style: estiloCuerpo),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.Divider(height: 1, color: colorBorde),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        flex: 1,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.RichText(
                                text: pw.TextSpan(children: [
                              pw.TextSpan(text: 'Obra: ', style: estiloBold),
                              pw.TextSpan(text: obra['titulo'] ?? '', style: estiloCuerpo),
                            ])),
                            pw.SizedBox(height: 4),
                            pw.RichText(
                                text: pw.TextSpan(children: [
                              pw.TextSpan(text: 'Cliente: ', style: estiloBold),
                              pw.TextSpan(text: datos['cliente'] ?? '', style: estiloCuerpo),
                            ])),
                            pw.SizedBox(height: 4),
                            pw.RichText(
                                text: pw.TextSpan(children: [
                              pw.TextSpan(text: 'Ubicación: ', style: estiloBold),
                              pw.TextSpan(text: datos['ubicacion'] ?? '', style: estiloCuerpo),
                            ])),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.RichText(
                                textAlign: pw.TextAlign.right,
                                text: pw.TextSpan(children: [
                              pw.TextSpan(text: 'Residente a Cargo: ', style: estiloBold),
                              pw.TextSpan(text: datos['residente'] ?? '', style: estiloCuerpo),
                            ])),
                            pw.SizedBox(height: 4),
                            pw.RichText(
                                textAlign: pw.TextAlign.right,
                                text: pw.TextSpan(children: [
                              pw.TextSpan(text: 'Plazo Contractual: ', style: estiloBold),
                              pw.TextSpan(text: datos['plazoContractual'] ?? '', style: estiloCuerpo),
                            ])),
                            pw.SizedBox(height: 4),
                            pw.RichText(
                                textAlign: pw.TextAlign.right,
                                text: pw.TextSpan(children: [
                              pw.TextSpan(text: 'Estado: ', style: estiloBold),
                              pw.TextSpan(
                                  text: datos['estado'] ?? '',
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor.fromHex('#2E7D32'),
                                  )),
                            ])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),

          // ─── 1. AVANCE ───
          _tablaHeader('1. REPORTE DE AVANCE %', estiloTituloSeccion, colorGrisFondo, colorBorde),
          pw.Table(
            border: pw.TableBorder.all(color: colorBorde, width: 1),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F3F4F6')),
                children: [
                  _celdaHeader('CONCEPTO / ACTIVIDAD', estiloBold),
                  _celdaHeader('% AVANCE', estiloBold, align: pw.TextAlign.center),
                ],
              ),
              _filaAvance('Preliminares', '${datos['avancePreliminares']}%', estiloCuerpo),
              _filaAvance('Cimentación', '${datos['avanceCimentacion']}%', estiloCuerpo),
              _filaAvance('Estructura', '${datos['avanceEstructura']}%', estiloCuerpo),
              _filaAvance('Albañilería', '${datos['avanceAlbanileria']}%', estiloCuerpo),
              pw.TableRow(
                decoration: pw.BoxDecoration(color: colorGrisFondo),
                children: [
                  _celdaTexto('AVANCE GENERAL DE LA OBRA', estiloBold),
                  _celdaTexto('${datos['avanceGeneral']}%', estiloBold, align: pw.TextAlign.center),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),

          // ─── 2. ACTIVIDADES Y FRENTES ───
          _tablaHeader('2. ACTIVIDADES Y FRENTES DE TRABAJO', estiloTituloSeccion, colorGrisFondo, colorBorde),
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: colorBorde, width: 1),
            headers: ['PARTIDA', 'DESCRIPCIÓN', 'MATERIALES', 'RESPONSABLE', '% AVANCE'],
            headerStyle: estiloBold,
            headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#F3F4F6')),
            headerAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerLeft,
              4: pw.Alignment.centerRight,
            },
            cellStyle: estiloCuerpo,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerLeft,
              4: pw.Alignment.centerRight,
            },
            columnWidths: {
              0: const pw.FlexColumnWidth(2.5),
              1: const pw.FlexColumnWidth(4),
              2: const pw.FlexColumnWidth(2.5),
              3: const pw.FlexColumnWidth(2.5),
              4: const pw.FlexColumnWidth(1.2),
            },
            data: (datos['actividades'] as List).map<List<String>>((a) {
              return [
                a['fase'].toString().toUpperCase(),
                a['actividad'].toString(),
                a['materiales_usados']?.toString() ?? '-',
                a['responsable'].toString(),
                '${a['avance']}%',
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 10),

          // ─── 3. MATERIALES ───
          _tablaHeader('3. RESUMEN DE MATERIALES UTILIZADOS', estiloTituloSeccion, colorGrisFondo, colorBorde),
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: colorBorde, width: 1),
            headers: ['MATERIAL', 'CANTIDAD'],
            headerStyle: estiloBold,
            headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#F3F4F6')),
            headerAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
            },
            cellStyle: estiloCuerpo,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
            },
            columnWidths: {
              0: const pw.FlexColumnWidth(7),
              1: const pw.FlexColumnWidth(2),
            },
            data: (datos['materiales'] as List).map<List<String>>((m) {
              return [
                m['material'].toString(),
                '${m['cantidad']} ${m['unidad']}',
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 10),

          // ─── 4. PERSONAL Y MAQUINARIA ───
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    _tablaHeader('PERSONAL', estiloTituloSeccion, colorGrisFondo, colorBorde),
                    pw.Table(
                      border: pw.TableBorder.all(color: colorBorde, width: 1),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(5),
                        1: const pw.FlexColumnWidth(1),
                      },
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F3F4F6')),
                          children: [
                            _celdaHeader('CATEGORÍA', estiloBold),
                            _celdaHeader('CANT.', estiloBold, align: pw.TextAlign.center),
                          ],
                        ),
                        ...(datos['personal'] as List? ?? []).map((p) {
                          return pw.TableRow(
                            children: [
                              _celdaTexto(p['categoria'].toString(), estiloCuerpo),
                              _celdaTexto(p['cantidad'].toString(), estiloCuerpo, align: pw.TextAlign.center),
                            ],
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    _tablaHeader('MAQUINARIA / EQUIPO', estiloTituloSeccion, colorGrisFondo, colorBorde),
                    pw.Table(
                      border: pw.TableBorder.all(color: colorBorde, width: 1),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(5),
                        1: const pw.FlexColumnWidth(1),
                      },
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F3F4F6')),
                          children: [
                            _celdaHeader('EQUIPO', estiloBold),
                            _celdaHeader('CANT.', estiloBold, align: pw.TextAlign.center),
                          ],
                        ),
                        ...(datos['maquinaria'] as List? ?? []).map((m) {
                          return pw.TableRow(
                            children: [
                              _celdaTexto(m['equipo'].toString(), estiloCuerpo),
                              _celdaTexto(m['cantidad'].toString(), estiloCuerpo, align: pw.TextAlign.center),
                            ],
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),

          // ─── 5. INCIDENCIAS ───
          _tablaHeader('5. INCIDENCIAS / PAROS REGISTRADOS', estiloTituloSeccion, colorGrisFondo, colorBorde),
          pw.Table(
            border: pw.TableBorder.all(color: colorBorde, width: 1),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(5),
              2: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F3F4F6')),
                children: [
                  _celdaHeader('TIPO', estiloBold),
                  _celdaHeader('DESCRIPCIÓN', estiloBold),
                  _celdaHeader('ESTADO / FECHA', estiloBold),
                ],
              ),
              if ((datos['incidencias'] as List).isEmpty)
                pw.TableRow(children: [
                  _celdaTexto('-', estiloCuerpo),
                  _celdaTexto('Sin incidencias reportadas', estiloCuerpo),
                  _celdaTexto('-', estiloCuerpo),
                ])
              else
                ...(datos['incidencias'] as List).map((i) {
                  return pw.TableRow(
                    children: [
                      _celdaTexto(i['tipo'].toString().toUpperCase(), estiloCuerpo),
                      _celdaTexto(i['descripcion'].toString(), estiloCuerpo),
                      _celdaTexto('${i['estado']}\n${i['fecha']}', estiloCuerpo),
                    ],
                  );
                }),
            ],
          ),
          pw.SizedBox(height: 10),

          // ─── 6. EVIDENCIAS FOTOGRÁFICAS (Ancho completo y tarjetas con tamaño uniforme) ───
          _tablaHeader('6. REPORTE FOTOGRÁFICO', estiloTituloSeccion, colorGrisFondo, colorBorde),
          pw.Container(
            width: double.infinity, // Ocupa todo el ancho de la página igual que las tablas superiores
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: colorBorde, width: 1),
            ),
            padding: const pw.EdgeInsets.all(8),
            child: evidencias.isEmpty
                ? pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('No hay evidencias fotográficas registradas en este periodo.', style: estiloCuerpo),
                  )
                : pw.Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(evidencias.length, (index) {
                      final img = imagenesEvidencias[index];
                      final titulo = evidencias[index] is Map ? (evidencias[index]['titulo'] ?? '') : '';

                      // TARJETA CON TAMAÑO UNIFORME Y ALTURA FIJA PARA EL PIE DE FOTO
                      return pw.Container(
                        width: 140,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.ClipRRect(
                          horizontalRadius: 4,
                          verticalRadius: 4,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                            children: [
                              // Imagen con altura fija
                              img != null
                                  ? pw.Image(img, height: 90, fit: pw.BoxFit.cover)
                                  : pw.Container(
                                      height: 90,
                                      color: PdfColors.grey200,
                                      alignment: pw.Alignment.center,
                                      child: pw.Text('Sin imagen', style: estiloCuerpo),
                                    ),
                              
                              // Contenedor de título con altura fija para que todas las tarjetas midan exactamente lo mismo
                              pw.Container(
                                height: 35, // Altura fija uniforme para el pie de foto (hasta 2 líneas)
                                padding: const pw.EdgeInsets.symmetric(horizontal: 4),
                                alignment: pw.Alignment.center, // Centrado vertical y horizontal automático
                                decoration: pw.BoxDecoration(
                                  color: PdfColor.fromHex('#1F2937'), // Fondo gris oscuro corporativo
                                ),
                                child: pw.Text(
                                  titulo.isNotEmpty ? titulo : 'Sin descripción',
                                  textAlign: pw.TextAlign.center,
                                  maxLines: 2,
                                  style: pw.TextStyle(
                                    fontSize: 7.5,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.white, // Texto blanco
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
          ),
          pw.SizedBox(height: 10),

          // ─── 7. NOTAS GENERALES ───
          _tablaHeader('7. NOTAS GENERALES', estiloTituloSeccion, colorGrisFondo, colorBorde),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: colorBorde, width: 1),
            ),
            child: pw.Text(
              datos['notasGenerales'] ?? 'SIN NOTAS',
              style: estiloCuerpo,
            ),
          ),
          
          // ─── FORZAR SALTO DE PÁGINA ANTES DE LAS FIRMAS ───
          pw.NewPage(),

          pw.SizedBox(height: 50),

          // ─── FIRMAS ───
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _firmaFormal(datos['residente'], 'RESIDENTE DE OBRA', estiloBold, estiloCuerpo),
              _firmaFormal(datos['cliente'], 'SUPERVISIÓN / CLIENTE', estiloBold, estiloCuerpo),
            ],
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'reporte_${obra['codigo'] ?? 'obra'}.pdf',
    );
  }

  // ─── HELPERS PARA DISEÑO TIPO DOCUMENTO ───

  static pw.Widget _tablaHeader(String titulo, pw.TextStyle estilo, PdfColor fondo, PdfColor borde) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#1F2937'),
        border: pw.Border.all(color: borde, width: 1),
      ),
      child: pw.Text(titulo, style: estilo),
    );
  }

  static pw.Widget _celdaHeader(String texto, pw.TextStyle estilo, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(texto, style: estilo, textAlign: align),
    );
  }

  static pw.Widget _celdaTexto(String texto, pw.TextStyle estilo, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(texto, style: estilo, textAlign: align),
    );
  }

  static pw.TableRow _filaAvance(String concepto, String valor, pw.TextStyle estilo) {
    return pw.TableRow(
      children: [
        _celdaTexto(concepto, estilo),
        _celdaTexto(valor, estilo, align: pw.TextAlign.center),
      ],
    );
  }

  static pw.Widget _firmaFormal(String nombre, String cargo, pw.TextStyle estiloBold, pw.TextStyle estiloCuerpo) {
    return pw.Column(
      children: [
        pw.Container(width: 180, height: 1, color: PdfColors.black),
        pw.SizedBox(height: 14),
        pw.Text(nombre, style: estiloBold),
        pw.Text(cargo, style: pw.TextStyle(fontSize: 7)),
      ],
    );
  }
}