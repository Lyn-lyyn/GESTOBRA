import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/ui/screens/obras/obra_detail_screen.dart';

class ObrasListScreen extends StatefulWidget {
  const ObrasListScreen({super.key});

  @override
  State<ObrasListScreen> createState() => _ObrasListScreenState();
}

class _ObrasListScreenState extends State<ObrasListScreen> {
  final TextEditingController _busquedaController = TextEditingController();
  String _filtro = 'Todas';

  // ─── Datos mock de obras ───
  final List<Map<String, dynamic>> _obras = [
    {
      'codigo': 'OBRA-2026-042',
      'titulo': 'Edificio de oficinas corporativas',
      'cliente': 'Inmobiliaria del Golfo S.A. de C.V.',
      'ubicacion': 'Boca del Río, Veracruz',
      'residente': 'Ing. Carlos Márquez',
      'periodo': '28/09/2026 al 28/10/2026',
      'estado': 'EN PROCESO',
      'estadoKey': 'en_ejecucion',
      'avance': 0.78,
      'avanceTexto': '78%',
    },
    {
      'codigo': 'OBRA-2026-043',
      'titulo': 'Construcción de vivienda 2 plantas',
      'cliente': 'Grupo Constructor del Norte S.A.',
      'ubicacion': 'Monterrey, Nuevo León',
      'residente': 'Ing. Laura Sánchez',
      'periodo': '15/09/2026 al 15/12/2026',
      'estado': 'EN PROCESO',
      'estadoKey': 'en_ejecucion',
      'avance': 0.45,
      'avanceTexto': '45%',
    },
    {
      'codigo': 'OBRA-2026-044',
      'titulo': 'Pavimentación con concreto hidráulico',
      'cliente': 'Ayuntamiento de Veracruz',
      'ubicacion': 'Veracruz, Veracruz',
      'residente': 'Ing. Roberto Díaz',
      'periodo': '01/10/2026 al 30/11/2026',
      'estado': 'PLANIFICADA',
      'estadoKey': 'planificada',
      'avance': 0.0,
      'avanceTexto': '0%',
    },
    {
      'codigo': 'OBRA-2026-045',
      'titulo': 'Remodelación Centro Médico Santa María',
      'cliente': 'Servicios Médicos del Sur S.A.',
      'ubicacion': 'Coaztacoalcos, Veracruz',
      'residente': 'Ing. Patricia Ríos',
      'periodo': '10/08/2026 al 10/11/2026',
      'estado': 'SUSPENDIDA',
      'estadoKey': 'suspendida',
      'avance': 0.30,
      'avanceTexto': '30%',
    },
    {
      'codigo': 'OBRA-2026-038',
      'titulo': 'Ampliación de bodega industrial',
      'cliente': 'Logística Portuaria S.A. de C.V.',
      'ubicacion': 'Manzanillo, Colima',
      'residente': 'Ing. Fernando Cruz',
      'periodo': '15/05/2026 al 15/08/2026',
      'estado': 'FINALIZADA',
      'estadoKey': 'finalizada',
      'avance': 1.0,
      'avanceTexto': '100%',
    },
  ];

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: AppColors.blanco,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double pad = (constraints.maxWidth * 0.02).clamp(16.0, 24.0);

          return SingleChildScrollView(
            padding: EdgeInsets.all(pad),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Cabecera principal (Borde oscuro y marcado) ───
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.grisfondo,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.gris, // Borde sólido y oscuro
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/logo_gestobra.png',
                                  height: 56,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.business, color: AppColors.naranja, size: 48);
                                  },
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'MIS OBRAS',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textoNegro,
                                          letterSpacing: 0.5,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Gestión y seguimiento de proyectos',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textoGris,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.blanco,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.gris,
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              '${_obrasFiltradas.length} obras',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.naranja,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Contenedor principal (Borde oscuro y marcado) ───
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.grisfondo,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.gris, // Borde sólido y oscuro
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ─── Tarjetas de Resumen ───
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Total Obras',
                                  '${_obras.length}',
                                  Icons.folder_shared,
                                  AppColors.naranja,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'En Proceso',
                                  '${_obras.where((o) => o['estadoKey'] == 'en_ejecucion').length}',
                                  Icons.engineering,
                                  AppColors.estadoVerde,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Pendientes / Plan',
                                  '${_obras.where((o) => o['estadoKey'] == 'planificada' || o['estadoKey'] == 'suspendida').length}',
                                  Icons.schedule,
                                  AppColors.estadoAmarillo,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // ─── Buscador + Filtros ───
                          _buildBuscadorYFiltros(),
                          const SizedBox(height: 20),

                          // ─── Lista de Obras ───
                          _obrasFiltradas.isEmpty
                              ? _buildSinResultados()
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _obrasFiltradas.length,
                                  itemBuilder: (context, index) {
                                    return _ObraCard(
                                      obra: _obrasFiltradas[index],
                                      onTap: () => _abrirObra(_obrasFiltradas[index]),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gris, // Borde oscuro y marcado
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textoNegro,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textoGris,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuscadorYFiltros() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _busquedaController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Buscar por título, código o cliente...',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.textoGris,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.naranja,
                size: 22,
              ),
              filled: true,
              fillColor: AppColors.blanco,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.gris, // Borde oscuro y marcado
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.gris, // Borde oscuro y marcado
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.naranja, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.blanco,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.gris, // Borde oscuro y marcado
              width: 1.2,
            ),
          ),
          child: Center(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _filtro,
                icon: const Icon(Icons.filter_list, size: 18, color: AppColors.naranja),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textoNegro,
                  fontWeight: FontWeight.bold,
                ),
                items: ['Todas', 'Planificadas', 'En ejecución', 'Suspendidas', 'Finalizadas']
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.blanco,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gris,
                  width: 1.2,
                ),
              ),
              child: const Icon(Icons.search_off, size: 40, color: AppColors.naranja),
            ),
            const SizedBox(height: 16),
            const Text(
              'No se encontraron obras',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textoNegro,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Prueba con otro criterio de búsqueda o filtro.',
              style: TextStyle(fontSize: 13, color: AppColors.textoGris),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Tarjeta de obra mejorada
// ────────────────────────────────────────────────────────────
class _ObraCard extends StatelessWidget {
  final Map<String, dynamic> obra;
  final VoidCallback onTap;

  const _ObraCard({required this.obra, required this.onTap});

  Color _colorEstado(String estadoKey) {
    switch (estadoKey) {
      case 'planificada':
        return AppColors.estadoAmarillo;
      case 'en_ejecucion':
        return AppColors.naranja;
      case 'suspendida':
        return AppColors.estadoRojo;
      case 'finalizada':
        return AppColors.estadoVerde;
      default:
        return AppColors.gris;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorEstado = _colorEstado(obra['estadoKey']);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gris, // Borde oscuro y marcado
          width: 1.2,
        ),
      ),
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
                // ─── Fila superior: código + estado ───
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.naranja.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        obra['codigo'],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.naranja,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorEstado.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colorEstado.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: colorEstado,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            obra['estado'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorEstado,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ─── Título ───
                Text(
                  obra['titulo'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textoNegro,
                  ),
                ),
                const SizedBox(height: 10),

                // ─── Información interna en gris suave para contraste ───
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.grisfondo,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.gris.withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                  ),
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

                // ─── Barra de progreso ───
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: obra['avance'] as double,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(colorEstado),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      obra['avanceTexto'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorEstado,
                      ),
                    ),
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
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textoNegro,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}