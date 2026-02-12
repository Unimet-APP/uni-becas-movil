import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/aspirante_provider.dart';
import '../../../utils/constants.dart';
import '../../../models/orientacion_vocacional.dart';

class PerfilTab extends StatelessWidget {
  const PerfilTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, AspiranteProvider>(
      builder: (context, authProvider, aspiranteProvider, _) {
        final user = authProvider.user;

        if (aspiranteProvider.cargandoPerfil) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            await aspiranteProvider.cargarPerfilYHistorial();
            await aspiranteProvider.cargarTrayectoria();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile card
                _ProfileCard(
                  nombre: user?.fullName ?? 'Usuario',
                  role: user?.role ?? 'aspirante',
                  email: user?.email ?? '',
                  testsCompletados: aspiranteProvider.testsCompletados,
                  totalRecomendaciones:
                      aspiranteProvider.totalRecomendaciones,
                ),
                const SizedBox(height: 16),

                // Resumen vocacional
                _ResumenVocacionalCard(
                  perfilDominante: aspiranteProvider.perfilDominante,
                  codigoHolland: aspiranteProvider.codigoHolland,
                ),
                const SizedBox(height: 16),

                // Info de contacto
                _ContactInfoCard(
                  email: user?.email ?? '',
                  telefono: user?.telefono,
                  cedula: user?.cedula,
                  activo: user?.activo ?? false,
                  emailVerified: user?.emailVerified ?? false,
                ),
                const SizedBox(height: 16),

                // Mi Trayectoria - Tests completados
                _buildSectionTitle('Mi Trayectoria'),
                const SizedBox(height: 8),
                _TestsSection(
                  historial: aspiranteProvider.historial,
                  sesionesEnProgreso:
                      aspiranteProvider.sesionesEnProgreso,
                ),
                const SizedBox(height: 16),

                // Resumen académico
                _AcademicSummary(
                    trayectoria: aspiranteProvider.trayectoria),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String nombre;
  final String role;
  final String email;
  final int testsCompletados;
  final int totalRecomendaciones;

  const _ProfileCard({
    required this.nombre,
    required this.role,
    required this.email,
    required this.testsCompletados,
    required this.totalRecomendaciones,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Gradient top bar
          Container(
            height: 6,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.person,
                      color: AppColors.primary, size: 32),
                ),
                const SizedBox(height: 12),
                Text(nombre,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  '${role[0].toUpperCase()}${role.substring(1)}',
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),

                // Stats row
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                          value: '$testsCompletados',
                          label: 'Tests'),
                      Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey.shade200),
                      _StatItem(
                          value:
                              totalRecomendaciones > 0
                                  ? '$totalRecomendaciones'
                                  : '-',
                          label: 'Recomendaciones'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                letterSpacing: 0.5)),
      ],
    );
  }
}

class _ResumenVocacionalCard extends StatelessWidget {
  final String? perfilDominante;
  final String? codigoHolland;

