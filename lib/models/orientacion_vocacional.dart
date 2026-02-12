enum TipoTest { hollandRiasec, ico }

extension TipoTestExtension on TipoTest {
  String get value {
    switch (this) {
      case TipoTest.hollandRiasec:
        return 'Holland_RIASEC';
      case TipoTest.ico:
        return 'ICO';
    }
  }

  String get displayName {
    switch (this) {
      case TipoTest.hollandRiasec:
        return 'Test Holland RIASEC';
      case TipoTest.ico:
        return 'Test ICO';
    }
  }

  static TipoTest fromString(String value) {
    switch (value) {
      case 'ICO':
        return TipoTest.ico;
      case 'Holland_RIASEC':
      default:
        return TipoTest.hollandRiasec;
    }
  }
}

class Pregunta {
  final String id;
  final String codigo;
  final String texto;
  final String tipoPregunta;
  final String? peso;
  final String? dimensionPrincipal;
  final List<String>? dimensionSecundaria;
  final List<String>? opcionesRespuesta;

  Pregunta({
    required this.id,
    required this.codigo,
    required this.texto,
    required this.tipoPregunta,
    this.peso,
    this.dimensionPrincipal,
    this.dimensionSecundaria,
    this.opcionesRespuesta,
  });

  factory Pregunta.fromJson(Map<String, dynamic> json) {
    return Pregunta(
      id: json['id']?.toString() ?? '',
      codigo: json['codigo']?.toString() ?? '',
      texto: json['texto']?.toString() ?? '',
      tipoPregunta: json['tipoPregunta']?.toString() ?? 'directa',
      peso: json['peso']?.toString(),
      dimensionPrincipal: json['dimensionPrincipal']?.toString(),
      dimensionSecundaria: json['dimensionSecundaria'] != null
          ? List<String>.from(json['dimensionSecundaria'])
          : null,
      opcionesRespuesta: json['opcionesRespuesta'] != null
          ? List<String>.from(json['opcionesRespuesta'])
          : null,
    );
  }
}

class RespuestaPregunta {
  final String preguntaId;
  final dynamic respuesta; // String | bool
  final int? tiempoRespuesta;
  final String? nivelSeguridad;

  RespuestaPregunta({
    required this.preguntaId,
    required this.respuesta,
    this.tiempoRespuesta,
    this.nivelSeguridad,
  });

  Map<String, dynamic> toJson() => {
        'preguntaId': preguntaId,
        'respuesta': respuesta,
        if (tiempoRespuesta != null) 'tiempoRespuesta': tiempoRespuesta,
        if (nivelSeguridad != null) 'nivelSeguridad': nivelSeguridad,
      };
}

class RespuestaIcoBody {
  final String preguntaId;
  final bool respuesta;
  final int? tiempoRespuesta;
  final String? nivelSeguridad;

  RespuestaIcoBody({
    required this.preguntaId,
    required this.respuesta,
    this.tiempoRespuesta,
    this.nivelSeguridad,
  });

  Map<String, dynamic> toJson() => {
        'pregunta_id': preguntaId,
        'respuesta': respuesta,
        if (tiempoRespuesta != null) 'tiempo_respuesta': tiempoRespuesta,
        if (nivelSeguridad != null) 'nivel_seguridad': nivelSeguridad,
      };
}

class RecomendacionCarrera {
  final int? id;
  final String name;
  final String razon;
  final String? faculty;
  final String? area;

  RecomendacionCarrera({
    this.id,
    required this.name,
    required this.razon,
    this.faculty,
    this.area,
  });

  factory RecomendacionCarrera.fromJson(Map<String, dynamic> json) {
    return RecomendacionCarrera(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id'] ?? ''}'),
      name: json['name']?.toString() ?? json['nombre']?.toString() ?? '',
      razon: json['razon']?.toString() ?? '',
      faculty: json['faculty']?.toString() ?? json['facultad']?.toString(),
      area: json['area']?.toString(),
    );
  }
}

class PerfilVocacional {
  final List<String> fortalezas;
  final List<String> debilidades;
  final List<String> oportunidades;

  PerfilVocacional({
    required this.fortalezas,
    required this.debilidades,
    required this.oportunidades,
  });

