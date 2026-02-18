import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/orientacion_vocacional.dart' hide PerfilVocacional;
import '../../models/vocational_models.dart';
import '../../providers/auth_provider.dart';
import '../../services/vocational_service.dart';
import '../../utils/constants.dart';
import '../welcome_screen.dart';
import 'select_test_screen.dart';
import 'historial_screen.dart';
import 'perfil_vocacional_screen.dart';
import '../student/vocational/career_list_screen.dart';
import '../postulaciones/postulaciones_main_screen.dart';
import 'chatbot_vocacional_screen.dart';

// ─── Dashboard principal del aspirante ────────────────────────────────────────

class DashboardAspiranteScreen extends StatefulWidget {
  const DashboardAspiranteScreen({super.key});

  @override
  State<DashboardAspiranteScreen> createState() =>
      _DashboardAspiranteScreenState();
}

class _DashboardAspiranteScreenState extends State<DashboardAspiranteScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      _HomeTab(),
      _TestsTab(),
      _TrayectoriaTab(),
      _NotificacionesTab(),
      _PerfilTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.psychology_outlined),
              activeIcon: Icon(Icons.psychology),
              label: 'Tests'),
          BottomNavigationBarItem(
              icon: Icon(Icons.upload_file_outlined),
              activeIcon: Icon(Icons.upload_file),
              label: 'Trayectoria'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Novedades'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Mi Perfil'),
        ],
      ),
    );
  }
}

