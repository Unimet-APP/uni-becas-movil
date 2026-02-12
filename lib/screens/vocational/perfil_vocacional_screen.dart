import 'package:flutter/material.dart';

import '../../models/vocational_models.dart';
import '../../services/vocational_service.dart';
import '../../utils/constants.dart';
import 'historial_screen.dart';
import 'resultados_screen.dart';
import 'resultados_ico_screen.dart';

class PerfilVocacionalScreen extends StatefulWidget {
  const PerfilVocacionalScreen({super.key});

  @override
  State<PerfilVocacionalScreen> createState() => _PerfilVocacionalScreenState();
}

class _PerfilVocacionalScreenState extends State<PerfilVocacionalScreen> {
  final VocationalService _service = VocationalService();
  late Future<PerfilVocacional> _futurePerfil;

  @override
  void initState() {
    super.initState();
    _futurePerfil = _service.obtenerPerfilVocacional();
  }

  static const _riasecColors = {
    'R': Color(0xFF4CAF50),
    'I': Color(0xFF2196F3),
    'A': Color(0xFF9C27B0),
    'S': Color(0xFFFF9800),
    'E': Color(0xFFF44336),
    'C': Color(0xFF795548),
  };

  Color _colorFor(String code) =>
      _riasecColors[code.toUpperCase()] ?? AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil Vocacional'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Ver historial',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const HistorialScreen())),
          ),
        ],
      ),
      body: FutureBuilder<PerfilVocacional>(
        future: _futurePerfil,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _ErrorView(
              error: snap.error.toString(),
              onRetry: () =>
                  setState(() => _futurePerfil = _service.obtenerPerfilVocacional()),
            );
          }
          final p = snap.data!;
          if (p.perfilDominante.isEmpty && p.totalTests == 0) {
            return const _EmptyPerfil();
          }
          return _PerfilBody(perfil: p, colorFor: _colorFor);
        },
      ),
    );
  }
}

// ─── Cuerpo del perfil ────────────────────────────────────────────────────────

class _PerfilBody extends StatelessWidget {
  final PerfilVocacional perfil;
  final Color Function(String) colorFor;
  const _PerfilBody({required this.perfil, required this.colorFor});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Orange gradient header card
        _HeaderCard(perfil: perfil),
        const SizedBox(height: 16),

        // Tests realizados stat row
        _StatRow(totalTests: perfil.totalTests),
        const SizedBox(height: 16),

