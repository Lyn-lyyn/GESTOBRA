import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import 'sections/bitacora_section.dart';
import 'sections/materiales_section.dart';
import 'sections/evidencias_section.dart';
import 'sections/reportes_section.dart';
import 'widgets/nueva_actividad_modal.dart';
//ESTA ES LA PANTALLA DE DETALLES DE LA OBRA (PERFIL DE O¿LA OBRA)
//LAS SECCIONES (BOTONES BITACORA,EVIDENCIAS,ETC) LOS ENCONTRARAN DENTRO DE LA CARPETA SECTIONS
class ObraDetailScreen extends StatefulWidget {
  final Map<String, dynamic> obra;

  const ObraDetailScreen({super.key, required this.obra});

  @override
  State<ObraDetailScreen> createState() => _ObraDetailScreenState();
}

class _ObraDetailScreenState extends State<ObraDetailScreen> {
  int _selectedTabIndex = 0;
  String _faseSeleccionada = 'Todas las fases';

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
    // ============ VISTA DE ESCRITORIO ============
    ? SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna IZQUIERDA: Cabecera + Tabs
            SizedBox(
              width: 420, // Ancho fijo para la columna izquierda
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildObraHeader(),
                  const SizedBox(height: 16),
                  _buildTabs(),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Columna DERECHA: Contenido del tab
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      )
    // ============ VISTA DE MÓVIL (como está actualmente) ============
    : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildObraHeader(),
            const SizedBox(height: 16),
            _buildTabs(),
            const SizedBox(height: 16),
            _buildTabContent(),
          ],
        ),
      ),
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

  // 1. CABECERA DE LA OBRA
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

          // RECUADRO DE AVANCE GENERAL
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
                // Columna del porcentaje
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'AVANCE GENERAL',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.gris),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '40%',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.naranja),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Columna de la barra y el contador (con padding superior para bajarla)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0), // <-- EMPUJA LA BARRA HACIA ABAJO
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
                            child: LinearProgressIndicator(
                              value: 0.40,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.naranja),
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

  // 2. TABS DE NAVEGACIÓN (CORREGIDO: Scroll con espacio extra al final)
 Widget _buildTabs() {
  final tabs = ['ACTIVIDADES', 'BITÁCORA', 'MATERIALES', 'EVIDENCIAS', 'REPORTES'];
  
  return Row(
    children: List.generate(tabs.length, (index) {
      final isSelected = _selectedTabIndex == index;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
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

  // 3. BARRA DE ACCIONES (CORREGIDO: Botón del mismo alto)
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
// Helper para el dropdown (así lo reutilizas en ambos layouts)
Widget _buildFaseDropdown() {
  return SizedBox(
    height: 40,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
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

// Helper para el botón
Widget _buildNuevaActividadButton() {
  return SizedBox(
    height: 40,
    child: ElevatedButton.icon(
      onPressed: _abrirModalNuevaActividad, // <-- CAMBIO AQUÍ
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
            // Agregamos la nueva actividad al inicio de la lista
            _actividades.insert(0, nuevaActividad);
          });
          // Opcional: mostrar un SnackBar de confirmación
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

  // 4. RESUMEN DE FASES
Widget _buildFasesResumen() {
  return LayoutBuilder(
    builder: (context, constraints) {
      // En escritorio, limitamos el ancho de cada tarjeta a 200px
      final isDesktop = constraints.maxWidth > 900;
      
      if (isDesktop) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _fases.map((fase) {
            return SizedBox(
              width: 200,
              child: _buildFaseCard(fase),
            );
          }).toList(),
        );
      }
      
      // En móvil, como está actualmente (Row con Expanded)
      return Row(
        children: _fases.map((fase) {
          return Expanded(child: _buildFaseCard(fase));
        }).toList(),
      );
    },
  );
}

// Extraemos la tarjeta a un helper
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

  // 5. TARJETA DE ACTIVIDAD
  Widget _buildActividadCard(Map<String, dynamic> actividad) {
    return Container(
     margin: const EdgeInsets.only(bottom: 8), // <-- Reducir a 8 para que no quede tan separado
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
// 6. SECCIÓN DE ACTIVIDADES (agrupadas en un contenedor)
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
        // Puedes agregar un título si quieres
        // const Text(
        //   'Actividades',
        //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        // ),
        // const SizedBox(height: 12),
        
        // Aquí van todas las tarjetas de actividades
        ..._actividades.map((actividad) => _buildActividadCard(actividad)),
      ],
    ),
  );
}


  // --- HELPERS ---

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
              color: isOutlined ? color : color,
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
      ReportesSection(obra: widget.obra),
    ],
  );
}
}
