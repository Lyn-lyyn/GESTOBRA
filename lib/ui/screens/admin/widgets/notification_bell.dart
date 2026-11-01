import 'package:flutter/material.dart';
import 'package:gestobra/config/theme/app_colors.dart';
import 'package:gestobra/servicios/api_service.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _noLeidas = 0;
  List<Map<String, dynamic>> _notificaciones = [];

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    final res = await ApiService.get('notificaciones.php');
    if (res['estado'] == true) {
      final data = List<Map<String, dynamic>>.from(res['data']);
      setState(() {
        _notificaciones = data;
        _noLeidas = data.where((n) => n['leida'] == 0 || n['leida'] == false).length;
      });
    }
  }

  Future<void> _marcarLeida(int id) async {
    await ApiService.post('notificaciones.php', {'id_notificacion': id});
    _cargarNotificaciones();
  }

  Future<void> _marcarTodas() async {
    await ApiService.post('notificaciones.php', {'marcar_todas': true});
    _cargarNotificaciones();
  }

  void _abrirPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.grisfondo,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Notificaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (_noLeidas > 0)
                    TextButton(onPressed: _marcarTodas, child: const Text('Marcar todas leídas')),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _notificaciones.isEmpty
                    ? const Center(child: Text('No tienes notificaciones'))
                    : ListView.builder(
                        itemCount: _notificaciones.length,
                        itemBuilder: (context, i) {
                          final n = _notificaciones[i];
                          final esLeida = n['leida'] == 1 || n['leida'] == true;
                          return Card(
                            color: esLeida ? AppColors.blanco : AppColors.naranja.withValues(alpha: 0.1),
                            child: ListTile(
                              leading: Icon(Icons.notifications, color: esLeida ? AppColors.textoGris : AppColors.naranja),
                              title: Text(n['titulo'], style: TextStyle(fontWeight: esLeida ? FontWeight.normal : FontWeight.bold)),
                              subtitle: Text(n['mensaje']),
                              onTap: () => _marcarLeida(n['id_notificacion']),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.naranja),
          onPressed: _abrirPanel,
        ),
        if (_noLeidas > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: AppColors.estadoRojo, shape: BoxShape.circle),
              child: Text('$_noLeidas', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }
}