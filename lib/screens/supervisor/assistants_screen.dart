import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/supervisor_provider.dart';
import '../../models/becario.dart';
import '../../utils/constants.dart';

class AssistantsScreen extends StatelessWidget {
  final bool filterWithoutPlaza;

  const AssistantsScreen({super.key, this.filterWithoutPlaza = false});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SupervisorProvider>(context);

    final assistants = filterWithoutPlaza
        ? provider.assistants.where((a) => !a.hasPlaza).toList()
        : provider.assistants;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
            filterWithoutPlaza ? 'Estudiantes Sin Plaza' : 'Mis Ayudantes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : assistants.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        filterWithoutPlaza ? Icons.check_circle : Icons.people,
                        size: 80,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        filterWithoutPlaza
                            ? 'Todos tienen plaza asignada'
                            : 'No tienes ayudantes',
                        style: AppTextStyles.heading2,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: assistants.length,
                  itemBuilder: (context, index) {
                    final assistant = assistants[index];
                    return _AssistantCard(assistant: assistant);
                  },
                ),
    );
  }
}

class _AssistantCard extends StatelessWidget {
  final Becario assistant;

  const _AssistantCard({required this.assistant});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      assistant.usuario.nombre[0].toUpperCase(),
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
                        assistant.usuario.fullName,
                        style: AppTextStyles.heading3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        assistant.usuario.email,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: assistant.isActiva
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: assistant.isActiva
                          ? AppColors.success.withOpacity(0.3)
                          : AppColors.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: assistant.isActiva ? AppColors.success : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        assistant.estado,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: assistant.isActiva ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoChipModern(
                    icon: Icons.school,
                    label: assistant.tipoBeca,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoChipModern(
                    icon: Icons.access_time,
                    label: '${assistant.horasCompletadas.toInt()}/${assistant.horasRequeridas}h',
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            if (assistant.hasPlaza && assistant.plaza != null) ...[
              const SizedBox(height: 8),
              _InfoChipModern(
                icon: Icons.location_on,
                label: assistant.plaza!.materia,
                color: AppColors.success,
              ),
            ],
          ],
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
