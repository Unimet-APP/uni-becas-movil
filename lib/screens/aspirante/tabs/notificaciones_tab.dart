import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/aspirante_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/constants.dart';
import '../../../models/orientacion_vocacional.dart';

class NotificacionesTab extends StatelessWidget {
  const NotificacionesTab({super.key});

  IconData _getIconForType(String tipo) {
    switch (tipo) {
      case 'evento':
        return Icons.event;
      case 'anuncio':
        return Icons.campaign;
      case 'recordatorio':
        return Icons.alarm;
      case 'campana':
        return Icons.email;
      case 'mensaje':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String tipo) {
    switch (tipo) {
      case 'evento':
        return AppColors.info;
      case 'anuncio':
        return const Color(0xFF9C27B0);
      case 'recordatorio':
        return AppColors.warning;
      case 'campana':
        return AppColors.success;
      case 'mensaje':
        return const Color(0xFFE91E63);
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatFechaRelativa(String fecha) {
    try {
      final f = DateTime.parse(fecha);
      final ahora = DateTime.now();
      final diff = ahora.difference(f);

      if (diff.inMinutes < 60) {
        return diff.inMinutes <= 1
            ? 'Hace 1 minuto'
            : 'Hace ${diff.inMinutes} minutos';
      }
      if (diff.inHours < 24) {
        return diff.inHours == 1
            ? 'Hace 1 hora'
            : 'Hace ${diff.inHours} horas';
      }
      if (diff.inDays == 1) return 'Ayer';
      if (diff.inDays < 7) return 'Hace ${diff.inDays} dias';
      return '${f.day}/${f.month}/${f.year}';
    } catch (_) {
      return fecha;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AspiranteProvider, AuthProvider>(
      builder: (context, provider, authProvider, _) {
        return RefreshIndicator(
          onRefresh: () => provider.cargarNotificaciones(
              authProvider.user?.id ?? ''),
          child: CustomScrollView(
            slivers: [
              // Botón marcar todas como leídas
              if (provider.notificacionesNoLeidas > 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: TextButton.icon(
                      onPressed: () => provider.marcarTodasLeidas(),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Marcar todas como leidas'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                ),

              // Notificaciones
              if (provider.cargandoNotificaciones)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.notificaciones.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_off,
                            size: 64,
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        const Text('No tienes notificaciones',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        const Text(
                            'Los eventos y anuncios apareceran aqui.',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final notif = provider.notificaciones[index];
                        return _NotificacionCard(
                          notificacion: notif,
                          icon: _getIconForType(notif.tipo),
                          color: _getColorForType(notif.tipo),
                          fechaRelativa:
                              _formatFechaRelativa(notif.fechaCreacion),
                          onMarcarLeida: () =>
                              provider.marcarNotificacionLeida(notif.id),
                        );
                      },
                      childCount: provider.notificaciones.length,
                    ),
                  ),
                ),

              // Sección citas próximas
              if (provider.citasProximas.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Icon(Icons.event,
                            size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Proximas citas',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final cita = provider.citasProximas[index];
                        return _CitaCard(
                          cita: cita,
                          onConfirmar: cita.estado == 'pendiente'
                              ? () => provider.confirmarCita(cita.id)
                              : null,
                          onCancelar: cita.estado == 'pendiente'
                              ? () => provider.cancelarCita(cita.id)
                              : null,
                        );
                      },
                      childCount: provider.citasProximas.length > 3
                          ? 3
                          : provider.citasProximas.length,
                    ),
                  ),
                ),
              ],

              // Espacio final
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }
}

class _NotificacionCard extends StatelessWidget {
  final Notificacion notificacion;
  final IconData icon;
  final Color color;
  final String fechaRelativa;
  final VoidCallback onMarcarLeida;

  const _NotificacionCard({
    required this.notificacion,
    required this.icon,
    required this.color,
    required this.fechaRelativa,
    required this.onMarcarLeida,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: notificacion.leida
            ? Colors.white
            : AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color:
                notificacion.leida ? Colors.transparent : AppColors.primary,
            width: 3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(notificacion.titulo,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                      Text(fechaRelativa,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notificacion.contenido,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis),
                  if (!notificacion.leida) ...[
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onMarcarLeida,
                      child: const Text(
                        'Marcar como leida',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CitaCard extends StatelessWidget {
  final Cita cita;
  final VoidCallback? onConfirmar;
  final VoidCallback? onCancelar;

  const _CitaCard({
    required this.cita,
    this.onConfirmar,
    this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    // Parse fecha
    final parts = cita.fecha.split('-');
    String mes = '';
    String dia = '';
    if (parts.length == 3) {
      final dt = DateTime.tryParse(cita.fecha);
      if (dt != null) {
        const meses = [
          'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
          'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'
        ];
        mes = meses[dt.month - 1];
        dia = '${dt.day}';
      }
    }

    final isConfirmada = cita.estado == 'confirmada';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: isConfirmada ? AppColors.success : AppColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    // Date badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(mes,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary)),
                          Text(dia,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cita.motivoLabel,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          Text(
                              '${cita.hora} - ${cita.modalidadLabel}',
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
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isConfirmada
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isConfirmada ? 'Confirmada' : 'Pendiente',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isConfirmada
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
                if (onConfirmar != null || onCancelar != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (onConfirmar != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onConfirmar,
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Confirmar',
                                style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                      if (onConfirmar != null && onCancelar != null)
                        const SizedBox(width: 8),
                      if (onCancelar != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onCancelar,
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Cancelar',
                                style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(
                                  color: AppColors.error),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
