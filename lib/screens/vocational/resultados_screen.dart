import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/vocational_models.dart';
import '../../services/vocational_service.dart';
import '../../utils/constants.dart';
import 'historial_screen.dart';
import 'perfil_vocacional_screen.dart';

class ResultadosScreen extends StatefulWidget {
  final String sesionId;
  const ResultadosScreen({super.key, required this.sesionId});

  @override
  State<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  final VocationalService _service = VocationalService();
  late Future<HollandResults> _futureResultados;

  @override
  void initState() {
    super.initState();
    _futureResultados = _fetchWithRetry();
  }

  Future<HollandResults> _fetchWithRetry() async {
    for (var i = 0; i < 5; i++) {
      try {
        return await _service.obtenerResultados(widget.sesionId);
      } catch (_) {
        if (i < 4) await Future.delayed(const Duration(seconds: 3));
      }
    }
    return _service.obtenerResultados(widget.sesionId);
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
      appBar: AppBar(title: const Text('Resultados – Holland RIASEC')),
      body: FutureBuilder<HollandResults>(
        future: _futureResultados,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const _LoadingView();
          }
          if (snap.hasError) {
            return _ErrorView(
              error: snap.error.toString(),
              onRetry: () =>
                  setState(() => _futureResultados = _fetchWithRetry()),
            );
          }
          return _ResultadosBody(r: snap.data!, colorFor: _colorFor);
        },
      ),
    );
  }
}

// ─── Cuerpo de resultados ─────────────────────────────────────────────────────

class _ResultadosBody extends StatelessWidget {
  final HollandResults r;
  final Color Function(String) colorFor;
  const _ResultadosBody({required this.r, required this.colorFor});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Perfil Dominante (orange gradient) — igual que React
          _ProfileCard(r: r),
          const SizedBox(height: 16),

          // 2. Puntuaciones RIASEC
          if (r.dimensiones.isNotEmpty) ...[
            _SectionTitle(title: 'Puntuaciones por Dimensión (RIASEC)', icon: Icons.bar_chart),
            const SizedBox(height: 4),
            const Text(
              'Cada barra representa tu puntuación en una dimensión del modelo Holland.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            _RiasecBars(dimensiones: r.dimensiones, colorFor: colorFor),
            const SizedBox(height: 16),
          ],

          // 3. Carreras recomendadas
          if (r.carrerasRecomendadas.isNotEmpty) ...[
            _SectionTitle(title: 'Carreras Recomendadas', icon: Icons.school_outlined),
            const SizedBox(height: 10),
            ...r.carrerasRecomendadas.map((c) => _CarreraCard(carrera: c)),
            const SizedBox(height: 16),
          ],

          // 4. Perfil Vocacional (Fortalezas, Debilidades, Oportunidades)
          if (r.fortalezas.isNotEmpty ||
              r.debilidades.isNotEmpty ||
              r.oportunidades.isNotEmpty) ...[
            _SectionTitle(title: 'Perfil Vocacional', icon: Icons.track_changes),
            const SizedBox(height: 10),
            if (r.fortalezas.isNotEmpty)
              _LabeledBulletList(
                  label: 'Fortalezas',
                  items: r.fortalezas,
                  color: AppColors.success,
                  icon: Icons.check_circle_outline),
            if (r.debilidades.isNotEmpty) ...[
              const SizedBox(height: 10),
              _LabeledBulletList(
                  label: 'Debilidades',
                  items: r.debilidades,
                  color: AppColors.error,
                  icon: Icons.track_changes),
            ],
            if (r.oportunidades.isNotEmpty) ...[
              const SizedBox(height: 10),
              _LabeledBulletList(
                  label: 'Oportunidades',
                  items: r.oportunidades,
                  color: AppColors.info,
                  icon: Icons.lightbulb_outline),
            ],
            const SizedBox(height: 16),
          ],

          // 5. Áreas de desarrollo
          if (r.areasDesarrollo.isNotEmpty) ...[
            _SectionTitle(title: 'Áreas de Desarrollo', icon: Icons.track_changes),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: r.areasDesarrollo
                  .map((a) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(a,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textPrimary)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          // 6. Sugerencias de Acompañamiento
          if (r.sugerenciasAcompanamiento.isNotEmpty) ...[
            _SectionTitle(title: 'Sugerencias de Acompañamiento', icon: Icons.lightbulb_outline),
            const SizedBox(height: 10),
            ...r.sugerenciasAcompanamiento.asMap().entries.map((e) =>
                _NumberedItem(index: e.key + 1, text: e.value)),
            const SizedBox(height: 16),
          ],

          // 7. Plan de Desarrollo
          if (r.planDesarrollo != null && !r.planDesarrollo!.isEmpty) ...[
            _SectionTitle(title: 'Plan de Desarrollo', icon: Icons.track_changes),
            const SizedBox(height: 10),
            if (r.planDesarrollo!.cortoPlazo.isNotEmpty)
              _PlanSection(
                  label: 'Corto Plazo', items: r.planDesarrollo!.cortoPlazo),
            if (r.planDesarrollo!.medianoPlazo.isNotEmpty) ...[
              const SizedBox(height: 8),
              _PlanSection(
                  label: 'Mediano Plazo',
                  items: r.planDesarrollo!.medianoPlazo),
            ],
            if (r.planDesarrollo!.largoPlazo.isNotEmpty) ...[
              const SizedBox(height: 8),
              _PlanSection(
                  label: 'Largo Plazo', items: r.planDesarrollo!.largoPlazo),
            ],
            const SizedBox(height: 16),
          ],

          // 8. PDU CTA
          const _PduCta(),
          const SizedBox(height: 20),

          // 9. Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PerfilVocacionalScreen())),
                  child: const Text('Ver Mi Perfil Completo'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HistorialScreen())),
                  child: const Text('Ver Historial'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Profile card (orange gradient, like React) ──────────────────────────────

class _ProfileCard extends StatelessWidget {
  final HollandResults r;
  const _ProfileCard({required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF37021), Color(0xFFE65C15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFF37021).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.trending_up, color: Colors.white, size: 28),
          SizedBox(width: 10),
          Text('Tu Perfil Vocacional',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 12),
        Text(
          r.perfilDominante.isNotEmpty ? r.perfilDominante : '–',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900),
        ),
        if (r.perfilSecundario.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text('Perfil Secundario: ${r.perfilSecundario}',
              style: const TextStyle(color: Colors.white70, fontSize: 15)),
        ],
        const SizedBox(height: 10),
        Text(
          'Código Holland: ${r.codigoHolland.isNotEmpty ? r.codigoHolland : 'N/A'}',
          style: const TextStyle(
              color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ]),
    );
  }
}

// ─── RIASEC bars ──────────────────────────────────────────────────────────────

class _RiasecBars extends StatelessWidget {
  final List<RiasecDimension> dimensiones;
  final Color Function(String) colorFor;
  const _RiasecBars({required this.dimensiones, required this.colorFor});

