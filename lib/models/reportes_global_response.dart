import 'reporte_semanal.dart';

class ReportesGlobalResponse {
  final List<ReporteSemanal> reportes;
  final int total;
  final EstadisticasReportes estadisticas;
  final int limit;
  final int offset;
  final int totalPages;

  ReportesGlobalResponse({
    required this.reportes,
    required this.total,
    required this.estadisticas,
    required this.limit,
    required this.offset,
    required this.totalPages,
  });

  factory ReportesGlobalResponse.fromJson(Map<String, dynamic> json) {
    return ReportesGlobalResponse(
      reportes: (json['reportes'] as List<dynamic>?)
              ?.map((e) => ReporteSemanal.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      estadisticas: EstadisticasReportes.fromJson(json['estadisticas'] ?? {}),
      limit: json['limit'] ?? 20,
      offset: json['offset'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}

class EstadisticasReportes {
  final Map<String, int> porEstado;
  final double horasTotalesAprobadas;
  final int estudiantesUnicos;

  EstadisticasReportes({
    required this.porEstado,
    required this.horasTotalesAprobadas,
    required this.estudiantesUnicos,
  });

  factory EstadisticasReportes.fromJson(Map<String, dynamic> json) {
    return EstadisticasReportes(
      porEstado: Map<String, int>.from(json['porEstado'] ?? {}),
      horasTotalesAprobadas:
          (json['horasTotalesAprobadas'] ?? 0).toDouble(),
      estudiantesUnicos: json['estudiantesUnicos'] ?? 0,
    );
  }

  int get pendiente => porEstado['Pendiente'] ?? 0;
  int get aprobada => porEstado['Aprobada'] ?? 0;
  int get rechazada => porEstado['Rechazada'] ?? 0;
  int get enRevision => porEstado['En Revisión'] ?? 0;
  int get total => pendiente + aprobada + rechazada + enRevision;
}
