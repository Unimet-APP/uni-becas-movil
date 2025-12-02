import 'user.dart';
import 'plaza.dart';

class Becario {
  final String id;
  final String usuarioId;
  final String? supervisorId;
  final String? plazaAsignada;
  final String tipoBeca;
  final String estado;
  final String periodoInicio;
  final String? periodoFin;
  final int horasRequeridas;
  final double horasCompletadas;
  final double descuentoAplicado;
  final User usuario;
  final User? supervisor;
  final Plaza? plaza;

  Becario({
    required this.id,
    required this.usuarioId,
    this.supervisorId,
    this.plazaAsignada,
    required this.tipoBeca,
    required this.estado,
    required this.periodoInicio,
    this.periodoFin,
    required this.horasRequeridas,
    required this.horasCompletadas,
    required this.descuentoAplicado,
    required this.usuario,
    this.supervisor,
    this.plaza,
  });

  factory Becario.fromJson(Map<String, dynamic> json) {
    // Helper para convertir valores que pueden venir como string o número
    double parseToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Becario(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      supervisorId: json['supervisorId'],
      plazaAsignada: json['plazaAsignada'],
      tipoBeca: json['tipoBeca'] ?? json['programaBeca'] ?? 'Ayudantía',
      estado: json['estado'] ?? 'Activa',
      periodoInicio: json['periodoInicio'] ?? '',
      periodoFin: json['periodoFin'],
      horasRequeridas: json['horasRequeridas'] ?? 0,
      horasCompletadas: parseToDouble(json['horasCompletadas']),
      descuentoAplicado: parseToDouble(json['descuentoAplicado']),
      usuario: User.fromJson(json['usuario'] ?? {}),
      supervisor: json['supervisor'] != null ? User.fromJson(json['supervisor']) : null,
      plaza: json['plaza'] != null ? Plaza.fromJson(json['plaza']) : null,
    );
  }

  double get porcentajeCompletado =>
      horasRequeridas > 0
          ? (horasCompletadas / horasRequeridas * 100).clamp(0, 100)
          : 0;

  bool get hasPlaza => plazaAsignada != null;
  bool get hasSupervisor => supervisorId != null;
  bool get isActiva => estado == 'Activa';

  int get horasRestantes =>
      (horasRequeridas - horasCompletadas).clamp(0, horasRequeridas).toInt();
}