        // Barras RIASEC + tabla de detalle
        if (perfil.dimensiones.isNotEmpty) ...[
          _SectionTitle(
              title: 'Puntuaciones por Dimensión (RIASEC)',
              icon: Icons.trending_up),
          const SizedBox(height: 6),
          const Text(
            'Este gráfico muestra tus puntuaciones en cada dimensión del modelo Holland RIASEC.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          _RiasecBars(dimensiones: perfil.dimensiones, colorFor: colorFor),
          const SizedBox(height: 12),
          _RiasecTable(dimensiones: perfil.dimensiones),
          const SizedBox(height: 16),
        ],

        // Carreras recomendadas
        if (perfil.carrerasRecomendadas.isNotEmpty) ...[
          _SectionTitle(
              title: 'Carreras Recomendadas', icon: Icons.menu_book),
          const SizedBox(height: 10),
          ...perfil.carrerasRecomendadas
              .take(6)
              .map((c) => _CarreraCard(carrera: c)),
          const SizedBox(height: 16),
        ],

        // Perfil vocacional: Fortalezas / Debilidades / Oportunidades
        if (perfil.fortalezas.isNotEmpty ||
            perfil.debilidades.isNotEmpty ||
            perfil.oportunidades.isNotEmpty) ...[
          _SectionTitle(
              title: 'Perfil Vocacional', icon: Icons.gps_fixed),
          const SizedBox(height: 10),

          if (perfil.fortalezas.isNotEmpty) ...[
            _BulletSection(
              title: 'Fortalezas',
              items: perfil.fortalezas,
              color: const Color(0xFF388E3C),
            ),
            const SizedBox(height: 12),
          ],

          if (perfil.debilidades.isNotEmpty) ...[
            _BulletSection(
              title: 'Debilidades',
              items: perfil.debilidades,
              color: const Color(0xFFD32F2F),
            ),
            const SizedBox(height: 12),
          ],

          if (perfil.oportunidades.isNotEmpty) ...[
            _BulletSection(
              title: 'Oportunidades',
              items: perfil.oportunidades,
              color: const Color(0xFF1976D2),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
        ],

        // Botón ver último resultado
        if ((perfil.ultimaSesionId ?? '').isNotEmpty)
          _UltimoResultadoBtn(
            sesionId: perfil.ultimaSesionId!,
            tipoTest: perfil.ultimoTipoTest ?? '',
          ),
        const SizedBox(height: 12),

        // Ver historial button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistorialScreen()),
            ),
            icon: const Icon(Icons.history),
            label: const Text('Ver Historial',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}

// ─── Header card (orange gradient, matches React) ────────────────────────────

class _HeaderCard extends StatelessWidget {
  final PerfilVocacional perfil;
  const _HeaderCard({required this.perfil});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF37021), Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF37021).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.trending_up,
                      color: Colors.white, size: 28),
                  const SizedBox(height: 8),
                  const Text('Tu Perfil Vocacional Consolidado',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  if (perfil.perfilDominante.isNotEmpty)
                    Text(perfil.perfilDominante,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold)),
                  if (perfil.perfilSecundario.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                          'Perfil Secundario: ${perfil.perfilSecundario}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14)),
                    ),
                  if (perfil.codigoHolland.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                          'Código Holland: ${perfil.codigoHolland}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                  if (perfil.nivelConfianza > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                          'Nivel de confianza: ${perfil.nivelConfianza.round()}%',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Total de tests: ${perfil.totalTests}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                if ((perfil.ultimaSesionId ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Builder(
                    builder: (ctx) => OutlinedButton(
                      onPressed: () {
                        final screen = perfil.ultimoTipoTest == 'ICO'
                            ? ResultadosIcoScreen(
                                sesionId: perfil.ultimaSesionId!)
                            : ResultadosScreen(
                                sesionId: perfil.ultimaSesionId!) as Widget;
                        Navigator.push(
                            ctx, MaterialPageRoute(builder: (_) => screen));
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white70),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Ver Último Test',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ]),
    );
  }
}

