import 'package:flutter/material.dart';

import '../../models/vocational_models.dart';
import '../../services/vocational_service.dart';
import '../../utils/constants.dart';
import 'resultados_screen.dart';
import 'historial_screen.dart';
import 'test_widgets.dart';

class Ronda2Screen extends StatefulWidget {
  final String sesionId;
  final List<VocationalQuestion> preguntas;
  const Ronda2Screen({super.key, required this.sesionId, required this.preguntas});

  @override
  State<Ronda2Screen> createState() => _Ronda2ScreenState();
}

class _Ronda2ScreenState extends State<Ronda2Screen> {
  final VocationalService _service = VocationalService();
  int _current = 0;
  final Map<String, VocationalAnswer> _respuestas = {};
  dynamic _seleccionada;
  DateTime _inicioPregunta = DateTime.now();
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _inicioPregunta = DateTime.now();
  }

  VocationalQuestion get _pregunta => widget.preguntas[_current];
  double get _progreso =>
      widget.preguntas.isEmpty ? 0 : (_current + 1) / widget.preguntas.length;

  void _onSel(dynamic v) => setState(() => _seleccionada = v);

  void _avanzar() {
    if (_seleccionada == null) return;
    final seg = DateTime.now().difference(_inicioPregunta).inSeconds;
    _respuestas[_pregunta.id] = VocationalAnswer(
      preguntaId: _pregunta.id,
      respuesta: _seleccionada,
      tiempoRespuesta: seg,
      nivelSeguridad: seg < 10 ? 'seguro' : 'no_seguro',
    );
    if (_current < widget.preguntas.length - 1) {
      setState(() {
        _current++;
        _seleccionada = _respuestas[widget.preguntas[_current].id]?.respuesta;
        _inicioPregunta = DateTime.now();
      });
    } else {
      _enviar();
    }
  }

  void _anterior() {
    if (_current > 0) {
      setState(() {
        _current--;
        _seleccionada = _respuestas[widget.preguntas[_current].id]?.respuesta;
        _inicioPregunta = DateTime.now();
      });
    }
  }

  Future<void> _enviar() async {
    setState(() => _enviando = true);
    try {
      final res = await _service.guardarRespuestasRonda2(
          widget.sesionId, _respuestas.values.toList());
      if (!mounted) return;
      final sesionId =
          (res['data'] is Map ? (res['data'] as Map)['sesionId'] : null)
                  ?.toString() ??
              widget.sesionId;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ResultadosScreen(sesionId: sesionId)),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.preguntas.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ronda 2')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No hay preguntas para Ronda 2.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HistorialScreen())),
                child: const Text('Ver historial'),
              ),
            ],
          ),
        ),
      );
    }

    final esUltima = _current == widget.preguntas.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ronda 2 – Holland RIASEC'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Salir y continuar después',
          onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HistorialScreen())),
        ),
      ),
      body: Column(children: [
        TestProgressBar(
            progreso: _progreso, actual: _current + 1, total: widget.preguntas.length),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              RondaLabel(label: 'RONDA 2 – ADAPTATIVA', color: Colors.indigo),
              const SizedBox(height: 12),
              Text(_pregunta.texto,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3)),
              const SizedBox(height: 24),
              if (_pregunta.opcionesRespuesta.isNotEmpty)
                ..._pregunta.opcionesRespuesta.map((o) => OpcionRadio(
                      opcion: o,
                      selected: _seleccionada == o,
                      accentColor: Colors.indigo,
                      onTap: () => _onSel(o),
                    ))
              else ...[
                SiNoButton(
                    label: 'Sí',
                    value: true,
                    selected: _seleccionada == true,
                    color: AppColors.success,
                    onTap: () => _onSel(true)),
                const SizedBox(height: 12),
                SiNoButton(
                    label: 'No',
                    value: false,
                    selected: _seleccionada == false,
                    color: AppColors.error,
                    onTap: () => _onSel(false)),
              ],
            ]),
          ),
        ),
        TestNavBar(
          onAnterior: _current > 0 ? _anterior : null,
          onSiguiente: _seleccionada != null ? _avanzar : null,
          esUltima: esUltima,
          enviando: _enviando,
          labelFinalizar: 'Finalizar y ver resultados',
        ),
      ]),
    );
  }
}
