import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

// Importa aquí las pantallas que irán dentro (tus compañeros las crearán)
import 'dashboard_screen.dart'; // Asumimos que existe
import '../obras/obras_list_screen.dart'; // Asumimos que existe
import '../perfil/perfil_screen.dart'; // Asumimos que existe

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // Lista de pantallas que se mostrarán según el índice
  final List<Widget> _screens = [
    const DashboardScreen(),
    const ObrasListScreen(),
    const PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      
      // El cuerpo cambia según la pestaña seleccionada
      body: _screens[_currentIndex],
      
      // La barra de navegación inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.naranja,
        unselectedItemColor: AppColors.textoGris,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed, // Para que no se muevan los iconos
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.engineering_outlined),
            activeIcon: Icon(Icons.engineering),
            label: 'Obras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}