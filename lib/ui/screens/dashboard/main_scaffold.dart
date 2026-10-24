import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';

import 'dashboard_screen.dart';
import '../obras/obras_list_screen.dart';
import '../perfil/perfil_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ObrasListScreen(),
    const PerfilScreen(),
  ];

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  @override
  Widget build(BuildContext context) {
    if (_isDesktop(context)) {
      // ============ VISTA ESCRITORIO (Con Sidebar) ============
      return Scaffold(
        body: Row(
          children: [
            // Menú Lateral (Sidebar)
            _buildSidebar(),
            // Contenido Principal
            Expanded(
              child: _screens[_currentIndex],
            ),
          ],
        ),
      );
    }

    // ============ VISTA MÓVIL (Tu diseño original intacto) ============
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.naranja,
        unselectedItemColor: AppColors.textoGris,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.engineering_outlined), activeIcon: Icon(Icons.engineering), label: 'Obras'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Color(0xFF2B2D31),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(2, 0)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Row(
              children: [
                // 🔴 AQUÍ ESTÁ EL LOGO PARA FONDO OSCURO (SOLO PC)
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
          
          _buildSidebarItem(0, Icons.home_outlined, 'Inicio'),
          _buildSidebarItem(1, Icons.engineering_outlined, 'Obras'),
          _buildSidebarItem(2, Icons.person_outline, 'Perfil'),
          
          const Spacer(),
          
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white70),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white70)),
            onTap: () {
              // Lógica de cerrar sesión
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
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
              Icon(icon, color: isSelected ? AppColors.naranja : Colors.white70, size: 24),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}