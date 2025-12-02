import 'package:flutter/material.dart';
import '../../models/reporte_semanal.dart';
import '../../utils/constants.dart';

class StudentReportDetailScreen extends StatelessWidget {
  final ReporteSemanal report;

  const StudentReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalle del Reporte'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado del reporte
            _buildStatusCard(),
            const SizedBox(height: 16),

            // Información General
            _InfoSection(
              title: 'Información General',
              children: [
                _InfoRow('Semana', report.semana.toString()),
                _InfoRow('Período', report.periodoAcademico),
                _InfoRow('Horas Trabajadas', '${report.horasTrabajadas.toStringAsFixed(1)} horas'),
                if (report.fecha != null)
                  _InfoRow('Fecha', _formatDate(report.fecha!)),
              ],
            ),
            const SizedBox(height: 16),

            // Objetivos
            if (report.objetivosPeriodo != null)
              _InfoSection(
                title: 'Objetivos del Período',
                icon: Icons.flag_outlined,
                iconColor: AppColors.primary,
                children: [
                  Text(report.objetivosPeriodo!, style: AppTextStyles.bodyMedium),
                ],
              ),
            const SizedBox(height: 16),

            // Metas
            if (report.metasEspecificas != null)
              _InfoSection(
                title: 'Metas Específicas',
                icon: Icons.gps_fixed_outlined,
                iconColor: AppColors.info,
                children: [
                  Text(report.metasEspecificas!, style: AppTextStyles.bodyMedium),
                ],
              ),
            const SizedBox(height: 16),

            // Actividades Programadas
            if (report.actividadesProgramadas != null)
              _InfoSection(
                title: 'Actividades Programadas',
                icon: Icons.event_note_outlined,
                iconColor: AppColors.warning,
                children: [
                  Text(report.actividadesProgramadas!, style: AppTextStyles.bodyMedium),
                ],
              ),
            const SizedBox(height: 16),

            // Actividades Realizadas
            if (report.actividadesRealizadas != null)
              _InfoSection(
                title: 'Actividades Realizadas',
                icon: Icons.checklist_outlined,
                iconColor: AppColors.success,
                children: [
                  Text(report.actividadesRealizadas!, style: AppTextStyles.bodyMedium),
                ],
              ),
            const SizedBox(height: 16),

            // Descripción
            if (report.descripcionActividades != null)
              _InfoSection(
                title: 'Descripción de Actividades',
                icon: Icons.description_outlined,
                iconColor: AppColors.info,
                children: [
                  Text(report.descripcionActividades!, style: AppTextStyles.bodyMedium),
                ],
              ),
            const SizedBox(height: 16),

            // Observaciones del estudiante
            if (report.observaciones != null)
              _InfoSection(
                title: 'Mis Observaciones',
                icon: Icons.note_outlined,
                iconColor: AppColors.textSecondary,
                children: [
                  Text(report.observaciones!, style: AppTextStyles.bodyMedium),
                ],
              ),
            const SizedBox(height: 16),

            // Observaciones del supervisor
            if (report.observacionesSupervisor != null)
              _InfoSection(
                title: 'Observaciones del Supervisor',
                icon: Icons.comment_outlined,
                iconColor: AppColors.success,
                children: [
                  Text(report.observacionesSupervisor!, style: AppTextStyles.bodyMedium),
                ],
              ),

            // Motivo de rechazo
            if (report.motivoRechazo != null) ...[
              const SizedBox(height: 16),
              _InfoSection(
                title: 'Motivo del Rechazo',
                icon: Icons.info_outline,
                iconColor: AppColors.error,
                children: [
                  Text(
                    report.motivoRechazo!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ],

            // Información del supervisor
            if (report.supervisor != null) ...[
              const SizedBox(height: 16),
              _InfoSection(
                title: 'Supervisor',
                icon: Icons.person_outline,
                iconColor: AppColors.primary,
                children: [
                  _InfoRow('Nombre', report.supervisor!.fullName),
                  _InfoRow('Email', report.supervisor!.email),
                ],
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (report.estado) {
      case EstadoReporte.aprobada:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        statusText = 'Aprobado';
        break;
      case EstadoReporte.rechazada:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        statusText = 'Rechazado';
        break;
      case EstadoReporte.enRevision:
        statusColor = AppColors.info;
        statusIcon = Icons.rate_review;
        statusText = 'En Revisión';
        break;
      case EstadoReporte.pendiente:
      default:
        statusColor = AppColors.warning;
        statusIcon = Icons.pending;
        statusText = 'Pendiente';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado del Reporte',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: AppTextStyles.heading2.copyWith(
                    color: statusColor,
                  ),
                ),
                if (report.fechaAprobacion != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Fecha: ${_formatDate(report.fechaAprobacion!)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final IconData? icon;
  final Color? iconColor;

  const _InfoSection({
    required this.title,
    required this.children,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              AppColors.background.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: iconColor ?? AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(title, style: AppTextStyles.heading3),
                ],
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
