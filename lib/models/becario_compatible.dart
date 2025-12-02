import 'user.dart';

class BecarioCompatible {
  final String id;
  final String usuarioId;
  final User usuario;
  final String tipoBeca;
  final int bloquesMatcheados;
  final int totalBloques;
  final double porcentajeCobertura;
  final Map<String, DetallesPorDia> detallesPorDia;

  BecarioCompatible({
    required this.id,
    required this.usuarioId,
    required this.usuario,
    required this.tipoBeca,
    required this.bloquesMatcheados,
    required this.totalBloques,
    required this.porcentajeCobertura,
    required this.detallesPorDia,
  });

  factory BecarioCompatible.fromJson(Map<String, dynamic> json) {
    return BecarioCompatible(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      usuario: User.fromJson(json['usuario']),
      tipoBeca: json['tipoBeca'] ?? '',
      bloquesMatcheados: json['bloquesMatcheados'] ?? 0,
      totalBloques: json['totalBloques'] ?? 0,
      porcentajeCobertura: (json['porcentajeCobertura'] ?? 0).toDouble(),
      detallesPorDia: (json['detallesPorDia'] as Map<String, dynamic>?)
              ?.map((key, value) =>
                  MapEntry(key, DetallesPorDia.fromJson(value)))
          ?? {},
    );
  }
}

class DetallesPorDia {
  final int requeridos;
  final int disponibles;
  final List<BloqueHorario> bloques;

  DetallesPorDia({
    required this.requeridos,
    required this.disponibles,
    required this.bloques,
  });

  factory DetallesPorDia.fromJson(Map<String, dynamic> json) {
    return DetallesPorDia(
      requeridos: json['requeridos'] ?? 0,
      disponibles: json['disponibles'] ?? 0,
      bloques: (json['bloques'] as List?)
              ?.map((b) => BloqueHorario.fromJson(b))
              .toList() ??
          [],
    );
  }
}

class BloqueHorario {
  final String inicio;
  final String fin;
  final bool matchea;

  BloqueHorario({
    required this.inicio,
    required this.fin,
    required this.matchea,
  });

  factory BloqueHorario.fromJson(Map<String, dynamic> json) {
    return BloqueHorario(
      inicio: json['inicio'] ?? '',
      fin: json['fin'] ?? '',
      matchea: json['matchea'] ?? false,
    );
  }
}

class BecariosCompatiblesResponse {
  final PlazaInfo plaza;
  final int umbralBloques;
  final List<BecarioCompatible> becarios;
  final int total;
  final int limit;
  final int offset;
  final int totalPages;

  BecariosCompatiblesResponse({
    required this.plaza,
    required this.umbralBloques,
    required this.becarios,
    required this.total,
    required this.limit,
    required this.offset,
    required this.totalPages,
  });

  factory BecariosCompatiblesResponse.fromJson(Map<String, dynamic> json) {
    return BecariosCompatiblesResponse(
      plaza: PlazaInfo.fromJson(json['plaza']),
      umbralBloques: json['umbralBloques'] ?? 0,
      becarios: (json['becarios'] as List?)
              ?.map((b) => BecarioCompatible.fromJson(b))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 20,
      offset: json['offset'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class PlazaInfo {
  final String id;
  final String materia;
  final String codigo;
  final String departamento;
  final String tipoAyudantia;
  final List<HorarioPlaza> horario;
  final int totalBloques;

  PlazaInfo({
    required this.id,
    required this.materia,
    required this.codigo,
    required this.departamento,
    required this.tipoAyudantia,
    required this.horario,
    required this.totalBloques,
  });

  factory PlazaInfo.fromJson(Map<String, dynamic> json) {
    return PlazaInfo(
      id: json['id'] ?? '',
      materia: json['materia'] ?? '',
      codigo: json['codigo'] ?? '',
      departamento: json['departamento'] ?? '',
      tipoAyudantia: json['tipoAyudantia'] ?? '',
      horario: (json['horario'] as List?)
              ?.map((h) => HorarioPlaza.fromJson(h))
              .toList() ??
          [],
      totalBloques: json['totalBloques'] ?? 0,
    );
  }
}

class HorarioPlaza {
  final String dia;
  final String horaInicio;
  final String horaFin;

  HorarioPlaza({
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
  });

  factory HorarioPlaza.fromJson(Map<String, dynamic> json) {
    return HorarioPlaza(
      dia: json['dia'] ?? '',
      horaInicio: json['horaInicio'] ?? '',
      horaFin: json['horaFin'] ?? '',
    );
  }
}
