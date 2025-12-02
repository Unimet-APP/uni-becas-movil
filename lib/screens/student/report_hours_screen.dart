import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

class ReportHoursScreen extends StatefulWidget {
  const ReportHoursScreen({super.key});

  @override
  State<ReportHoursScreen> createState() => _ReportHoursScreenState();
}

class _ReportHoursScreenState extends State<ReportHoursScreen> {
  final _formKey = GlobalKey<FormState>();
  final _horasController = TextEditingController();
  final _actividadesRealizadasController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _observacionesController = TextEditingController();
  int _selectedWeek = 1;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);
    final currentPeriod = provider.currentPeriod;

    if (currentPeriod == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Reportar Horas'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No se pudo cargar el período académico'),
        ),
      );
    }

    final enabledWeeks = currentPeriod.semanasHabilitadas;

    if (enabledWeeks.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Reportar Horas'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'No hay semanas habilitadas para reportar en este momento.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reportar Horas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Período Académico', style: AppTextStyles.heading3),
                      const SizedBox(height: 8),
                      Text(
                        currentPeriod.periodoAcademico,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Semanas habilitadas: ${enabledWeeks.length}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Selecciona la Semana', style: AppTextStyles.heading3),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: enabledWeeks.contains(_selectedWeek) ? _selectedWeek : enabledWeeks.first,
                decoration: InputDecoration(
                  labelText: 'Semana',
                  prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                items: enabledWeeks
                    .map((week) => DropdownMenuItem(
                          value: week,
                          child: Text('Semana $week'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedWeek = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _horasController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Horas Trabajadas',
                  prefixIcon: const Icon(Icons.access_time, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  helperText: 'Ingresa el número de horas (ej: 10 o 10.5)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa las horas trabajadas';
                  }
                  final hours = double.tryParse(value);
                  if (hours == null || hours <= 0) {
                    return 'Ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _actividadesRealizadasController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Actividades Realizadas',
                  prefixIcon: const Icon(Icons.list, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  helperText: 'Describe las actividades que realizaste esta semana',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Describe las actividades realizadas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Descripción Detallada',
                  prefixIcon: const Icon(Icons.description, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  helperText: 'Proporciona detalles adicionales',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacionesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Observaciones (Opcional)',
                  prefixIcon: const Icon(Icons.note, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Enviar Reporte',
                  icon: Icons.send,
                  isLoading: provider.isLoading,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      
                      final success = await provider.createReport(
                        userId: authProvider.user!.id,
                        semana: _selectedWeek,
                        periodoAcademico: currentPeriod.periodoAcademico,
                        fecha: DateTime.now().toIso8601String().split('T')[0],
                        horasTrabajadas: double.parse(_horasController.text),
                        actividadesRealizadas: _actividadesRealizadasController.text,
                        descripcionActividades: _descripcionController.text.isNotEmpty
                            ? _descripcionController.text
                            : null,
                        observaciones: _observacionesController.text.isNotEmpty
                            ? _observacionesController.text
                            : null,
                      );

                      if (success && mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.success),
                                const SizedBox(width: 8),
                                const Text('Reporte Enviado'),
                              ],
                            ),
                            content: const Text(
                              'Tu reporte ha sido enviado exitosamente y está pendiente de aprobación.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: const Text('Aceptar'),
                              ),
                            ],
                          ),
                        );
                      } else if (provider.error != null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(provider.error!),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
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
  void dispose() {
    _horasController.dispose();
    _actividadesRealizadasController.dispose();
    _descripcionController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }
}
