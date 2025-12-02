import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/supervisor_provider.dart';
import '../../models/reporte_semanal.dart';
import '../../utils/constants.dart';
import 'report_detail_screen.dart';

class PendingReportsScreen extends StatefulWidget {
  const PendingReportsScreen({super.key});

  @override
  State<PendingReportsScreen> createState() => _PendingReportsScreenState();
}

class _PendingReportsScreenState extends State<PendingReportsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReports();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final supervisorProvider = Provider.of<SupervisorProvider>(context, listen: false);

    if (authProvider.user != null) {
      await supervisorProvider.refreshWithId(authProvider.user!.id);
    }
  }

  Future<void> _handleRefresh() async {
    await _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    final supervisorProvider = Provider.of<SupervisorProvider>(context);

    // Obtener reportes pendientes de reportesGlobales y filtrar por búsqueda
    final pendingReports = supervisorProvider.reportesGlobales?.reportes
        .where((r) => r.estado == EstadoReporte.pendiente)
        .where((r) {
          if (_searchQuery.isEmpty) return true;
          final fullName = r.estudiante?.fullName.toLowerCase() ?? '';
          final email = r.estudiante?.email.toLowerCase() ?? '';
          return fullName.contains(_searchQuery) || email.contains(_searchQuery);
        })
        .toList() ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Reportes Pendientes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Diseño de fondo moderno con líneas naranjas
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
            painter: ModernLinesPainter(),
          ),

          // Contenido
          Column(
            children: [
              // Buscador
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o email...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
              ),

              // Lista de reportes
              Expanded(
                child: supervisorProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _handleRefresh,
                        child: pendingReports.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: pendingReports.length,
                                itemBuilder: (context, index) {
                                  final reporte = pendingReports[index];
                                  return _ReportCard(
                                    reporte: reporte,
                                    onTap: () => _navigateToDetail(reporte),
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppColors.success.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay reportes pendientes',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Todos los reportes han sido revisados',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(ReporteSemanal reporte) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailScreen(report: reporte),
      ),
    );
    // Recargar la lista al regresar
    _handleRefresh();
  }
}

class _ReportCard extends StatelessWidget {
  final ReporteSemanal reporte;
  final VoidCallback onTap;

  const _ReportCard({
    required this.reporte,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.primary.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con estudiante y badge
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          reporte.estudiante?.nombre[0].toUpperCase() ?? 'E',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reporte.estudiante?.fullName ?? 'Sin nombre',
                          style: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          reporte.estudiante?.email ?? '',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pending_actions,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pendiente',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Información del reporte
              Row(
                children: [
                  Expanded(
                    child: _InfoChipModern(
                      icon: Icons.calendar_today,
                      label: 'Semana ${reporte.semana}',
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoChipModern(
                      icon: Icons.access_time,
                      label: '${reporte.horasTrabajadas.toStringAsFixed(1)}h',
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _InfoChipModern(
                icon: Icons.school,
                label: reporte.periodoAcademico,
                color: AppColors.primary,
              ),

              // Fecha de creación
              if (reporte.fecha != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Fecha: ${_formatDate(reporte.fecha!)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],

              // Botón de ver detalles
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ver detalles',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: AppColors.primary,
                        ),
                      ],
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

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return isoDate;
    }
  }
}

class _InfoChipModern extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChipModern({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// Painter para las líneas de fondo modernas
class ModernLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.12)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Líneas diagonales en la parte superior derecha
    for (int i = 0; i < 5; i++) {
      final path = Path();
      path.moveTo(size.width * 0.6 + (i * 40), 0);
      path.lineTo(size.width + (i * 40), size.height * 0.3);
      canvas.drawPath(path, paint);
    }

    // Líneas horizontales sutiles en el medio
    for (int i = 0; i < 3; i++) {
      final y = size.height * 0.4 + (i * 60);
      final path = Path();
      path.moveTo(0, y);
      path.lineTo(size.width * 0.3, y);
      canvas.drawPath(path, paint);
    }

    // Líneas diagonales en la parte inferior izquierda
    for (int i = 0; i < 4; i++) {
      final path = Path();
      path.moveTo(0 - (i * 50), size.height * 0.7);
      path.lineTo(size.width * 0.4 - (i * 50), size.height);
      canvas.drawPath(path, paint);
    }

    // Líneas verticales sutiles a la derecha
    for (int i = 0; i < 2; i++) {
      final x = size.width * 0.85 + (i * 30);
      final path = Path();
      path.moveTo(x, size.height * 0.5);
      path.lineTo(x, size.height * 0.8);
      canvas.drawPath(path, paint);
    }

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
