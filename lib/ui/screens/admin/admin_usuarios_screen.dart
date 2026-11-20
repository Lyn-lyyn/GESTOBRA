import 'package:flutter/material.dart';
import 'widgets/admin_usuarios_list.dart';

class AdminUsuariosScreen extends StatelessWidget {
  const AdminUsuariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminUsuariosList(
      titulo: 'Gestión de Usuarios',
      filtrarSoloOperativos: false,
      iconoNuevo: Icons.person_add_alt_1,
    );
  }
}