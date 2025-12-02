import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/configuracion_beca.dart';
import '../../services/configuracion_service.dart';
import 'unified_application_form.dart';

class ProgramaExcelenciaScreen extends StatefulWidget {
  const ProgramaExcelenciaScreen({super.key});

  @override
  State<ProgramaExcelenciaScreen> createState() => _ProgramaExcelenciaScreenState();
}

class _ProgramaExcelenciaScreenState extends State<ProgramaExcelenciaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ConfiguracionService _configuracionService = ConfiguracionService();

  final List<Map<String, dynamic>> subtipos = [
    {'nombre': 'Académica', 'icono': Icons.school, 'emoji': '🏆'},
    {'nombre': 'Deportiva', 'icono': Icons.sports_soccer, 'emoji': '💪'},
    {'nombre': 'Artística', 'icono': Icons.palette, 'emoji': '🎨'},
    {'nombre': 'Emprendimiento', 'icono': Icons.lightbulb, 'emoji': '💡'},
    {'nombre': 'Compromiso Cívico', 'icono': Icons.favorite, 'emoji': '❤️'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: subtipos.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Programa de Excelencia'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: subtipos
              .map((subtipo) => Tab(text: subtipo['nombre']))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: subtipos.map((subtipo) {
          return _buildTabContent(subtipo['nombre'], subtipo['icono'], subtipo['emoji']);
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(String subtipoNombre, IconData icono, String emoji) {
    return FutureBuilder<ConfiguracionBeca?>(
      future: _configuracionService.getConfiguracion('Excelencia', subtipoNombre),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        final config = snapshot.data;

        if (config == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 60),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Excelencia $subtipoNombre',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Programa de becas por excelencia $subtipoNombre',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UnifiedApplicationForm(
                              tipoBeca: 'Excelencia',
                              subtipoExcelencia: subtipoNombre,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.send),
                      label: Text('Postular a Excelencia $subtipoNombre'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con ícono
              Center(
                child: Column(
                  children: [
                    Text(
                      emoji,
                      style: const TextStyle(fontSize: 60),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Excelencia $subtipoNombre',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      config.requisitosEspeciales ?? 'Para estudiantes destacados',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Requisitos Académicos
              _buildSection(
                'Requisitos Académicos',
                Icons.school,
                [
                  'Semestre: ${config.semestreMinimo} - ${config.semestreMaximo}',
                  'Edad máxima: ${config.edadMaxima} años',
                  'Duración: ${config.duracionMeses} meses',
                  'Promedio mínimo: ${config.promedioMinimo}',
                ],
              ),

              const SizedBox(height: 20),

              // Documentos Requeridos
              _buildSection(
                'Documentos Requeridos',
                Icons.description,
                config.documentosRequeridos,
              ),

              const SizedBox(height: 32),

              // Botón de postulación
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UnifiedApplicationForm(
                          tipoBeca: 'Excelencia',
                          subtipoExcelencia: subtipoNombre,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send),
                  label: Text('Postular a Excelencia $subtipoNombre'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
