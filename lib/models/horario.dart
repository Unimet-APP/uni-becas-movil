class Horario {
  final String dia;
  final String horaInicio;
  final String horaFin;

  Horario({
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
  });

  factory Horario.fromJson(Map<String, dynamic> json) => Horario(
        dia: json['dia'] ?? '',
        horaInicio: json['horaInicio'] ?? '',
        horaFin: json['horaFin'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'dia': dia,
        'horaInicio': horaInicio,
        'horaFin': horaFin,
      };

  String get displayText => '$dia: $horaInicio - $horaFin';
}
