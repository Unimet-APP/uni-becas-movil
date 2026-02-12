import 'package:flutter/material.dart';

import '../../models/vocational_models.dart';
import '../../services/vocational_service.dart';
import '../../utils/constants.dart';
import 'resultados_screen.dart';
import 'resultados_ico_screen.dart';
import 'ronda1_screen.dart';
import 'ronda2_screen.dart';
import 'test_ico_screen.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final VocationalService _service = VocationalService();
  late Future<Historial> _futureHistorial;
  String? _continuandoId;

  @override
  void initState() {
    super.initState();
    _futureHistorial = _service.obtenerHistorial();
  }

  Future<void> _continuarTest(SesionProgreso sesion) async {
    setState(() => _continuandoId = sesion.sesionId);
    try {
      if (sesion.tipoTest == 'ICO') {
        final res = await _service.obtenerPreguntasIco(sesion.sesionId);
        if (!mounted) return;
        _goTo(TestIcoScreen(sesionId: sesion.sesionId, preguntas: res.preguntas));
      } else {
        final estado = sesion.estado.toLowerCase();
        if (estado.contains('ronda_1_completada') || estado.contains('ronda_2')) {
          final data = await _service.obtenerSesion(sesion.sesionId);
          final rawData = data['data'] is Map ? data['data'] as Map : data;
          final pregs = VocationalQuestion.listFromJson(rawData['preguntasRonda2']);
          if (!mounted) return;
          if (pregs.isNotEmpty) {
            _goTo(Ronda2Screen(sesionId: sesion.sesionId, preguntas: pregs));
            return;
          }
        }
        _showSnack('No se pudieron cargar las preguntas. Inicia un nuevo test.', error: true);
      }
    } catch (e) {
      _showSnack('Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _continuandoId = null);
    }
  }

  void _goTo(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : AppColors.success,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de tests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {
              _futureHistorial = _service.obtenerHistorial();
            }),
          ),
        ],
      ),
      body: FutureBuilder<Historial>(
        future: _futureHistorial,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _ErrorView(
              error: snap.error.toString(),
              onRetry: () => setState(() {
                _futureHistorial = _service.obtenerHistorial();
              }),
            );
          }
          final h = snap.data!;
          if (h.sesionesEnProgreso.isEmpty && h.sesionesCompletadas.isEmpty) {
            return const _EmptyView();
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (h.sesionesEnProgreso.isNotEmpty) ...[
                _SectionHeader(label: 'En progreso', color: AppColors.warning, icon: Icons.hourglass_empty),
                const SizedBox(height: 8),
                ...h.sesionesEnProgreso.map((s) => _ProgresoCard(
                      sesion: s,
                      continuandoId: _continuandoId,
                      onContinuar: () => _continuarTest(s),
                    )),
                const SizedBox(height: 20),
              ],
              if (h.sesionesCompletadas.isNotEmpty) ...[
                _SectionHeader(label: 'Completados', color: AppColors.success, icon: Icons.check_circle_outline),
                const SizedBox(height: 8),
                ...h.sesionesCompletadas.map((s) => _CompletadoCard(
                      sesion: s,
                      onVerResultados: () => _verResultados(s),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }

  void _verResultados(SesionCompletada s) {
    if (s.tipoTest == 'ICO') {
      _goTo(ResultadosIcoScreen(sesionId: s.sesionId));
    } else {
      _goTo(ResultadosScreen(sesionId: s.sesionId));
    }
  }
}

// ─── Widgets internos ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _SectionHeader({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
    ]);
  }
}

class _ProgresoCard extends StatelessWidget {
  final SesionProgreso sesion;
  final String? continuandoId;
  final VoidCallback onContinuar;
  const _ProgresoCard({required this.sesion, required this.continuandoId, required this.onContinuar});

  @override
  Widget build(BuildContext context) {
    final loading = continuandoId == sesion.sesionId;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_tipoIcon(sesion.tipoTest), color: AppColors.warning, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_tipoLabel(sesion.tipoTest), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text(_dondeQuedo(sesion.estado, sesion.tipoTest),
                  style: TextStyle(fontSize: 12, color: AppColors.warning.withValues(alpha: 0.9))),
              if (sesion.fechaInicio.isNotEmpty)
                Text(_formatFecha(sesion.fechaInicio),
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ]),
          ),
          ElevatedButton(
            onPressed: loading ? null : onContinuar,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: loading
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Continuar', style: TextStyle(fontSize: 12)),
          ),
        ]),
      ),
    );
  }
}

class _CompletadoCard extends StatelessWidget {
  final SesionCompletada sesion;
  final VoidCallback onVerResultados;
  const _CompletadoCard({required this.sesion, required this.onVerResultados});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: onVerResultados,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_tipoIcon(sesion.tipoTest), color: AppColors.success, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(_tipoLabel(sesion.tipoTest), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Completado', style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w600)),
                  ),
                ]),
                if (sesion.perfilDominante.isNotEmpty)
                  Text('Perfil: ${sesion.perfilDominante}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                if (sesion.fechaCompletado.isNotEmpty)
                  Text(_formatFecha(sesion.fechaCompletado),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ]),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.history, size: 56, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        const Text('No tienes tests registrados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('Inicia tu primer test vocacional para ver tu historial aquí.',
            textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
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
          const Text('Error al cargar historial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
        ]),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

IconData _tipoIcon(String tipo) =>
    tipo == 'ICO' ? Icons.psychology : Icons.bar_chart;

String _tipoLabel(String tipo) =>
    tipo == 'ICO' ? 'Test ICO' : 'Test Holland RIASEC';

String _dondeQuedo(String estado, String tipo) {
  if (tipo == 'ICO') return 'ICO en curso';
  final e = estado.toLowerCase();
  if (e.contains('ronda_2') || e.contains('ronda_1_completada')) return 'En Ronda 2';
  return 'En Ronda 1';
}

String _formatFecha(String fecha) {
  try {
    final d = DateTime.parse(fecha).toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  } catch (_) {
    return fecha;
  }
}
