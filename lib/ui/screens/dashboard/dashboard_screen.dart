import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import '../obras/obra_detail_screen.dart';
import 'package:gestobra/servicios/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _cargando = true;
  List<Map<String, dynamic>> _obras = [];

  List<Map<String, dynamic>> get _stats {
    int activas = _obras.where((o) => o['estadoKey'] == 'en_ejecucion').length;
    return [
      {'titulo': 'Obras activas', 'valor': '$activas', 'color': AppColors.naranja},
      {'titulo': 'Alertas operativas', 'valor': '0', 'color': Colors.black},
      {'titulo': 'Obras registradas', 'valor': '${_obras.length}', 'color': Colors.black},
    ];
  }

  @override
  void initState() {
    super.initState();
    _cargarObras();
  }

  Future<void> _cargarObras() async {
    setState(() => _cargando = true);
    final res = await ApiService.get('obras.php');

    if (res['estado'] == true) {
      setState(() {
        _obras = List<Map<String, dynamic>>.from(res['obras']).map((o) {
          String estadoKey = 'planificada';
          String estadoTexto = 'PLANIFICADA';
          Color color = AppColors.naranja;

          if (o['estado_nombre'] == 'EN_EJECUCION') {
            estadoKey = 'en_ejecucion';
            estadoTexto = 'EN PROCESO';
            color = AppColors.naranja;
          } else if (o['estado_nombre'] == 'SUSPENDIDA') {
            estadoKey = 'suspendida';
            estadoTexto = 'SUSPENDIDA';
            color = AppColors.estadoRojo;
          } else if (o['estado_nombre'] == 'FINALIZADA') {
            estadoKey = 'finalizada';
            estadoTexto = 'CONCLUIDO';
            color = Colors.green;
          }

          return {
            'id_obra': o['id_obra'],
            'codigo': o['codigo'],
            'titulo': o['nombre'],
            'cliente': 'Cliente: ${o['nombre_cliente'] ?? 'Sin cliente'}',
            'ubicacion': o['ubicacion'],
            
            // 👇 CAMPOS AGREGADOS 👇
            'descripcion': o['descripcion'] ?? 'Sin descripción',
            'fechaInicio': o['fecha_inicio'] ?? '',
            'fechaTermino': o['fecha_fin_estimada'] ?? '',
            'avance_general': o['avance_general'] ?? 0,
            
            'supervisor': 'Ver asignaciones',
            'fecha': '${o['fecha_inicio'] ?? '--'} al ${o['fecha_fin_estimada'] ?? '--'}',
            'avance': (double.tryParse(o['avance_general'].toString()) ?? 0.0) / 100.0,
            'estado': estadoTexto,
            'colorEstado': color,
            'estadoKey': estadoKey,
          };
        }).toList();
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
    }
  }

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        backgroundColor: AppColors.grisfondo,
        body: Center(child: CircularProgressIndicator(color: AppColors.naranja)),
      );
    }

    if (_isDesktop(context)) {
      return _buildDesktopLayout();
    }
    return _buildMobileLayout();
  }

  // ============================================================
  // VISTA DE ESCRITORIO
  // ============================================================
  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Container(
          width: 400,
          height: 40,
          decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(20)),
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
          const CircleAvatar(backgroundColor: AppColors.naranja, radius: 18, child: Text('M', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
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
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stat['titulo'], style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(stat['valor'], style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: stat['color'])),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            const Text('Proyectos y obras civiles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 16),

            _obras.isEmpty 
              ? const Center(child: Text('No hay obras registradas', style: TextStyle(color: Colors.grey)))
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    mainAxisExtent: 260,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _obras.length,
                  itemBuilder: (context, index) => _buildDesktopObraCard(_obras[index]),
                ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // VISTA MÓVIL
  // ============================================================
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/images/logo_gestobra.png', height: 30,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.construction, color: AppColors.naranja, size: 30)),
            const SizedBox(width: 8),
            const Text('GestObra', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.naranja), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bienvenido Marcos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 16),
            _buildMainStatsContainer(),
            const SizedBox(height: 20),
            _buildProjectsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStatsContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.bordeSuave)),
      child: Column(
        children: [
          Row(children: _stats.map((stat) => _buildStatCard(stat)).toList()),
          const SizedBox(height: 12),
          _buildBigInfoBox(),
        ],
      ),
    );
  }

  Widget _buildProjectsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.bordeSuave)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Proyectos y obras civiles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            height: 42,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(21), border: Border.all(color: Colors.grey.shade300)),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Buscar proyecto...',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.gris),
                prefixIcon: Padding(padding: EdgeInsets.only(left: 8.0, right: 4.0), child: Icon(Icons.search, size: 20, color: AppColors.gris)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _obras.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('No hay obras registradas', style: TextStyle(color: Colors.grey))),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250,
                  mainAxisExtent: 235,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _obras.length,
                itemBuilder: (context, index) => _buildMobileObraCard(_obras[index], context),
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.bordeSuave)),
        child: Column(
          children: [
            Text(stat['valor'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: stat['color'])),
            const SizedBox(height: 4),
            Text(stat['titulo'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.gris)),
          ],
        ),
      ),
    );
  }

  Widget _buildBigInfoBox() {
    double promAvance = 0.0;
    if (_obras.isNotEmpty) {
      double suma = 0;
      for (var o in _obras) { suma += (o['avance'] as double); }
      promAvance = suma / _obras.length;
    }
    int porcentaje = (promAvance * 100).toInt();

    return Container(
      width: double.infinity,
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.bordeSuave)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.naranja.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.insights, color: AppColors.naranja, size: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Resumen General de Obras', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: promAvance, backgroundColor: Colors.grey.shade200, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.naranja), minHeight: 8),
                  ),
                ),
                const SizedBox(height: 8),
                Text('$porcentaje% de avance global en todas las obras', style: const TextStyle(fontSize: 11, color: AppColors.gris)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileObraCard(Map<String, dynamic> obra, BuildContext context) {
    final bool isCompleted = obra['avance'] >= 1.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ObraDetailScreen(obra: obra))),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.bordeSuave)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: obra['colorEstado'].withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(obra['estado'], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: obra['colorEstado'])),
              ),
              const SizedBox(height: 8),
              Text(obra['titulo'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(value: obra['avance'], backgroundColor: Colors.grey.shade100, valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? Colors.green : AppColors.naranja), minHeight: 6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${(obra['avance'] * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopObraCard(Map<String, dynamic> obra) {
    final bool isCompleted = obra['avance'] >= 1.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ObraDetailScreen(obra: obra))),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: obra['colorEstado'].withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(obra['estado'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: obra['colorEstado'])),
              ),
              const SizedBox(height: 12),
              Text(obra['titulo'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.business, obra['cliente'], 11.5),
              _buildDetailRow(Icons.location_on, obra['ubicacion'], 11.5),
              _buildDetailRow(Icons.person, obra['supervisor'], 11.5),
              _buildDetailRow(Icons.calendar_today, obra['fecha'], 11.5),
              const Spacer(),
              Row(
                children: [
                  Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: obra['avance'], backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? Colors.green : AppColors.naranja), minHeight: 8))),
                  const SizedBox(width: 12),
                  Text('${(obra['avance'] * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isCompleted ? Colors.green : AppColors.naranja)),
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
          Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: fontSize, color: AppColors.gris))),
        ],
      ),
    );
  }
}