import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/aspirante_provider.dart';
import '../../utils/constants.dart';
import '../welcome_screen.dart';
import 'tabs/trayectoria_tab.dart';
import 'tabs/orientacion_tab.dart';
import 'tabs/chatbot_tab.dart';
import 'tabs/notificaciones_tab.dart';
import 'tabs/perfil_tab.dart';

class DashboardAspiranteScreen extends StatefulWidget {
  const DashboardAspiranteScreen({super.key});

  @override
  State<DashboardAspiranteScreen> createState() =>
      _DashboardAspiranteScreenState();
}

class _DashboardAspiranteScreenState extends State<DashboardAspiranteScreen> {
  int _currentIndex = 0;

  final List<_TabItem> _tabs = const [
    _TabItem(icon: Icons.upload_file, label: 'Trayectoria'),
    _TabItem(icon: Icons.explore, label: 'Orientacion'),
    _TabItem(icon: Icons.psychology, label: 'Chatbot'),
    _TabItem(icon: Icons.notifications, label: 'Avisos'),
    _TabItem(icon: Icons.person, label: 'Perfil'),
  ];

  @override
  void initState() {
    super.initState();
    // Cargar datos iniciales según la pestaña activa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatosTab(_currentIndex);
    });
  }

  void _cargarDatosTab(int index) {
    final provider = Provider.of<AspiranteProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    switch (index) {
      case 0: // Trayectoria
        provider.cargarTrayectoria();
        break;
      case 3: // Notificaciones
        if (authProvider.user != null) {
          provider.cargarNotificaciones(authProvider.user!.id);
        }
        break;
      case 4: // Perfil
        provider.cargarPerfilYHistorial();
        provider.cargarTrayectoria();
        break;
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesion'),
        content: const Text('¿Estas seguro que deseas salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Trayectoria Academica';
      case 1:
        return 'Orientacion Vocacional';
      case 2:
        return 'Chatbot Vocacional';
      case 3:
        return 'Notificaciones';
      case 4:
        return 'Mi Perfil';
      default:
        return 'Orientacion Vocacional';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getTitle(_currentIndex),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_currentIndex == 0)
              const Text(
                'Sistema de Orientacion',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_currentIndex == 3)
            Consumer<AspiranteProvider>(
              builder: (context, provider, _) {
                final count = provider.notificacionesNoLeidas;
                if (count == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count sin leer',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          TrayectoriaTab(),
          OrientacionTab(),
          ChatbotTab(),
          NotificacionesTab(),
          PerfilTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index != _currentIndex) {
              setState(() => _currentIndex = index);
              _cargarDatosTab(index);
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: _tabs.map((tab) {
            final idx = _tabs.indexOf(tab);
            // Badge para notificaciones
            if (idx == 3) {
              return BottomNavigationBarItem(
                icon: Consumer<AspiranteProvider>(
                  builder: (context, provider, child) {
                    final count = provider.notificacionesNoLeidas;
                    return Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      child: Icon(tab.icon),
                    );
                  },
                ),
                label: tab.label,
              );
            }
            return BottomNavigationBarItem(
              icon: Icon(tab.icon),
              label: tab.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;

  const _TabItem({required this.icon, required this.label});
}
