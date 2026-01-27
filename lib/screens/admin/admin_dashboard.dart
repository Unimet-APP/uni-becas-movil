import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/stat_card.dart';
import 'pending_users_screen.dart';
import 'plazas_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      provider.loadPendingUsers();
      provider.loadStatistics();
    });
  }

  Future<void> _handleRefresh() async {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    await Future.wait([
      provider.loadPendingUsers(),
      provider.loadStatistics(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);
    final stats = adminProvider.statistics;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro que deseas salir?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        authProvider.logout();
                        Navigator.pop(context);
                      },
                      child: const Text('Salir'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, ${authProvider.user?.nombre ?? "Admin"}',
                        style: AppTextStyles.heading1,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Panel de Administración',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.3,
                        children: [
                          StatCard(
                            title: 'Usuarios Pendientes',
                            value: '${adminProvider.pendingUsersCount}',
                            icon: Icons.pending,
                            color: AppColors.warning,
                            badge: adminProvider.pendingUsersCount,
                          ),
                          StatCard(
                            title: 'Total Beneficiarios',
                            value: '${stats?['total_beneficiarios'] ?? 0}',
                            icon: Icons.people,
                            color: AppColors.info,
                          ),
                          StatCard(
                            title: 'Solicitudes',
                            value: '${stats?['total_solicitudes'] ?? 0}',
                            icon: Icons.assignment,
                            color: AppColors.primary,
                          ),
                          StatCard(
                            title: 'Tasa Aprobación',
                            value: '${stats?['tasa_aprobacion']?.toInt() ?? 0}%',
                            icon: Icons.check_circle,
                            color: AppColors.success,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text('Acciones Rápidas', style: AppTextStyles.heading2),
                      const SizedBox(height: 16),
                      _QuickActionCard(
                        title: 'Usuarios Pendientes',
                        subtitle:
                            '${adminProvider.pendingUsersCount} esperando aprobación',
                        icon: Icons.how_to_reg,
                        color: AppColors.warning,
                        badge: adminProvider.pendingUsersCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PendingUsersScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _QuickActionCard(
                        title: 'Gestionar Estudiantes',
                        subtitle: 'Ver y administrar estudiantes',
                        icon: Icons.school,
                        color: AppColors.info,
                        onTap: () {
                          // TODO: Navigate to students screen
                        },
                      ),
                      const SizedBox(height: 12),
                      _QuickActionCard(
                        title: 'Gestionar Plazas',
                        subtitle: 'Administrar plazas disponibles',
                        icon: Icons.location_on,
                        color: AppColors.primary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PlazasManagementScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _QuickActionCard(
                        title: 'Reportes y Estadísticas',
                        subtitle: 'Ver reportes del sistema',
                        icon: Icons.bar_chart,
                        color: AppColors.success,
                        onTap: () {
                          // TODO: Navigate to statistics screen
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int? badge;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              if (badge != null && badge! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
