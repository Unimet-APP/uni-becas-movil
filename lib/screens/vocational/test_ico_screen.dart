import 'package:flutter/material.dart';

import '../../models/vocational_models.dart';
import '../../services/vocational_service.dart';
import '../../utils/constants.dart';
import 'resultados_ico_screen.dart';
import 'historial_screen.dart';
import 'test_widgets.dart';

class TestIcoScreen extends StatefulWidget {
  final String sesionId;
  final List<VocationalQuestion> preguntas;
  const TestIcoScreen({super.key, required this.sesionId, required this.preguntas});

  @override
  State<TestIcoScreen> createState() => _TestIcoScreenState();
}

class _TestIcoScreenState extends State<TestIcoScreen> {
  final VocationalService _service = VocationalService();
  int _current = 0;
  final Map<String, bool> _respuestas = {};
  bool? _seleccionada;
  bool _enviando = false;

  VocationalQuestion get _pregunta => widget.preguntas[_current];
  double get _progreso =>
      widget.preguntas.isEmpty ? 0 : (_current + 1) / widget.preguntas.length;

  void _onSel(bool valor) => setState(() => _seleccionada = valor);

  void _avanzar() {
    if (_seleccionada == null) return;
    _respuestas[_pregunta.id] = _seleccionada!;
    if (_current < widget.preguntas.length - 1) {
      setState(() {
        _current++;
        _seleccionada = _respuestas[widget.preguntas[_current].id];
      });
    } else {
      _enviar();
    }
  }

  void _anterior() {
    if (_current > 0) {
      setState(() {
        _current--;
        _seleccionada = _respuestas[widget.preguntas[_current].id];
      });
    }
  }

  Future<void> _enviar() async {
    setState(() => _enviando = true);
    try {
      final lista = _respuestas.entries
          .map((e) => VocationalAnswer(preguntaId: e.key, respuesta: e.value))
          .toList();
      await _service.guardarRespuestasIco(widget.sesionId, lista);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ResultadosIcoScreen(sesionId: widget.sesionId),
      ));
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
        appBar: AppBar(title: const Text('Test ICO')),
        body: const Center(child: Text('No hay preguntas disponibles.')),
      );
    }

    final esUltima = _current == widget.preguntas.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test ICO'),
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
              // Badge ICO
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('TEST ICO',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C3AED),
                        letterSpacing: 1)),
              ),
              const SizedBox(height: 16),
              Text(_pregunta.texto,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3)),
              const SizedBox(height: 32),
              // Solo Sí / No
              SiNoButton(
                  label: 'Sí',
                  value: true,
                  selected: _seleccionada == true,
                  color: AppColors.success,
                  onTap: () => _onSel(true)),
              const SizedBox(height: 14),
              SiNoButton(
                  label: 'No',
                  value: false,
                  selected: _seleccionada == false,
                  color: AppColors.error,
                  onTap: () => _onSel(false)),
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
