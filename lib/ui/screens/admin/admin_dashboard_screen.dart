import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Panel de Control Global',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textoNegro),
                ),
                const SizedBox(height: 20),
                
                // ─── KPIs ───
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 800;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildKpiCard('Obras Activas', '12', Icons.engineering, AppColors.naranja, isMobile),
                        _buildKpiCard('Personal en Campo', '34', Icons.groups, AppColors.estadoVerde, isMobile),
                        _buildKpiCard('Obras en Riesgo', '2', Icons.warning_amber_rounded, AppColors.estadoRojo, isMobile),
                        _buildKpiCard('Presupuesto Ejercido', '\$1.2M', Icons.attach_money, Colors.blue, isMobile),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // ─── Gráficas ───
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 900;
                    final graficaAvance = _buildGraficaAvance();
                    final graficaPresupuesto = _buildGraficaPresupuesto();

                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: graficaAvance),
                          const SizedBox(width: 24),
                          Expanded(flex: 2, child: graficaPresupuesto),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        graficaAvance,
                        const SizedBox(height: 24),
                        graficaPresupuesto,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // ─── Feed de Actividad y Alertas ───
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 900;
                    final alertas = _buildAlertasRecientes();
                    final actividad = _buildActividadReciente();

                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 1, child: alertas),
                          const SizedBox(width: 24),
                          Expanded(flex: 1, child: actividad),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        alertas,
                        const SizedBox(height: 24),
                        actividad,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.blanco,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo_gestobra.png',
            height: 30,
            errorBuilder: (_, __, ___) => const Icon(Icons.construction, color: AppColors.naranja, size: 30),
          ),
          const SizedBox(width: 8),
          const Text(
            'GestObra Admin',
            style: TextStyle(color: AppColors.textoNegro, fontWeight: FontWeight.bold, fontSize: 20),
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

  Widget _buildKpiCard(String titulo, String valor, IconData icono, Color color, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grisfondo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gris, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icono, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(valor, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textoNegro)),
                const SizedBox(height: 4),
                Text(titulo, style: const TextStyle(fontSize: 13, color: AppColors.textoGris)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Gráfica de Avance Global ───
  Widget _buildGraficaAvance() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gris, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Avance Físico por Obra Activa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = ['Edificio', 'Vivienda', 'Pavimento', 'Centro M.'];
                        if (value.toInt() < titles.length) {
                          return Text(titles[value.toInt()], style: const TextStyle(fontSize: 10, color: AppColors.textoGris));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBar(0, 78, AppColors.naranja),
                  _makeBar(1, 45, AppColors.naranja),
                  _makeBar(2, 8, AppColors.estadoRojo),
                  _makeBar(3, 50, AppColors.naranja),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: y, color: color, width: 22, borderRadius: BorderRadius.circular(4)),
      ],
    );
  }

  // ─── Gráfica de Presupuesto (Pastel) ───
  Widget _buildGraficaPresupuesto() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gris, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Distribución Presupuestal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(value: 45, color: AppColors.naranja, title: 'Materiales', radius: 50, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(value: 30, color: Colors.blue, title: 'Mano Obra', radius: 50, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(value: 15, color: AppColors.estadoVerde, title: 'Equipo', radius: 50, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(value: 10, color: AppColors.textoGris, title: 'Otros', radius: 50, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertasRecientes() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gris, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Obras que requieren atención', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildAlertaItem('Remodelación Centro Médico', 'Retraso de 5 días en cimentación', AppColors.estadoRojo),
          const Divider(height: 24),
          _buildAlertaItem('Pavimentación Veracruz', 'Presupuesto al 95% con 60% de avance', AppColors.estadoAmarillo),
        ],
      ),
    );
  }

  Widget _buildAlertaItem(String obra, String detalle, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(obra, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(detalle, style: const TextStyle(color: AppColors.textoGris, fontSize: 12)),
            ],
          ),
        ),
        TextButton(onPressed: () {}, child: const Text('Revisar', style: TextStyle(color: AppColors.naranja, fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildActividadReciente() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grisfondo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gris, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Actividad Reciente (Bitácoras)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildActividadItem('Ing. Laura Sánchez', 'Registró bitácora de Vivienda 2 Plantas', 'Hace 2 horas'),
          const SizedBox(height: 12),
          _buildActividadItem('Ing. Carlos Márquez', 'Actualizó avance de Edificio Corporativo', 'Hace 4 horas'),
          const SizedBox(height: 12),
          _buildActividadItem('Arq. Sofía Méndez', 'Subió evidencia de Pavimentación', 'Ayer, 18:30'),
        ],
      ),
    );
  }

  Widget _buildActividadItem(String user, String accion, String tiempo) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.blanco,
          child: Icon(Icons.person, size: 18, color: AppColors.textoGris),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(accion, style: const TextStyle(color: AppColors.textoNegro, fontSize: 12)),
              Text(tiempo, style: const TextStyle(color: AppColors.textoGris, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }
}