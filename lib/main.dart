import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/supervisor_provider.dart';
import 'providers/student_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/supervisor/supervisor_dashboard.dart';
import 'screens/student/module_selection_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => SupervisorProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UNIMET Becas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Configuración de transiciones de página personalizadas
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) {
        // Manejo de deep links para reset password
        if (settings.name != null && settings.name!.startsWith('/reset-password')) {
          final uri = Uri.parse(settings.name!);
          final token = uri.queryParameters['token'];

          if (token != null && token.isNotEmpty) {
            return MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(token: token),
            );
          }
        }
        return null;
      },
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoggedIn && authProvider.user != null) {
            final role = authProvider.user!.role.toLowerCase();

            print('👤 User role: $role');

            // Verificar firstLogin
            if (authProvider.user!.firstLogin == true) {
              // TODO: Implementar pantalla de cambio de contraseña obligatorio
              print('⚠️ First login - debe cambiar contraseña');
            }

            switch (role) {
              case Roles.admin:
                return const AdminDashboard();
              case Roles.supervisor:
              case Roles.supervisorLaboral:
                return const SupervisorDashboard();
              case Roles.student:
                // Los estudiantes van primero a ModuleSelectionScreen
                // Esta pantalla verificará si tienen beca activa o postulaciones
                return const ModuleSelectionScreen();
              case Roles.mentor:
                return const SupervisorDashboard(); // Usar mismo dashboard por ahora
              case Roles.directorArea:
              case Roles.capitalHumano:
                return const AdminDashboard(); // Usar admin dashboard por ahora
              default:
                print('⚠️ Unknown role: $role, redirecting to welcome');
                return const WelcomeScreen();
            }
          }
          return const WelcomeScreen();
        },
      ),
    );
  }
}
