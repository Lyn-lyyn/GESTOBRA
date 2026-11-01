import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/ui/screens/obras/obra_detail_screen.dart';
import 'package:gestobra/servicios/api_service.dart';

class ObrasListScreen extends StatefulWidget {
  const ObrasListScreen({super.key});

  @override
  State<ObrasListScreen> createState() => _ObrasListScreenState();
}

class _ObrasListScreenState extends State<ObrasListScreen> {
  final TextEditingController _busquedaController = TextEditingController();
  String _filtro = 'Todas';
  bool _cargando = true;

  List<Map<String, dynamic>> _obras = [];

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
          
          if (o['estado_nombre'] == 'EN_EJECUCION') {
            estadoKey = 'en_ejecucion';
            estadoTexto = 'EN PROCESO';
          } else if (o['estado_nombre'] == 'SUSPENDIDA') {
            estadoKey = 'suspendida';
            estadoTexto = 'SUSPENDIDA';
          } else if (o['estado_nombre'] == 'FINALIZADA') {
            estadoKey = 'finalizada';
            estadoTexto = 'FINALIZADA';
          }

          return {
            'id_obra': o['id_obra'],
            'codigo': o['codigo'],
            'titulo': o['nombre'],
            'cliente': o['nombre_cliente'] ?? 'Sin cliente',
            'ubicacion': o['ubicacion'],
            
            // 👇 AGREGAMOS LOS CAMPOS QUE FALTABAN 👇
            'descripcion': o['descripcion'] ?? 'Sin descripción',
            'fechaInicio': o['fecha_inicio'] ?? '',
            'fechaTermino': o['fecha_fin_estimada'] ?? '',
            'avance_general': o['avance_general'] ?? 0,
            
            'residente': 'Ver asignaciones', 
            'periodo': '${o['fecha_inicio'] ?? '--'} al ${o['fecha_fin_estimada'] ?? '--'}',
            'estado': estadoTexto,
            'estadoKey': estadoKey,
            'avance': (double.tryParse(o['avance_general'].toString()) ?? 0.0) / 100.0,
            'avanceTexto': '${double.tryParse(o['avance_general'].toString())?.toStringAsFixed(0) ?? 0}%',
          };
        }).toList();
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al cargar las obras'), backgroundColor: AppColors.estadoRojo));
    }
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  List<Map<String, dynamic>> get _obrasFiltradas {
    final query = _busquedaController.text.trim().toLowerCase();

    return _obras.where((o) {
      final cumpleFiltro = _filtro == 'Todas' ||
          (_filtro == 'Planificadas' && o['estadoKey'] == 'planificada') ||
          (_filtro == 'En ejecución' && o['estadoKey'] == 'en_ejecucion') ||
          (_filtro == 'Suspendidas' && o['estadoKey'] == 'suspendida') ||
          (_filtro == 'Finalizadas' && o['estadoKey'] == 'finalizada');

      final cumpleBusqueda = query.isEmpty ||
          o['titulo'].toString().toLowerCase().contains(query) ||
          o['codigo'].toString().toLowerCase().contains(query) ||
          o['cliente'].toString().toLowerCase().contains(query);

      return cumpleFiltro && cumpleBusqueda;
    }).toList();
  }

  void _abrirObra(Map<String, dynamic> obra) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ObraDetailScreen(obra: obra),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        backgroundColor: AppColors.grisfondo,
        body: Center(child: CircularProgressIndicator(color: AppColors.naranja)),
      );
    }

    final desktop = _isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.grisfondo,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double pad = (constraints.maxWidth * 0.02).clamp(16.0, 32.0);
            return SingleChildScrollView(
              padding: EdgeInsets.all(pad),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: desktop ? _buildDesktopLayout() : _buildMobileLayout(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // VISTA DE ESCRITORIO
  // ============================================================
  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gestión de Obras',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(child: _buildDesktopKpiCard('Total Obras', '${_obras.length}', Icons.folder_shared, AppColors.naranja)),
            const SizedBox(width: 16),
            Expanded(child: _buildDesktopKpiCard('En Proceso', '${_obras.where((o) => o['estadoKey'] == 'en_ejecucion').length}', Icons.engineering, AppColors.estadoVerde)),
            const SizedBox(width: 16),
            Expanded(child: _buildDesktopKpiCard('Pendientes', '${_obras.where((o) => o['estadoKey'] == 'planificada' || o['estadoKey'] == 'suspendida').length}', Icons.schedule, AppColors.estadoAmarillo)),
            const SizedBox(width: 16),
            Expanded(child: _buildDesktopKpiCard('Finalizadas', '${_obras.where((o) => o['estadoKey'] == 'finalizada').length}', Icons.task_alt, AppColors.estadoVerde)),
          ],
        ),
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _busquedaController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Buscar obra por título, código o cliente...',
                          hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 22),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.naranja, width: 1.5)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filtro,
                          icon: const Icon(Icons.filter_list, size: 20, color: Colors.grey),
                          style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
                          items: ['Todas', 'Planificadas', 'En ejecución', 'Suspendidas', 'Finalizadas']
                              .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                              .toList(),
                          onChanged: (v) => setState(() => _filtro = v!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _obrasFiltradas.isEmpty
                  ? _buildSinResultados()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _obrasFiltradas.length,
                      itemBuilder: (context, index) => _buildDesktopObraCard(_obrasFiltradas[index]),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopKpiCard(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icono, color: color, size: 24)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(valor, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 4),
              Text(titulo, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopObraCard(Map<String, dynamic> obra) {
    Color colorEstado = AppColors.gris;
    switch (obra['estadoKey']) {
      case 'planificada': colorEstado = AppColors.estadoAmarillo; break;
      case 'en_ejecucion': colorEstado = AppColors.naranja; break;
      case 'suspendida': colorEstado = AppColors.estadoRojo; break;
      case 'finalizada': colorEstado = AppColors.estadoVerde; break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _abrirObra(obra),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.naranja.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(obra['codigo'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.naranja)),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: colorEstado.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text(obra['estado'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorEstado)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(obra['titulo'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Text('Cliente: ${obra['cliente']}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(Icons.location_on, obra['ubicacion']),
                      const SizedBox(height: 6),
                      _buildDetailRow(Icons.person, obra['residente']),
                      const SizedBox(height: 6),
                      _buildDetailRow(Icons.calendar_today, obra['periodo']),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(obra['avanceTexto'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorEstado)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(value: obra['avance'] as double, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(colorEstado), minHeight: 8),
                      ),
                      const SizedBox(height: 16),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  // ============================================================
  // VISTA MÓVIL
  // ============================================================
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeaderPanel(compact: true),
        const SizedBox(height: 16),
        _buildStatsGrid(),
        const SizedBox(height: 16),
        _buildListPanel(showHeader: true),
      ],
    );
  }

  Widget _buildHeaderPanel({required bool compact}) {
    return Container(
      padding: EdgeInsets.all(compact ? 18 : 24),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.bordeSuave, width: 1)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/images/logo_gestobra.png', height: compact ? 42 : 52,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.business, color: AppColors.naranja, size: compact ? 42 : 52)),
          const SizedBox(width: 16),
          Expanded(
            child: Text('MIS OBRAS', style: TextStyle(fontSize: compact ? 22 : 26, fontWeight: FontWeight.bold, color: AppColors.textoNegro, letterSpacing: 0.8), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Total Obras', '${_obras.length}', Icons.folder_shared, AppColors.naranja)),
            const SizedBox(width: 10),
            Expanded(child: _buildStatCard('En Proceso', '${_obras.where((o) => o['estadoKey'] == 'en_ejecucion').length}', Icons.engineering, AppColors.estadoVerde)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildStatCard('Pendientes', '${_obras.where((o) => o['estadoKey'] == 'planificada' || o['estadoKey'] == 'suspendida').length}', Icons.schedule, AppColors.estadoAmarillo)),
            const SizedBox(width: 10),
            Expanded(child: _buildStatCard('Finalizadas', '${_obras.where((o) => o['estadoKey'] == 'finalizada').length}', Icons.task_alt, AppColors.estadoVerde)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.bordeSuave, width: 1)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icono, color: color, size: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(valor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textoNegro, height: 1.0)),
                const SizedBox(width: 6),
                Expanded(child: Text(titulo, style: const TextStyle(fontSize: 11, color: AppColors.textoGris, fontWeight: FontWeight.w500, height: 1.0), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListPanel({bool showHeader = false}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.bordeSuave, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            const Text('Listado de obras', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textoNegro)),
            const SizedBox(height: 12),
          ],
          _buildBuscadorYFiltros(),
          const SizedBox(height: 18),
          _obrasFiltradas.isEmpty
              ? _buildSinResultados()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _obrasFiltradas.length,
                  itemBuilder: (context, index) => _ObraCard(obra: _obrasFiltradas[index], onTap: () => _abrirObra(_obrasFiltradas[index])),
                ),
        ],
      ),
    );
  }

  Widget _buildBuscadorYFiltros() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: TextField(
              controller: _busquedaController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar por título, código o cliente...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textoGris),
                prefixIcon: const Icon(Icons.search, color: AppColors.naranja, size: 22),
                filled: true,
                fillColor: AppColors.blanco,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.bordeSuave, width: 1.2)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.bordeSuave, width: 1.2)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.naranja, width: 1.5)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.bordeSuave, width: 1)),
          child: Center(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _filtro,
                icon: const Icon(Icons.filter_list, size: 18, color: AppColors.naranja),
                style: const TextStyle(fontSize: 13, color: AppColors.textoNegro, fontWeight: FontWeight.bold),
                items: ['Todas', 'Planificadas', 'En ejecución', 'Suspendidas', 'Finalizadas'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                onChanged: (v) => setState(() => _filtro = v!),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSinResultados() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.blanco, shape: BoxShape.circle, border: Border.all(color: AppColors.bordeSuave, width: 1)), child: const Icon(Icons.search_off, size: 40, color: AppColors.naranja)),
            const SizedBox(height: 16),
            const Text('No se encontraron obras', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textoNegro)),
            const SizedBox(height: 6),
            const Text('Prueba con otro criterio de búsqueda o filtro.', style: TextStyle(fontSize: 13, color: AppColors.textoGris)),
          ],
        ),
      ),
    );
  }
}

