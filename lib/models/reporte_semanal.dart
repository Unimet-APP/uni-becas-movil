import 'user.dart';

enum EstadoReporte { pendiente, aprobada, rechazada, enRevision }

class ReporteSemanal {
  final String id;
  final String estudianteId;
  final String estudianteBecarioId;
  final String? supervisorId;
  final String tipoBeca;
  final int semana;
  final String periodoAcademico;
  final String? fecha;
  final double horasTrabajadas;
  final String? objetivosPeriodo;
  final String? metasEspecificas;
  final String? actividadesProgramadas;
  final String? actividadesRealizadas;
  final String? descripcionActividades;
  final String? observaciones;
  final EstadoReporte estado;
  final bool bloqueado;
  final String? fechaAprobacion;
  final String? observacionesSupervisor;
  final String? motivoRechazo;
  final User? estudiante;
  final User? supervisor;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReporteSemanal({
    required this.id,
    required this.estudianteId,
    required this.estudianteBecarioId,
    this.supervisorId,
    required this.tipoBeca,
    required this.semana,
    required this.periodoAcademico,
    this.fecha,
    required this.horasTrabajadas,
    this.objetivosPeriodo,
    this.metasEspecificas,
    this.actividadesProgramadas,
    this.actividadesRealizadas,
    this.descripcionActividades,
    this.observaciones,
    required this.estado,
    required this.bloqueado,
    this.fechaAprobacion,
    this.observacionesSupervisor,
    this.motivoRechazo,
    this.estudiante,
    this.supervisor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReporteSemanal.fromJson(Map<String, dynamic> json) {
    EstadoReporte parseEstado(String estado) {
      switch (estado) {
        case 'Aprobada':
          return EstadoReporte.aprobada;
        case 'Rechazada':
          return EstadoReporte.rechazada;
        case 'En Revisión':
          return EstadoReporte.enRevision;
        default:
          return EstadoReporte.pendiente;
      }
    }

    // Helper para convertir valores que pueden venir como string o número
    double parseToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return ReporteSemanal(
      id: json['id'] ?? '',
      estudianteId: json['estudianteId'] ?? '',
      estudianteBecarioId: json['estudianteBecarioId'] ?? '',
      supervisorId: json['supervisorId'],
      tipoBeca: json['tipoBeca'] ?? 'Ayudantía',
      semana: json['semana'] ?? 1,
      periodoAcademico: json['periodoAcademico'] ?? '',
      fecha: json['fecha'],
      horasTrabajadas: parseToDouble(json['horasTrabajadas']),
      objetivosPeriodo: json['objetivosPeriodo'],
      metasEspecificas: json['metasEspecificas'],
      actividadesProgramadas: json['actividadesProgramadas'],
      actividadesRealizadas: json['actividadesRealizadas'],
      descripcionActividades: json['descripcionActividades'],
      observaciones: json['observaciones'],
      estado: parseEstado(json['estado'] ?? 'Pendiente'),
      bloqueado: json['bloqueado'] ?? false,
      fechaAprobacion: json['fechaAprobacion'],
      observacionesSupervisor: json['observacionesSupervisor'],
      motivoRechazo: json['motivoRechazo'],
      estudiante: json['estudiante'] != null
          ? User.fromJson(json['estudiante'])
          : null,
      supervisor: json['supervisor'] != null
          ? User.fromJson(json['supervisor'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  bool get isPendiente => estado == EstadoReporte.pendiente;
  bool get isAprobada => estado == EstadoReporte.aprobada;
  bool get isRechazada => estado == EstadoReporte.rechazada;
  bool get canEdit => !bloqueado && isPendiente;

  String get estadoString {
    switch (estado) {
      case EstadoReporte.aprobada:
        return 'Aprobada';
      case EstadoReporte.rechazada:
        return 'Rechazada';
      case EstadoReporte.enRevision:
        return 'En Revisión';
      default:
        return 'Pendiente';
    }
  }
}
