import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/reporte_semanal.dart';
import '../../providers/supervisor_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

class ReportDetailScreen extends StatefulWidget {
  final ReporteSemanal report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final _observacionesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SupervisorProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
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
            _InfoSection(
              title: 'Información General',
              icon: Icons.info_outline,
              iconColor: AppColors.primary,
              children: [
                _InfoRow('Estudiante', widget.report.estudiante?.fullName ?? 'N/A'),
                _InfoRow('Semana', widget.report.semana.toString()),
                _InfoRow('Periodo', widget.report.periodoAcademico),
                _InfoRow(
                    'Horas', '${widget.report.horasTrabajadas.toStringAsFixed(1)} horas'),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.report.objetivosPeriodo != null)
              _InfoSection(
                title: 'Objetivos del Período',
                icon: Icons.flag_outlined,
                iconColor: AppColors.textSecondary,
                children: [
                  Text(widget.report.objetivosPeriodo!,
                      style: AppTextStyles.bodyMedium),
                ],
              ),
            const SizedBox(height: 16),
            if (widget.report.actividadesRealizadas != null)
              _InfoSection(
                title: 'Actividades Realizadas',
                icon: Icons.checklist_outlined,
                iconColor: AppColors.textSecondary,
                children: [
                  Text(widget.report.actividadesRealizadas!,
                      style: AppTextStyles.bodyMedium),
                ],
              ),
            const SizedBox(height: 16),
            if (widget.report.descripcionActividades != null)
              _InfoSection(
                title: 'Descripción de Actividades',
                icon: Icons.description_outlined,
                iconColor: AppColors.textSecondary,
                children: [
                  Text(widget.report.descripcionActividades!,
                      style: AppTextStyles.bodyMedium),
                ],
              ),
            const SizedBox(height: 16),
            if (widget.report.observaciones != null)
              _InfoSection(
                title: 'Observaciones del Estudiante',
                icon: Icons.comment_outlined,
                iconColor: AppColors.textSecondary,
                children: [
                  Text(widget.report.observaciones!,
                      style: AppTextStyles.bodyMedium),
                ],
              ),
            const SizedBox(height: 24),
            if (widget.report.isPendiente) ...[
              _InfoSection(
                title: 'Observaciones del Supervisor',
                icon: Icons.comment_outlined,
                iconColor: AppColors.primary,
                children: [
                  TextField(
                    controller: _observacionesController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Ingresa observaciones o motivo de rechazo si es necesario...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Rechazar',
                      color: AppColors.textSecondary,
                      icon: Icons.cancel,
                      isLoading: provider.isLoading,
                      onPressed: () => _rejectReport(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Aprobar',
                      color: AppColors.primary,
                      icon: Icons.check_circle,
                      isLoading: provider.isLoading,
                      onPressed: () => _approveReport(context),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }


  Future<void> _approveReport(BuildContext context) async {
    final provider = Provider.of<SupervisorProvider>(context, listen: false);

    final success = await provider.approveReport(
      widget.report.estudianteBecarioId,
      widget.report.id,
      observaciones: _observacionesController.text.isNotEmpty
          ? _observacionesController.text
          : null,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte aprobado exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _rejectReport(BuildContext context) async {
    if (_observacionesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes indicar el motivo del rechazo'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final provider = Provider.of<SupervisorProvider>(context, listen: false);

    final success = await provider.rejectReport(
      widget.report.estudianteBecarioId,
      widget.report.id,
      _observacionesController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte rechazado'),
          backgroundColor: AppColors.warning,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
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
                  Text(
                    title,
                    style: AppTextStyles.heading3,
                  ),
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