  @override
  Widget build(BuildContext context) {
    final sorted = List<RiasecDimension>.from(dimensiones)
      ..sort((a, b) => b.puntuacion.compareTo(a.puntuacion));
    final maxVal =
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
          final pct = (d.puntuacion / maxVal).clamp(0.0, 1.0);
          final color = colorFor(d.codigo);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              SizedBox(
                width: 28,
                child: Text(d.codigo,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 14)),
              ),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.nombre.isNotEmpty ? d.nombre : d.codigo,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 8,
                          backgroundColor: color.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                    ]),
              ),
              const SizedBox(width: 8),
              Text('${d.puntuacion.round()}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 13)),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Carrera card ─────────────────────────────────────────────────────────────

class _CarreraCard extends StatelessWidget {
  final CarreraRecomendada carrera;
  const _CarreraCard({required this.carrera});

  @override
  Widget build(BuildContext context) {
    final faculty = carrera.facultad ?? '';
    final area = carrera.area ?? '';
    final subtitle =
        [faculty, area].where((s) => s.isNotEmpty).join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(carrera.nombre,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.textPrimary)),
        if (subtitle.isNotEmpty)
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFF37021),
                  fontWeight: FontWeight.w500)),
        if ((carrera.razon ?? '').isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(carrera.razon!,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4)),
        ],
      ]),
    );
  }
}

// ─── PDU CTA (matching React exactly) ─────────────────────────────────────────

class _PduCta extends StatelessWidget {
  const _PduCta();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF37021), Color(0xFFE65C15), Color(0xFFB45309)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFF37021).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Siguiente paso',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
        ),
        const SizedBox(height: 12),
        const Text(
          'Ya tomaste la decisión. ¡Realiza la PDU, te esperamos!',
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.3),
        ),
        const SizedBox(height: 8),
        const Text(
          'Inscríbete a la Prueba Diagnóstica de Ubicación (PDU) de la UNIMET. Evalúa tus habilidades verbales y cuantitativas para el ingreso a la universidad.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 16, runSpacing: 8, children: const [
          _PduDetail(icon: Icons.calendar_today, label: 'Fechas y modalidad'),
          _PduDetail(icon: Icons.attach_money, label: 'Costos y pago'),
          _PduDetail(icon: Icons.description, label: 'Inscripción en línea'),
        ]),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            onPressed: () => launchUrl(
              Uri.parse(
                  'https://www.unimet.edu.ve/pregrado/vias-de-ingreso/pdu/'),
              mode: LaunchMode.externalApplication,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFF37021),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Ir a inscripciones PDU',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }
}

class _PduDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PduDetail({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: Colors.amber.shade200),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ]);
  }
}

// ─── Labeled bullet list (Fortalezas / Debilidades / Oportunidades) ──────────

class _LabeledBulletList extends StatelessWidget {
  final String label;
  final List<String> items;
  final Color color;
  final IconData icon;
  const _LabeledBulletList(
      {required this.label,
      required this.items,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 14)),
        ]),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
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

// ─── Numbered item (sugerencias) ──────────────────────────────────────────────

class _NumberedItem extends StatelessWidget {
  final int index;
  final String text;
  const _NumberedItem({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFF37021),
            shape: BoxShape.circle,
          ),
          child: Text('$index',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style:
                    const TextStyle(fontSize: 13, height: 1.4))),
      ]),
    );
  }
}

// ─── Plan de desarrollo section ───────────────────────────────────────────────

class _PlanSection extends StatelessWidget {
  final String label;
  final List<String> items;
  const _PlanSection({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      const SizedBox(height: 6),
      ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle,
                        size: 6, color: Color(0xFFF37021)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(item,
                          style: const TextStyle(
                              fontSize: 13, height: 1.4))),
                ]),
          )),
    ]);
  }
}

// ─── Utility widgets ──────────────────────────────────────────────────────────

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
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
    ]);
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircularProgressIndicator(color: Color(0xFFF37021)),
        SizedBox(height: 16),
        Text('Generando tus resultados…',
            style: TextStyle(color: AppColors.textSecondary)),
        SizedBox(height: 4),
        Text('Esto puede tomar unos segundos',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ]),
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
          const Text('Error al obtener resultados',
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
