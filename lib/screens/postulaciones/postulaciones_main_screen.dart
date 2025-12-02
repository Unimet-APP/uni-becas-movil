import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/animations.dart';
import 'programa_excelencia_screen.dart';
import 'formacion_docente_screen.dart';
import 'ayudantia_screen.dart';
import 'beca_info_screen.dart';

class PostulacionesMainScreen extends StatelessWidget {
  const PostulacionesMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Postulaciones'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Diseño de fondo moderno con líneas naranjas finitas
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
            painter: ModernLinesPainter(),
          ),

          // Contenido
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Desplegable de Información de Becas
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 24,
                      ),
                    ),
                    title: const Text(
                      'Información de Becas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: const Text(
                      'Toca para ver información',
                      style: TextStyle(fontSize: 12),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          children: [
                            _buildBecaInfoCard(context, 'Ayudantía', Icons.people),
                            const SizedBox(height: 10),
                            _buildBecaInfoCard(context, 'Impacto', Icons.trending_up),
                            const SizedBox(height: 10),
                            _buildBecaInfoCard(context, 'Excelencia', Icons.emoji_events),
                            const SizedBox(height: 10),
                            _buildBecaInfoCard(context, 'Exoneración de Pago de Matrícula para Estudios del Personal e Hijos', Icons.payment),
                            const SizedBox(height: 10),
                            _buildBecaInfoCard(context, 'Formación Docente', Icons.menu_book),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Header de Postulaciones
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.school,
                          size: 50,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'POSTULACIONES A BECAS',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Explora y postúlate a los diferentes programas de becas disponibles',
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

                // Cards de becas
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildBecaCard(
                        context,
                        title: 'Programa de Excelencia',
                        icon: Icons.emoji_events,
                        description: 'Becas por excelencia académica, deportiva, artística y más',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProgramaExcelenciaScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildBecaCard(
                        context,
                        title: 'Beca de Formación Docente',
                        icon: Icons.menu_book,
                        description: 'Apoyo para estudiantes en formación docente',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FormacionDocenteScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildBecaCard(
                        context,
                        title: 'Programa de Ayudantía',
                        icon: Icons.people,
                        description: 'Oportunidades de ayudantías en diferentes áreas',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AyudantiaScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBecaCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBecaInfoCard(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          ScaleFadePageRoute(
            page: BecaInfoScreen(tipoBeca: title),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModernLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.12)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Líneas diagonales en la parte superior derecha
    for (int i = 0; i < 5; i++) {
      final path = Path();
      path.moveTo(size.width * 0.6 + (i * 40), 0);
      path.lineTo(size.width + (i * 40), size.height * 0.3);
      canvas.drawPath(path, paint);
    }

    // Líneas horizontales sutiles en el medio
    for (int i = 0; i < 3; i++) {
      final y = size.height * 0.4 + (i * 60);
      final path = Path();
      path.moveTo(0, y);
      path.lineTo(size.width * 0.3, y);
      canvas.drawPath(path, paint);
    }

    // Líneas diagonales en la parte inferior izquierda
    for (int i = 0; i < 4; i++) {
      final path = Path();
      path.moveTo(0 - (i * 50), size.height * 0.7);
      path.lineTo(size.width * 0.4 - (i * 50), size.height);
      canvas.drawPath(path, paint);
    }

    // Líneas verticales sutiles a la derecha
    for (int i = 0; i < 2; i++) {
      final x = size.width * 0.85 + (i * 30);
      final path = Path();
      path.moveTo(x, size.height * 0.5);
      path.lineTo(x, size.height * 0.8);
      canvas.drawPath(path, paint);
    }

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
