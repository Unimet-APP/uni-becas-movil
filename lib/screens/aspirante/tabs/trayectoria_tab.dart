import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/aspirante_provider.dart';
import '../../../utils/constants.dart';
import '../../../models/orientacion_vocacional.dart';

class TrayectoriaTab extends StatefulWidget {
  const TrayectoriaTab({super.key});

  @override
  State<TrayectoriaTab> createState() => _TrayectoriaTabState();
}

class _TrayectoriaTabState extends State<TrayectoriaTab> {
  final _materiaController = TextEditingController();
  final _notaController = TextEditingController();
  final _actividadController = TextEditingController();
  final _proyectoController = TextEditingController();

  // Inputs para materias por año/lapso
  final Map<String, TextEditingController> _materiaLapsoControllers = {};
  final Map<String, TextEditingController> _notaLapsoControllers = {};

  static const _gradoOpciones = ['4to ano', '5to ano'];

  @override
  void dispose() {
    _materiaController.dispose();
    _notaController.dispose();
    _actividadController.dispose();
    _proyectoController.dispose();
    for (final c in _materiaLapsoControllers.values) {
      c.dispose();
    }
    for (final c in _notaLapsoControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  int _getMaxAno(String? grado) {
    if (grado == null || grado.isEmpty) return 0;
    if (grado.contains('5')) return 5;
    if (grado.contains('4')) return 4;
    return 0;
  }

  TextEditingController _getMateriaLapsoCtrl(String key) {
    return _materiaLapsoControllers.putIfAbsent(
        key, () => TextEditingController());
  }

  TextEditingController _getNotaLapsoCtrl(String key) {
    return _notaLapsoControllers.putIfAbsent(
        key, () => TextEditingController());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AspiranteProvider>(
      builder: (context, provider, _) {
        if (provider.cargandoTrayectoria) {
          return const Center(child: CircularProgressIndicator());
        }

        final trayectoria = provider.trayectoria;

        return RefreshIndicator(
          onRefresh: () => provider.cargarTrayectoria(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.primaryLight.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.upload_file,
                            color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Perfil Academico (Bachillerato)',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary)),
                            SizedBox(height: 4),
                            Text(
                              'Completa tus datos de bachillerato para enriquecer tu perfil vocacional.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: AppColors.info),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Estos datos se usan en tu perfil de orientacion vocacional.',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.info),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Grado actual
                _buildSectionLabel('Grado actual'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _gradoOpciones.contains(trayectoria.gradoActual)
                      ? trayectoria.gradoActual
                      : null,
                  decoration: const InputDecoration(
                    hintText: 'Selecciona tu grado',
                    border: OutlineInputBorder(),
                  ),
                  items: _gradoOpciones
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (value) => provider.setGradoActual(value),
                ),
                const SizedBox(height: 20),

                // Materias destacadas
                _buildSectionLabel('Materias de mas interes con la nota'),
                const SizedBox(height: 4),
                const Text(
                  'Agrega las materias de mas interes para ti con su calificacion (nota 0-20).',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                _buildChipList(
                  items: trayectoria.materiasDestacadas ?? [],
                  onRemove: (i) => provider.removeMateriaDestacada(i),
                  color: AppColors.primary,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _materiaController,
                        decoration: const InputDecoration(
                          hintText: 'Ej: Matematicas, Fisica',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 70,
                      child: TextField(
                        controller: _notaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Nota',
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle,
                          color: AppColors.primary),
                      onPressed: () {
                        final mat = _materiaController.text.trim();
                        final nota = _notaController.text.trim();
                        if (mat.isNotEmpty) {
                          provider.addMateriaDestacada(
                              mat, nota.isEmpty ? '-' : nota);
                          _materiaController.clear();
                          _notaController.clear();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Actividades extracurriculares
                _buildSectionLabel('Actividades extracurriculares'),
                const SizedBox(height: 8),
                _buildChipList(
                  items:
                      trayectoria.actividadesExtracurriculares ?? [],
                  onRemove: (i) => provider.removeActividad(i),
                  color: AppColors.success,
                ),
                _buildAddItemRow(
                  controller: _actividadController,
                  hint: 'Ej: Deportes, Teatro, Voluntariado',
                  onAdd: () {
                    final val = _actividadController.text.trim();
                    if (val.isNotEmpty) {
                      provider.addActividad(val);
                      _actividadController.clear();
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Proyectos realizados
                _buildSectionLabel('Proyectos realizados'),
                const SizedBox(height: 8),
                _buildChipList(
                  items: trayectoria.proyectosRealizados ?? [],
                  onRemove: (i) => provider.removeProyecto(i),
                  color: const Color(0xFF9C27B0),
                ),
                _buildAddItemRow(
                  controller: _proyectoController,
                  hint: 'Ej: Feria cientifica 2024',
                  onAdd: () {
                    final val = _proyectoController.text.trim();
                    if (val.isNotEmpty) {
                      provider.addProyecto(val);
                      _proyectoController.clear();
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Materias por año y lapso
                _buildSectionLabel('Materias y notas por ano y lapso'),
                const SizedBox(height: 4),
                const Text(
                  'Agrega materias con su nota (0-20) por cada ano y lapso.',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                if (_getMaxAno(trayectoria.gradoActual) == 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: AppColors.info),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Selecciona tu grado actual arriba para ver los anos y lapsos.',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.info),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...List.generate(
                    _getMaxAno(trayectoria.gradoActual),
                    (anoIdx) {
                      final ano = '${anoIdx + 1}';
                      final labels = [
                        '1er ano',
                        '2do ano',
                        '3er ano',
                        '4to ano',
                        '5to ano'
                      ];
                      return _buildAnoCard(
                        provider: provider,
                        ano: ano,
                        label: labels[anoIdx],
                        trayectoria: trayectoria,
                      );
                    },
                  ),

                const SizedBox(height: 24),

                // Botón guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: provider.guardandoTrayectoria
                        ? null
                        : () async {
                            final ok = await provider.guardarTrayectoria();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok
                                    ? 'Trayectoria guardada correctamente'
                                    : 'Error al guardar la trayectoria'),
                                backgroundColor:
                                    ok ? AppColors.success : AppColors.error,
                              ),
                            );
                          },
                    icon: provider.guardandoTrayectoria
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save),
                    label: Text(provider.guardandoTrayectoria
                        ? 'Guardando...'
                        : 'Guardar trayectoria academica'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildChipList({
    required List<String> items,
    required void Function(int) onRemove,
    required Color color,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: items.asMap().entries.map((entry) {
          return Chip(
            label: Text(entry.value,
                style: TextStyle(fontSize: 12, color: color)),
            deleteIcon: Icon(Icons.close, size: 16, color: color),
            onDeleted: () => onRemove(entry.key),
            backgroundColor: color.withValues(alpha: 0.1),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
            visualDensity: VisualDensity.compact,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddItemRow({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onAdd,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hint, isDense: true),
            onSubmitted: (_) => onAdd(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle, color: AppColors.primary),
          onPressed: onAdd,
        ),
      ],
    );
  }

  Widget _buildAnoCard({
    required AspiranteProvider provider,
    required String ano,
    required String label,
    required TrayectoriaBody trayectoria,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          ...['1', '2', '3'].map((lapso) {
            final key = '$ano-$lapso';
            final materias =
                trayectoria.materiasPorAnoLapso?[ano]?[lapso] ?? [];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lapso $lapso',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary)),
                  if (materias.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ...materias.asMap().entries.map((entry) {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${entry.value.materia}: ${entry.value.nota}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => provider.removeMateriaLapso(
                                ano, lapso, entry.key),
                            child: const Icon(Icons.close,
                                size: 14, color: AppColors.error),
                          ),
                        ],
                      );
                    }),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _getMateriaLapsoCtrl(key),
                          decoration: const InputDecoration(
                            hintText: 'Materia',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 55,
                        child: TextField(
                          controller: _getNotaLapsoCtrl(key),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Nota',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          final mat =
                              _getMateriaLapsoCtrl(key).text.trim();
                          final notaStr =
                              _getNotaLapsoCtrl(key).text.trim();
                          final nota =
                              double.tryParse(notaStr) ?? 0;
                          if (mat.isNotEmpty && nota >= 0 && nota <= 20) {
                            provider.addMateriaLapso(
                                ano, lapso, mat, nota);
                            _getMateriaLapsoCtrl(key).clear();
                            _getNotaLapsoCtrl(key).clear();
                          }
                        },
                        child: const Icon(Icons.add_circle,
                            color: AppColors.primary, size: 24),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
