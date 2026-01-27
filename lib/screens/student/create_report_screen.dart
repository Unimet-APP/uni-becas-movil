import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../utils/constants.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _horasController = TextEditingController();
  final _objetivosController = TextEditingController();
  final _metasController = TextEditingController();
  final _actividadesProgramadasController = TextEditingController();
  final _actividadesRealizadasController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _observacionesController = TextEditingController();

  int? _selectedWeek;
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  bool _isLoadingPeriod = true;

  @override
  void initState() {
    super.initState();
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPeriodoActual();
    });
  }

  Future<void> _loadPeriodoActual() async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    setState(() => _isLoadingPeriod = true);

    // Cargar período actual si no está cargado
    if (studentProvider.currentPeriod == null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await studentProvider.loadStudentData(authProvider.user?.id ?? '');
    }

    // Establecer semana actual como predeterminada si está habilitada
    final currentPeriod = studentProvider.currentPeriod;
    if (currentPeriod != null &&
        currentPeriod.semanasHabilitadas.contains(currentPeriod.semanaActual)) {
      setState(() {
        _selectedWeek = currentPeriod.semanaActual;
      });
    } else if (currentPeriod != null && currentPeriod.semanasHabilitadas.isNotEmpty) {
      setState(() {
        _selectedWeek = currentPeriod.semanasHabilitadas.first;
      });
    }

    setState(() => _isLoadingPeriod = false);
  }

  @override
  void dispose() {
    _horasController.dispose();
    _objetivosController.dispose();
    _metasController.dispose();
    _actividadesProgramadasController.dispose();
    _actividadesRealizadasController.dispose();
    _descripcionController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final currentPeriod = studentProvider.currentPeriod;

    if (currentPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cargar el período académico actual'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedWeek == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una semana'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona la fecha del reporte'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Obtener userId del AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id ?? '';

    // Usar la fecha seleccionada por el usuario
    final reportDate = _selectedDate!;

    final success = await studentProvider.createReport(
      userId: userId,
      semana: _selectedWeek!,
      periodoAcademico: currentPeriod.periodoAcademico,
      fecha: reportDate.toIso8601String(),
      horasTrabajadas: double.tryParse(_horasController.text) ?? 0.0,
      objetivosPeriodo: _objetivosController.text.isNotEmpty ? _objetivosController.text : null,
      metasEspecificas: _metasController.text.isNotEmpty ? _metasController.text : null,
      actividadesProgramadas: _actividadesProgramadasController.text.isNotEmpty
          ? _actividadesProgramadasController.text
          : null,
      actividadesRealizadas: _actividadesRealizadasController.text.isNotEmpty
          ? _actividadesRealizadasController.text
          : null,
      descripcionActividades: _descripcionController.text.isNotEmpty
          ? _descripcionController.text
          : null,
      observaciones: _observacionesController.text.isNotEmpty
          ? _observacionesController.text
          : null,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte creado exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(studentProvider.error ?? 'Error al crear el reporte'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final currentPeriod = studentProvider.currentPeriod;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Crear Reporte de Actividades'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingPeriod
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Información General
                  Text(
                    'Información General',
                    style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),

                  // Mostrar período académico actual (solo lectura)
                  if (currentPeriod != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Período Académico',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentPeriod.periodoAcademico,
                                style: AppTextStyles.heading3.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Selector de Semana (solo semanas habilitadas)
                  if (currentPeriod != null && currentPeriod.semanasHabilitadas.isNotEmpty)
                    DropdownButtonFormField<int>(
                      initialValue: _selectedWeek,
                      decoration: InputDecoration(
                        labelText: 'Semanas Disponibles',
                        prefixIcon: const Icon(Icons.event, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        helperText:
                            'Semana actual: ${currentPeriod.semanaActual}',
                      ),
                      items: currentPeriod.semanasHabilitadas
                          .map((week) => DropdownMenuItem(
                                value: week,
                                child: Text('Semana $week'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedWeek = value);
                        }
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor selecciona una semana';
                        }
                        return null;
                      },
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, color: AppColors.warning),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No hay semanas habilitadas para reportar en este momento',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Selector de Fecha
                  InkWell(
                    onTap: () async {
                      final now = DateTime.now();
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? now,
                        firstDate: DateTime(now.year - 1),
                        lastDate: now,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        setState(() => _selectedDate = pickedDate);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Fecha del Reporte',
                        prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        helperText: 'La fecha no puede ser futura',
                      ),
                      child: Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Selecciona una fecha',
                        style: TextStyle(
                          color: _selectedDate != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Horas Trabajadas
                  TextFormField(
                    controller: _horasController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Horas Trabajadas',
                      prefixIcon: const Icon(Icons.access_time, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa las horas trabajadas';
                      }
                      final hours = double.tryParse(value);
                      if (hours == null || hours <= 0) {
                        return 'Por favor ingresa un número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

            // Objetivos y Metas
            Text(
              'Objetivos y Metas',
              style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _objetivosController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Objetivo General del Período',
                hintText: 'Describe el objetivo principal de este período...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _metasController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Metas Específicas',
                hintText: 'Lista las metas que deseas alcanzar...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Actividades
            Text(
              'Actividades',
              style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _actividadesProgramadasController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Actividades Programadas',
                hintText: 'Describe las actividades que planeaste realizar...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _actividadesRealizadasController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Actividades Realizadas',
                hintText: 'Describe las actividades que completaste...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor describe las actividades realizadas';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descripcionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Descripción Detallada de Actividades',
                hintText: 'Proporciona detalles sobre las actividades...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor proporciona una descripción detallada';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Observaciones
            Text(
              'Observaciones',
              style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _observacionesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Observaciones del Ayudante (Opcional)',
                hintText: 'Agrega comentarios adicionales si lo deseas...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Enviar Reporte',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
