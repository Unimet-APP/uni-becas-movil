import 'package:flutter/material.dart';
import 'career_list_screen.dart'; // cuando la tengas
// Importarás luego otras screens: test, perfil, etc.

class VocationalHomeScreen extends StatelessWidget {
  const VocationalHomeScreen({super.key});

  void _goTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orientación vocacional'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO (equivalente al encabezado grande de la web)
            Text(
              'Sistema de orientación inteligente',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Conecta tus intereses con las carreras de la UNIMET y recibe recomendaciones personalizadas.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: navegar a la pantalla del test vocacional
                  // _goTo(context, const VocationalTestScreen());
                },
                icon: const Icon(Icons.play_circle_fill),
                label: const Text('Iniciar diagnóstico'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Módulos del sistema',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Arquitectura modular para acompañarte en cada etapa de tu decisión profesional.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // GRID DE MÓDULOS (versión móvil: cards en columna)
            _ModuleCard(
              title: 'Asesoría Vocacional IA',
              subtitle:
                  'Tests estandarizados interpretados por un motor LLM para recomendaciones personalizadas.',
              chip: 'Módulo 1 & 5',
              icon: Icons.psychology,
              color: Colors.deepPurple,
              onTap: () {
                // TODO: ir a pantalla de test vocacional
                // _goTo(context, const VocationalTestScreen());
              },
            ),
            const SizedBox(height: 12),
            _ModuleCard(
              title: 'Mi perfil y trayectoria',
              subtitle:
                  'Historial de tests, preferencias e información que alimenta al modelo de IA.',
              chip: 'Módulo 2',
              icon: Icons.person,
              color: Colors.teal,
              onTap: () {
                // TODO: ir a pantalla de perfil vocacional
                // _goTo(context, const VocationalProfileScreen());
              },
            ),
            const SizedBox(height: 12),
            _ModuleCard(
              title: 'Contenido académico',
              subtitle:
                  'Catálogo de carreras, mallas y perfiles de egreso de la UNIMET.',
              chip: 'Módulo 3',
              icon: Icons.menu_book,
              color: Colors.blue,
              onTap: () {
                _goTo(context, const CareerListScreen());
              },
            ),
            const SizedBox(height: 12),
            _ModuleCard(
              title: 'Novedades y CRM',
              subtitle:
                  'Notificaciones inteligentes y seguimiento basado en tus intereses.',
              chip: 'Módulo 4',
              icon: Icons.notifications_active,
              color: Colors.pink,
              onTap: () {
                // TODO: ir a pantalla de CRM vocacional
              },
            ),
            const SizedBox(height: 12),
            _ModuleCard(
              title: 'Monitoreo y Analytics',
              subtitle:
                  'Vista administrativa para ver métricas y tendencias vocacionales.',
              chip: 'Módulo 6',
              icon: Icons.bar_chart,
              color: Colors.black87,
              textOnDark: true,
              onTap: () {
                // TODO: ir a pantalla de analytics (probablemente solo para admin/orientador)
              },
            ),
            const SizedBox(height: 12),
            _ModuleCard(
              title: 'Panel del orientador',
              subtitle:
                  'Gestión de casos y seguimiento individualizado de estudiantes.',
              chip: 'Dirección de Bienestar',
              icon: Icons.group,
              color: Colors.teal.shade900,
              textOnDark: true,
              onTap: () {
                // TODO: ir a pantalla de counselor/orientador
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String chip;
  final IconData icon;
  final Color color;
  final bool textOnDark;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.chip,
    required this.icon,
    required this.color,
    this.textOnDark = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = textOnDark ? color : Colors.white;
    final fgTitle = textOnDark ? Colors.white : Colors.black87;
    final fgSubtitle = textOnDark ? Colors.white70 : Colors.black54;
    final chipColor = textOnDark ? Colors.white24 : color.withOpacity(0.1);
    final chipTextColor = textOnDark ? Colors.white70 : color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: textOnDark ? Colors.black54 : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: textOnDark ? Colors.white10 : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(
                icon,
                color: textOnDark ? Colors.white : color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      chip,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: chipTextColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: fgTitle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: fgSubtitle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: textOnDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
