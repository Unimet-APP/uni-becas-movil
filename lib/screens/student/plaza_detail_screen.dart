import 'package:flutter/material.dart';
import '../../models/plaza.dart';
import '../../utils/constants.dart';

class PlazaDetailScreen extends StatelessWidget {
  final Plaza plaza;

  const PlazaDetailScreen({super.key, required this.plaza});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalle de Plaza'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con gradiente
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plaza.materia,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plaza.codigo,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoSection(
                    title: 'Información General',
                    icon: Icons.info_outline,
                    iconColor: AppColors.info,
                    children: [
                      _InfoItem(Icons.location_on, 'Ubicación', plaza.ubicacion),
                      _InfoItem(Icons.category, 'Tipo', plaza.tipoAyudantia),
                      _InfoItem(
                        Icons.access_time,
                        'Horas/Semana',
                        '${plaza.horasSemana} horas',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _InfoSection(
                    title: 'Horario',
                    icon: Icons.schedule,
                    iconColor: AppColors.primary,
                    children: plaza.horario
                        .map((h) => _InfoItem(
                              Icons.calendar_today,
                              h.dia,
                              '${h.horaInicio} - ${h.horaFin}',
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  _InfoSection(
                    title: 'Descripción de Actividades',
                    icon: Icons.description_outlined,
                    iconColor: AppColors.warning,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          plaza.descripcionActividades,
                          style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                        ),
                      ),
                    ],
                  ),
                  if (plaza.requisitosEspeciales.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _InfoSection(
                      title: 'Requisitos Especiales',
                      icon: Icons.checklist,
                      iconColor: AppColors.success,
                      children: plaza.requisitosEspeciales
                          .map((req) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 18,
                                      color: AppColors.success,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        req,
                                        style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                  if (plaza.supervisor != null) ...[
                    const SizedBox(height: 20),
                    _InfoSection(
                      title: 'Supervisor',
                      icon: Icons.supervisor_account,
                      iconColor: AppColors.primary,
                      children: [
                        _InfoItem(Icons.person, 'Nombre', plaza.supervisor!.fullName),
                        _InfoItem(Icons.email, 'Email', plaza.supervisor!.email),
                        if (plaza.supervisor!.departamento != null)
                          _InfoItem(
                            Icons.business,
                            'Departamento',
                            plaza.supervisor!.departamento!,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withOpacity(0.08),
                  iconColor.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.center,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.heading3.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