// ─── Tab: Inicio ──────────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final VocationalService _service = VocationalService();
  Historial? _historial;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistorial();
  }

  Future<void> _loadHistorial() async {
    try {
      final h = await _service.obtenerHistorial();
      if (mounted) setState(() { _historial = h; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goTo(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final nombre = auth.user?.nombre ?? 'Usuario';
    final isEstudiante = (auth.user?.role ?? '').toLowerCase() == 'estudiante';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal UNIMET'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => _confirmLogout(context, auth),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistorial,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroBanner(nombre: nombre),
              const SizedBox(height: 20),
              if (!_loading && _historial != null)
                _ProgressSummary(historial: _historial!),
              if (_loading) const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 20),
              Text('Módulos',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _DashModuleCard(
                title: 'Chatbot vocacional',
                subtitle: 'Chat, consultas y recomendaciones con IA',
                chip: 'Inteligencia Artificial',
                icon: Icons.smart_toy_outlined,
                color: Colors.indigo,
                onTap: () => _goTo(const ChatbotVocacionalScreen()),
              ),
              const SizedBox(height: 10),
              _DashModuleCard(
                title: 'Historial de tests',
                subtitle: 'Sesiones completadas y en progreso',
                chip: 'Historial',
                icon: Icons.history,
                color: Colors.orange,
                onTap: () => _goTo(const HistorialScreen()),
              ),
              const SizedBox(height: 10),
              _DashModuleCard(
                title: 'Explorar carreras',
                subtitle: 'Catálogo de carreras de la UNIMET',
                chip: 'Contenido',
                icon: Icons.menu_book,
                color: Colors.blue,
                onTap: () => _goTo(const CareerListScreen()),
              ),
              if (isEstudiante) ...[
                const SizedBox(height: 10),
                _DashModuleCard(
                  title: 'Gestión de Becas',
                  subtitle: 'Postúlate y gestiona tus solicitudes de beca',
                  chip: 'Becas',
                  icon: Icons.school,
                  color: const Color(0xFF0D9488),
                  onTap: () => _goTo(const PostulacionesMainScreen()),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext ctx, AuthProvider auth) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar tu sesión?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.logout();
              if (ctx.mounted) {
                Navigator.of(ctx).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (_) => false,
                );
              }
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}

// ─── Tab: Tests ───────────────────────────────────────────────────────────────

class _TestsTab extends StatelessWidget {
  const _TestsTab();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const SelectTestScreen(showAppBar: true),
      ),
    );
  }
}

// ─── Tab: Trayectoria Académica (NEW) ────────────────────────────────────────

class _TrayectoriaTab extends StatefulWidget {
  const _TrayectoriaTab();

  @override
  State<_TrayectoriaTab> createState() => _TrayectoriaTabState();
}

class _TrayectoriaTabState extends State<_TrayectoriaTab> {
  final VocationalService _service = VocationalService();
  TrayectoriaBody _trayectoria = TrayectoriaBody();
  bool _loading = true;
  bool _saving = false;

  final _materiaCtrl = TextEditingController();
  final _materiaNotaCtrl = TextEditingController();
  final _actividadCtrl = TextEditingController();
  final _proyectoCtrl = TextEditingController();

  static const _gradoOpciones = ['4to año', '5to año'];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _materiaCtrl.dispose();
    _materiaNotaCtrl.dispose();
    _actividadCtrl.dispose();
    _proyectoCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final data = await _service.obtenerMiTrayectoria();
      final d = data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;
      if (mounted) {
        setState(() {
          _trayectoria = TrayectoriaBody.fromJson(d);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _guardar() async {
    setState(() => _saving = true);
    try {
      await _service.actualizarMiTrayectoria(_trayectoria.toJson());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trayectoria guardada correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addMateria() {
    final mat = _materiaCtrl.text.trim();
    final nota = _materiaNotaCtrl.text.trim();
    if (mat.isEmpty) return;
    final entry = nota.isNotEmpty ? '$mat: $nota' : mat;
    setState(() {
      _trayectoria.materiasDestacadas ??= [];
      _trayectoria.materiasDestacadas!.add(entry);
    });
    _materiaCtrl.clear();
    _materiaNotaCtrl.clear();
  }

  void _addActividad() {
    final v = _actividadCtrl.text.trim();
    if (v.isEmpty) return;
    setState(() {
      _trayectoria.actividadesExtracurriculares ??= [];
      _trayectoria.actividadesExtracurriculares!.add(v);
    });
    _actividadCtrl.clear();
  }

  void _addProyecto() {
    final v = _proyectoCtrl.text.trim();
    if (v.isEmpty) return;
    setState(() {
      _trayectoria.proyectosRealizados ??= [];
      _trayectoria.proyectosRealizados!.add(v);
    });
    _proyectoCtrl.clear();
  }

  int _getMaxAno() {
    final g = (_trayectoria.gradoActual ?? '').trim().toLowerCase();
    if (g.contains('5to') || g.contains('quinto')) return 5;
    if (g.contains('4to') || g.contains('cuarto')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trayectoria Académica')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.2)),
                    ),
                    child: const Row(children: [
                      Icon(Icons.info_outline,
                          color: AppColors.info, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Estos datos enriquecen tu perfil de orientación vocacional. Todos los campos son opcionales.',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Grado actual
                  const Text('Grado actual',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _gradoOpciones.contains(_trayectoria.gradoActual)
                        ? _trayectoria.gradoActual
                        : null,
                    decoration: const InputDecoration(
                      hintText: 'Selecciona tu grado',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: _gradoOpciones
                        .map((g) =>
                            DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _trayectoria.gradoActual = v),
                  ),
                  const SizedBox(height: 20),

                  // Materias destacadas con nota
                  _ChipListField(
                    label: 'Materias de más interés (con nota)',
                    items: _trayectoria.materiasDestacadas ?? [],
                    onRemove: (i) => setState(
                        () => _trayectoria.materiasDestacadas!.removeAt(i)),
                    child: Row(children: [
                      Expanded(
                        child: TextField(
                          controller: _materiaCtrl,
                          decoration: const InputDecoration(
                              hintText: 'Ej: Matemáticas',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10)),
                          onSubmitted: (_) => _addMateria(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _materiaNotaCtrl,
                          decoration: const InputDecoration(
                              hintText: 'Nota',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 10)),
                          keyboardType: TextInputType.number,
                          onSubmitted: (_) => _addMateria(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: _addMateria,
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.primary,
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // Actividades extracurriculares
                  _ChipListField(
                    label: 'Actividades extracurriculares',
                    items:
                        _trayectoria.actividadesExtracurriculares ?? [],
                    onRemove: (i) => setState(() => _trayectoria
                        .actividadesExtracurriculares!
                        .removeAt(i)),
                    child: Row(children: [
                      Expanded(
                        child: TextField(
                          controller: _actividadCtrl,
                          decoration: const InputDecoration(
                              hintText: 'Ej: Deportes, Teatro',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10)),
                          onSubmitted: (_) => _addActividad(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: _addActividad,
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.primary,
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // Proyectos realizados
                  _ChipListField(
                    label: 'Proyectos realizados',
                    items: _trayectoria.proyectosRealizados ?? [],
                    onRemove: (i) => setState(() =>
                        _trayectoria.proyectosRealizados!.removeAt(i)),
                    child: Row(children: [
                      Expanded(
                        child: TextField(
                          controller: _proyectoCtrl,
                          decoration: const InputDecoration(
                              hintText: 'Ej: Feria científica 2024',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10)),
                          onSubmitted: (_) => _addProyecto(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: _addProyecto,
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.primary,
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  // Materias por año/lapso
                  const Text('Materias y notas por año y lapso',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text(
                    'Agrega materias con nota (0-20) por cada año/lapso.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  if (_getMaxAno() == 0)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Row(children: [
                        Icon(Icons.info_outline,
                            size: 16, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Selecciona tu grado actual arriba para ver los años y lapsos.',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                        ),
                      ]),
                    )
                  else
                    ...List.generate(_getMaxAno(), (i) {
                      final ano = '${i + 1}';
                      final anoLabels = [
                        '1er año',
                        '2do año',
                        '3er año',
                        '4to año',
                        '5to año'
                      ];
                      return _AnoLapsoCard(
                        anoLabel: anoLabels[i],
                        ano: ano,
                        trayectoria: _trayectoria,
                        onChanged: () => setState(() {}),
                      );
                    }),
                  const SizedBox(height: 24),

                  // Guardar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _guardar,
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Guardar trayectoria académica'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

// ─── Tab: Notificaciones (enhanced with citas + mark all) ────────────────────

class _NotificacionesTab extends StatefulWidget {
  const _NotificacionesTab();

  @override
  State<_NotificacionesTab> createState() => _NotificacionesTabState();
}

class _NotificacionesTabState extends State<_NotificacionesTab> {
  final VocationalService _service = VocationalService();
  List<VocationalNotification> _notifs = [];
  List<Cita> _citas = [];
  bool _loading = true;
  String? _citaActionId;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final userId = auth.user?.id ?? '';

      // Fetch independently so one failure doesn't kill the other
      late List<VocationalNotification> notifs;
      List<Map<String, dynamic>> citasRaw = [];

      try {
        notifs = await _service.obtenerNotificaciones(limit: 10);
      } catch (_) {
        notifs = [];
      }

      if (userId.isNotEmpty) {
        try {
          citasRaw = await _service.obtenerCitasEstudiante(userId);
        } catch (_) {
          citasRaw = [];
        }
      }

      final hoy = DateTime.now();
      final citasParsed = citasRaw
          .map((c) => Cita.fromJson(c))
          .where((c) =>
              ['pendiente', 'confirmada'].contains(c.estado) &&
              DateTime.tryParse('${c.fecha}T00:00:00')
                      ?.isAfter(hoy.subtract(const Duration(days: 1))) ==
                  true)
          .toList()
        ..sort(
            (a, b) => a.fecha.compareTo(b.fecha) * 10 + a.hora.compareTo(b.hora));

      if (mounted) {
        setState(() {
          _notifs = notifs;
          _citas = citasParsed;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _sinLeer => _notifs.where((n) => !n.leido).length;

  Future<void> _marcarLeida(VocationalNotification n) async {
    if (n.leido) return;
    try {
      await _service.marcarComoLeida(n.id);
      if (mounted) {
        setState(() {
          final i = _notifs.indexWhere((x) => x.id == n.id);
          if (i >= 0) {
            _notifs[i] = VocationalNotification(
              id: n.id,
              tipo: n.tipo,
              titulo: n.titulo,
              mensaje: n.mensaje,
              leido: true,
              fecha: n.fecha,
              urlAccion: n.urlAccion,
              ctaTexto: n.ctaTexto,
            );
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _marcarTodasLeidas() async {
    try {
      await _service.marcarTodasComoLeidas();
      if (mounted) {
        setState(() {
          _notifs = _notifs
              .map((n) => VocationalNotification(
                    id: n.id,
                    tipo: n.tipo,
                    titulo: n.titulo,
                    mensaje: n.mensaje,
                    leido: true,
                    fecha: n.fecha,
                    urlAccion: n.urlAccion,
                    ctaTexto: n.ctaTexto,
                  ))
              .toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _confirmarCita(String citaId) async {
    setState(() => _citaActionId = citaId);
    try {
      await _service.actualizarCita(citaId, 'confirmada');
      if (mounted) {
        setState(() {
          final i = _citas.indexWhere((c) => c.id == citaId);
          if (i >= 0) {
            _citas[i] = Cita(
              id: _citas[i].id,
              fecha: _citas[i].fecha,
              hora: _citas[i].hora,
              motivo: _citas[i].motivo,
              modalidad: _citas[i].modalidad,
              estado: 'confirmada',
              especialista: _citas[i].especialista,
            );
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cita confirmada')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _citaActionId = null);
    }
  }

  Future<void> _cancelarCita(String citaId) async {
    setState(() => _citaActionId = citaId);
    try {
      await _service.cancelarCita(citaId);
      if (mounted) {
        setState(() => _citas.removeWhere((c) => c.id == citaId));
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cita cancelada')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _citaActionId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Text('Notificaciones'),
          if (_sinLeer > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10)),
              child: Text('$_sinLeer',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ]),
        actions: [
          if (_sinLeer > 0)
            TextButton.icon(
              onPressed: _marcarTodasLeidas,
              icon: const Icon(Icons.done_all, size: 18, color: Colors.white),
              label: const Text('Leer todas',
                  style: TextStyle(fontSize: 12, color: Colors.white)),
            ),
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _cargar),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargar,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Próximas citas
                    if (_citas.isNotEmpty) ...[
                      Row(children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        const Text('Próximas citas',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ]),
                      const SizedBox(height: 10),
                      ..._citas.take(3).map((cita) => _CitaCard(
                            cita: cita,
                            loading: _citaActionId == cita.id,
                            onConfirmar: () => _confirmarCita(cita.id),
                            onCancelar: () => _cancelarCita(cita.id),
                          )),
                      const Divider(height: 32),
                    ],

                    // Notificaciones
                    if (_notifs.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.notifications_none,
                                    size: 56, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                const Text('No tienes notificaciones',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                const Text(
                                    'Los eventos y anuncios aparecerán aquí.',
                                    style: TextStyle(
                                        color: AppColors.textSecondary)),
                              ]),
                        ),
                      )
                    else
                      ..._notifs.map((n) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _NotifCard(
                              notif: n,
                              onTap: () => _marcarLeida(n),
                            ),
                          )),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─── Tab: Perfil (enhanced with convertir a estudiante) ──────────────────────

class _PerfilTab extends StatefulWidget {
  const _PerfilTab();

  @override
  State<_PerfilTab> createState() => _PerfilTabState();
}

class _PerfilTabState extends State<_PerfilTab> {
  final VocationalService _service = VocationalService();
  PerfilVocacional? _perfil;
  bool _loadingPerfil = true;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    try {
      final p = await _service.obtenerPerfilVocacional();
      if (mounted) setState(() { _perfil = p; _loadingPerfil = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingPerfil = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar + basic info
            Center(
              child: Column(children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    _initials(user?.nombre, user?.apellido),
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${user?.nombre ?? ''} ${user?.apellido ?? ''}'.trim(),
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(user?.email ?? '',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _rolLabel(user?.role),
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // Resumen vocacional
            if (_loadingPerfil)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else if (_perfil != null &&
                (_perfil!.perfilDominante.isNotEmpty ||
                    _perfil!.totalTests > 0))
              _VocationalSummaryCard(perfil: _perfil!),
            const SizedBox(height: 16),

            // Info personal
            _InfoCard(
              title: 'Información personal',
              icon: Icons.person_outline,
              items: [
                if ((user?.cedula ?? '').isNotEmpty)
                  _InfoRow(label: 'Cédula', value: user!.cedula!),
                if ((user?.telefono ?? '').isNotEmpty)
                  _InfoRow(label: 'Teléfono', value: user!.telefono!),
                if ((user?.carrera ?? '').isNotEmpty)
                  _InfoRow(label: 'Carrera', value: user!.carrera!),
                if (user?.trimestre != null)
                  _InfoRow(
                      label: 'Trimestre', value: '${user!.trimestre}'),
              ],
            ),
            const SizedBox(height: 16),

            // Acciones rápidas
            _InfoCard(
              title: 'Acciones rápidas',
              icon: Icons.flash_on,
              items: [
                _ActionRow(
                  label: 'Ver perfil vocacional',
                  icon: Icons.insert_chart,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const PerfilVocacionalScreen())),
                ),
                _ActionRow(
                  label: 'Historial de tests',
                  icon: Icons.history,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HistorialScreen())),
                ),
                _ActionRow(
                  label: 'Iniciar nuevo test',
                  icon: Icons.play_arrow,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SelectTestScreen(showAppBar: true))),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Convertir aspirante a estudiante
            if (user?.role == 'aspirante')
              _ConvertirEstudianteBtn(
                  service: _service, auth: auth),
            const SizedBox(height: 16),

            // Cerrar sesión
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const WelcomeScreen()),
                      (_) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text('Cerrar sesión',
                    style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _initials(String? nombre, String? apellido) {
    final n =
        (nombre ?? '').isNotEmpty ? nombre![0].toUpperCase() : '';
    final a =
        (apellido ?? '').isNotEmpty ? apellido![0].toUpperCase() : '';
    return '$n$a';
  }

  String _rolLabel(String? role) {
    switch ((role ?? '').toLowerCase()) {
      case 'aspirante':
        return 'Aspirante';
      case 'estudiante':
        return 'Estudiante';
      default:
        return role ?? 'Usuario';
    }
  }
}

// ─── Vocational summary card ────────────────────────────────────────────────

class _VocationalSummaryCard extends StatelessWidget {
  final PerfilVocacional perfil;
  const _VocationalSummaryCard({required this.perfil});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text('Resumen Vocacional',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ]),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          if (perfil.perfilDominante.isNotEmpty)
            _Badge(
                label: perfil.perfilDominante,
                color: AppColors.primary),
          if (perfil.codigoHolland.isNotEmpty)
            _Badge(
                label: 'Código: ${perfil.codigoHolland}',
                color: Colors.orange),
        ]),
        if (perfil.perfilSecundario.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('Secundario: ${perfil.perfilSecundario}',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ],
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.check_circle_outline,
              size: 16, color: AppColors.success),
          const SizedBox(width: 6),
          Text(
              '${perfil.totalTests} test${perfil.totalTests == 1 ? '' : 's'} completado${perfil.totalTests == 1 ? '' : 's'}',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Convertir aspirante a estudiante ─────────────────────────────────────────

class _ConvertirEstudianteBtn extends StatelessWidget {
  final VocationalService service;
  final AuthProvider auth;
  const _ConvertirEstudianteBtn(
      {required this.service, required this.auth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showConvertirDialog(context),
        icon: const Icon(Icons.school, color: Color(0xFFF37021)),
        label: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pasar a estudiante',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC45A1A))),
            Text('Universidad Metropolitana',
                style: TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
              color: const Color(0xFFF37021).withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          backgroundColor: Colors.orange.shade50,
        ),
      ),
    );
  }

  void _showConvertirDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    final carreraCtrl = TextEditingController();
    final trimestreCtrl = TextEditingController();
    var loading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Pasar a Estudiante UNIMET'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ingresa tu correo institucional para actualizar tu cuenta.',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email institucional',
                    hintText: 'tu.correo@correo.unimet.edu.ve',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: carreraCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Carrera (opcional)',
                    hintText: 'Ej: Ingeniería de Sistemas',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: trimestreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Trimestre (opcional)',
                    hintText: '1-15',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      final email = emailCtrl.text.trim().toLowerCase();
                      if (email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Ingresa tu email institucional')),
                        );
                        return;
                      }
                      if (!email
                          .endsWith('@correo.unimet.edu.ve')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Usa tu correo @correo.unimet.edu.ve')),
                        );
                        return;
                      }
                      setDialogState(() => loading = true);
                      try {
                        final trimestre = int.tryParse(
                                trimestreCtrl.text.trim()) ??
                            1;
                        await service.convertirAspiranteAEstudiante(
                          email: email,
                          carrera: carreraCtrl.text.trim(),
                          trimestre: trimestre.clamp(1, 15),
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    '¡Bienvenido a la UNIMET! Tu cuenta ha sido actualizada.')),
                          );
                          // Refresh auth
                          await auth.init();
                        }
                      } catch (e) {
                        setDialogState(() => loading = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
              child: loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Convertir'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Cita card ──────────────────────────────────────────────────────────────

class _CitaCard extends StatelessWidget {
  final Cita cita;
  final bool loading;
  final VoidCallback onConfirmar;
  final VoidCallback onCancelar;

  const _CitaCard({
    required this.cita,
    required this.loading,
    required this.onConfirmar,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    final parts = cita.fecha.split('-');
    final month = parts.length >= 2 ? _mesCorto(int.tryParse(parts[1]) ?? 0) : '';
    final day = parts.length >= 3 ? parts[2] : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(children: [
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: cita.estado == 'confirmada'
                ? AppColors.success
                : AppColors.primary,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Row(children: [
              // Date box
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(children: [
                  Text(month,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600)),
                  Text(day,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cita.motivoLabel,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('${cita.hora} · ${cita.modalidadLabel}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                      if (cita.especialista != null)
                        Text(
                          'Con ${cita.especialista!['nombre'] ?? ''} ${cita.especialista!['apellido'] ?? ''}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary),
                        ),
                    ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cita.estado == 'confirmada'
                      ? AppColors.success.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cita.estado == 'confirmada'
                      ? 'Confirmada'
                      : 'Pendiente',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cita.estado == 'confirmada'
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ]),
            if (cita.estado == 'pendiente') ...[
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: loading ? null : onConfirmar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: loading
                          ? const SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white))
                          : const Text('Confirmar',
                              style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: OutlinedButton(
                      onPressed: loading ? null : onCancelar,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: loading
                          ? SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.error))
                          : const Text('Cancelar',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.error)),
                    ),
                  ),
                ),
              ]),
            ],
          ]),
        ),
      ]),
    );
  }

  String _mesCorto(int m) {
    const meses = [
      '', 'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
      'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'
    ];
    return (m >= 1 && m <= 12) ? meses[m] : '';
  }
}

// ─── Notification card (reused from CRM) ─────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final VocationalNotification notif;
  final VoidCallback onTap;
  const _NotifCard({required this.notif, required this.onTap});

  /// Strip HTML tags and decode common entities
  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForTipo(notif.tipo);
    final bg = _bgForTipo(notif.tipo);
    final plainMsg = _stripHtml(notif.mensaje);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.leido ? Colors.white : bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notif.leido
                ? Colors.grey.shade200
                : color.withValues(alpha: 0.3),
          ),
        ),
        child:
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_iconForTipo(notif.tipo),
                color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(notif.titulo,
                          style: TextStyle(
                              fontWeight: notif.leido
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              fontSize: 14)),
                    ),
                    if (!notif.leido)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle),
                      ),
                  ]),
                  const SizedBox(height: 4),
                  Text(plainMsg,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.access_time,
                        size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(_formatFecha(notif.fecha),
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500)),
                    ),
                    // CTA button if urlAccion exists
                    if ((notif.urlAccion ?? '').isNotEmpty)
                      InkWell(
                        onTap: () async {
                          final uri = Uri.tryParse(notif.urlAccion!);
                          if (uri != null && await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.open_in_new, size: 12, color: color),
                            const SizedBox(width: 4),
                            Text(notif.ctaTexto ?? 'Ver más',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: color)),
                          ]),
                        ),
                      ),
                  ]),
                ]),
          ),
        ]),
      ),
    );
  }
}

// ─── Chip list field for trayectoria ─────────────────────────────────────────

class _ChipListField extends StatelessWidget {
  final String label;
  final List<String> items;
  final void Function(int) onRemove;
  final Widget child;

  const _ChipListField({
    required this.label,
    required this.items,
    required this.onRemove,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      const SizedBox(height: 8),
      if (items.isNotEmpty)
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items.asMap().entries.map((e) {
            return Chip(
              label: Text(e.value, style: const TextStyle(fontSize: 12)),
              deleteIcon: const Icon(Icons.close, size: 14),
              onDeleted: () => onRemove(e.key),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      const SizedBox(height: 8),
      child,
    ]);
  }
}

// ─── Año/Lapso card for materias por año ──────────────────────────────────────

class _AnoLapsoCard extends StatefulWidget {
  final String anoLabel;
  final String ano;
  final TrayectoriaBody trayectoria;
  final VoidCallback onChanged;

  const _AnoLapsoCard({
    required this.anoLabel,
    required this.ano,
    required this.trayectoria,
    required this.onChanged,
  });

  @override
  State<_AnoLapsoCard> createState() => _AnoLapsoCardState();
}

class _AnoLapsoCardState extends State<_AnoLapsoCard> {
  final Map<String, TextEditingController> _materiaControllers = {};
  final Map<String, TextEditingController> _notaControllers = {};

  TextEditingController _getMateriaCtrl(String lapso) {
    return _materiaControllers.putIfAbsent(
        lapso, () => TextEditingController());
  }

  TextEditingController _getNotaCtrl(String lapso) {
    return _notaControllers.putIfAbsent(
        lapso, () => TextEditingController());
  }

  List<MateriaNota> _getMaterias(String lapso) {
    return widget.trayectoria.materiasPorAnoLapso?[widget.ano]?[lapso] ?? [];
  }

  void _addMateria(String lapso) {
    final matCtrl = _getMateriaCtrl(lapso);
    final notaCtrl = _getNotaCtrl(lapso);
    final mat = matCtrl.text.trim();
    if (mat.isEmpty) return;
    final nota = double.tryParse(notaCtrl.text.trim()) ?? 0;

    widget.trayectoria.materiasPorAnoLapso ??= {};
    widget.trayectoria.materiasPorAnoLapso![widget.ano] ??= {};
    widget.trayectoria.materiasPorAnoLapso![widget.ano]![lapso] ??= [];
    widget.trayectoria.materiasPorAnoLapso![widget.ano]![lapso]!
        .add(MateriaNota(materia: mat, nota: nota.clamp(0, 20)));

    matCtrl.clear();
    notaCtrl.clear();
    widget.onChanged();
  }

  void _removeMateria(String lapso, int index) {
    widget.trayectoria.materiasPorAnoLapso?[widget.ano]?[lapso]
        ?.removeAt(index);
    widget.onChanged();
  }

  @override
  void dispose() {
    for (final c in _materiaControllers.values) {
      c.dispose();
    }
    for (final c in _notaControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.anoLabel,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        ...['1', '2', '3'].map((lapso) {
          final materias = _getMaterias(lapso);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lapso $lapso',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    if (materias.isNotEmpty)
                      ...materias.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(children: [
                              Expanded(
                                child: Text(
                                    '${e.value.materia}: ${e.value.nota}',
                                    style: const TextStyle(fontSize: 13)),
                              ),
                              InkWell(
                                onTap: () =>
                                    _removeMateria(lapso, e.key),
                                child: Icon(Icons.close,
                                    size: 14,
                                    color: Colors.grey.shade400),
                              ),
                            ]),
                          )),
                    const SizedBox(height: 4),
                    Row(children: [
                      Expanded(
                        child: TextField(
                          controller: _getMateriaCtrl(lapso),
                          decoration: const InputDecoration(
                              hintText: 'Materia',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8)),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 50,
                        child: TextField(
                          controller: _getNotaCtrl(lapso),
                          decoration: const InputDecoration(
                              hintText: 'Nota',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 8)),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => _addMateria(lapso),
                        child: Icon(Icons.add_circle_outline,
                            size: 22, color: AppColors.primary),
                      ),
                    ]),
                  ]),
            ),
          );
        }),
      ]),
    );
  }
}

// ─── Sub-widgets (shared) ────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final String nombre;
  const _HeroBanner({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.explore, color: Colors.white, size: 32),
          const SizedBox(height: 10),
          Text('¡Hola, $nombre!',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text(
            'Explora tu orientación vocacional\ny gestiona tus becas universitarias.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  final Historial historial;
  const _ProgressSummary({required this.historial});

  @override
  Widget build(BuildContext context) {
    final completados = historial.sesionesCompletadas.length;
    final enProgreso = historial.sesionesEnProgreso.length;
    if (completados == 0 && enProgreso == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(children: [
        Expanded(
          child: _StatChip(
            label: 'Completados',
            value: '$completados',
            color: AppColors.success,
            icon: Icons.check_circle_outline,
          ),
        ),
        if (enProgreso > 0) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _StatChip(
              label: 'En progreso',
              value: '$enProgreso',
              color: AppColors.warning,
              icon: Icons.hourglass_empty,
            ),
          ),
        ],
      ]),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatChip(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
      ]),
    ]);
  }
}

class _DashModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String chip;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashModuleCard({
    required this.title,
    required this.subtitle,
    required this.chip,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(chip,
                    style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 4),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ]),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> items;

  const _InfoCard(
      {required this.title, required this.icon, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15)),
        ]),
        const SizedBox(height: 12),
        ...items,
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionRow(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
        ]),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

Color _colorForTipo(String tipo) {
  switch (tipo) {
    case 'evento': return const Color(0xFF2196F3);
    case 'anuncio': return const Color(0xFF9C27B0);
    case 'recordatorio': return const Color(0xFFFF9800);
    case 'campana': return const Color(0xFF4CAF50);
    case 'mensaje': return const Color(0xFFE91E63);
    default: return AppColors.textSecondary;
  }
}

Color _bgForTipo(String tipo) {
  switch (tipo) {
    case 'evento': return const Color(0xFFE3F2FD);
    case 'anuncio': return const Color(0xFFF3E5F5);
    case 'recordatorio': return const Color(0xFFFFF3E0);
    case 'campana': return const Color(0xFFE8F5E9);
    case 'mensaje': return const Color(0xFFFCE4EC);
    default: return const Color(0xFFF5F5F5);
  }
}

IconData _iconForTipo(String tipo) {
  switch (tipo) {
    case 'evento': return Icons.event;
    case 'anuncio': return Icons.campaign;
    case 'recordatorio': return Icons.alarm;
    case 'campana': return Icons.mail_outline;
    case 'mensaje': return Icons.message_outlined;
    default: return Icons.notifications_outlined;
  }
}

String _formatFecha(String fecha) {
  if (fecha.isEmpty) return '';
  try {
    final d = DateTime.parse(fecha).toLocal();
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  } catch (_) {
    return fecha;
  }
}
