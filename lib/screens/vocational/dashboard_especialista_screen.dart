import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/vocational_service.dart';
import '../../utils/constants.dart';
import '../welcome_screen.dart';
import '../student/vocational/career_list_screen.dart';

class DashboardEspecialistaScreen extends StatefulWidget {
  const DashboardEspecialistaScreen({super.key});

  @override
  State<DashboardEspecialistaScreen> createState() =>
      _DashboardEspecialistaScreenState();
}

class _DashboardEspecialistaScreenState
    extends State<DashboardEspecialistaScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _EstudiantesTab(),
    _AgendaTab(),
    _CarrerasTab(),
    _PerfilEspecialistaTab(),
  ];

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
              icon: Icon(Icons.people_outlined),
              activeIcon: Icon(Icons.people),
              label: 'Estudiantes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Agenda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Carreras'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Mi Perfil'),
        ],
      ),
    );
  }
}

// ─── Tab Estudiantes ──────────────────────────────────────────────────────────

class _EstudiantesTab extends StatefulWidget {
  const _EstudiantesTab();

  @override
  State<_EstudiantesTab> createState() => _EstudiantesTabState();
}

class _EstudiantesTabState extends State<_EstudiantesTab> {
  final VocationalService _service = VocationalService();
  List<Map<String, dynamic>> _estudiantes = [];
  List<Map<String, dynamic>> _filtrados = [];
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _seleccionado;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await _service.obtenerEstudiantesEspecialista();
      if (mounted) {
        setState(() {
          _estudiantes = list;
          _filtrados = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _onSearch(String q) {
    setState(() {
      _filtrados = q.isEmpty
          ? _estudiantes
          : _estudiantes.where((e) {
              final name = (e['name'] ?? e['nombre'] ?? '').toString().toLowerCase();
              final career = (e['career_interest'] ?? '').toString().toLowerCase();
              return name.contains(q.toLowerCase()) || career.contains(q.toLowerCase());
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de estudiantes')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _CenteredError(error: _error!, onRetry: _cargar)
              : Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar estudiante…',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onChanged: _onSearch,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text('${_filtrados.length} estudiante${_filtrados.length == 1 ? '' : 's'}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ),
                  Expanded(
                    child: _seleccionado != null
                        ? _DetalleEstudiante(
                            data: _seleccionado!,
                            service: _service,
                            onBack: () => setState(() => _seleccionado = null),
                          )
                        : RefreshIndicator(
                            onRefresh: _cargar,
                            child: _filtrados.isEmpty
                                ? const Center(child: Text('No se encontraron estudiantes.'))
                                : ListView.separated(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    itemCount: _filtrados.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                                    itemBuilder: (ctx, i) => _EstudianteCard(
                                      data: _filtrados[i],
                                      onTap: () => setState(() => _seleccionado = _filtrados[i]),
                                    ),
                                  ),
                          ),
                  ),
                ]),
    );
  }
}

class _EstudianteCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  const _EstudianteCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = (data['name'] ?? data['nombre'] ?? 'Sin nombre').toString();
    final career = (data['career_interest'] ?? '').toString();
    final risk = (data['risk_level'] ?? '').toString();
    final code = (data['codigoHolland'] ?? '').toString();
    final riskColor = risk == 'Alto'
        ? AppColors.error
        : risk == 'Medio'
            ? AppColors.warning
            : AppColors.success;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            if (career.isNotEmpty)
              Text(career, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Row(children: [
              if (code.isNotEmpty)
                _Chip(label: code, color: AppColors.primary),
              if (risk.isNotEmpty) ...[
                const SizedBox(width: 6),
                _Chip(label: 'Riesgo: $risk', color: riskColor),
              ],
            ]),
          ])),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ]),
      ),
    );
  }
}

class _DetalleEstudiante extends StatefulWidget {
  final Map<String, dynamic> data;
  final VocationalService service;
  final VoidCallback onBack;
  const _DetalleEstudiante({required this.data, required this.service, required this.onBack});

