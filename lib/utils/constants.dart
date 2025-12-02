import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryDark = Color(0xFFE55A2B);
  static const Color primaryLight = Color(0xFFFF8C66);
  static const Color white = Colors.white;
  static const Color background = Color(0xFFFAFAFA);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

class Roles {
  // Roles del backend (en lowercase)
  static const String admin = 'admin';
  static const String supervisor = 'supervisor';
  static const String supervisorLaboral = 'supervisor-laboral';
  static const String student = 'estudiante';
  static const String aspirant = 'aspirante';
  static const String mentor = 'mentor';
  static const String directorArea = 'director-area';
  static const String capitalHumano = 'capital-humano';

  // Nombres para display
  static const String adminDisplay = 'Administrador';
  static const String supervisorDisplay = 'Supervisor Laboral';
  static const String studentDisplay = 'Estudiante';
}

class EstadoBeca {
  static const String activa = 'Activa';
  static const String suspendida = 'Suspendida';
  static const String culminada = 'Culminada';
  static const String cancelada = 'Cancelada';
}
