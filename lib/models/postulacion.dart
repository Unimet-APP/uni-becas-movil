class Postulacion {
  final String? id;
  final String nombre;
  final String cedula;
  final String email;
  final String telefono;
  final DateTime fechaNacimiento;
  final String estadoCivil;
  final String tipoPostulante;
  final String carrera;
  final String tipoBeca;
  final String? subtipoExcelencia;
  final String? trimestre;
  final double? iaa;
  final double? promedioBachillerato;
  final int? asignaturasAprobadas;
  final int? creditosInscritos;
  final String? estado;

  Postulacion({
    this.id,
    required this.nombre,
    required this.cedula,
    required this.email,
    required this.telefono,
    required this.fechaNacimiento,
    required this.estadoCivil,
    required this.tipoPostulante,
    required this.carrera,
    required this.tipoBeca,
    this.subtipoExcelencia,
    this.trimestre,
    this.iaa,
    this.promedioBachillerato,
    this.asignaturasAprobadas,
    this.creditosInscritos,
    this.estado,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'cedula': cedula,
      'email': email,
      'telefono': telefono,
      'fechaNacimiento': fechaNacimiento.toIso8601String().split('T')[0],
      'estadoCivil': estadoCivil,
      'tipoPostulante': tipoPostulante,
      'carrera': carrera,
      'tipoBeca': tipoBeca,
      if (subtipoExcelencia != null) 'subtipoExcelencia': subtipoExcelencia,
      if (trimestre != null) 'trimestre': trimestre,
      if (iaa != null) 'iaa': iaa,
      if (promedioBachillerato != null) 'promedioBachillerato': promedioBachillerato,
      if (asignaturasAprobadas != null) 'asignaturasAprobadas': asignaturasAprobadas,
      if (creditosInscritos != null) 'creditosInscritos': creditosInscritos,
      if (estado != null) 'estado': estado,
    };
  }

  factory Postulacion.fromJson(Map<String, dynamic> json) {
    return Postulacion(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      cedula: json['cedula'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      fechaNacimiento: json['fechaNacimiento'] != null
          ? DateTime.parse(json['fechaNacimiento'])
          : DateTime.now(),
      estadoCivil: json['estadoCivil'] ?? 'soltero',
      tipoPostulante: json['tipoPostulante'] ?? 'estudiante-pregrado',
      carrera: json['carrera'] ?? '',
      tipoBeca: json['tipoBeca'] ?? '',
      subtipoExcelencia: json['subtipoExcelencia'],
      trimestre: json['trimestre'],
      iaa: json['iaa']?.toDouble(),
      promedioBachillerato: json['promedioBachillerato']?.toDouble(),
      asignaturasAprobadas: json['asignaturasAprobadas'],
      creditosInscritos: json['creditosInscritos'],
      estado: json['estado'],
    );
  }
}
