import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gestobra/servicios/api_service.dart';
import 'widgets/notification_bell.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _cargando = true;
  int _obrasActivas = 0;
  int _totalObras = 0;
  int _personalTotal = 0;
  List<Map<String, dynamic>> _obrasGrafica = [];
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    
    final resObras = await ApiService.get('obras.php');
    final resUsuarios = await ApiService.get('listar_usuarios.php');
    final resLogs = await ApiService.get('auditoria.php');

    if (resObras['estado'] == true) {
      final obras = List<Map<String, dynamic>>.from(resObras['obras']);
      _obrasActivas = obras.where((o) => o['estado_nombre'] == 'EN_EJECUCION').length;
      _totalObras = obras.length;
      _obrasGrafica = obras.take(4).toList(); // Tomamos las primeras 4 para la gráfica
    }

    if (resUsuarios['estado'] == true) {
      _personalTotal = List<Map<String, dynamic>>.from(resUsuarios['usuarios']).length;
    }

    if (resLogs['estado'] == true) {
      _logs = List<Map<String, dynamic>>.from(resLogs['data']).take(3).toList();
    }

    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: _buildAppBar(),
      body: _cargando 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Panel de Control Global', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textoNegro)),
                    const SizedBox(height: 20),
                    
                    // ─── KPIs DINÁMICOS ───
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 800;
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _buildKpiCard('Obras Activas', '$_obrasActivas', Icons.engineering, AppColors.naranja, isMobile),
                            _buildKpiCard('Personal Registrado', '$_personalTotal', Icons.groups, AppColors.estadoVerde, isMobile),
                            _buildKpiCard('Obras en Total', '$_totalObras', Icons.business_center, Colors.blue, isMobile),
                            _buildKpiCard('Incidencias', '0', Icons.warning_amber_rounded, AppColors.estadoRojo, isMobile),
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
                        return Column(children: [graficaAvance, const SizedBox(height: 24), graficaPresupuesto]);
                      },
                    ),
                    const SizedBox(height: 24),

                    // ─── Feed de Actividad ───
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
                        return Column(children: [alertas, const SizedBox(height: 24), actividad]);
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
          Image.asset('assets/images/logo_gestobra.png', height: 30, errorBuilder: (_, __, ___) => const Icon(Icons.construction, color: AppColors.naranja, size: 30)),
          const SizedBox(width: 8),
          const Text('GestObra Admin', style: TextStyle(color: AppColors.textoNegro, fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
      actions: const [NotificationBell(), SizedBox(width: 8)],
    );
  }

  Widget _buildKpiCard(String titulo, String valor, IconData icono, Color color, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.bordeSuave, width: 1)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle), child: Icon(icono, color: color, size: 28)),
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

  Widget _buildGraficaAvance() {
    List<BarChartGroupData> barras = [];
    List<String> titulos = [];
    
    for (int i = 0; i < _obrasGrafica.length; i++) {
      double avance = double.tryParse(_obrasGrafica[i]['avance_general'].toString()) ?? 0;
      barras.add(_makeBar(i, avance, avance < 30 ? AppColors.estadoRojo : AppColors.naranja));
      String nombre = _obrasGrafica[i]['nombre'];
      titulos.add(nombre.length > 8 ? '${nombre.substring(0, 8)}..' : nombre);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.bordeSuave, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Avance Físico por Obra Reciente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          SizedBox(
            height: 200,
            child: _obrasGrafica.isEmpty 
              ? const Center(child: Text('No hay datos suficientes'))
              : BarChart(
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
                            if (value.toInt() < titulos.length) {
                              return Text(titulos[value.toInt()], style: const TextStyle(fontSize: 10, color: AppColors.textoGris));
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
                    barGroups: barras,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBar(int x, double y, Color color) {
    return BarChartGroupData(x: x, barRods: [BarChartRodData(toY: y, color: color, width: 22, borderRadius: BorderRadius.circular(4))]);
  }

  Widget _buildGraficaPresupuesto() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.bordeSuave, width: 1)),
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
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.bordeSuave, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Obras que requieren atención', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildAlertaItem('Revisión de presupuesto', 'Obras con avance menor al 30%', AppColors.estadoRojo),
          const Divider(height: 24),
          _buildAlertaItem('Falta de personal', 'Obras sin supervisor asignado', AppColors.estadoAmarillo),
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
      ],
    );
  }

  Widget _buildActividadReciente() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.bordeSuave, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Últimas acciones (Auditoría)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_logs.isEmpty) const Text('No hay actividad reciente'),
          ..._logs.map((log) => _buildActividadItem(
            log['nombre_usuario'] != null ? '${log['nombre_usuario']} ${log['apellido_usuario']}' : 'Sistema', 
            log['descripcion'] ?? 'Acción', 
            log['fecha'] ?? ''
          )),
        ],
      ),
    );
  }

  Widget _buildActividadItem(String user, String accion, String tiempo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 16, backgroundColor: AppColors.grisfondo, child: Icon(Icons.person, size: 18, color: AppColors.textoGris)),
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
      ),
    );
  }
}