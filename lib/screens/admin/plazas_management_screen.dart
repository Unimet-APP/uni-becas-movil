import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../utils/constants.dart';
import 'assign_becario_screen.dart';

class PlazasManagementScreen extends StatefulWidget {
  const PlazasManagementScreen({super.key});

  @override
  State<PlazasManagementScreen> createState() => _PlazasManagementScreenState();
}

class _PlazasManagementScreenState extends State<PlazasManagementScreen> {
  String? _selectedDepartamento;
  String? _selectedEstado;

  @override
  void initState() {
    super.initState();
    _loadPlazas();
  }

  Future<void> _loadPlazas() async {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    await provider.loadPlazas(
      departamento: _selectedDepartamento,
      estado: _selectedEstado,
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestionar Plazas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPlazas,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedEstado,
                        decoration: InputDecoration(
                          labelText: 'Estado',
                          prefixIcon: const Icon(Icons.filter_list),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Todos')),
                          DropdownMenuItem(
                              value: 'Activa', child: Text('Activa')),
                          DropdownMenuItem(
                              value: 'Inactiva', child: Text('Inactiva')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedEstado = value;
                          });
                          _loadPlazas();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDepartamento,
                        decoration: InputDecoration(
                          labelText: 'Departamento',
                          prefixIcon: const Icon(Icons.business),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Todos')),
                          DropdownMenuItem(
                              value: 'Computación',
                              child: Text('Computación')),
                          DropdownMenuItem(
                              value: 'Matemáticas',
                              child: Text('Matemáticas')),
                          DropdownMenuItem(
                              value: 'Física', child: Text('Física')),
                          DropdownMenuItem(
                              value: 'Química', child: Text('Química')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedDepartamento = value;
                          });
                          _loadPlazas();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de plazas
          Expanded(
            child: adminProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : adminProvider.plazas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off,
                              size: 64,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay plazas disponibles',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPlazas,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: adminProvider.plazas.length,
                          itemBuilder: (context, index) {
                            final plaza = adminProvider.plazas[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.location_on,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                plaza.materia,
                                                style: AppTextStyles.heading3,
                                              ),
                                              Text(
                                                plaza.codigo,
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _StatusChip(
                                          label: plaza.estado,
                                          color: plaza.isActiva
                                              ? AppColors.success
                                              : AppColors.error,
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    Row(
                                      children: [
                                        const Icon(Icons.business,
                                            size: 16,
                                            color: AppColors.textSecondary),
                                        const SizedBox(width: 8),
                                        Text(
                                          plaza.departamento,
                                          style: AppTextStyles.bodyMedium,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.people,
                                            size: 16,
                                            color: AppColors.textSecondary),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Ocupación: ${plaza.ocupadas}/${plaza.capacidad}',
                                          style: AppTextStyles.bodyMedium,
                                        ),
                                        const SizedBox(width: 8),
                                        if (plaza.isDisponible)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.success
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${plaza.plazasDisponibles} disponible${plaza.plazasDisponibles > 1 ? 's' : ''}',
                                              style:
                                                  AppTextStyles.bodySmall.copyWith(
                                                color: AppColors.success,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Horarios:',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ...plaza.horario.take(2).map(
                                          (h) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.calendar_today,
                                                    size: 14,
                                                    color:
                                                        AppColors.textSecondary),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${h.dia} ${h.horaInicio}-${h.horaFin}',
                                                  style:
                                                      AppTextStyles.bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    if (plaza.horario.length > 2)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 22),
                                        child: Text(
                                          '+${plaza.horario.length - 2} más',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                            color: AppColors.textSecondary,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: plaza.isDisponible
                                            ? () async {
                                                final result =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AssignBecarioScreen(
                                                            plaza: plaza),
                                                  ),
                                                );
                                                if (result == true) {
                                                  _loadPlazas();
                                                }
                                              }
                                            : null,
                                        icon: const Icon(Icons.person_add,
                                            size: 18),
                                        label: const Text('Asignar Estudiante'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
