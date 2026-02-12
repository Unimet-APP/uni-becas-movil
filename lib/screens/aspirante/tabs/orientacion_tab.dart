import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/aspirante_provider.dart';
import '../../../utils/constants.dart';
import '../../../services/orientacion_vocacional_service.dart';
import '../../../models/orientacion_vocacional.dart';
import '../../student/vocational/career_list_screen.dart';

class OrientacionTab extends StatefulWidget {
  const OrientacionTab({super.key});

  @override
  State<OrientacionTab> createState() => _OrientacionTabState();
}

class _OrientacionTabState extends State<OrientacionTab> {
  TipoTest? _selectedTest;
  bool _cargandoTest = false;
  final _service = OrientacionVocacionalService();

  Future<void> _iniciarTest() async {
    if (_selectedTest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un tipo de test para continuar'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _cargandoTest = true);

    try {
      if (_selectedTest == TipoTest.ico) {
        final res = await _service.iniciarTestIco();
        final sesionId = res['data']?['sesionId']?.toString() ?? '';
        final preguntas = await _service.obtenerPreguntasIco(sesionId);
        if (!mounted) return;
        // TODO: Navigate to ICO test screen with sesionId and preguntas
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Test ICO iniciado - $sesionId (${preguntas.length} preguntas)'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        final res = await _service.iniciarTest(_selectedTest!);
        final sesionId = res['data']?['sesionId']?.toString() ?? '';
        if (!mounted) return;
        // TODO: Navigate to Holland RIASEC Ronda 1 screen with sesionId
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test Holland RIASEC iniciado - $sesionId'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _cargandoTest = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.explore, color: Colors.white, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'Descubre tu vocacion',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Conecta tus intereses con las carreras de la UNIMET y recibe recomendaciones personalizadas.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Selección de test
          const Text(
            'Selecciona un test',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          _TestOptionCard(
            title: 'Test Holland RIASEC',
            description:
                'Identifica tu perfil vocacional mediante dos rondas de preguntas sobre tus intereses y habilidades.',
            icon: Icons.psychology,
            color: AppColors.primary,
            isSelected: _selectedTest == TipoTest.hollandRiasec,
            onTap: () =>
                setState(() => _selectedTest = TipoTest.hollandRiasec),
          ),
          const SizedBox(height: 12),
          _TestOptionCard(
            title: 'Test ICO',
            description:
                'Evaluacion de intereses y competencias organizacionales en una sola ronda de preguntas Si/No.',
            icon: Icons.assignment,
            color: AppColors.info,
            isSelected: _selectedTest == TipoTest.ico,
            onTap: () => setState(() => _selectedTest = TipoTest.ico),
          ),
          const SizedBox(height: 20),

          // Botón iniciar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _cargandoTest ? null : _iniciarTest,
              icon: _cargandoTest
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.play_circle_fill),
              label: Text(
                  _cargandoTest ? 'Iniciando...' : 'Iniciar diagnostico'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Sesiones en progreso
          Consumer<AspiranteProvider>(
            builder: (context, provider, _) {
              if (provider.sesionesEnProgreso.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 18, color: Color(0xFFF59E0B)),
                      SizedBox(width: 8),
                      Text('Tests en progreso',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...provider.sesionesEnProgreso.map((sesion) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: const Border(
                          left: BorderSide(
                              color: Color(0xFFF59E0B), width: 3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(sesion.displayName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const SizedBox(height: 2),
                                Text('Estado: ${sesion.estado}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Continue test
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              textStyle: const TextStyle(fontSize: 13),
                            ),
                            child: const Text('Continuar'),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),

          // Acceso rápido a carreras
          const Text(
            'Explorar contenido',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _QuickAccessCard(
            title: 'Catalogo de carreras',
            subtitle: 'Mallas, perfiles de egreso y campo laboral',
            icon: Icons.menu_book,
            color: AppColors.info,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const CareerListScreen()),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _TestOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TestOptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? color : AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24)
            else
              Icon(Icons.radio_button_off,
                  color: Colors.grey.shade400, size: 24),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
