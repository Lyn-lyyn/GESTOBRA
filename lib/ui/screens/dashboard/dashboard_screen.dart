import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../obras/obra_detail_screen.dart';
//ESTA ES LA PANTALLA PRINCIPAL DE LA APLICACION (DASHBOARD)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Map<String, dynamic>> _stats = [
    {'titulo': 'Obras activas', 'valor': '7', 'color': AppColors.naranja},
    {'titulo': 'Alertas operativas', 'valor': '0', 'color': Colors.black},
    {'titulo': 'Obras registradas', 'valor': '16', 'color': Colors.black},
  ];

  final List<Map<String, dynamic>> _obras = [
    {
      'titulo': 'Edificio de oficinas corporativas',
      'cliente': 'Cliente: Inmobiliaria del Golfo S.A. de C.V.',
      'ubicacion': 'Boca del Río, Veracruz',
      'supervisor': 'Ing. Carlos Márquez',
      'fecha': '28/09/2026 al 28/10/2026',
      'avance': 0.78,
      'estado': 'EN PROCESO',
      'colorEstado': AppColors.naranja,
    },
    {
      'titulo': 'Construcción de vivienda 2 plantas',
      'cliente': 'Cliente: Sra. Juan Pérez González',
      'ubicacion': 'Cuitláhuac, Veracruz (Col. Petrolera)',
      'supervisor': 'Ing. Carlos Márquez',
      'fecha': '28/09/2026 al 28/10/2026',
      'avance': 0.44,
      'estado': 'EN PROCESO',
      'colorEstado': AppColors.naranja,
    },
    {
      'titulo': 'Pavimentación con concreto hidráulico y drenaje',
      'cliente': 'Cliente: Gobierno municipal / Obra pública',
      'ubicacion': 'Cuitláhuac, Veracruz (Av. de la Sepultura)',
      'supervisor': 'Ing. Carlos Márquez',
      'fecha': '28/09/2026 al 28/10/2026',
      'avance': 0.08,
      'estado': 'EN PROCESO',
      'colorEstado': AppColors.naranja,
    },
    {
      'titulo': 'Remodelación Centro Médico Santa María',
      'cliente': 'Cliente: Grupo Salud Integral',
      'ubicacion': 'Cuitláhuac, Veracruz',
      'supervisor': 'Ing. Carlos Márquez',
      'fecha': '28/09/2026 al 28/10/2026',
      'avance': 0.50,
      'estado': 'EN PROCESO',
      'colorEstado': AppColors.naranja,
    },
    {
      'titulo': 'Construcción de bodega industrial',
      'cliente': 'Cliente: Logística del Sureste',
      'ubicacion': 'Boca del Río, Veracruz',
      'supervisor': 'Ing. Carlos Márquez',
      'fecha': '28/09/2026 al 28/10/2026',
      'avance': 0.15,
      'estado': 'EN PROCESO',
      'colorEstado': AppColors.naranja,
    },
    {
      'titulo': 'Ampliación de red de agua potable',
      'cliente': 'Cliente: CAEV',
      'ubicacion': 'Cuitláhuac, Veracruz',
      'supervisor': 'Ing. Carlos Márquez',
      'fecha': '28/09/2026 al 28/10/2026',
      'avance': 1.0,
      'estado': 'CONCLUIDO',
      'colorEstado': Colors.green,
    },
  ];

  // Detectar si es pantalla de escritorio (>= 900px)
  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenido Marcos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // LAYOUT ADAPTATIVO
            if (_isDesktop(context))
              // ============ VISTA DE ESCRITORIO ============
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Columna IZQUIERDA: Estadísticas
                  Expanded(
                    flex: 2,
                    child: _buildMainStatsContainer(),
                  ),
                  const SizedBox(width: 16),
                  // Columna DERECHA: Proyectos
                  Expanded(
                    flex: 5,
                    child: _buildProjectsSection(),
                  ),
                ],
              )
            else
              // ============ VISTA DE MÓVIL ============
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainStatsContainer(),
                  const SizedBox(height: 20),
                  _buildProjectsSection(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo_gestobra.png',
            height: 30,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.construction, color: AppColors.naranja, size: 30),
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

  Widget _buildMainStatsContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grisfondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gris),
      ),
      child: Column(
        children: [
          Row(
            children: _stats.map((stat) => _buildStatCard(stat)).toList(),
          ),
          const SizedBox(height: 12),
          _buildBigInfoBox(),
        ],
      ),
    );
  }

  Widget _buildProjectsSection() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

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
          const Text(
            'Proyectos y obras civiles',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // BUSCADOR
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Buscar proyecto...',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.gris),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 8.0, right: 4.0),
                  child: Icon(Icons.search, size: 20, color: AppColors.gris),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                isDense: true,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Filtros
          if (isSmallScreen)
            Row(
              children: [
                _buildFilterChip('Todas', true),
                const SizedBox(width: 6),
                _buildFilterChip('Activas', false),
                const SizedBox(width: 6),
                _buildFilterChip('Concluidas', false),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildFilterChip('Todas', true),
                const SizedBox(width: 6),
                _buildFilterChip('Activas', false),
                const SizedBox(width: 6),
                _buildFilterChip('Concluidas', false),
              ],
            ),

          const SizedBox(height: 16),

          // Grid de Obras
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
              mainAxisExtent: 235,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _obras.length,
            itemBuilder: (context, index) {
              return _buildObraCard(_obras[index], context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gris),
        ),
        child: Column(
          children: [
            Text(
              stat['valor'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: stat['color'],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stat['titulo'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppColors.gris),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBigInfoBox() {
    return Container(
      width: double.infinity,
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gris),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.naranja.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.insights, color: AppColors.naranja, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Resumen General de Obras',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.65,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.naranja),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '65% de avance global en todas las obras',
                  style: TextStyle(fontSize: 11, color: AppColors.gris),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.naranja : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.naranja : AppColors.gris,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.gris,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildObraCard(Map<String, dynamic> obra, BuildContext context) {
    final bool isCompleted = obra['avance'] >= 1.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ObraDetailScreen(obra: obra),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gris),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: obra['colorEstado'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  obra['estado'],
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: obra['colorEstado'],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                obra['titulo'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),

              _buildDetailRow(Icons.business, obra['cliente']),
              _buildDetailRow(Icons.location_on, obra['ubicacion']),
              _buildDetailRow(Icons.person, obra['supervisor']),
              _buildDetailRow(Icons.calendar_today, obra['fecha']),

              const Spacer(),

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
                          value: obra['avance'],
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted ? Colors.green : AppColors.naranja,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(obra['avance'] * 100).toInt()}%',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Row(
        children: [
          Icon(icon, size: 11, color: AppColors.gris),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9.5, color: AppColors.gris),
            ),
          ),
        ],
      ),
    );
  }
}