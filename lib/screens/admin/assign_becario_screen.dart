import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/plaza.dart';
import '../../providers/admin_provider.dart';
import '../../utils/constants.dart';

class AssignBecarioScreen extends StatefulWidget {
  final Plaza plaza;

  const AssignBecarioScreen({
    super.key,
    required this.plaza,
  });

  @override
  State<AssignBecarioScreen> createState() => _AssignBecarioScreenState();
}

class _AssignBecarioScreenState extends State<AssignBecarioScreen> {
  String? _selectedBecarioId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      provider.loadBecariosCompatibles(widget.plaza.id);
    });
  }

  Future<void> _assignBecario() async {
    if (_selectedBecarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un estudiante'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final provider = Provider.of<AdminProvider>(context, listen: false);
    final success =
        await provider.assignBecarioToPlaza(_selectedBecarioId!, widget.plaza.id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Becario asignado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Error al asignar becario'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final response = adminProvider.becariosCompatibles;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Asignar Estudiante a Plaza'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : response == null
              ? const Center(child: Text('No se pudieron cargar los datos'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información de la Plaza
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          response.plaza.materia,
                                          style: AppTextStyles.heading2,
                                        ),
                                        Text(
                                          response.plaza.codigo,
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                  color:
                                                      AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              _InfoRow(
                                icon: Icons.business,
                                label: 'Departamento',
                                value: response.plaza.departamento,
                              ),
                              const SizedBox(height: 8),
                              _InfoRow(
                                icon: Icons.work,
                                label: 'Tipo de Ayudantía',
                                value: response.plaza.tipoAyudantia,
                              ),
                              const SizedBox(height: 8),
                              _InfoRow(
                                icon: Icons.schedule,
                                label: 'Total de Bloques',
                                value: '${response.plaza.totalBloques} bloques',
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Horarios de la Plaza:',
                                style: AppTextStyles.heading3,
                              ),
                              const SizedBox(height: 8),
                              ...response.plaza.horario.map(
                                (h) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 16,
                                          color: AppColors.textSecondary),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${h.dia} ${h.horaInicio}-${h.horaFin}',
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Información del umbral
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.info),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info, color: AppColors.info),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Mostrando becarios con al menos ${response.umbralBloques} bloques compatibles',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Lista de becarios compatibles
                      Text(
                        'Selecciona un estudiante para asignar:',
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: 12),

                      if (response.becarios.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.person_off,
                                  size: 64,
                                  color: AppColors.textSecondary
                                      .withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay becarios compatibles disponibles',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...response.becarios.map((becario) {
                          final isSelected = _selectedBecarioId == becario.id;
                          return Card(
                            elevation: isSelected ? 4 : 1,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedBecarioId = becario.id;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: isSelected
                                              ? AppColors.primary
                                              : AppColors.primary
                                                  .withOpacity(0.1),
                                          child: Icon(
                                            Icons.person,
                                            color: isSelected
                                                ? Colors.white
                                                : AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${becario.usuario.nombre} ${becario.usuario.apellido}',
                                                style: AppTextStyles.heading3,
                                              ),
                                              Text(
                                                becario.usuario.email,
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle,
                                            color: AppColors.primary,
                                            size: 28,
                                          ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    _InfoRow(
                                      icon: Icons.badge,
                                      label: 'Cédula',
                                      value: becario.usuario.cedula ?? 'N/A',
                                    ),
                                    const SizedBox(height: 8),
                                    _InfoRow(
                                      icon: Icons.school,
                                      label: 'Carrera',
                                      value: becario.usuario.carrera ?? 'N/A',
                                    ),
                                    const SizedBox(height: 12),
                                    // Estadísticas de compatibilidad
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _getCompatibilityColor(
                                                becario.porcentajeCobertura)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              _StatChip(
                                                label: 'Compatibilidad',
                                                value:
                                                    '${becario.porcentajeCobertura.toInt()}%',
                                                color: _getCompatibilityColor(
                                                    becario
                                                        .porcentajeCobertura),
                                              ),
                                              _StatChip(
                                                label: 'Bloques',
                                                value:
                                                    '${becario.bloquesMatcheados}/${becario.totalBloques}',
                                                color: AppColors.info,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: becario.porcentajeCobertura /
                                                  100,
                                              minHeight: 8,
                                              backgroundColor: Colors.grey[300],
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                _getCompatibilityColor(
                                                    becario.porcentajeCobertura),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                      const SizedBox(height: 24),

                      // Botón de asignación
                      if (response.becarios.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _selectedBecarioId != null
                                ? _assignBecario
                                : null,
                            icon: const Icon(Icons.assignment_turned_in),
                            label: const Text('Asignar Becario'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: AppTextStyles.heading3,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Color _getCompatibilityColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.warning;
    return AppColors.error;
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(color: color),
        ),
      ],
    );
  }
}
