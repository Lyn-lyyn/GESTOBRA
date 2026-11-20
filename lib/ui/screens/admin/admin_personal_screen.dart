import 'package:flutter/material.dart';
import 'widgets/admin_usuarios_list.dart';

class AdminPersonalScreen extends StatelessWidget {
  const AdminPersonalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminUsuariosList(
      titulo: 'Directorio de Personal',
      filtrarSoloOperativos: true,
      iconoNuevo: Icons.group_add_outlined,
    );
  }
}