// ─── Stat row ────────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final int totalTests;
  const _StatRow({required this.totalTests});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(children: [
        const Icon(Icons.check_circle_outline, color: AppColors.success),
        const SizedBox(width: 10),
        Text(
            '$totalTests test${totalTests == 1 ? '' : 's'} realizado${totalTests == 1 ? '' : 's'}',
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ─── RIASEC bars ─────────────────────────────────────────────────────────────

class _RiasecBars extends StatelessWidget {
  final List<RiasecDimension> dimensiones;
  final Color Function(String) colorFor;
  const _RiasecBars({required this.dimensiones, required this.colorFor});

  @override
  Widget build(BuildContext context) {
    final sorted = List<RiasecDimension>.from(dimensiones)
      ..sort((a, b) => b.puntuacion.compareTo(a.puntuacion));
    final max =
        sorted.isEmpty ? 100.0 : sorted.first.puntuacion.clamp(1.0, 100.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: sorted.map((d) {
          final pct = (d.puntuacion / max).clamp(0.0, 1.0);
          const barColor = Color(0xFFF37021); // orange, matching React
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              SizedBox(
                width: 28,
                child: Text(d.codigo,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: barColor,
                        fontSize: 14)),
              ),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.nombre.isNotEmpty ? d.nombre : d.codigo,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 8,
                          backgroundColor: barColor.withValues(alpha: 0.1),
                          valueColor:
                              const AlwaysStoppedAnimation(barColor),
                        ),
                      ),
                    ]),
              ),
              const SizedBox(width: 8),
              Text('${d.puntuacion.round()}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: barColor,
                      fontSize: 13)),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

// ─── RIASEC detail table ─────────────────────────────────────────────────────

class _RiasecTable extends StatelessWidget {
  final List<RiasecDimension> dimensiones;
  const _RiasecTable({required this.dimensiones});

  @override
  Widget build(BuildContext context) {
    final sorted = List<RiasecDimension>.from(dimensiones)
      ..sort((a, b) => b.puntuacion.compareTo(a.puntuacion));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        // Header row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          color: Colors.grey.shade50,
          child: const Row(children: [
            Expanded(
                flex: 3,
                child: Text('Dimensión',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 12))),
            SizedBox(
                width: 60,
                child: Text('Punt.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 12))),
            Expanded(
                flex: 5,
                child: Text('Qué significa',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 12))),
          ]),
        ),
        const Divider(height: 1),
        // Data rows
        ...sorted.asMap().entries.map((entry) {
          final d = entry.value;
          final isEven = entry.key.isEven;
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: isEven ? Colors.white : Colors.grey.shade50,
            child: Row(children: [
              Expanded(
                flex: 3,
                child: Text(
                    d.nombre.isNotEmpty ? d.nombre : d.codigo,
                    style: const TextStyle(fontSize: 13)),
              ),
              SizedBox(
                width: 60,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFF37021)
                              .withValues(alpha: 0.3)),
                    ),
                    child: Text('${d.puntuacion.round()}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFC45A1A))),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  d.descripcion.isNotEmpty
                      ? d.descripcion
                      : _defaultDesc(d.codigo),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ]),
          );
        }),
      ]),
    );
  }

  String _defaultDesc(String code) {
    const descs = {
      'R': 'Preferencia por trabajos manuales, técnicos y al aire libre.',
      'I': 'Interés por la investigación, análisis y resolución de problemas.',
      'A': 'Creatividad, expresión artística y originalidad.',
      'S': 'Orientación a ayudar, enseñar y servir a otros.',
      'E': 'Liderazgo, persuasión y emprendimiento.',
      'C': 'Organización, estructura y trabajo con datos.',
    };
    return descs[code.toUpperCase()] ?? '';
  }
}

// ─── Carreras recomendadas card (React-style with faculty + reason) ──────────

class _CarreraCard extends StatelessWidget {
  final CarreraRecomendada carrera;
  const _CarreraCard({required this.carrera});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(carrera.nombre,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15)),
        if ((carrera.facultad ?? '').isNotEmpty ||
            (carrera.area ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              [
                if ((carrera.facultad ?? '').isNotEmpty) carrera.facultad!,
                if ((carrera.area ?? '').isNotEmpty) carrera.area!,
              ].join(' · '),
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFEA580C),
                  fontWeight: FontWeight.w600),
            ),
          ),
        if ((carrera.razon ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(carrera.razon!,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4)),
          ),
      ]),
    );
  }
}

// ─── Bullet section (Fortalezas / Debilidades / Oportunidades) ───────────────

class _BulletSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;
  const _BulletSection(
      {required this.title, required this.items, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, size: 6, color: color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(item,
                            style: const TextStyle(
                                fontSize: 13, height: 1.4))),
                  ]),
            )),
      ]),
    );
  }
}

// ─── Ver último resultado ────────────────────────────────────────────────────

class _UltimoResultadoBtn extends StatelessWidget {
  final String sesionId;
  final String tipoTest;
  const _UltimoResultadoBtn(
      {required this.sesionId, required this.tipoTest});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          final screen = tipoTest == 'ICO'
              ? ResultadosIcoScreen(sesionId: sesionId)
              : ResultadosScreen(sesionId: sesionId) as Widget;
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => screen));
        },
        icon: const Icon(Icons.bar_chart),
        label: const Text('Ver último resultado'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 20, color: const Color(0xFFF37021)),
      const SizedBox(width: 8),
      Expanded(
        child: Text(title,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    ]);
  }
}

class _EmptyPerfil extends StatelessWidget {
  const _EmptyPerfil();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.insert_chart_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Aún no tienes perfil vocacional',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text(
              'Completa al menos un test para ver tu perfil consolidado.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ir a tests'),
          ),
        ]),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 40),
          const SizedBox(height: 12),
          const Text('Error al cargar perfil',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar')),
        ]),
      ),
    );
  }
}
