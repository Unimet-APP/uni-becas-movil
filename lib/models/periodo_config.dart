class SemanaConfig {
  final int numeroSemana;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool habilitada;

  SemanaConfig({
    required this.numeroSemana,
    required this.fechaInicio,
    required this.fechaFin,
    required this.habilitada,
  });

  factory SemanaConfig.fromJson(Map<String, dynamic> json) {
    return SemanaConfig(
      numeroSemana: json['numeroSemana'] ?? 0,
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaFin: DateTime.parse(json['fechaFin']),
      habilitada: json['habilitada'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'numeroSemana': numeroSemana,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaFin': fechaFin.toIso8601String(),
        'habilitada': habilitada,
      };
}

class PeriodoConfig {
  final String periodoAcademico;
  final int semanaActual;
  final List<int> semanasHabilitadas;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? descripcion;
  final bool activo;
  final int totalSemanasHabilitadas;

  PeriodoConfig({
    required this.periodoAcademico,
    required this.semanaActual,
    required this.semanasHabilitadas,
    required this.fechaInicio,
    required this.fechaFin,
    this.descripcion,
    required this.activo,
    required this.totalSemanasHabilitadas,
  });

  factory PeriodoConfig.fromJson(Map<String, dynamic> json) {
    return PeriodoConfig(
      periodoAcademico: json['periodoAcademico'] ?? '',
      semanaActual: json['semanaActual'] ?? 1,
      semanasHabilitadas: (json['semanasHabilitadas'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaFin: DateTime.parse(json['fechaFin']),
      descripcion: json['descripcion'],
      activo: json['activo'] ?? false,
      totalSemanasHabilitadas: json['totalSemanasHabilitadas'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'periodoAcademico': periodoAcademico,
        'semanaActual': semanaActual,
        'semanasHabilitadas': semanasHabilitadas,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaFin': fechaFin.toIso8601String(),
        'descripcion': descripcion,
        'activo': activo,
        'totalSemanasHabilitadas': totalSemanasHabilitadas,
      };

  // Helper method
  bool isSemanaHabilitada(int semana) {
    return semanasHabilitadas.contains(semana);
  }
}
