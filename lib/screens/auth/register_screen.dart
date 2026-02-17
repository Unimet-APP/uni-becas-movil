import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../student/module_selection_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _carreraController = TextEditingController();
  final _departamentoController = TextEditingController();
  final _cargoController = TextEditingController();

  String _selectedRole = 'estudiante';
  int? _trimestre;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _tipoCedula = 'V';
  String? _selectedCarrera;
  bool _carreraPersonalizada = false;

  // Lista de carreras disponibles
  final List<String> _carreras = [
    'Ingeniería Civil',
    'Ingeniería Eléctrica',
    'Ingeniería Mecánica',
    'Ingeniería Química',
    'Ingeniería de Sistemas',
    'Ingeniería de Producción',
    'Ciencias Administrativas',
    'Contaduría Pública',
    'Economía Empresarial',
    'Psicología',
    'Matemáticas Industriales',
    'Derecho',
    'Estudios Liberales',
    'Comunicación Social y Empresarial',
    'Educación',
    'Idiomas Modernos',
    'Turismo Sostenible',
    'Otra',
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Limpiar errores previos al entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();
    });
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          // Limpiar errores cuando se sale de la pantalla
          authProvider.clearError();
        }
      },
      child: Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Diseño de fondo moderno con líneas naranjas finitas
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
            painter: ModernLinesPainter(),
          ),

          // Contenido del registro
          SafeArea(
            child: Column(
              children: [
                // Botón de regresar y título
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.primary, size: 28),
                        onPressed: () {
                          // Limpiar errores antes de salir
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          authProvider.clearError();
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 8),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Crear Cuenta',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Completa tu información',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Formulario
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sección: Información de Cuenta
                              _buildSectionHeader(
                                icon: Icons.account_circle_outlined,
                                title: 'Información de Cuenta',
                              ),
                              const SizedBox(height: 20),
                              _buildDropdown(
                                value: _selectedRole,
                                label: 'Tipo de cuenta',
                                icon: Icons.person_pin_outlined,
                                items: const [
                                  DropdownMenuItem(value: 'estudiante', child: Text('Usuario')),
                                  DropdownMenuItem(value: 'supervisor', child: Text('Supervisor')),
                                  DropdownMenuItem(value: 'aspirante', child: Text('Aspirante')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRole = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: 32),

                              // Campos para Estudiante
                              if (_selectedRole == 'estudiante') ...[
                                _buildTextField(
                                  controller: _nombreController,
                                  label: 'Nombre',
                                  icon: Icons.person,
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'Ingresa tu nombre' : null,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _apellidoController,
                                  label: 'Apellido',
                                  icon: Icons.person_outline,
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'Ingresa tu apellido' : null,
                                ),
                                const SizedBox(height: 16),
                                // Cédula
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: DropdownButtonFormField<String>(
                                          initialValue: _tipoCedula,
                                          decoration: InputDecoration(
                                            labelText: 'Tipo',
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                          items: const [
                                            DropdownMenuItem(value: 'V', child: Text('V')),
                                            DropdownMenuItem(value: 'E', child: Text('E')),
                                          ],
                                          onChanged: (value) {
                                            setState(() => _tipoCedula = value!);
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _cedulaController,
                                        label: 'Cédula',
                                        icon: Icons.badge,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value?.isEmpty ?? true) return 'Ingresa tu cédula';
                                          if (!RegExp(r'^\d{7,8}$').hasMatch(value!)) {
                                            return 'Ingresa 7 u 8 dígitos';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _telefonoController,
                                  label: 'Teléfono',
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'Ingresa tu teléfono' : null,
                                ),
                                const SizedBox(height: 32),
                                // Carrera
                                _buildDropdown<String>(
                                  value: _selectedCarrera,
                                  label: 'Carrera',
                                  icon: Icons.school,
                                  items: _carreras.map((carrera) {
                                    return DropdownMenuItem(
                                      value: carrera,
                                      child: Text(carrera),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCarrera = value;
                                      if (value == 'Otra') {
                                        _carreraPersonalizada = true;
                                        _carreraController.clear();
                                      } else {
                                        _carreraPersonalizada = false;
                                        _carreraController.text = value ?? '';
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                // Campo de texto para carrera personalizada
                                if (_carreraPersonalizada) ...[
                                  _buildTextField(
                                    controller: _carreraController,
                                    label: 'Escribe tu carrera',
                                    icon: Icons.edit,
                                    validator: (value) =>
                                        value?.isEmpty ?? true ? 'Ingresa tu carrera' : null,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                // Trimestre (opcional)
                                _buildDropdown<int>(
                                  value: _trimestre,
                                  label: 'Trimestre (Opcional)',
                                  icon: Icons.calendar_month,
                                  items: [
                                    const DropdownMenuItem<int>(
                                      value: null,
                                      child: Text('No especificar'),
                                    ),
                                    ...List.generate(
                                      12,
                                      (index) => DropdownMenuItem(
                                        value: index + 1,
                                        child: Text('Trimestre ${index + 1}'),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _trimestre = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Correo Electrónico',
                                  icon: Icons.email,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) return 'Ingresa tu correo';
                                    if (!value!.contains('@')) return 'Correo inválido';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildPasswordField(
                                  controller: _passwordController,
                                  obscurePassword: _obscurePassword,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) return 'Ingresa tu contraseña';
                                    if (value!.length < 6) return 'Mínimo 6 caracteres';
                                    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])').hasMatch(value)) {
                                      return 'Debe incluir mayúscula, minúscula, número y símbolo';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildPasswordField(
                                  controller: _confirmPasswordController,
                                  obscurePassword: _obscureConfirmPassword,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                  label: 'Confirmar Contraseña',
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) return 'Confirma tu contraseña';
                                    if (value != _passwordController.text) {
                                      return 'Las contraseñas no coinciden';
                                    }
                                    return null;
                                  },
                                ),
                              ],

                              // Campos para Aspirante
                              if (_selectedRole == 'aspirante') ...[
                                _buildTextField(
                                  controller: _nombreController,
                                  label: 'Nombre',
                                  icon: Icons.person,
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'Ingresa tu nombre' : null,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _apellidoController,
                                  label: 'Apellido',
                                  icon: Icons.person_outline,
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'Ingresa tu apellido' : null,
                                ),
                                const SizedBox(height: 16),
                                // Cédula
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: DropdownButtonFormField<String>(
                                          initialValue: _tipoCedula,
                                          decoration: InputDecoration(
                                            labelText: 'Tipo',
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                          items: const [
                                            DropdownMenuItem(value: 'V', child: Text('V')),
                                            DropdownMenuItem(value: 'E', child: Text('E')),
                                          ],
                                          onChanged: (value) {
                                            setState(() => _tipoCedula = value!);
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _cedulaController,
                                        label: 'Cédula',
                                        icon: Icons.badge,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value?.isEmpty ?? true) return 'Ingresa tu cédula';
                                          if (!RegExp(r'^\d{7,8}$').hasMatch(value!)) {
                                            return 'Ingresa 7 u 8 dígitos';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _telefonoController,
                                  label: 'Teléfono',
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'Ingresa tu teléfono' : null,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Correo Electrónico',
                                  icon: Icons.email,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) return 'Ingresa tu correo';
                                    if (!value!.contains('@')) return 'Correo inválido';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildPasswordField(
                                  controller: _passwordController,
                                  obscurePassword: _obscurePassword,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) return 'Ingresa tu contraseña';
                                    if (value!.length < 6) return 'Mínimo 6 caracteres';
                                    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])').hasMatch(value)) {
                                      return 'Debe incluir mayúscula, minúscula, número y símbolo';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildPasswordField(
                                  controller: _confirmPasswordController,
                                  obscurePassword: _obscureConfirmPassword,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                  label: 'Confirmar Contraseña',
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) return 'Confirma tu contraseña';
                                    if (value != _passwordController.text) {
                                      return 'Las contraseñas no coinciden';
                                    }
                                    return null;
                                  },
                                ),
                              ],

                              // Campos para Supervisor
                              if (_selectedRole == 'supervisor') ...[
                                _buildTextField(
                                  controller: _nombreController,
                                  label: 'Nombre',
                                  icon: Icons.person,
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'Ingresa tu nombre' : null,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _apellidoController,
                                  label: 'Apellido',
                                  icon: Icons.person_outline,
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'Ingresa tu apellido' : null,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Correo Institucional',
                                  icon: Icons.email,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) return 'Ingresa tu correo institucional';
                                    if (!value!.contains('@')) return 'Correo inválido';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                // Cédula
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: DropdownButtonFormField<String>(
                                          initialValue: _tipoCedula,
                                          decoration: InputDecoration(
                                            labelText: 'Tipo',
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                          items: const [
                                            DropdownMenuItem(value: 'V', child: Text('V')),
                                            DropdownMenuItem(value: 'E', child: Text('E')),
                                          ],
                                          onChanged: (value) {
                                            setState(() => _tipoCedula = value!);
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _cedulaController,
                                        label: 'Cédula',
                                        icon: Icons.badge,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value?.isEmpty ?? true) return 'Ingresa tu cédula';
                                          if (!RegExp(r'^\d{7,8}$').hasMatch(value!)) {
                                            return 'Ingresa 7 u 8 dígitos';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _telefonoController,
                                  label: 'Teléfono',
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'Ingresa tu teléfono' : null,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _departamentoController,
                                  label: 'Departamento',
                                  icon: Icons.business,
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'Ingresa tu departamento' : null,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _cargoController,
                                  label: 'Cargo',
                                  icon: Icons.work_outline,
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? 'Ingresa tu cargo' : null,
                                ),
                                const SizedBox(height: 16),
                                _buildPasswordField(
                                  controller: _passwordController,
                                  obscurePassword: _obscurePassword,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) return 'Ingresa tu contraseña';
                                    if (value!.length < 6) return 'Mínimo 6 caracteres';
                                    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])').hasMatch(value)) {
                                      return 'Debe incluir mayúscula, minúscula, número y símbolo';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildPasswordField(
                                  controller: _confirmPasswordController,
                                  obscurePassword: _obscureConfirmPassword,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                  label: 'Confirmar Contraseña',
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) return 'Confirma tu contraseña';
                                    if (value != _passwordController.text) {
                                      return 'Las contraseñas no coinciden';
                                    }
                                    return null;
                                  },
                                ),
                              ],

                              const SizedBox(height: 32),
                              // Mensaje de error
                              if (authProvider.error != null)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  margin: const EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.error,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: AppColors.error),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          authProvider.error!,
                                          style: const TextStyle(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Botón de registro
                              SizedBox(
                                width: double.infinity,
                                child: CustomButton(
                                  text: 'Crear Cuenta',
                                  isLoading: authProvider.isLoading,
                                  icon: Icons.app_registration,
                                  onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Concatenar tipo de cédula con el número
                        final cedulaCompleta = '$_tipoCedula-${_cedulaController.text.trim()}';
                        final email = _emailController.text.trim();
                        final password = _passwordController.text;

                        final success = await authProvider.register(
                          email: email,
                          password: password,
                          nombre: _nombreController.text.trim(),
                          apellido: _apellidoController.text.trim(),
                          cedula: cedulaCompleta,
                          telefono: _telefonoController.text.trim(),
                          role: _selectedRole,
                          carrera: _selectedRole == 'estudiante'
                              ? (_carreraPersonalizada 
                                  ? _carreraController.text.trim()
                                  : _selectedCarrera)
                              : null,
                          trimestre:
                              _selectedRole == 'estudiante' ? _trimestre : null,
                          departamento: _selectedRole == 'supervisor'
                              ? _departamentoController.text.trim()
                              : null,
                          cargo: _selectedRole == 'supervisor'
                              ? _cargoController.text.trim()
                              : null,
                        );

                                      if (success && mounted) {
                                        // Auto-login para estudiantes y aspirantes
                                        if (_selectedRole == 'estudiante' || _selectedRole == 'aspirante') {
                                          print('🔐 Iniciando auto-login para $_selectedRole...');

                                          final loginSuccess = await authProvider.login(email, password);

                                          if (loginSuccess && mounted) {
                                            print('✅ Auto-login exitoso, redirigiendo a módulos...');

                                            // Navegar a la pantalla de selección de módulos
                                            Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) => ModuleSelectionScreen(
                                                  isNewRegistration: true,
                                                  userEmail: email,
                                                ),
                                              ),
                                            );
                                          } else {
                                            // Si el auto-login falla, mostrar mensaje de error
                                            if (mounted) {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  title: const Row(
                                                    children: [
                                                      Icon(Icons.warning, color: AppColors.warning),
                                                      SizedBox(width: 12),
                                                      Text('Registro Exitoso'),
                                                    ],
                                                  ),
                                                  content: const Text(
                                                    'Tu cuenta ha sido creada, pero hubo un problema al iniciar sesión automáticamente. Por favor, inicia sesión manualmente.',
                                                    style: TextStyle(height: 1.5),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                        'Entendido',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          }
                                        } else {
                                          // Para supervisor, mostrar mensaje de aprobación pendiente
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              title: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.success.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: const Icon(
                                                      Icons.check_circle,
                                                      color: AppColors.success,
                                                      size: 28,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  const Text('Registro Exitoso'),
                                                ],
                                              ),
                                              content: const Text(
                                                'Tu cuenta ha sido creada. Espera la aprobación del administrador para acceder.',
                                                style: TextStyle(height: 1.5),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text(
                                                    'Entendido',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  // Widget helper para los encabezados de sección
  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // Widget helper para campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
        ),
        validator: validator,
      ),
    );
  }

  // Widget helper para dropdowns
  Widget _buildDropdown<T>({
    T? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
        ),
        items: items,
        onChanged: onChanged,
        validator: (value) {
          if (value == null && label == 'Carrera') {
            return 'Selecciona tu carrera';
          }
          return null;
        },
      ),
    );
  }

  // Widget helper para campo de contraseña
  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscurePassword,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
    String label = 'Contraseña',
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscurePassword,
        decoration: InputDecoration(
          labelText: label,
          helperText: label == 'Contraseña' 
              ? 'Debe incluir: Mayúscula, minúscula, número y símbolo (@\$!%*?&)'
              : null,
          helperMaxLines: 2,
          prefixIcon: const Icon(Icons.lock, color: AppColors.primary),
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: onToggleVisibility,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
        ),
        validator: validator,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    _carreraController.dispose();
    _departamentoController.dispose();
    _cargoController.dispose();
    super.dispose();
  }
}

// Painter para las líneas de fondo modernas
class ModernLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.12)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Líneas diagonales en la parte superior derecha
    for (int i = 0; i < 5; i++) {
      final path = Path();
      path.moveTo(size.width * 0.6 + (i * 40), 0);
      path.lineTo(size.width + (i * 40), size.height * 0.3);
      canvas.drawPath(path, paint);
    }

    // Líneas horizontales sutiles en el medio
    for (int i = 0; i < 3; i++) {
      final y = size.height * 0.4 + (i * 60);
      final path = Path();
      path.moveTo(0, y);
      path.lineTo(size.width * 0.3, y);
      canvas.drawPath(path, paint);
    }

    // Líneas diagonales en la parte inferior izquierda
    for (int i = 0; i < 4; i++) {
      final path = Path();
      path.moveTo(0 - (i * 50), size.height * 0.7);
      path.lineTo(size.width * 0.4 - (i * 50), size.height);
      canvas.drawPath(path, paint);
    }

    // Líneas verticales sutiles a la derecha
    for (int i = 0; i < 2; i++) {
      final x = size.width * 0.85 + (i * 30);
      final path = Path();
      path.moveTo(x, size.height * 0.5);
      path.lineTo(x, size.height * 0.8);
      canvas.drawPath(path, paint);
    }

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
