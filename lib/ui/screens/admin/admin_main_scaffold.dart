import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'admin_dashboard_screen.dart';
import 'admin_obras_screen.dart';
import 'admin_personal_screen.dart';
import 'admin_trabajadores_screen.dart';
import 'admin_maquinaria_screen.dart';
import 'admin_catalogos_screen.dart';
import 'admin_perfil_screen.dart';
import 'admin_asignaciones_screen.dart';
import 'admin_proveedores_screen.dart';
import 'admin_usuarios_screen.dart';
import 'admin_clientes_screen.dart';
import 'admin_auditoria_screen.dart'; // <-- IMPORTACIÓN NUEVA

class AdminMainScaffold extends StatefulWidget {
  const AdminMainScaffold({super.key});

  @override
  State<AdminMainScaffold> createState() => _AdminMainScaffoldState();
}

class _AdminMainScaffoldState extends State<AdminMainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),      // 0 - Inicio
    const AdminObrasScreen(),          // 1 - Obras
    const AdminAsignacionesScreen(),   // 2 - Asignaciones
    const AdminClientesScreen(),       // 3 - Clientes
    const AdminProveedoresScreen(),    // 4 - Proveedores
    const AdminMaquinariaScreen(),     // 5 - Maquinaria
    const AdminPersonalScreen(),       // 6 - Personal
    const AdminTrabajadoresScreen(),   // 7 - Trabajadores
    const AdminUsuariosScreen(),       // 8 - Usuarios
    const AdminCatalogosScreen(),      // 9 - Catálogos
    const AdminAuditoriaScreen(),      // 10 - Auditoría (NUEVO)
    const AdminPerfilScreen(),         // 11 - Perfil (Corrido a 11)
  ];

  int get _currentMobileNavIndex {
    if (_currentIndex == 0) return 0;
    if (_currentIndex == 1) return 1;
    if (_currentIndex == 11) return 3; // Perfil ahora es el índice 11
    return 2; // Todo lo demás cae en "Gestión"
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.grisfondo,
        body: Row(
          children: [
            _buildDesktopSidebar(),
            Expanded(child: _screens[_currentIndex]),
          ],
        ),
      );
    }

    // ============ VISTA MÓVIL (Optimizada) ============
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentMobileNavIndex,
        onTap: (index) {
          if (index == 2) {
            _mostrarMenuMovil(context); // Abre el menú agrupado
          } else {
            setState(() {
              if (index == 0) _currentIndex = 0; // Inicio
              if (index == 1) _currentIndex = 1; // Obras
              if (index == 3) _currentIndex = 11; // Perfil (Actualizado a 11)
            });
          }
        },
        selectedItemColor: AppColors.naranja,
        unselectedItemColor: AppColors.textoGris,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.business_center_outlined), activeIcon: Icon(Icons.business_center), label: 'Obras'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view), label: 'Gestión'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), activeIcon: Icon(Icons.admin_panel_settings), label: 'Perfil'),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM SHEET (Menú agrupado para celular)
  // ============================================================
  void _mostrarMenuMovil(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.grisfondo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Módulos de Gestión', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textoNegro)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildMenuOption(ctx, 'Asignaciones', Icons.link, 2),
                    _buildMenuOption(ctx, 'Clientes', Icons.business, 3),
                    _buildMenuOption(ctx, 'Proveedores', Icons.local_shipping, 4),
                    _buildMenuOption(ctx, 'Maquinaria', Icons.precision_manufacturing, 5),
                    _buildMenuOption(ctx, 'Personal', Icons.groups, 6),
                    _buildMenuOption(ctx, 'Trabajadores', Icons.engineering, 7),
                    _buildMenuOption(ctx, 'Catálogos', Icons.list_alt, 9),
                    _buildMenuOption(ctx, 'Auditoría', Icons.security_update_good, 10), // <-- NUEVO
                    _buildMenuOption(ctx, 'Usuarios', Icons.manage_accounts, 8),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuOption(BuildContext context, String title, IconData icon, int index) {
    return InkWell(
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context); // Cierra el menú
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.blanco,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.bordeSuave),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.naranja),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SIDEBAR ESCRITORIO (Con Índices Corregidos)
  // ============================================================
  Widget _buildDesktopSidebar() {
    return Container(
      width: 240,
      color: AppColors.fondoNavegacion,
      // Agregamos scroll por si la pantalla de la compu es pequeña
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/GestObra_blanco.png',
                    height: 32,
                    errorBuilder: (_, __, ___) => const Icon(Icons.construction, color: AppColors.naranja, size: 32),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'GestObra',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // 👇 ÍNDICES CORREGIDOS 0 a 11
            _buildDesktopItem(0, Icons.home_outlined, Icons.home, 'Inicio'),
            _buildDesktopItem(1, Icons.business_center_outlined, Icons.business_center, 'Obras'),
            _buildDesktopItem(2, Icons.link_outlined, Icons.link, 'Asignaciones'),
            _buildDesktopItem(3, Icons.business_outlined, Icons.business, 'Clientes'),
            _buildDesktopItem(4, Icons.local_shipping_outlined, Icons.local_shipping, 'Proveedores'),
            _buildDesktopItem(5, Icons.precision_manufacturing_outlined, Icons.precision_manufacturing, 'Maquinaria'),
            _buildDesktopItem(6, Icons.groups_outlined, Icons.groups, 'Personal'),
            _buildDesktopItem(7, Icons.engineering_outlined, Icons.engineering, 'Trabajadores'),
            _buildDesktopItem(8, Icons.manage_accounts_outlined, Icons.manage_accounts, 'Usuarios'),
            _buildDesktopItem(9, Icons.list_alt_outlined, Icons.list_alt, 'Catálogos'),
            _buildDesktopItem(10, Icons.security_update_good_outlined, Icons.security_update_good, 'Auditoría'), // <-- NUEVO
            _buildDesktopItem(11, Icons.person_outline, Icons.person, 'Perfil'), // <-- Perfil en 11
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3E4046) : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isSelected ? AppColors.naranja : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? AppColors.naranja : Colors.white70,
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}