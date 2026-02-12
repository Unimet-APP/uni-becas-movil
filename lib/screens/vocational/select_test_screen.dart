import 'package:flutter/material.dart';

import '../../models/vocational_models.dart';
import '../../services/vocational_service.dart';
import '../../utils/constants.dart';
import 'ronda1_screen.dart';
import 'ronda2_screen.dart';
import 'test_ico_screen.dart';
import 'resultados_screen.dart';
import 'resultados_ico_screen.dart';
import 'historial_screen.dart';

class SelectTestScreen extends StatefulWidget {
  final bool showAppBar;
  const SelectTestScreen({super.key, this.showAppBar = false});

  @override
  State<SelectTestScreen> createState() => _SelectTestScreenState();
}

class _SelectTestScreenState extends State<SelectTestScreen> {
  final VocationalService _service = VocationalService();

  TipoTest? _tipoSeleccionado;
  bool _cargandoHistorial = true;
  bool _cargando = false;
  String? _continuandoId;

  bool _yaTieneHolland = false;
  bool _yaTieneIco = false;
  String? _sesionIdHolland;
  String? _sesionIdIco;
  SesionProgreso? _hollandEnProgreso;
  SesionProgreso? _icoEnProgreso;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    try {
      final historial = await _service.obtenerHistorial();
      if (!mounted) return;
      setState(() {
        final hollandComp = historial.sesionesCompletadas
            .where((s) => s.tipoTest.contains('Holland'))
            .firstOrNull;
        final icoComp = historial.sesionesCompletadas
            .where((s) => s.tipoTest == 'ICO')
            .firstOrNull;

        _yaTieneHolland = hollandComp != null;
        _yaTieneIco = icoComp != null;
        _sesionIdHolland = hollandComp?.sesionId;
        _sesionIdIco = icoComp?.sesionId;

        _hollandEnProgreso = historial.sesionesEnProgreso
            .where((s) => s.tipoTest.contains('Holland'))
            .firstOrNull;
        _icoEnProgreso = historial.sesionesEnProgreso
            .where((s) => s.tipoTest == 'ICO')
            .firstOrNull;

        _cargandoHistorial = false;
      });
    } catch (_) {
      if (mounted) setState(() => _cargandoHistorial = false);
    }
  }

  // Continuar test en progreso
  Future<void> _continuarTest(SesionProgreso sesion) async {
    setState(() => _continuandoId = sesion.sesionId);
    try {
      if (sesion.tipoTest == 'ICO') {
        final res = await _service.obtenerPreguntasIco(sesion.sesionId);
        if (!mounted) return;
        _goTo(TestIcoScreen(sesionId: sesion.sesionId, preguntas: res.preguntas));
      } else {
        // Holland
        final estado = sesion.estado.toLowerCase();
        if (estado.contains('ronda_1_completada') || estado.contains('ronda_2')) {
          final data = await _service.obtenerSesion(sesion.sesionId);
          final pregsData = data['data'] is Map
              ? (data['data'] as Map)['preguntasRonda2']
              : data['preguntasRonda2'];
          final pregs = VocationalQuestion.listFromJson(pregsData);
          if (!mounted) return;
          if (pregs.isNotEmpty) {
            _goTo(Ronda2Screen(sesionId: sesion.sesionId, preguntas: pregs));
            return;
          }
        }
        // Default: ronda 1 — necesita preguntas del inicio
        _showError('No se encontraron preguntas. Inicia un nuevo test.');
      }
    } catch (e) {
      _showError('Error al cargar el test: $e');
    } finally {
      if (mounted) setState(() => _continuandoId = null);
    }
  }

  // Iniciar test nuevo
  Future<void> _iniciarTest() async {
    if (_tipoSeleccionado == null) return;
    setState(() => _cargando = true);
    try {
      if (_tipoSeleccionado == TipoTest.ico) {
        final res = await _service.iniciarTestIco();
        final pregsRes = await _service.obtenerPreguntasIco(res.sesionId);
        if (!mounted) return;
        _goTo(TestIcoScreen(sesionId: res.sesionId, preguntas: pregsRes.preguntas));
      } else {
        final res = await _service.iniciarTestHolland();
        if (!mounted) return;
        _goTo(Ronda1Screen(sesionId: res.sesionId, preguntas: res.preguntas));
      }
    } catch (e) {
      _showError('Error al iniciar test: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _goTo(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  bool get _puedeIniciar {
    if (_tipoSeleccionado == null || _cargando) return false;
    if (_tipoSeleccionado == TipoTest.hollandRiasec &&
        (_yaTieneHolland || _hollandEnProgreso != null)) return false;
    if (_tipoSeleccionado == TipoTest.ico &&
        (_yaTieneIco || _icoEnProgreso != null)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: const Text('Tests vocacionales'))
          : null,
      body: Column(
        children: [
          Expanded(
            child: _cargandoHistorial
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildTestCard(
                          tipo: TipoTest.hollandRiasec,
                          titulo: 'Test Holland RIASEC',
                          descripcion:
                              'Evalúa tus intereses en 6 dimensiones: Realista, Investigador, Artístico, Social, Emprendedor y Convencional.',
                          detalles: const ['Dos rondas de preguntas', 'Código Holland y carreras recomendadas'],
                          icon: Icons.bar_chart,
                          completado: _yaTieneHolland,
                          enProgreso: _hollandEnProgreso,
                          sesionIdComp: _sesionIdHolland,
                          onVerResultados: _sesionIdHolland != null
                              ? () => _goTo(ResultadosScreen(sesionId: _sesionIdHolland!))
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTestCard(
                          tipo: TipoTest.ico,
                          titulo: 'Test ICO',
                          descripcion:
                              'Versión corta con preguntas Sí/No. Incluye análisis con inteligencia artificial.',
                          detalles: const ['Una sola ronda, más rápido', 'Perfil RIASEC y análisis con IA'],
                          icon: Icons.psychology,
                          completado: _yaTieneIco,
                          enProgreso: _icoEnProgreso,
                          sesionIdComp: _sesionIdIco,
                          onVerResultados: _sesionIdIco != null
                              ? () => _goTo(ResultadosIcoScreen(sesionId: _sesionIdIco!))
                              : null,
                        ),
                        const SizedBox(height: 12),
                        // Ver historial
                        TextButton.icon(
                          onPressed: () => _goTo(const HistorialScreen()),
                          icon: const Icon(Icons.history),
                          label: const Text('Ver historial completo'),
                        ),
                        const SizedBox(height: 80), // espacio para el botón flotante
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.explore, color: AppColors.primary, size: 32),
        const SizedBox(height: 8),
        Text(
          'Tests de Orientación Vocacional',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Elige un test para descubrir tu perfil vocacional y las carreras que mejor se alinean contigo.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        if (_cargandoHistorial)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 8),
                Text('Verificando historial...', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTestCard({
    required TipoTest tipo,
    required String titulo,
    required String descripcion,
    required List<String> detalles,
    required IconData icon,
    required bool completado,
    required SesionProgreso? enProgreso,
    required String? sesionIdComp,
    VoidCallback? onVerResultados,
  }) {
    final selected = _tipoSeleccionado == tipo && !completado && enProgreso == null;
    final disabled = completado;

    Color borderColor;
    Color bgColor;
    if (completado) {
      borderColor = Colors.grey.shade300;
      bgColor = Colors.grey.shade50;
    } else if (enProgreso != null) {
      borderColor = Colors.amber.shade300;
      bgColor = Colors.amber.shade50;
    } else if (selected) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primary.withValues(alpha: 0.05);
    } else {
      borderColor = Colors.grey.shade200;
      bgColor = Colors.white;
    }

    return GestureDetector(
      onTap: disabled || enProgreso != null
          ? null
          : () => setState(() => _tipoSeleccionado = tipo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
          boxShadow: selected
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: completado
                        ? Colors.grey.shade200
                        : enProgreso != null
                            ? Colors.amber.shade100
                            : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: completado
                        ? Colors.grey
                        : enProgreso != null
                            ? Colors.amber.shade800
                            : AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                      if (completado)
                        _Badge(label: 'Completado', color: AppColors.success)
                      else if (enProgreso != null)
                        _Badge(label: 'En progreso', color: AppColors.warning),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
              ],
            ),
            const SizedBox(height: 10),
            if (enProgreso != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'Quedaste en: ${_dondeQuedo(enProgreso.estado, enProgreso.tipoTest)}',
                  style: TextStyle(color: Colors.amber.shade800, fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ),
            Text(descripcion, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 10),
            ...detalles.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                const Icon(Icons.check, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(d, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ]),
            )),
            // Botones de acción
            if (completado && onVerResultados != null) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onVerResultados,
                icon: const Icon(Icons.bar_chart, size: 16),
                label: const Text('Ver mis resultados'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ],
            if (enProgreso != null) ...[
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _continuandoId == enProgreso.sesionId
                    ? null
                    : () => _continuarTest(enProgreso),
                icon: _continuandoId == enProgreso.sesionId
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.play_arrow, size: 16),
                label: Text(_continuandoId == enProgreso.sesionId ? 'Cargando...' : 'Continuar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    String buttonText;
    if (_tipoSeleccionado == null) {
      buttonText = 'Selecciona un test arriba';
    } else if ((_tipoSeleccionado == TipoTest.hollandRiasec && _yaTieneHolland) ||
        (_tipoSeleccionado == TipoTest.ico && _yaTieneIco)) {
      buttonText = 'Test ya completado';
    } else if ((_tipoSeleccionado == TipoTest.hollandRiasec && _hollandEnProgreso != null) ||
        (_tipoSeleccionado == TipoTest.ico && _icoEnProgreso != null)) {
      buttonText = 'Usa "Continuar" en la tarjeta';
    } else {
      buttonText = 'Comenzar test';
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, -4))],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _puedeIniciar ? _iniciarTest : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _cargando
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(
                    buttonText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _puedeIniciar ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String _dondeQuedo(String estado, String tipo) {
    if (tipo == 'ICO') return 'Test ICO en curso';
    final e = estado.toLowerCase();
    if (e.contains('ronda_2') || e.contains('ronda_1_completada')) return 'Ronda 2';
    return 'Ronda 1';
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
