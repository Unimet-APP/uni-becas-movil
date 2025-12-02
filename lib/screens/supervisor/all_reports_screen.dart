import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/supervisor_provider.dart';
import '../../models/reporte_semanal.dart';
import '../../utils/constants.dart';
import 'report_detail_screen.dart';

class AllReportsScreen extends StatefulWidget {
  const AllReportsScreen({super.key});

  @override
  State<AllReportsScreen> createState() => _AllReportsScreenState();
}

class _AllReportsScreenState extends State<AllReportsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedFilter;

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

    // Obtener todos los reportes y filtrar
    final allReports = supervisorProvider.reportesGlobales?.reportes
        .where((r) {
          // Filtro por estado
          if (_selectedFilter != null) {
            if (_selectedFilter == 'Pendientes' && r.estado != EstadoReporte.pendiente) return false;
            if (_selectedFilter == 'Aprobados' && r.estado != EstadoReporte.aprobada) return false;
            if (_selectedFilter == 'Rechazados' && r.estado != EstadoReporte.rechazada) return false;
          }
          return true;
        })
        .where((r) {
          // Filtro por búsqueda
          if (_searchQuery.isEmpty) return true;
          final fullName = r.estudiante?.fullName.toLowerCase() ?? '';
          final email = r.estudiante?.email.toLowerCase() ?? '';
          return fullName.contains(_searchQuery) || email.contains(_searchQuery);
        })
        .toList() ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Todos los Reportes'),
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
                child: Column(
                  children: [
                    TextField(
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
                    const SizedBox(height: 12),
                    // Filtros por estado
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'Todos',
                            isSelected: _selectedFilter == null,
                            onTap: () => setState(() => _selectedFilter = null),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Pendientes',
                            isSelected: _selectedFilter == 'Pendientes',
                            color: AppColors.warning,
                            onTap: () => setState(() => _selectedFilter = 'Pendientes'),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Aprobados',
                            isSelected: _selectedFilter == 'Aprobados',
                            color: AppColors.success,
                            onTap: () => setState(() => _selectedFilter = 'Aprobados'),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Rechazados',
                            isSelected: _selectedFilter == 'Rechazados',
                            color: AppColors.error,
                            onTap: () => setState(() => _selectedFilter = 'Rechazados'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de reportes
              Expanded(
                child: supervisorProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _handleRefresh,
                        child: allReports.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: allReports.length,
                                itemBuilder: (context, index) {
                                  final reporte = allReports[index];
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
            Icons.assignment_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay reportes',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta cambiar los filtros',
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : chipColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: chipColor,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : chipColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReporteSemanal reporte;
  final VoidCallback onTap;

  const _ReportCard({
    required this.reporte,
    required this.onTap,
  });

  Color _getStatusColor(EstadoReporte estado) {
    switch (estado) {
      case EstadoReporte.pendiente:
        return AppColors.warning;
      case EstadoReporte.aprobada:
        return AppColors.success;
      case EstadoReporte.rechazada:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(EstadoReporte estado) {
    switch (estado) {
      case EstadoReporte.pendiente:
        return 'Pendiente';
      case EstadoReporte.aprobada:
        return 'Aprobado';
      case EstadoReporte.rechazada:
        return 'Rechazado';
      default:
        return 'Desconocido';
    }
  }

  IconData _getStatusIcon(EstadoReporte estado) {
    switch (estado) {
      case EstadoReporte.pendiente:
        return Icons.pending_actions;
      case EstadoReporte.aprobada:
        return Icons.check_circle;
      case EstadoReporte.rechazada:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(reporte.estado);
    
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
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(reporte.estado),
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusLabel(reporte.estado),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: statusColor,
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

