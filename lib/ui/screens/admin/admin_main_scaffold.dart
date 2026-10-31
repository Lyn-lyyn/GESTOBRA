import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'admin_dashboard_screen.dart';
import 'admin_obras_screen.dart';
import 'admin_personal_screen.dart';
import 'admin_perfil_screen.dart';
import 'admin_usuarios_screen.dart';

class AdminMainScaffold extends StatefulWidget {
  const AdminMainScaffold({super.key});

  @override
  State<AdminMainScaffold> createState() => _AdminMainScaffoldState();
}

class _AdminMainScaffoldState extends State<AdminMainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminObrasScreen(),
    const AdminPersonalScreen(),
    const AdminUsuariosScreen(),
    const AdminPerfilScreen(),
  ];

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
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_center_outlined),
            activeIcon: Icon(Icons.business_center),
            label: 'Obras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: 'Personal',
          ),BottomNavigationBarItem(
  icon: Icon(Icons.manage_accounts_outlined),
  activeIcon: Icon(Icons.manage_accounts),
  label: 'Usuarios',
),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_outlined),
            activeIcon: Icon(Icons.admin_panel_settings),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      width: 240,
      color: AppColors.fondoNavegacion,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/GestObra_blanco.png',
                  height: 32,
                  errorBuilder:
                      (_, __, ___) => const Icon(
                        Icons.construction,
                        color: AppColors.naranja,
                        size: 32,
                      ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'GestObra',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildDesktopItem(0, Icons.home_outlined, Icons.home, 'Inicio'),
          _buildDesktopItem(
            1,
            Icons.business_center_outlined,
            Icons.business_center,
            'Obras',
          ),
          _buildDesktopItem(2, Icons.groups_outlined, Icons.groups, 'Personal'),
          _buildDesktopItem(
            3,
            Icons.manage_accounts_outlined,
            Icons.manage_accounts,
            'Usuarios',
          ),
          _buildDesktopItem(4, Icons.person_outline, Icons.person, 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildDesktopItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
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
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