  @override
  State<_DetalleEstudiante> createState() => _DetalleEstudianteState();
}

class _DetalleEstudianteState extends State<_DetalleEstudiante> {
  bool _agendando = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final name = (d['name'] ?? d['nombre'] ?? '').toString();
    final email = (d['email'] ?? '').toString();
    final code = (d['codigoHolland'] ?? '').toString();
    final risk = (d['risk_level'] ?? '').toString();
    final total = d['totalSesiones'] ?? 0;
    final recomendaciones = (d['recomendacionesCarreras'] as List? ?? []);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
          const Text('Detalle del estudiante', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
        const SizedBox(height: 12),

        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              if (email.isNotEmpty)
                Text(email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ])),
          ]),
        ),
        const SizedBox(height: 14),

        // Stats
        Row(children: [
          if (code.isNotEmpty)
            _StatTile(label: 'Código Holland', value: code, color: AppColors.primary),
          if (risk.isNotEmpty) ...[
            const SizedBox(width: 10),
            _StatTile(
              label: 'Nivel de riesgo',
              value: risk,
              color: risk == 'Alto' ? AppColors.error : risk == 'Medio' ? AppColors.warning : AppColors.success,
            ),
          ],
          if (total > 0) ...[
            const SizedBox(width: 10),
            _StatTile(label: 'Tests', value: '$total', color: Colors.teal),
          ],
        ]),
        const SizedBox(height: 14),

        // Carreras recomendadas
        if (recomendaciones.isNotEmpty) ...[
          const Text('Carreras recomendadas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          ...recomendaciones.take(3).map((c) {
            final r = c is Map ? c : {};
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                const Icon(Icons.school_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text((r['nombre'] ?? r['name'] ?? '').toString(),
                    style: const TextStyle(fontSize: 13))),
              ]),
            );
          }),
          const SizedBox(height: 12),
        ],

        // Agendar cita
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _agendando ? null : () => _showAgendarDialog(context),
            icon: _agendando
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.calendar_today, size: 18),
            label: Text(_agendando ? 'Agendando…' : 'Agendar cita'),
          ),
        ),
      ]),
    );
  }

  void _showAgendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Agendar cita'),
        content: const Text('Función disponible próximamente desde el módulo de Agenda.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }
}

// ─── Tab Agenda ───────────────────────────────────────────────────────────────

class _AgendaTab extends StatefulWidget {
  const _AgendaTab();

  @override
  State<_AgendaTab> createState() => _AgendaTabState();
}

class _AgendaTabState extends State<_AgendaTab> {
  final VocationalService _service = VocationalService();
  List<Map<String, dynamic>> _citas = [];
  bool _loading = true;
  String? _error;
  String _filtroEstado = 'todas';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await _service.obtenerMisCitas();
      if (mounted) setState(() { _citas = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Map<String, dynamic>> get _citasFiltradas => _filtroEstado == 'todas'
      ? _citas
      : _citas.where((c) => (c['estado'] ?? '').toString().toLowerCase() == _filtroEstado).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda de citas')),
      body: Column(children: [
        // Filtros
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: ['todas', 'pendiente', 'confirmada', 'completada', 'cancelada']
                .map((e) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_estadoLabel(e), style: const TextStyle(fontSize: 13)),
                    selected: _filtroEstado == e,
                    onSelected: (_) => setState(() => _filtroEstado = e),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.primary,
                  ),
                ))
                .toList(),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _CenteredError(error: _error!, onRetry: _cargar)
                  : _citasFiltradas.isEmpty
                      ? const Center(child: Text('No hay citas en este estado.'))
                      : RefreshIndicator(
                          onRefresh: _cargar,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _citasFiltradas.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (ctx, i) => _CitaCard(
                              cita: _citasFiltradas[i],
                              onActualizar: (estado) async {
                                final id = (_citasFiltradas[i]['id'] ?? '').toString();
                                if (id.isEmpty) return;
                                try {
                                  await _service.actualizarCita(id, estado);
                                  _cargar();
                                } catch (e) {
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
                                  }
                                }
                              },
                            ),
                          ),
                        ),
        ),
      ]),
    );
  }

  String _estadoLabel(String e) {
    const labels = {
      'todas': 'Todas',
      'pendiente': 'Pendiente',
      'confirmada': 'Confirmada',
      'completada': 'Completada',
      'cancelada': 'Cancelada',
    };
    return labels[e] ?? e;
  }
}

