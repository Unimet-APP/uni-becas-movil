class User {
  final String id;
  final String email;
  final String nombre;
  final String? apellido;
  final String role;
  final bool activo;
  final bool emailVerified;
  final bool? firstLogin;
  final String? cedula;
  final String? telefono;
  final String? carrera;
  final int? trimestre;
  final String? departamento;
  final String? cargo;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.nombre,
    this.apellido,
    required this.role,
    required this.activo,
    required this.emailVerified,
    this.firstLogin,
    this.cedula,
    this.telefono,
    this.carrera,
    this.trimestre,
    this.departamento,
    this.cargo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString(),
      role: json['role']?.toString() ?? 'estudiante',
      activo: json['activo'] ?? false,
      emailVerified: json['emailVerified'] ?? false,
      firstLogin: json['firstLogin'],
      cedula: json['cedula']?.toString(),
      telefono: json['telefono']?.toString(),
      carrera: json['carrera']?.toString(),
      trimestre: json['trimestre'] is int
          ? json['trimestre']
          : (json['trimestre'] != null
              ? int.tryParse(json['trimestre'].toString())
              : null),
      departamento: json['departamento']?.toString(),
      cargo: json['cargo']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'nombre': nombre,
        'apellido': apellido,
        'role': role,
        'activo': activo,
        'emailVerified': emailVerified,
        'firstLogin': firstLogin,
        'cedula': cedula,
        'telefono': telefono,
        'carrera': carrera,
        'trimestre': trimestre,
        'departamento': departamento,
        'cargo': cargo,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  String get fullName => '$nombre ${apellido ?? ''}'.trim();

  bool get isAdmin => role == 'Administrador';
  bool get isSupervisor => role == 'SupervisorLaboral';
  bool get isStudent => role == 'Estudiante';
}
