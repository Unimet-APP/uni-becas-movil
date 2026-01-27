import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/postulacion_service.dart';
import '../../services/student_service.dart';
import '../../utils/constants.dart';
import '../postulaciones/postulaciones_main_screen.dart';
import '../welcome_screen.dart';
import 'student_dashboard.dart';

class ModuleSelectionScreen extends StatefulWidget {
  final bool isNewRegistration;
  final String? userEmail;

  const ModuleSelectionScreen({
    super.key,
    this.isNewRegistration = false,
    this.userEmail,
  });

  @override
  State<ModuleSelectionScreen> createState() => _ModuleSelectionScreenState();
}

class _ModuleSelectionScreenState extends State<ModuleSelectionScreen> {
  final PostulacionService _postulacionService = PostulacionService();
  final StudentService _studentService = StudentService();
  List<Map<String, dynamic>> _postulaciones = [];
  bool _isLoadingPostulaciones = true;
  bool _hasError = false;
  bool _hasBecaActiva = false;
  bool _isCheckingBeca = true;

  @override
  void initState() {
    super.initState();
    _verificarBecaActiva();

    // Verificar postulaciones usando el email del widget o del usuario logueado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final email = widget.userEmail ?? authProvider.user?.email;

      if (email != null) {
        _verificarPostulacionesConEmail(email);
      } else {
        if (mounted) {
          setState(() {
            _isLoadingPostulaciones = false;
          });
        }
      }
    });
  }

  Future<void> _verificarBecaActiva() async {
    try {
      if (!mounted) return;
      setState(() {
        _isCheckingBeca = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        final becario = await _studentService.getMyBecario(authProvider.user!.id);
        if (!mounted) return;
        setState(() {
          _hasBecaActiva = becario != null;
          _isCheckingBeca = false;
        });

        // Si hay beca activa de tipo "Ayudantía", redirigir al dashboard
        if (becario != null) {
          final tipoBecaLower = becario.tipoBeca.toLowerCase().trim();
          // Normalizar: quitar tildes y espacios para comparar
          final tipoBecaNormalizado = tipoBecaLower
              .replaceAll('á', 'a')
              .replaceAll('é', 'e')
              .replaceAll('í', 'i')
              .replaceAll('ó', 'o')
              .replaceAll('ú', 'u');
          if (tipoBecaNormalizado == 'ayudantia' || tipoBecaLower == 'ayudantía') {
            _redirigirAlDashboard();
          }
        }
      } else {
        if (!mounted) return;
        setState(() {
          _hasBecaActiva = false;
          _isCheckingBeca = false;
        });
      }
    } catch (e) {
      // Si hay error (especialmente 404), no hay beca activa
      print('⚠️ Error verificando beca activa: $e');
      final errorMessage = e.toString().toLowerCase();
      final hasBecaError = errorMessage.contains('no se encontró un registro de beca activo') ||
          errorMessage.contains('registro de beca activo');

      if (!mounted) return;
      setState(() {
        _hasBecaActiva = !hasBecaError;
        _isCheckingBeca = false;
      });
    }
  }

  Future<void> _verificarPostulacionesConEmail(String email) async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoadingPostulaciones = true;
        _hasError = false;
      });

      final postulaciones = await _postulacionService
          .verificarPostulacionesPorEmail(email);

      if (!mounted) return;
      setState(() {
        _postulaciones = postulaciones;
        _isLoadingPostulaciones = false;
      });

      // Si hay postulaciones aprobadas, verificar beca activa
      final tienePostulacionAprobada = postulaciones.any((p) {
        final estado = (p['estado'] ?? '').toString().toLowerCase();
        return estado == 'aprobada' || estado == 'aprobado';
      });
      if (tienePostulacionAprobada && !_hasBecaActiva) {
        // Si hay postulación aprobada pero no beca activa aún, verificar de nuevo
        _verificarBecaActiva();
      }

      // Verificar si hay postulación aprobada de tipo "Ayudantía"
      final tieneAyudantiaAprobada = postulaciones.any((p) {
        final estado = (p['estado'] ?? '').toString().toLowerCase().trim();
        final tipoBeca = (p['tipoBeca'] ?? '').toString().toLowerCase().trim();
        // Normalizar: quitar tildes para comparar
        final tipoBecaNormalizado = tipoBeca
            .replaceAll('á', 'a')
            .replaceAll('é', 'e')
            .replaceAll('í', 'i')
            .replaceAll('ó', 'o')
            .replaceAll('ú', 'u');
        return (estado == 'aprobada' || estado == 'aprobado') &&
               (tipoBecaNormalizado == 'ayudantia' || tipoBeca == 'ayudantía');
      });

      // Si hay postulación aprobada de Ayudantía, redirigir al dashboard
      if (tieneAyudantiaAprobada) {
        // Esperar un momento para que la UI se actualice antes de redirigir
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _redirigirAlDashboard();
          }
        });
      }
    } catch (e) {
      print('Error verificando postulaciones: $e');
      // Si es 404, significa que no hay postulaciones (es normal)
      final errorMessage = e.toString().toLowerCase();
      final is404 = errorMessage.contains('404') ||
                    errorMessage.contains('not found') ||
                    e.toString().contains('404');

      if (!mounted) return;
      setState(() {
        _isLoadingPostulaciones = false;
        _hasError = is404 ? false : true; // 404 no es un error, es que no hay postulaciones
        if (is404) {
          _postulaciones = []; // Lista vacía para mostrar opciones de postulación
        }
      });
    }
  }
  
  void _redirigirAlDashboard() {
    if (!mounted) return;
    
    print('🔄 Redirigiendo al dashboard - Becario con Ayudantía aprobada');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const StudentDashboard(),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobada':
      case 'aprobado':
        return AppColors.success;
      case 'rechazada':
      case 'rechazado':
        return AppColors.error;
      case 'pendiente':
      default:
        return AppColors.warning;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobada':
      case 'aprobado':
        return Icons.check_circle;
      case 'rechazada':
      case 'rechazado':
        return Icons.cancel;
      case 'pendiente':
      default:
        return Icons.access_time;
    }
  }

  bool _tienePostulacionAprobada() {
    return _postulaciones.any((p) {
      final estado = (p['estado'] ?? '').toString().toLowerCase();
      return estado == 'aprobada' || estado == 'aprobado';
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Bienvenido',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro que deseas salir?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context); // Cerrar el diálogo primero
                        await authProvider.logout();
                        if (context.mounted) {
                          // Navegar a la pantalla de bienvenida limpiando todo el stack
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const WelcomeScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      child: const Text('Salir'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mensaje de bienvenida para nuevos registros
            if (widget.isNewRegistration) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withOpacity(0.1),
                      AppColors.success.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.success,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '¡Registro Exitoso!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bienvenido ${authProvider.user?.nombre ?? ""}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Estado de postulaciones
            if (_isLoadingPostulaciones)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Verificando postulaciones...',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_postulaciones.isNotEmpty) ...[
              // Si hay postulaciones, mostrar su estado
              const Text(
                'Tus Postulaciones',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _postulaciones.length,
                itemBuilder: (context, index) {
                  final postulacion = _postulaciones[index];
                  final estado = postulacion['estado'] ?? 'pendiente';
                  final tipoBeca = postulacion['tipoBeca'] ?? 'N/A';
                  final fechaPostulacion =
                      postulacion['fechaPostulacion'] ?? 'N/A';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getEstadoColor(estado).withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getEstadoColor(estado).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getEstadoIcon(estado),
                              color: _getEstadoColor(estado),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tipoBeca,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Estado: $estado',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _getEstadoColor(estado),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Fecha: $fechaPostulacion',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ] else if (!_hasError && !_isLoadingPostulaciones) ...[
              // Si no hay postulaciones (404 o lista vacía), mostrar mensaje para postularse
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.info,
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 32,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'No tienes postulaciones activas. ¡Explora las becas disponibles y postúlate!',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Módulos disponibles
            const Text(
              'Módulos Disponibles',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Módulo de Gestión de Becas (siempre visible para postularse)
            _buildModuleCard(
              context: context,
              title: 'Gestión de Becas',
              description:
                  'Explora programas de becas, postúlate y gestiona tus solicitudes',
              icon: Icons.school,
              gradientColors: [AppColors.primary, AppColors.primaryLight],
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PostulacionesMainScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
