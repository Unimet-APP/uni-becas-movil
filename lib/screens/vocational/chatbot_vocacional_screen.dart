import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../services/vocational_service.dart';
import '../../utils/constants.dart';

// ─── Chatbot Vocacional (3 tabs: Chat · Consulta · Recomendaciones) ───────────

class ChatbotVocacionalScreen extends StatelessWidget {
  const ChatbotVocacionalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chatbot Vocacional'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Chat'),
              Tab(icon: Icon(Icons.help_outline), text: 'Consulta'),
              Tab(icon: Icon(Icons.lightbulb_outline), text: 'Recomendaciones'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ChatTab(),
            _ConsultaTab(),
            _RecomendacionesTab(),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 1: Chat conversacional ───────────────────────────────────────────────

class _ChatMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime timestamp;

  _ChatMessage({required this.role, required this.content})
      : timestamp = DateTime.now();
}

class _ChatTab extends StatefulWidget {
  const _ChatTab();

  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  final VocationalService _service = VocationalService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<_ChatMessage> _mensajes = [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _loading) return;

    setState(() {
      _mensajes.add(_ChatMessage(role: 'user', content: texto));
      _error = null;
      _loading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final historial = _mensajes
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();
      final respuesta = await _service.chatLLM(historial);
      if (mounted) {
        setState(() {
          _mensajes.add(_ChatMessage(role: 'assistant', content: respuesta));
          _loading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Messages area
        Expanded(
          child: _mensajes.isEmpty
              ? _ChatEmptyState()
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: _mensajes.length + (_loading ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    if (i == _mensajes.length) {
                      return _TypingIndicator();
                    }
                    return _ChatBubble(msg: _mensajes[i]);
                  },
                ),
        ),

        if (_error != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_error!,
                style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ),

        // Input area
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                enabled: !_loading,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText: 'Escribe tu pregunta…',
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onSubmitted: (_loading) ? null : (_) => _enviar(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _loading ? null : _enviar,
              icon: const Icon(Icons.send),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

class _ChatEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.smart_toy_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Chat de Orientación Vocacional',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Haz preguntas sobre carreras,\norientación vocacional y más.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ...const [
            '¿Qué carrera me recomiendas si me gusta la tecnología?',
            '¿Cuál es la diferencia entre Ingeniería y Sistemas?',
            '¿Qué habilidades necesito para estudiar Derecho?',
          ].map((q) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Text(q,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12)),
              )),
          ]),
        ),
      ),
    ),
  ),
);
  }
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage msg;
  const _ChatBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == 'user';
    final time =
        '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Icon(Icons.smart_toy_outlined,
                  size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.primary
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                  child: Text(time,
                      style: TextStyle(
                          fontSize: 10, color: Colors.grey.shade500)),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Icon(Icons.person, size: 16, color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child:
              Icon(Icons.smart_toy_outlined, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text('Pensando…',
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 13)),
          ]),
        ),
      ]),
    );
  }
}

// ─── Tab 2: Consulta puntual ──────────────────────────────────────────────────

class _ConsultaTab extends StatefulWidget {
  const _ConsultaTab();

  @override
  State<_ConsultaTab> createState() => _ConsultaTabState();
}

class _ConsultaTabState extends State<_ConsultaTab> {
  final VocationalService _service = VocationalService();
  final TextEditingController _controller = TextEditingController();
  String? _respuesta;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _consultar() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty || _loading) return;
    setState(() { _loading = true; _error = null; _respuesta = null; });
    try {
      final resp = await _service.consultaLLM(prompt);
      if (mounted) setState(() { _respuesta = resp; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
          ),
          child: Row(children: [
            Icon(Icons.smart_toy_outlined, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Consulta de Orientación Vocacional',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // Input
        const Text('¿En qué te puedo ayudar?',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          maxLines: 4,
          enabled: !_loading,
          decoration: InputDecoration(
            hintText:
                'Ej: ¿Qué carrera me recomiendas si me gusta la tecnología y las matemáticas?',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _loading ? null : _consultar,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send),
            label: Text(_loading ? 'Procesando…' : 'Enviar consulta'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),

        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_error!,
                style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ),
        ],

        if (_respuesta != null && _respuesta!.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Respuesta:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(_respuesta!,
                style: const TextStyle(fontSize: 14, height: 1.5)),
          ),
        ],
      ]),
    );
  }
}

// ─── Tab 3: Recomendaciones IA ────────────────────────────────────────────────

class _RecomendacionesTab extends StatefulWidget {
  const _RecomendacionesTab();

  @override
  State<_RecomendacionesTab> createState() => _RecomendacionesTabState();
}

class _RecomendacionesTabState extends State<_RecomendacionesTab> {
  final VocationalService _service = VocationalService();
  final ApiClient _api = ApiClient();
  Map<String, dynamic>? _resultado;
  bool _loading = false;
  String? _error;

