import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'sections/bitacora_section.dart';
import 'sections/materiales_section.dart';
import 'sections/evidencias_section.dart';
import 'sections/reportes_section.dart';
import 'widgets/nueva_actividad_modal.dart';
import 'sections/pipeline_actividades_section.dart';

class ObraDetailScreen extends StatefulWidget {
  final Map<String, dynamic> obra;

  const ObraDetailScreen({super.key, required this.obra});

  @override
  State<ObraDetailScreen> createState() => _ObraDetailScreenState();
}

class _ObraDetailScreenState extends State<ObraDetailScreen> {
  int _selectedTabIndex = 0;
  bool _showPipeline = false;
  String _faseSeleccionada = 'Todas las fases';
  String _tipoReporte = 'Semanal';

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  final List<Map<String, dynamic>> _fases = [
    {'nombre': 'Preliminares', 'porcentaje': 100, 'concluidas': 2, 'total': 2},
    {'nombre': 'Cimentación', 'porcentaje': 63, 'concluidas': 2, 'total': 5},
    {'nombre': 'Estructura', 'porcentaje': 0, 'concluidas': 0, 'total': 2},
    {'nombre': 'Albañilería', 'porcentaje': 0, 'concluidas': 0, 'total': 1},
  ];

  final List<Map<String, dynamic>> _actividades = [
    {
      'fase': 'PRELIMINARES',
      'estado': 'Concluida',
      'titulo': 'Limpieza y desmonte del terreno',
      'descripcion': 'Retiro de maleza, escombros y nivelación superficial del terreno con maquinaria ligera',
      'responsable': 'Cuadrilla 1 - Don Pedro',
      'programado': 'Programado 2026/09/07 al 2026/09/09',
      'fechaInicio': DateTime(2026, 9, 7),
      'fechaFin': DateTime(2026, 9, 9),
      'reporte': 'Concluida sin novedades',
      'avance': 1.0,
      'ponderacion': '5%',
      'isCompleted': true,
    },
    {
      'fase': 'PRELIMINARES',
      'estado': 'Concluida',
      'titulo': 'Trazo y nivelación topográfica',
      'descripcion': 'Colocación de valas de madera y tendido de hilos según planos arquitectónicos y estructurales',
      'responsable': 'Topógrafo Miguel Narvaez',
      'programado': 'Programado 2026/09/10 al 2026/09/11',
      'fechaInicio': DateTime(2026, 9, 10),
      'fechaFin': DateTime(2026, 9, 11),
      'reporte': 'Verificados ejes perimetrales con el perito responsable',
      'avance': 1.0,
      'ponderacion': '5%',
      'isCompleted': true,
    },
    {
      'fase': 'CIMENTACIÓN',
      'estado': 'Concluida',
      'titulo': 'Excavación para zapatas y contratrabes',
      'descripcion': 'Excavación a cielo abierto a 1.60 m de profundidad para 12 zapatas aisladas y zanjas de liga',
      'responsable': 'Cuadrilla 2 - Operador Retro',
      'programado': 'Programado 2026/09/12 al 2026/09/16',
      'fechaInicio': DateTime(2026, 9, 12),
      'fechaFin': DateTime(2026, 9, 16),
      'reporte': 'Suelo arcilloso duro. Se alcanzó estrato resistente a 1.55m',
      'avance': 1.0,
      'ponderacion': '10%',
      'isCompleted': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _isDesktop(context)
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 420,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildObraHeader(),
                        const SizedBox(height: 16),
                        _buildPipelineButton(),
                        const SizedBox(height: 12),
                        _buildTabs(),
                        
                        // AQUÍ ESTÁN TUS BOTONES
                        if (_selectedTabIndex == 4 && !_showPipeline) ...[
                          const SizedBox(height: 16),
                          _buildSelectorTiempo(),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTabContent(),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildObraHeader(),
                  const SizedBox(height: 16),
                  _buildPipelineButton(),
                  const SizedBox(height: 12),
                  _buildTabs(),
                  
                  // AQUÍ ESTÁN TUS BOTONES EN MÓVIL
                  if (_selectedTabIndex == 4 && !_showPipeline) ...[
                    const SizedBox(height: 16),
                    _buildSelectorTiempo(),
                  ],
                  
                  const SizedBox(height: 16),
                  _buildTabContent(),
                ],
              ),
            ),
    );
  }

  Widget _buildSelectorTiempo() {
    final opciones = ['Diario', 'Semanal', 'Quincenal', 'Acumulado'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: opciones.map((opcion) {
        final isSelected = _tipoReporte == opcion;
        return GestureDetector(
          onTap: () => setState(() => _tipoReporte = opcion),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.naranja : AppColors.blanco,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.naranja : AppColors.gris,
                width: 1.2,
              ),
            ),
            child: Text(
              opcion,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textoGris,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo_gestobra.png',
            height: 28,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.construction, color: AppColors.naranja, size: 28),
          ),
          const SizedBox(width: 8),
          const Text(
            'GestObra',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.naranja),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildObraHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
              _buildBadge('OBRA-2026-042', AppColors.naranja, isOutlined: true),
              const SizedBox(width: 8),
              _buildBadge('OBRA EN EJECUCIÓN', Colors.green.shade700, isOutlined: true),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.obra['titulo'] ?? 'Construcción de vivienda 2 plantas',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            widget.obra['cliente'] ?? 'Cliente: Sr. Juan Pérez González',
            style: const TextStyle(fontSize: 12, color: AppColors.naranja, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Construcción de vivienda residencial unifamiliar de 2 plantas con cimentación a base de zapatas aisladas, estructura de concreto armado, losa aligerada y acabados de primera',
            style: TextStyle(fontSize: 12, color: AppColors.gris, height: 1.4),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildIconText(Icons.location_on, 'Coaztacoalcos, Veracruz (Col. Petrolera)'),
              _buildIconText(Icons.person, 'Ing. Carlos Morales'),
              _buildIconText(Icons.calendar_today, '07/02/2026 al 15/04/2026'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gris),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text(
                      'AVANCE GENERAL',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.gris),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '40%',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.naranja),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: const LinearProgressIndicator(
                              value: 0.40,
                              backgroundColor: Colors.white,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.naranja),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '4 de 10 concluidas',
                          style: TextStyle(fontSize: 11, color: AppColors.gris),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () => setState(() => _showPipeline = true),
        icon: const Icon(Icons.view_timeline_outlined, size: 19),
        label: const Text('Vista de pipeline',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _showPipeline ? AppColors.naranja : AppColors.noseleccionado,
          foregroundColor: _showPipeline ? Colors.white : AppColors.gris,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['ACTIVIDADES', 'BITÁCORA', 'MATERIALES', 'EVIDENCIAS', 'REPORTES'];

    return Row(
      children: List.generate(tabs.length, (index) {
        final isSelected = !_showPipeline && _selectedTabIndex == index;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedTabIndex = index;
                _showPipeline = false;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.naranja : AppColors.noseleccionado,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.gris,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActionBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grisfondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gris),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: Text(
              'Programa y control de actividades',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFaseDropdown(),
              const SizedBox(width: 8),
              _buildNuevaActividadButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFaseDropdown() {
    return SizedBox(
      height: 40,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.noseleccionado,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<String>(
          value: _faseSeleccionada,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.gris),
          style: const TextStyle(fontSize: 12, color: AppColors.gris, fontWeight: FontWeight.bold),
          items: ['Todas las fases', 'Preliminares', 'Cimentación', 'Estructura', 'Albañilería']
              .map((fase) => DropdownMenuItem(value: fase, child: Text(fase)))
              .toList(),
          onChanged: (value) => setState(() => _faseSeleccionada = value!),
        ),
      ),
    );
  }

  Widget _buildNuevaActividadButton() {
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: _abrirModalNuevaActividad,
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Nueva Actividad', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.naranja,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  void _abrirModalNuevaActividad() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return NuevaActividadModal(
          fasesDisponibles: _fases,
          onCrear: (nuevaActividad) {
            setState(() {
              _actividades.insert(0, nuevaActividad);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Actividad creada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFasesResumen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;

        if (isDesktop) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _fases.map((fase) {
              return SizedBox(width: 200, child: _buildFaseCard(fase));
            }).toList(),
          );
        }

        return Row(
          children: _fases.map((fase) {
            return Expanded(child: _buildFaseCard(fase));
          }).toList(),
        );
      },
    );
  }

  Widget _buildFaseCard(Map<String, dynamic> fase) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.grisfondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gris),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${fase['porcentaje']}%',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: fase['porcentaje'] == 100 ? Colors.green : AppColors.naranja,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            fase['nombre'],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${fase['concluidas']} de ${fase['total']} concluidas',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: AppColors.gris),
          ),
        ],
      ),
    );
  }

  Widget _buildActividadCard(Map<String, dynamic> actividad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gris),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildBadge(actividad['fase'], AppColors.naranja, isOutlined: true),
              const SizedBox(width: 8),
              _buildBadge(actividad['estado'], Colors.green.shade700, icon: Icons.check),
              const Spacer(),
              Text(
                'Ponderación ${actividad['ponderacion']}',
                style: const TextStyle(fontSize: 10, color: AppColors.gris),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            actividad['titulo'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            actividad['descripcion'],
            style: const TextStyle(fontSize: 12, color: AppColors.gris, height: 1.4),
          ),
          const SizedBox(height: 12),
          _buildIconText(Icons.person, actividad['responsable']),
          const SizedBox(height: 4),
          _buildIconText(Icons.calendar_today, actividad['programado']),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.naranja.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.naranja.withOpacity(0.3)),
            ),
            child: Text(
              'Último reporte: "${actividad['reporte']}"',
              style: const TextStyle(fontSize: 11, color: AppColors.naranja, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Avance actual', style: TextStyle(fontSize: 10, color: AppColors.gris)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: actividad['avance'],
                                backgroundColor: Colors.grey.shade100,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  actividad['isCompleted'] ? Colors.green : AppColors.naranja,
                                ),
                                minHeight: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(actividad['avance'] * 100).toInt()}%',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.naranja,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Editar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActividadesSection() {
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
          ..._actividades.map((actividad) => _buildActividadCard(actividad)),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color, {bool isOutlined = false, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: isOutlined ? Border.all(color: color) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.gris),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 11, color: AppColors.gris),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    if (_showPipeline) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActionBar(),
          const SizedBox(height: 16),
          PipelineActividadesSection(
            actividades: _actividades,
            fases: _fases,
            faseSeleccionada: _faseSeleccionada,
          ),
        ],
      );
    }

    return IndexedStack(
      index: _selectedTabIndex,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionBar(),
            const SizedBox(height: 16),
            _buildFasesResumen(),
            const SizedBox(height: 20),
            _buildActividadesSection(),
          ],
        ),
        BitacoraSection(obra: widget.obra),
        MaterialesSection(obra: widget.obra),
        EvidenciasSection(
          obra: widget.obra,
          fasesDisponibles: _fases,
        ),
        ReportesSection(
          obra: widget.obra,
          tipoReporteInicial: _tipoReporte,
        ),
      ],
    );
  }
}