  factory PerfilVocacional.fromJson(Map<String, dynamic> json) {
    return PerfilVocacional(
      fortalezas: List<String>.from(json['fortalezas'] ?? []),
      debilidades: List<String>.from(json['debilidades'] ?? []),
      oportunidades: List<String>.from(json['oportunidades'] ?? []),
    );
  }
}

class ResultadoVocacional {
  final String? id;
  final String? codigoHolland;
  final String? perfilDominante;
  final String? perfilSecundario;
  final double? nivelConfianza;
  final List<RecomendacionCarrera> recomendacionesCarreras;
  final PerfilVocacional? perfilVocacional;
  final List<String> areasDesarrollo;
  final List<String> sugerenciasAcompanamiento;
  final Map<String, List<String>>? planDesarrollo;

  ResultadoVocacional({
    this.id,
    this.codigoHolland,
    this.perfilDominante,
    this.perfilSecundario,
    this.nivelConfianza,
    this.recomendacionesCarreras = const [],
    this.perfilVocacional,
    this.areasDesarrollo = const [],
    this.sugerenciasAcompanamiento = const [],
    this.planDesarrollo,
  });

  factory ResultadoVocacional.fromJson(Map<String, dynamic> json) {
    return ResultadoVocacional(
      id: json['id']?.toString(),
      codigoHolland:
          json['codigoHolland']?.toString() ?? json['codigo_holland']?.toString(),
      perfilDominante: json['perfilDominante']?.toString() ??
          json['perfil_dominante']?.toString(),
      perfilSecundario: json['perfilSecundario']?.toString() ??
          json['perfil_secundario']?.toString(),
      nivelConfianza: json['nivelConfianza'] is num
          ? (json['nivelConfianza'] as num).toDouble()
          : null,
      recomendacionesCarreras: (json['recomendacionesCarreras'] as List?)
              ?.map((e) => RecomendacionCarrera.fromJson(e))
              .toList() ??
          (json['recomendaciones_carreras'] as List?)
              ?.map((e) => RecomendacionCarrera.fromJson(e))
              .toList() ??
          [],
      perfilVocacional: json['perfilVocacional'] != null
          ? PerfilVocacional.fromJson(json['perfilVocacional'])
          : json['perfil_vocacional'] != null
              ? PerfilVocacional.fromJson(json['perfil_vocacional'])
              : null,
      areasDesarrollo:
          List<String>.from(json['areasDesarrollo'] ?? json['areas_desarrollo'] ?? []),
      sugerenciasAcompanamiento: List<String>.from(
          json['sugerenciasAcompanamiento'] ??
              json['sugerencias_acompanamiento'] ??
              []),
      planDesarrollo: json['planDesarrollo'] != null
          ? (json['planDesarrollo'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, List<String>.from(v)),
            )
          : null,
    );
  }
}

class HistorialItem {
  final String id;
  final String tipoTest;
  final String estado;
  final String? fechaInicio;
  final String? fechaFin;
  final String? fechaCompletada;
  final String? perfilDominante;
  final String? codigoHolland;
  final bool? tieneResultado;
  final Map<String, num>? puntuacionesRonda1;
  final Map<String, num>? puntuacionesRonda2;

  HistorialItem({
    required this.id,
    required this.tipoTest,
    required this.estado,
    this.fechaInicio,
    this.fechaFin,
    this.fechaCompletada,
    this.perfilDominante,
    this.codigoHolland,
    this.tieneResultado,
    this.puntuacionesRonda1,
    this.puntuacionesRonda2,
  });

  factory HistorialItem.fromJson(Map<String, dynamic> json) {
    return HistorialItem(
      id: (json['id'] ?? json['sesion_id'] ?? '').toString(),
      tipoTest:
          json['tipoTest']?.toString() ?? json['tipo_test']?.toString() ?? 'Holland_RIASEC',
      estado: json['estado']?.toString() ?? 'iniciada',
      fechaInicio:
          json['fechaInicio']?.toString() ?? json['fecha_inicio']?.toString(),
      fechaFin: json['fechaFin']?.toString() ?? json['fecha_fin']?.toString(),
      fechaCompletada: json['fechaCompletada']?.toString() ??
          json['fecha_completada']?.toString(),
      perfilDominante: json['perfilDominante']?.toString() ??
          json['perfil_dominante']?.toString(),
      codigoHolland: json['codigoHolland']?.toString() ??
          json['codigo_holland']?.toString(),
      tieneResultado: json['tieneResultado'] is bool
          ? json['tieneResultado']
          : null,
      puntuacionesRonda1: json['puntuacionesRonda1'] != null
          ? Map<String, num>.from(json['puntuacionesRonda1'])
          : null,
      puntuacionesRonda2: json['puntuacionesRonda2'] != null
          ? Map<String, num>.from(json['puntuacionesRonda2'])
          : null,
    );
  }