  const _ResumenVocacionalCard({
    this.perfilDominante,
    this.codigoHolland,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 3,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.6),
                  AppColors.primaryLight.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Row(
            children: [
              Icon(Icons.auto_awesome,
                  size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Resumen Vocacional',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          if (perfilDominante != null || codigoHolland != null) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (perfilDominante != null)
                  _badge(perfilDominante!, AppColors.primary),
                if (codigoHolland != null)
                  _badge(
                      'Codigo: $codigoHolland', const Color(0xFFEA580C)),
              ],
            ),
          ] else
            const Text(
              'Completa un test de orientacion para ver tu perfil dominante y codigo Holland.',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  final String email;
  final String? telefono;
  final String? cedula;
  final bool activo;
  final bool emailVerified;

  const _ContactInfoCard({
    required this.email,
    this.telefono,
    this.cedula,
    required this.activo,
    required this.emailVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline,
                  size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Informacion de Contacto',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('Correo Electronico', email),
          _infoRow('Telefono', telefono ?? 'No disponible'),
          _infoRow('Cedula', cedula ?? 'No disponible'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: activo
                  ? AppColors.success.withValues(alpha: 0.08)
                  : AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Estado de la cuenta:',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: activo ? AppColors.success : AppColors.warning,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    activo ? 'Activa' : 'Pendiente',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          if (!emailVerified) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber,
                      size: 16, color: AppColors.warning),
                  SizedBox(width: 8),
                  Text('Correo no verificado',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.warning)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _TestsSection extends StatelessWidget {
  final List<HistorialItem> historial;
  final List<HistorialItem> sesionesEnProgreso;

  const _TestsSection({
    required this.historial,
    required this.sesionesEnProgreso,
  });

  @override
  Widget build(BuildContext context) {
    if (historial.isEmpty && sesionesEnProgreso.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.psychology,
                size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text('No hay tests completados',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            const Text(
              'Completa un test de orientacion para ver tus resultados aqui.',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En progreso
        if (sesionesEnProgreso.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.access_time,
                    size: 16, color: Color(0xFFF59E0B)),
                SizedBox(width: 6),
                Text('En progreso',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
          ...sesionesEnProgreso.map((s) => _buildTestCard(s, false)),
          const SizedBox(height: 12),
        ],

        // Completados
        if (historial.isNotEmpty) ...[
          if (sesionesEnProgreso.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Completados',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
            ),
          ...historial.map((s) => _buildTestCard(s, true)),
        ],
      ],
    );
  }

  Widget _buildTestCard(HistorialItem sesion, bool completed) {
    final isIco = sesion.isIco;
    final color = isIco ? AppColors.info : AppColors.primary;
    final fecha = sesion.fechaFin ??
        sesion.fechaCompletada ??
        sesion.fechaInicio ??
        '';
    String fechaDisplay = '-';
    if (fecha.isNotEmpty) {
      try {
        final dt = DateTime.parse(fecha);
        fechaDisplay =
            '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      } catch (_) {
        fechaDisplay = fecha;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(sesion.displayName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(fechaDisplay,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                  ],
                ),
                if (sesion.perfilDominante != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Dominante: ${sesion.perfilDominante}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: color),
                    ),
                  ),
                ],
                if (!completed) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('En progreso',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFD97706))),
                  ),
                ],
              ],
            ),
          ),
          if (completed)
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }
}

class _AcademicSummary extends StatelessWidget {
  final TrayectoriaBody trayectoria;

  const _AcademicSummary({required this.trayectoria});

  @override
  Widget build(BuildContext context) {
    final hasData = trayectoria.gradoActual != null ||
        (trayectoria.materiasDestacadas?.isNotEmpty ?? false) ||
        (trayectoria.actividadesExtracurriculares?.isNotEmpty ?? false) ||
        (trayectoria.proyectosRealizados?.isNotEmpty ?? false);

    if (!hasData) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.description,
                size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text('Sin Historial Academico',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            const Text(
              'Completa tu trayectoria academica en la pestana Trayectoria.',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.school, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Resumen Academico',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          if (trayectoria.gradoActual != null)
            _summaryItem(Icons.school, 'Grado: ${trayectoria.gradoActual}',
                AppColors.primary),
          if (trayectoria.materiasDestacadas?.isNotEmpty ?? false)
            _summaryItem(
                Icons.menu_book,
                '${trayectoria.materiasDestacadas!.length} materia(s) destacada(s)',
                const Color(0xFFEA580C)),
          if (trayectoria.actividadesExtracurriculares?.isNotEmpty ??
              false)
            _summaryItem(
                Icons.group,
                '${trayectoria.actividadesExtracurriculares!.length} actividad(es)',
                AppColors.success),
          if (trayectoria.proyectosRealizados?.isNotEmpty ?? false)
            _summaryItem(
                Icons.flag,
                '${trayectoria.proyectosRealizados!.length} proyecto(s)',
                const Color(0xFF9C27B0)),
        ],
      ),
    );
  }

  Widget _summaryItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(text,
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
