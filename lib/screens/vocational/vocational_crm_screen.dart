import 'package:flutter/material.dart';

import '../../models/vocational_models.dart';
import '../../services/vocational_service.dart';
import '../../utils/constants.dart';

class VocationalCrmScreen extends StatefulWidget {
  const VocationalCrmScreen({super.key});

  @override
  State<VocationalCrmScreen> createState() => _VocationalCrmScreenState();
}

class _VocationalCrmScreenState extends State<VocationalCrmScreen> {
  final VocationalService _service = VocationalService();
  List<VocationalNotification> _notifs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await _service.obtenerNotificaciones(limit: 30);
      if (mounted) setState(() { _notifs = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _marcarLeida(VocationalNotification n) async {
    if (n.leido) return;
    try {
      await _service.marcarComoLeida(n.id);
      if (mounted) {
        setState(() {
          final i = _notifs.indexWhere((x) => x.id == n.id);
          if (i >= 0) {
            _notifs[i] = VocationalNotification(
              id: n.id, tipo: n.tipo, titulo: n.titulo,
              mensaje: n.mensaje, leido: true, fecha: n.fecha,
              urlAccion: n.urlAccion,
            );
          }
        });
      }
    } catch (_) {}
  }

  int get _sinLeer => _notifs.where((n) => !n.leido).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Text('Novedades'),
          if (_sinLeer > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$_sinLeer',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargar,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(error: _error!, onRetry: _cargar)
              : _notifs.isEmpty
                  ? const _EmptyView()
                  : RefreshIndicator(
                      onRefresh: _cargar,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) => _NotifCard(
                          notif: _notifs[i],
                          onTap: () => _marcarLeida(_notifs[i]),
                        ),
                      ),
                    ),
    );
  }
}

// ─── Tarjeta de notificación ──────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final VocationalNotification notif;
  final VoidCallback onTap;
  const _NotifCard({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _colorForTipo(notif.tipo);
    final bg = _bgForTipo(notif.tipo);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.leido ? Colors.white : bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notif.leido ? Colors.grey.shade200 : color.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_iconForTipo(notif.tipo), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(notif.titulo,
                      style: TextStyle(
                          fontWeight: notif.leido ? FontWeight.w500 : FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary)),
                ),
                if (!notif.leido)
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
              ]),
              const SizedBox(height: 4),
              Text(notif.mensaje,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(_formatFecha(notif.fecha),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                if ((notif.urlAccion ?? '').isNotEmpty) ...[
                  const Spacer(),
                  Text('Ver más →',
                      style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                ],
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─── Vistas de estado ─────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.notifications_none, size: 56, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        const Text('No tienes notificaciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('Aquí aparecerán eventos, anuncios y recordatorios.',
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
          const Text('Error al cargar notificaciones',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