  bool get isCompleted {
    final e = estado.toLowerCase();
    return e == 'finalizada' || e == 'ronda_2_completada' || e == 'completada' || tieneResultado == true;
  }

  bool get isIco => tipoTest == 'ICO';

  String get displayName => isIco ? 'Test ICO' : 'Test Holland RIASEC';
}

/// Materia con nota (por año/lapso)
class MateriaNota {
  final String materia;
  final double nota;

  MateriaNota({required this.materia, required this.nota});

  factory MateriaNota.fromJson(Map<String, dynamic> json) {
    return MateriaNota(
      materia: json['materia']?.toString() ?? '',
      nota: (json['nota'] is num) ? (json['nota'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {'materia': materia, 'nota': nota};
}

/// Área con materias (para graduados)
class MateriasPorAreaItem {
  final String area;
  final List<MateriaNotaArea> materias;

  MateriasPorAreaItem({required this.area, required this.materias});

  factory MateriasPorAreaItem.fromJson(Map<String, dynamic> json) {
    return MateriasPorAreaItem(
      area: json['area']?.toString() ?? '',
      materias: (json['materias'] as List?)
              ?.map((e) => MateriaNotaArea.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'area': area,
        'materias': materias.map((m) => m.toJson()).toList(),
      };
}

class MateriaNotaArea {
  final String nombre;
  final double nota;

  MateriaNotaArea({required this.nombre, required this.nota});

  factory MateriaNotaArea.fromJson(Map<String, dynamic> json) {
    return MateriaNotaArea(
      nombre: json['nombre']?.toString() ?? '',
      nota: (json['nota'] is num) ? (json['nota'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {'nombre': nombre, 'nota': nota};
}

/// Body para crear/actualizar trayectoria
class TrayectoriaBody {
  Map<String, double>? promediosPorAno;
  double? promedioGeneral;
  String? gradoActual;
  List<String>? materiasDestacadas;
  List<String>? actividadesExtracurriculares;
  List<String>? proyectosRealizados;
  Map<String, Map<String, List<MateriaNota>>>? materiasPorAnoLapso;
  List<MateriasPorAreaItem>? materiasPorArea;

  TrayectoriaBody({
    this.promediosPorAno,
    this.promedioGeneral,
    this.gradoActual,
    this.materiasDestacadas,
    this.actividadesExtracurriculares,
    this.proyectosRealizados,
    this.materiasPorAnoLapso,
    this.materiasPorArea,
  });

  factory TrayectoriaBody.fromJson(Map<String, dynamic>? data) {
    if (data == null) return TrayectoriaBody();

    // Parse materiasPorAnoLapso
    Map<String, Map<String, List<MateriaNota>>>? materiasPorAnoLapso;
    final rawMaterias = data['materiasPorAnoLapso'] ?? data['materias_por_ano_lapso'];
    if (rawMaterias is Map) {
      materiasPorAnoLapso = {};
      for (final anoEntry in rawMaterias.entries) {
        final ano = anoEntry.key.toString();
        if (anoEntry.value is Map) {
          materiasPorAnoLapso[ano] = {};
          for (final lapsoEntry in (anoEntry.value as Map).entries) {
            final lapso = lapsoEntry.key.toString();
            if (lapsoEntry.value is List) {
              materiasPorAnoLapso[ano]![lapso] = (lapsoEntry.value as List)
                  .map((e) => MateriaNota.fromJson(e))
                  .toList();
            }
          }
        }
      }
    }

    return TrayectoriaBody(
      promediosPorAno: _parseMapDouble(
          data['promediosPorAno'] ?? data['promedios_por_ano']),
      promedioGeneral: _parseDouble(
          data['promedioGeneral'] ?? data['promedio_general_acumulado']),
      gradoActual:
          data['gradoActual']?.toString() ?? data['grado_actual']?.toString(),
      materiasDestacadas: _parseStringList(
          data['materiasDestacadas'] ?? data['materias_destacadas']),
      actividadesExtracurriculares: _parseStringList(
          data['actividadesExtracurriculares'] ??
              data['actividades_extracurriculares']),
      proyectosRealizados: _parseStringList(
          data['proyectosRealizados'] ?? data['proyectos_realizados']),
      materiasPorAnoLapso: materiasPorAnoLapso,
      materiasPorArea: (data['materiasPorArea'] ?? data['materias_por_area'])
              is List
          ? (data['materiasPorArea'] ?? data['materias_por_area'] as List)
              .map((e) => MateriasPorAreaItem.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (gradoActual != null && gradoActual!.trim().isNotEmpty) {
      json['gradoActual'] = gradoActual;
    }
    if (materiasDestacadas != null && materiasDestacadas!.isNotEmpty) {
      json['materiasDestacadas'] = materiasDestacadas;
    }
    if (actividadesExtracurriculares != null &&
        actividadesExtracurriculares!.isNotEmpty) {
      json['actividadesExtracurriculares'] = actividadesExtracurriculares;
    }
    if (proyectosRealizados != null && proyectosRealizados!.isNotEmpty) {
      json['proyectosRealizados'] = proyectosRealizados;
    }
    if (materiasPorAnoLapso != null && materiasPorAnoLapso!.isNotEmpty) {
      json['materiasPorAnoLapso'] = materiasPorAnoLapso!.map(
        (ano, lapsos) => MapEntry(
          ano,
          lapsos.map(
            (lapso, materias) =>
                MapEntry(lapso, materias.map((m) => m.toJson()).toList()),
          ),
        ),
      );
    }
    if (materiasPorArea != null && materiasPorArea!.isNotEmpty) {
      json['materiasPorArea'] =
          materiasPorArea!.map((a) => a.toJson()).toList();
    }
    return json;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static Map<String, double>? _parseMapDouble(dynamic value) {
    if (value == null || value is! Map) return null;
    return value.map((k, v) => MapEntry(
        k.toString(), v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0));
  }

  static List<String>? _parseStringList(dynamic value) {
    if (value == null || value is! List) return null;
    return value.map((e) => e.toString()).toList();
  }
}

class Notificacion {
  final String id;
  final String titulo;
  final String contenido;
  final String tipo;
  final bool leida;
  final String fechaCreacion;
  final Map<String, dynamic>? metadata;

  Notificacion({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.tipo,
    required this.leida,
    required this.fechaCreacion,
    this.metadata,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      contenido: json['contenido']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      leida: json['leida'] == true,
      fechaCreacion: json['fecha_creacion']?.toString() ?? json['fechaCreacion']?.toString() ?? '',
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  Notificacion copyWith({bool? leida}) {
    return Notificacion(
      id: id,
      titulo: titulo,
      contenido: contenido,
      tipo: tipo,
      leida: leida ?? this.leida,
      fechaCreacion: fechaCreacion,
      metadata: metadata,
    );
  }
}

class Cita {
  final String id;
  final String fecha;
  final String hora;
  final String motivo;
  final String modalidad;
  final String estado;
  final Map<String, dynamic>? especialista;

  Cita({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.motivo,
    required this.modalidad,
    required this.estado,
    this.especialista,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id']?.toString() ?? '',
      fecha: json['fecha']?.toString() ?? '',
      hora: json['hora']?.toString() ?? '',
      motivo: json['motivo']?.toString() ?? '',
      modalidad: json['modalidad']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
      especialista: json['especialista'] is Map
          ? Map<String, dynamic>.from(json['especialista'])
          : null,
    );
  }

  String get motivoLabel {
    const labels = {
      'orientacion_vocacional': 'Orientacion Vocacional',
      'revision_resultados': 'Revision de Resultados',
      'opciones_beca': 'Info. sobre Becas',
      'plan_estudios': 'Plan de Estudios',
      'seguimiento': 'Seguimiento',
      'otro': 'Otro',
    };
    return labels[motivo] ?? motivo;
  }

  String get modalidadLabel {
    const labels = {
      'presencial': 'Presencial',
      'virtual': 'Virtual',
      'telefonica': 'Telefonica',
    };
    return labels[modalidad] ?? modalidad;
  }
}
