import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// Barra de progreso reutilizable para Ronda1, Ronda2 y TestICO.
class TestProgressBar extends StatelessWidget {
  final double progreso;
  final int actual;
  final int total;

  const TestProgressBar({
    super.key,
    required this.progreso,
    required this.actual,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pregunta $actual de $total',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              Text(
                '${(progreso * 100).round()}%',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progreso,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra de navegación inferior reutilizable (Anterior / Siguiente / Finalizar).
class TestNavBar extends StatelessWidget {
  final VoidCallback? onAnterior;
  final VoidCallback? onSiguiente;
  final bool esUltima;
  final bool enviando;
  final String? labelFinalizar;

  const TestNavBar({
    super.key,
    this.onAnterior,
    this.onSiguiente,
    required this.esUltima,
    required this.enviando,
    this.labelFinalizar,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: onAnterior,
              icon: const Icon(Icons.chevron_left, size: 18),
              label: const Text('Anterior'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: enviando ? null : onSiguiente,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: enviando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      esUltima ? (labelFinalizar ?? 'Finalizar') : 'Siguiente →',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón de Sí/No reutilizable para tests.
class SiNoButton extends StatelessWidget {
  final String label;
  final bool value;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const SiNoButton({
    super.key,
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

/// Etiqueta de ronda reutilizable.
class RondaLabel extends StatelessWidget {
  final String label;
  final Color color;
  const RondaLabel({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// Chip de opción de respuesta (radio) reutilizable.
class OpcionRadio extends StatelessWidget {
  final String opcion;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const OpcionRadio({
    super.key,
    required this.opcion,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? accentColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? accentColor : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? accentColor : Colors.grey.shade400,
                  width: 2,
                ),
                color: selected ? accentColor : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                opcion,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
