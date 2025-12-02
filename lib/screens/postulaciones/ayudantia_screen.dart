import 'package:flutter/material.dart';
import 'unified_application_form.dart';
import '../../utils/constants.dart';
import '../../services/configuracion_service.dart';
import '../../models/configuracion_beca.dart';

class AyudantiaScreen extends StatefulWidget {
  const AyudantiaScreen({super.key});

  @override
  State<AyudantiaScreen> createState() => _AyudantiaScreenState();
}

class _AyudantiaScreenState extends State<AyudantiaScreen> {
  final ConfiguracionService _configuracionService = ConfiguracionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Programa de Ayudantía'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<ConfiguracionBeca?>(
        future: _configuracionService.getConfiguracion('Ayudantía'),
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
                          Icons.people,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Programa de Ayudantía',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        config?.requisitosEspeciales ??
                        'Facilita el intercambio de valor entre estudiantes y la Universidad',
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
                    if (config != null)
                      'IAA mínimo de ${config.promedioMinimo} puntos'
                    else
                      'IAA mínimo de 12.00 puntos',
                    'Disponer preferiblemente de una plaza de ayudantía activa',
                    'Perfil de competencias acordes con las actividades',
                    'Realizar entrevista de evaluación de competencias',
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
                      'Mantener IAA ≥ ${config.promedioMinimo} puntos'
                    else
                      'Mantener IAA ≥ 12.00 puntos',
                    'Cumplir con 120 horas en trimestres regulares',
                    'Entregar reporte de actividades',
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
                            tipoBeca: 'Ayudantía',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Postular a Ayudantía'),
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
