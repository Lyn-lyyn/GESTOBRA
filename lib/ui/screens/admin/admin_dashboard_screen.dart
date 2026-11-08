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
  
  // KPIs
  int _obrasActivas = 0;
  int _totalObras = 0;
  int _personalTotal = 0;
  int _incidenciasAbiertas = 0;

  // Datos para gráficas y listas
  List<Map<String, dynamic>> _obrasGrafica = [];
  List<Map<String, dynamic>> _logs = [];
  List<Map<String, dynamic>> _obrasBajoAvance = [];
  List<Map<String, dynamic>> _obrasSinSupervisor = [];
  
  // Datos de presupuesto
  Map<String, double> _presupuesto = {
    'materiales': 0,
    'mano_obra': 0,
    'maquinaria': 0,
    'otros': 0,
  };

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    if (mounted) setState(() => _cargando = true);
    
    try {
      // Ejecutamos las peticiones en paralelo, pero capturamos errores individuales
      final resultados = await Future.wait([
        _safeApiCall('obras.php'),
        _safeApiCall('listar_usuarios.php'),
        _safeApiCall('auditoria.php'),
        _safeApiCall('dashboard_stats.php'),
        _safeApiCall('alertas_dashboard.php'),
      ]);

      final resObras = resultados[0];
      final resUsuarios = resultados[1];
      final resLogs = resultados[2];
      final resStats = resultados[3];
      final resAlertas = resultados[4];

      // Procesar Obras
      if (resObras != null && resObras['estado'] == true && resObras['obras'] != null) {
        final obras = List<Map<String, dynamic>>.from(resObras['obras']);
        _obrasActivas = obras.where((o) => o['estado_nombre'] == 'EN_EJECUCION').length;
        _totalObras = obras.length;
        _obrasGrafica = obras.take(4).toList(); 
      }

      // Procesar Usuarios
      if (resUsuarios != null && resUsuarios['estado'] == true && resUsuarios['usuarios'] != null) {
        _personalTotal = List<Map<String, dynamic>>.from(resUsuarios['usuarios']).length;
      }

      // Procesar Logs
      if (resLogs != null && resLogs['estado'] == true && resLogs['data'] != null) {
        _logs = List<Map<String, dynamic>>.from(resLogs['data']).take(3).toList();
      }

      // Procesar Stats
      if (resStats != null && resStats['estado'] == true) {
        _incidenciasAbiertas = (resStats['incidencias_abiertas'] as num?)?.toInt() ?? 0;
        final p = resStats['presupuesto'];
        if (p != null) {
          _presupuesto['materiales'] = (p['materiales'] as num?)?.toDouble() ?? 0;
          _presupuesto['mano_obra'] = (p['mano_obra'] as num?)?.toDouble() ?? 0;
          _presupuesto['maquinaria'] = (p['maquinaria'] as num?)?.toDouble() ?? 0;
          _presupuesto['otros'] = (p['otros'] as num?)?.toDouble() ?? 0;
        }
      }

      // Procesar Alertas
      if (resAlertas != null && resAlertas['estado'] == true) {
        final alertas = resAlertas['alertas'];
        if (alertas != null) {
          _obrasBajoAvance = List<Map<String, dynamic>>.from(alertas['bajo_avance'] ?? []);
          _obrasSinSupervisor = List<Map<String, dynamic>>.from(alertas['sin_supervisor'] ?? []);
        }
      }

    } catch (e) {
      debugPrint("Error general cargando dashboard: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    } finally {
      // SIEMPRE quitamos el estado de carga
      if (mounted) setState(() => _cargando = false);
    }
  }

  // Función auxiliar para que un error 500 en una API no tumbe todo el dashboard
  Future<Map<String, dynamic>?> _safeApiCall(String endpoint) async {
    try {
      return await ApiService.get(endpoint);
    } catch (e) {
      debugPrint("Fallo en API $endpoint: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: _buildAppBar(),
      body: _cargando 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _cargarDatos,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Panel de Control Global', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textoNegro)),
                      const SizedBox(height: 16),
                      
                      // ─── KPIs DINÁMICOS ───
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 600;
                          
                          if (isMobile) {
                            return GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.5,
                              children: [
                                _buildKpiCardMobile('Obras Activas', '$_obrasActivas', Icons.engineering, AppColors.naranja),
                                _buildKpiCardMobile('Personal', '$_personalTotal', Icons.groups, AppColors.estadoVerde),
                                _buildKpiCardMobile('Total Obras', '$_totalObras', Icons.business_center, Colors.blue),
                                _buildKpiCardMobile('Incidencias', '$_incidenciasAbiertas', Icons.warning_amber_rounded, AppColors.estadoRojo),
                              ],
                            );
                          }

                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              _buildKpiCardDesktop('Obras Activas', '$_obrasActivas', Icons.engineering, AppColors.naranja),
                              _buildKpiCardDesktop('Personal Registrado', '$_personalTotal', Icons.groups, AppColors.estadoVerde),
                              _buildKpiCardDesktop('Obras en Total', '$_totalObras', Icons.business_center, Colors.blue),
                              _buildKpiCardDesktop('Incidencias Abiertas', '$_incidenciasAbiertas', Icons.warning_amber_rounded, AppColors.estadoRojo),
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
                          return Column(children: [graficaAvance, const SizedBox(height: 20), graficaPresupuesto]);
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
                          return Column(children: [alertas, const SizedBox(height: 20), actividad]);
                        },
                      ),
                    ],
                  ),
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
          Image.asset('assets/images/logo_gestobra.png', height: 28, errorBuilder: (_, __, ___) => const Icon(Icons.construction, color: AppColors.naranja, size: 28)),
          const SizedBox(width: 8),
          const Text('GestObra Admin', style: TextStyle(color: AppColors.textoNegro, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
      actions: const [NotificationBell(), SizedBox(width: 8)],
    );
  }

  // ─── Tarjetas KPI para Móvil (Alineadas) ───
  Widget _buildKpiCardMobile(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blanco, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: AppColors.bordeSuave, width: 1)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8), 
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle), 
                child: Icon(icono, color: color, size: 20)
              ),
              const SizedBox(width: 12),
              Text(valor, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textoNegro)),
            ],
          ),
          const SizedBox(height: 8),
          Text(titulo, style: const TextStyle(fontSize: 12, color: AppColors.textoGris, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // ─── Tarjetas KPI para Escritorio ───
  Widget _buildKpiCardDesktop(String titulo, String valor, IconData icono, Color color) {
    return Container(
      width: 260,
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
      String nombre = _obrasGrafica[i]['nombre'] ?? 'Obra';
      titulos.add(nombre.length > 8 ? '${nombre.substring(0, 8)}..' : nombre);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.bordeSuave, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Avance Físico por Obra Reciente', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: _obrasGrafica.isEmpty 
              ? const Center(child: Text('No hay datos suficientes', style: TextStyle(fontSize: 12, color: AppColors.textoGris)))
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
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < titulos.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(titulos[value.toInt()], style: const TextStyle(fontSize: 9, color: AppColors.textoGris)),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 20)),
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
    double total = _presupuesto.values.fold(0, (sum, val) => sum + val);
    if (total == 0) total = 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.bordeSuave, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Distribución Presupuestal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 35,
                sections: [
                  PieChartSectionData(
                    value: _presupuesto['materiales'], 
                    color: AppColors.naranja, 
                    title: '${((_presupuesto['materiales']! / total) * 100).toStringAsFixed(0)}%', 
                    radius: 45, 
                    titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                  PieChartSectionData(
                    value: _presupuesto['mano_obra'], 
                    color: Colors.blue, 
                    title: '${((_presupuesto['mano_obra']! / total) * 100).toStringAsFixed(0)}%', 
                    radius: 45, 
                    titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                  PieChartSectionData(
                    value: _presupuesto['maquinaria'], 
                    color: AppColors.estadoVerde, 
                    title: '${((_presupuesto['maquinaria']! / total) * 100).toStringAsFixed(0)}%', 
                    radius: 45, 
                    titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                  PieChartSectionData(
                    value: _presupuesto['otros'], 
                    color: AppColors.textoGris, 
                    title: '${((_presupuesto['otros']! / total) * 100).toStringAsFixed(0)}%', 
                    radius: 45, 
                    titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildLeyendaItem('Materiales', AppColors.naranja),
              _buildLeyendaItem('Mano Obra', Colors.blue),
              _buildLeyendaItem('Maquinaria', AppColors.estadoVerde),
              _buildLeyendaItem('Otros', AppColors.textoGris),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLeyendaItem(String texto, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(texto, style: const TextStyle(fontSize: 10, color: AppColors.textoGris)),
      ],
    );
  }

  Widget _buildAlertasRecientes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.bordeSuave, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Obras que requieren atención', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_obrasBajoAvance.isEmpty && _obrasSinSupervisor.isEmpty)
            const Text('Todo en orden. No hay alertas críticas.', style: TextStyle(color: AppColors.textoGris, fontSize: 12))
          else ...[
            ..._obrasBajoAvance.map((obra) => InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ir a obra: ${obra['nombre']} (Avance: ${obra['avance_general']}%)')),
                );
              },
              child: _buildAlertaItem(
                'Bajo avance: ${obra['nombre']}',
                'Avance actual: ${obra['avance_general']}%',
                AppColors.estadoRojo,
              ),
            )),
            ..._obrasSinSupervisor.map((obra) => InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Asignar supervisor a: ${obra['nombre']}')),
                );
              },
              child: _buildAlertaItem(
                'Sin supervisor: ${obra['nombre']}',
                'Asigna un supervisor a esta obra',
                AppColors.estadoAmarillo,
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildAlertaItem(String obra, String detalle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(obra, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(detalle, style: const TextStyle(color: AppColors.textoGris, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActividadReciente() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.bordeSuave, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Últimas acciones (Auditoría)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_logs.isEmpty) const Text('No hay actividad reciente', style: TextStyle(color: AppColors.textoGris, fontSize: 12)),
          ..._logs.map((log) => _buildActividadItem(
            log['nombre_usuario'] != null ? '${log['nombre_usuario']} ${log['apellido_usuario']}' : 'Sistema', 
            log['descripcion'] ?? 'Acción', 
            log['fecha'] != null ? log['fecha'].toString().split(' ')[0] : ''
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
          const CircleAvatar(radius: 14, backgroundColor: AppColors.grisfondo, child: Icon(Icons.person, size: 16, color: AppColors.textoGris)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(accion, style: const TextStyle(color: AppColors.textoNegro, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(tiempo, style: const TextStyle(color: AppColors.textoGris, fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}