class _CitaCard extends StatelessWidget {
  final Map<String, dynamic> cita;
  final void Function(String estado) onActualizar;
  const _CitaCard({required this.cita, required this.onActualizar});

  @override
  Widget build(BuildContext context) {
    final estado = (cita['estado'] ?? '').toString();
    final motivo = (cita['motivo'] ?? '').toString();
    final fecha = (cita['fecha'] ?? '').toString();
    final hora = (cita['hora'] ?? '').toString();
    final estudiante = (cita['estudiante'] ?? cita['estudianteNombre'] ?? '').toString();
    final statusColor = _statusColor(estado);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(estudiante.isNotEmpty ? estudiante : 'Estudiante',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(estado, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
          ),
        ]),
        if (motivo.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(motivo, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
        if (fecha.isNotEmpty || hora.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.calendar_today, size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('$fecha${hora.isNotEmpty ? ' $hora' : ''}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
        ],
        if (estado == 'pendiente') ...[
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => onActualizar('confirmada'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.success,
                  side: const BorderSide(color: AppColors.success),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  minimumSize: Size.zero,
                ),
                child: const Text('Confirmar', style: TextStyle(fontSize: 12)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => onActualizar('cancelada'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  minimumSize: Size.zero,
                ),
                child: const Text('Cancelar', style: TextStyle(fontSize: 12)),
              ),
            ),
          ]),
        ],
      ]),
    );
  }

  Color _statusColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmada': return AppColors.success;
      case 'completada': return Colors.teal;
      case 'cancelada': return AppColors.error;
      default: return AppColors.warning;
    }
  }
}

// ─── Tab Carreras ─────────────────────────────────────────────────────────────

class _CarrerasTab extends StatelessWidget {
  const _CarrerasTab();

  @override
  Widget build(BuildContext context) {
    return const CareerListScreen();
  }
}

// ─── Tab Perfil Especialista ──────────────────────────────────────────────────

class _PerfilEspecialistaTab extends StatelessWidget {
  const _PerfilEspecialistaTab();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Center(
            child: Column(children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  _initials(user?.nombre, user?.apellido),
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${user?.nombre ?? ''} ${user?.apellido ?? ''}'.trim(),
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(user?.email ?? '',
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _rolLabel(user?.role),
                  style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          if ((user?.cedula ?? '').isNotEmpty || (user?.telefono ?? '').isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.person_outline, size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Información personal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ]),
                const SizedBox(height: 12),
                if ((user?.cedula ?? '').isNotEmpty)
                  _InfoRow(label: 'Cédula', value: user!.cedula!),
                if ((user?.telefono ?? '').isNotEmpty)
                  _InfoRow(label: 'Teléfono', value: user!.telefono!),
              ]),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await auth.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (_) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Cerrar sesión', style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  String _initials(String? n, String? a) {
    final ni = (n ?? '').isNotEmpty ? n![0].toUpperCase() : '';
    final ai = (a ?? '').isNotEmpty ? a![0].toUpperCase() : '';
    return '$ni$ai';
  }

  String _rolLabel(String? role) {
    switch ((role ?? '').toLowerCase()) {
      case 'orientador': case 'especialista': return 'Orientador';
      default: return role ?? 'Especialista';
    }
  }
}

// ─── Widgets compartidos ──────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ),
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
          width: 90,
          child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

class _CenteredError extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _CenteredError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 36),
          const SizedBox(height: 10),
          Text(error, textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 14),
          ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
        ]),
      ),
    );
  }
}
