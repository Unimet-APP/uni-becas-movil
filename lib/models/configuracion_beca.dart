class ConfiguracionBeca {
  final String tipoBeca;
  final String? subtipoExcelencia;
  final double montoMensual;
  final int cuposDisponibles;
  final double promedioMinimo;
  final int semestreMinimo;
  final int semestreMaximo;
  final int edadMaxima;
  final int duracionMeses;
  final List<String> documentosRequeridos;
  final String? requisitosEspeciales;

  ConfiguracionBeca({
    required this.tipoBeca,
    this.subtipoExcelencia,
    required this.montoMensual,
    required this.cuposDisponibles,
    required this.promedioMinimo,
    required this.semestreMinimo,
    required this.semestreMaximo,
    required this.edadMaxima,
    required this.duracionMeses,
    required this.documentosRequeridos,
    this.requisitosEspeciales,
  });

  factory ConfiguracionBeca.fromJson(Map<String, dynamic> json) {
    return ConfiguracionBeca(
      tipoBeca: json['tipoBeca'] ?? '',
      subtipoExcelencia: json['subtipoExcelencia'],
      montoMensual: _parseDouble(json['montoMensual'], 0),
      cuposDisponibles: _parseInt(json['cuposDisponibles'], 0),
      promedioMinimo: _parseDouble(json['promedioMinimo'], 0),
      semestreMinimo: _parseInt(json['semestreMinimo'], 1),
      semestreMaximo: _parseInt(json['semestreMaximo'], 12),
      edadMaxima: _parseInt(json['edadMaxima'], 30),
      duracionMeses: _parseInt(json['duracionMeses'], 12),
      documentosRequeridos: (json['documentosRequeridos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      requisitosEspeciales: json['requisitosEspeciales'],
    );
  }

  static double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static int _parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  Map<String, dynamic> toJson() => {
        'tipoBeca': tipoBeca,
        'subtipoExcelencia': subtipoExcelencia,
        'montoMensual': montoMensual,
        'cuposDisponibles': cuposDisponibles,
        'promedioMinimo': promedioMinimo,
        'semestreMinimo': semestreMinimo,
        'semestreMaximo': semestreMaximo,
        'edadMaxima': edadMaxima,
        'duracionMeses': duracionMeses,
        'documentosRequeridos': documentosRequeridos,
        'requisitosEspeciales': requisitosEspeciales,
      };
}