  Future<void> _generar() async {
    setState(() { _loading = true; _error = null; _resultado = null; });
    try {
      // 1. perfilEstudiante desde el perfil vocacional real del usuario
      //    Esquema backend: { intereses?, habilidades?, resultadosTest?, preferencias? }
      Map<String, dynamic> perfilEstudiante = {};
      try {
        final p = await _service.obtenerPerfilVocacional();
        perfilEstudiante = {
          if (p.fortalezas.isNotEmpty) 'intereses': p.fortalezas,
          if (p.oportunidades.isNotEmpty) 'habilidades': p.oportunidades,
          'resultadosTest': {
            'codigoHolland': p.codigoHolland,
            'perfilDominante': p.perfilDominante,
            'nivelConfianza': p.nivelConfianza,
            'dimensiones': p.dimensiones
                .map((d) => {'codigo': d.codigo, 'puntuacion': d.puntuacion})
                .toList(),
          },
        };
      } catch (_) {}

      // 2. carrerasDisponibles desde el catálogo real — [{ nombre, descripcion? }]
      //    Igual que React: carrerasDisponibles = lista de carreras de la UNIMET
      List<Map<String, String>> carrerasDisponibles = [];
      try {
        final resp = await _api.dio.get('/careers', queryParameters: {'limit': 200});
        final raw = resp.data is Map && resp.data['data'] is List
            ? resp.data['data'] as List
            : resp.data is List
                ? resp.data as List
                : [];
        carrerasDisponibles = raw.map((c) {
          final m = c as Map;
          return <String, String>{
            'nombre': (m['name'] ?? m['nombre'] ?? '').toString(),
            if ((m['description'] ?? '').toString().isNotEmpty)
              'descripcion': m['description'].toString(),
          };
        }).where((c) => c['nombre']!.isNotEmpty).toList();
      } catch (_) {}

      final resultado = await _service.generarRecomendaciones(
        perfilEstudiante: perfilEstudiante,
        carrerasDisponibles: carrerasDisponibles,
      );
      if (mounted) setState(() { _resultado = resultado; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.08),
                Colors.purple.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
          ),
          child: Row(children: [
            Icon(Icons.auto_awesome, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recomendaciones con IA',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 2),
                  Text(
                    'Basadas en tu perfil vocacional y tests completados',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // Generate button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _loading ? null : _generar,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.auto_awesome),
            label: Text(_loading
                ? 'Generando recomendaciones…'
                : 'Generar Recomendaciones'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),

        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_error!,
                style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ),
        ],

        if (_resultado != null) ...[
          const SizedBox(height: 20),
          _RecomendacionesResultado(resultado: _resultado!),
        ],
      ]),
    );
  }
}

class _RecomendacionesResultado extends StatelessWidget {
  final Map<String, dynamic> resultado;
  const _RecomendacionesResultado({required this.resultado});

  @override
  Widget build(BuildContext context) {
    final analisis = resultado['analisis']?.toString();
    final respuesta = resultado['respuesta']?.toString();
    final sugerencias = resultado['sugerencias'] is List
        ? (resultado['sugerencias'] as List).cast<String>()
        : <String>[];
    final carrerasRaw = resultado['carrerasRecomendadas'] is List
        ? List<dynamic>.from(resultado['carrerasRecomendadas'] as List)
        : <dynamic>[];
    carrerasRaw.sort((a, b) {
      final pa = (a is Map ? (a['puntuacion'] ?? 0) : 0);
      final pb = (b is Map ? (b['puntuacion'] ?? 0) : 0);
      final na = pa is num ? pa : num.tryParse(pa.toString()) ?? 0;
      final nb = pb is num ? pb : num.tryParse(pb.toString()) ?? 0;
      return nb.compareTo(na); // descending
    });
    final carreras = carrerasRaw;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Análisis de perfil
      if (analisis != null && analisis.isNotEmpty) ...[
        _SectionCard(
          icon: Icons.person_search,
          title: 'Análisis de tu Perfil',
          child: Text(analisis,
              style: const TextStyle(fontSize: 14, height: 1.5)),
        ),
        const SizedBox(height: 12),
      ],

      // Respuesta simple (sin estructura)
      if (respuesta != null &&
          respuesta.isNotEmpty &&
          carreras.isEmpty) ...[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(respuesta,
              style: const TextStyle(fontSize: 14, height: 1.5)),
        ),
        const SizedBox(height: 12),
      ],

      // Carreras recomendadas (estructuradas)
      if (carreras.isNotEmpty) ...[
        _SectionCard(
          icon: Icons.menu_book,
          title: 'Carreras Recomendadas',
          child: Column(
            children: carreras.map((c) {
              final m = c is Map ? c : {};
              final nombre = m['carrera']?.toString() ?? '';
              final match = m['match']?.toString() ?? '';
              final pct = m['puntuacion'];
              final razones = m['razones'] is List
                  ? (m['razones'] as List).cast<String>()
                  : <String>[];
              return _CarreraRecomCard(
                  nombre: nombre,
                  match: match,
                  puntuacion: pct,
                  razones: razones);
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
      ],

      // Sugerencias
      if (sugerencias.isNotEmpty)
        _SectionCard(
          icon: Icons.lightbulb_outline,
          title: 'Sugerencias',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sugerencias
                .map((s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Icon(Icons.circle,
                                  size: 6, color: AppColors.primary),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(s,
                                    style: const TextStyle(
                                        fontSize: 13, height: 1.4))),
                          ]),
                    ))
                .toList(),
          ),
        ),
    ]);
  }
}

class _CarreraRecomCard extends StatelessWidget {
  final String nombre;
  final String match;
  final dynamic puntuacion;
  final List<String> razones;
  const _CarreraRecomCard({
    required this.nombre,
    required this.match,
    required this.puntuacion,
    required this.razones,
  });

  Color _matchColor() {
    switch (match.toLowerCase()) {
      case 'alto':
        return const Color(0xFF388E3C);
      case 'medio':
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFFD32F2F);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(nombre,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          if (match.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _matchColor().withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${match.toUpperCase()}${puntuacion != null ? ' · $puntuacion%' : ''}',
                style: TextStyle(
                    color: _matchColor(),
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
        ]),
        if (razones.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...razones.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Icon(Icons.circle,
                            size: 5,
                            color: _matchColor()),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(r,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.3))),
                    ]),
              )),
        ],
      ]),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _SectionCard(
      {required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
        ]),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}