class _ObraCard extends StatelessWidget {
  final Map<String, dynamic> obra;
  final VoidCallback onTap;

  const _ObraCard({required this.obra, required this.onTap});

  Color _colorEstado(String estadoKey) {
    switch (estadoKey) {
      case 'planificada': return AppColors.estadoAmarillo;
      case 'en_ejecucion': return AppColors.naranja;
      case 'suspendida': return AppColors.estadoRojo;
      case 'finalizada': return AppColors.estadoVerde;
      default: return AppColors.gris;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorEstado = _colorEstado(obra['estadoKey']);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.bordeSuave, width: 1)),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.naranja.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: Text(obra['codigo'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.naranja))),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: colorEstado.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: colorEstado.withValues(alpha: 0.5))),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 6, height: 6, decoration: BoxDecoration(color: colorEstado, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(obra['estado'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorEstado)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(obra['titulo'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textoNegro)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.blanco, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.bordeSuave.withValues(alpha: 0.5), width: 1.0)),
                  child: Column(
                    children: [
                      _buildInfo(Icons.business, obra['cliente']),
                      const SizedBox(height: 6),
                      _buildInfo(Icons.location_on, obra['ubicacion']),
                      const SizedBox(height: 6),
                      _buildInfo(Icons.person, obra['residente']),
                      const SizedBox(height: 6),
                      _buildInfo(Icons.calendar_today, obra['periodo']),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: obra['avance'] as double, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(colorEstado), minHeight: 8))),
                    const SizedBox(width: 12),
                    Text(obra['avanceTexto'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorEstado)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(IconData icon, String texto) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textoGris),
        const SizedBox(width: 8),
        Expanded(child: Text(texto, style: const TextStyle(fontSize: 12, color: AppColors.textoNegro, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}