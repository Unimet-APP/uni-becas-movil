import 'package:flutter/material.dart';
import 'unified_application_form.dart';
import '../../utils/constants.dart';
import '../../services/configuracion_service.dart';
import '../../models/configuracion_beca.dart';

class FormacionDocenteScreen extends StatefulWidget {
  const FormacionDocenteScreen({super.key});

  @override
  State<FormacionDocenteScreen> createState() => _FormacionDocenteScreenState();
}

class _FormacionDocenteScreenState extends State<FormacionDocenteScreen> {
  final ConfiguracionService _configuracionService = ConfiguracionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Beca Formación Docente'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<ConfiguracionBeca?>(
        future: _configuracionService.getConfiguracion('Formación Docente'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final config = snapshot.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.menu_book,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Beca Formación Docente',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        config?.requisitosEspeciales ??
                        'Desarrollo de competencias para docentes en ejercicio',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Requisitos
                _buildSection(
                  'Requisitos para Postular',
                  Icons.check_circle_outline,
                  [
                    'Ser docente en ejercicio al momento de la postulación',
                    'Mantener condición de docente durante el proceso formativo',
                    if (config != null)
                      'IAA mínimo de ${config.promedioMinimo} puntos'
                    else
                      'IAA mínimo de 14.00 puntos',
                  ],
                ),

                const SizedBox(height: 20),

                // Documentos Requeridos
                if (config != null && config.documentosRequeridos.isNotEmpty)
                  _buildSection(
                    'Documentos Requeridos',
                    Icons.description,
                    config.documentosRequeridos,
                  ),

                const SizedBox(height: 20),

                // Condiciones
                _buildSection(
                  'Condiciones de Mantenimiento',
                  Icons.info_outline,
                  [
                    if (config != null)
                      'IAA ≥ ${config.promedioMinimo} puntos'
                    else
                      'IAA ≥ 14.00 puntos',
                    'Cursar mínimo 5 asignaturas por trimestre',
                    'No retirar asignaturas sin autorización',
                    'Observar conducta ética profesional',
                    'Participar en acompañamiento integral',
                  ],
                ),

                const SizedBox(height: 32),

                // Botón postular
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UnifiedApplicationForm(
                            tipoBeca: 'Formación Docente',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Postular a Formación Docente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16, color: AppColors.primary)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
