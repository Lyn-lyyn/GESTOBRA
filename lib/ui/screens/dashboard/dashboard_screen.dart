import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../obras/obra_detail_screen.dart';

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

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  @override
  Widget build(BuildContext context) {
    if (_isDesktop(context)) {
      return _buildDesktopLayout();
    }
    return _buildMobileLayout();
  }

  // ============================================================
  // VISTA DE ESCRITORIO (Estilo Opción 1)
  // ============================================================
  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Container(
          width: 400,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Buscar obra, cliente o reporte...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
              prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.grey), onPressed: () {}),
          const SizedBox(width: 16),
          const CircleAvatar(
            backgroundColor: AppColors.naranja,
            radius: 18,
            child: Text('M', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          const Text('Marcos', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          const SizedBox(width: 32),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: _stats.map((stat) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat['titulo'],
                          style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stat['valor'],
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: stat['color']),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            const Text(
              'Proyectos y obras civiles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                mainAxisExtent: 260,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _obras.length,
              itemBuilder: (context, index) {
                return _buildDesktopObraCard(_obras[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // VISTA MÓVIL (Exactamente tu diseño original)
  // ============================================================
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
      ),
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
            _buildMainStatsContainer(),
            const SizedBox(height: 20),
            _buildProjectsSection(),
          ],
        ),
      ),
    );
  }

  // ─── WIDGETS DE LA VISTA MÓVIL (TAL CUAL LOS TENÍAS) ───

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
              return _buildMobileObraCard(_obras[index], context);
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

  Widget _buildMobileObraCard(Map<String, dynamic> obra, BuildContext context) {
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

              _buildDetailRow(Icons.business, obra['cliente'], 9.5),
              _buildDetailRow(Icons.location_on, obra['ubicacion'], 9.5),
              _buildDetailRow(Icons.person, obra['supervisor'], 9.5),
              _buildDetailRow(Icons.calendar_today, obra['fecha'], 9.5),

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

  // ─── Componentes para Escritorio ───
  Widget _buildDesktopObraCard(Map<String, dynamic> obra) {
    final bool isCompleted = obra['avance'] >= 1.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ObraDetailScreen(obra: obra)));
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: obra['colorEstado'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  obra['estado'],
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: obra['colorEstado']),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                obra['titulo'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.business, obra['cliente'], 11.5),
              _buildDetailRow(Icons.location_on, obra['ubicacion'], 11.5),
              _buildDetailRow(Icons.person, obra['supervisor'], 11.5),
              _buildDetailRow(Icons.calendar_today, obra['fecha'], 11.5),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: obra['avance'],
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? Colors.green : AppColors.naranja),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(obra['avance'] * 100).toInt()}%',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isCompleted ? Colors.green : AppColors.naranja),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Row(
        children: [
          Icon(icon, size: fontSize + 2, color: AppColors.gris),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: fontSize, color: AppColors.gris),
            ),
          ),
        ],
      ),
    );
  }
}