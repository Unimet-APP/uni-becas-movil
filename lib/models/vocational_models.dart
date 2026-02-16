// ─── Enums ────────────────────────────────────────────────────────────────────

enum TipoTest { hollandRiasec, ico }

extension TipoTestExt on TipoTest {
  String get apiValue =>
      this == TipoTest.hollandRiasec ? 'Holland_RIASEC' : 'ICO';

  static TipoTest fromString(String s) {
    final lower = s.toLowerCase();
    if (lower.contains('holland') || lower.contains('riasec')) {
      return TipoTest.hollandRiasec;
    }
    return TipoTest.ico;
  }
}

// ─── Question models ──────────────────────────────────────────────────────────

class VocationalQuestion {
  final String id;
  final String texto;
  final List<String> opcionesRespuesta;

  VocationalQuestion({
    required this.id,
    required this.texto,
    required this.opcionesRespuesta,
  });

  factory VocationalQuestion.fromJson(Map<String, dynamic> json) {
    final opciones = <String>[];
    if (json['instrucciones_respuesta'] is List) {
      opciones.addAll(
        (json['instrucciones_respuesta'] as List).map((e) => e.toString()),
      );
    } else if (json['opciones_respuesta'] is List) {
      opciones.addAll(
        (json['opciones_respuesta'] as List).map((e) => e.toString()),
      );
    } else if (json['opcionesRespuesta'] is List) {
      opciones.addAll(
        (json['opcionesRespuesta'] as List).map((e) => e.toString()),
      );
    }
    return VocationalQuestion(
      id: (json['id'] ?? json['pregunta_id'] ?? '').toString(),
      texto: (json['texto'] ?? json['texto__pregunta'] ?? json['pregunta'] ?? '').toString(),
      opcionesRespuesta: opciones,
    );
  }

  static List<VocationalQuestion> listFromJson(dynamic data) {
    if (data is List) {
      return data
          .map((e) => VocationalQuestion.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map && data['preguntas'] is List) {
      return listFromJson(data['preguntas']);
    }
    return [];
  }
}

// ─── Answer model ─────────────────────────────────────────────────────────────

class VocationalAnswer {
  final String preguntaId;
  final dynamic respuesta; // String or bool
  final int tiempoRespuesta;
  final String nivelSeguridad;

  VocationalAnswer({
    required this.preguntaId,
    required this.respuesta,
    this.tiempoRespuesta = 0,
    this.nivelSeguridad = 'seguro',
  });

  Map<String, dynamic> toJson() => {
    'preguntaId': preguntaId,
    'respuesta': respuesta,
    'tiempoRespuesta': tiempoRespuesta,
    'nivelSeguridad': nivelSeguridad,
  };
}

// ─── Session start response ───────────────────────────────────────────────────

class IniciarTestResponse {
  final String sesionId;
  final String tipoTest;
  final String estado;
  final List<VocationalQuestion> preguntas;

  IniciarTestResponse({
    required this.sesionId,
    required this.tipoTest,
    required this.estado,
    required this.preguntas,
  });

  factory IniciarTestResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    return IniciarTestResponse(
      sesionId: (data['sesionId'] ?? data['sesion_id'] ?? '').toString(),
      tipoTest: (data['tipoTest'] ?? data['tipo_test'] ?? '').toString(),
      estado: (data['estado'] ?? '').toString(),
      preguntas: VocationalQuestion.listFromJson(data['preguntas']),
    );
  }
}

// ─── Round 1 response ─────────────────────────────────────────────────────────

class Ronda1Response {
  final String sesionId;
  final String estado;
  final List<VocationalQuestion> preguntasRonda2;
  final Map<String, dynamic> puntuacionesRonda1;

  Ronda1Response({
    required this.sesionId,
    required this.estado,
    required this.preguntasRonda2,
    required this.puntuacionesRonda1,
  });

  factory Ronda1Response.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    return Ronda1Response(
      sesionId: (data['sesionId'] ?? data['sesion_id'] ?? '').toString(),
      estado: (data['estado'] ?? '').toString(),
      preguntasRonda2: VocationalQuestion.listFromJson(data['preguntasRonda2']),
      puntuacionesRonda1:
          (data['puntuacionesRonda1'] as Map<String, dynamic>?) ?? {},
    );
  }
}

// ─── ICO questions response ────────────────────────────────────────────────────

class PreguntasIcoResponse {
  final String sesionId;
  final List<VocationalQuestion> preguntas;

  PreguntasIcoResponse({required this.sesionId, required this.preguntas});

  factory PreguntasIcoResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    return PreguntasIcoResponse(
      sesionId: (data['sesionId'] ?? data['sesion_id'] ?? '').toString(),
      preguntas: VocationalQuestion.listFromJson(data['preguntas'] ?? data),
    );
  }
}

// ─── Holland Results ──────────────────────────────────────────────────────────

class RiasecDimension {
  final String codigo;
  final String nombre;
  final double puntuacion;
  final String descripcion;

  RiasecDimension({
    required this.codigo,
    required this.nombre,
    required this.puntuacion,
    required this.descripcion,
  });

  factory RiasecDimension.fromJson(Map<String, dynamic> json) {
    return RiasecDimension(
      codigo: (json['codigo'] ?? json['code'] ?? '').toString(),
      nombre: (json['nombre'] ?? json['name'] ?? '').toString(),
      puntuacion: _toDouble(json['puntuacion'] ?? json['score'] ?? 0),
      descripcion: (json['descripcion'] ?? json['description'] ?? '').toString(),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}

class CarreraRecomendada {
  final String nombre;
  final String? facultad;
  final String? area;
  final String? razon;

  CarreraRecomendada({
    required this.nombre,
    this.facultad,
    this.area,
    this.razon,
  });

  factory CarreraRecomendada.fromJson(Map<String, dynamic> json) {
    return CarreraRecomendada(
      // Backend returns 'name' (React type: RecomendacionCarrera.name)
      nombre: (json['name'] ?? json['nombre'] ?? '').toString(),
      facultad: (json['faculty'] ?? json['facultad'])?.toString(),
      area: json['area']?.toString(),
      razon: (json['razon'] ?? json['reason'])?.toString(),
    );
  }
}

class PlanDesarrollo {
  final List<String> cortoPlazo;
  final List<String> medianoPlazo;
  final List<String> largoPlazo;

  PlanDesarrollo({
    this.cortoPlazo = const [],
    this.medianoPlazo = const [],
    this.largoPlazo = const [],
  });

  factory PlanDesarrollo.fromJson(Map<String, dynamic> json) {
    List<String> toList(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return [];
    }

    return PlanDesarrollo(
      cortoPlazo: toList(json['cortoPlazo'] ?? json['corto_plazo']),
      medianoPlazo: toList(json['medianoPlazo'] ?? json['mediano_plazo']),
      largoPlazo: toList(json['largoPlazo'] ?? json['largo_plazo']),
    );
  }

  bool get isEmpty =>
      cortoPlazo.isEmpty && medianoPlazo.isEmpty && largoPlazo.isEmpty;
}

class HollandResults {
  final String sesionId;
  final String codigoHolland;
  final String perfilDominante;
  final String perfilSecundario;
  final double nivelConfianza;
  final List<RiasecDimension> dimensiones;
  final List<CarreraRecomendada> carrerasRecomendadas;
  final Map<String, dynamic> perfilVocacional;
  final List<String> fortalezas;
  final List<String> debilidades;
  final List<String> oportunidades;
  final List<String> areasDesarrollo;
  final List<String> sugerenciasAcompanamiento;
  final PlanDesarrollo? planDesarrollo;

  HollandResults({
    required this.sesionId,
    required this.codigoHolland,
    required this.perfilDominante,
    required this.perfilSecundario,
    this.nivelConfianza = 0,
    required this.dimensiones,
    required this.carrerasRecomendadas,
    required this.perfilVocacional,
    required this.fortalezas,
    required this.debilidades,
    required this.oportunidades,
    required this.areasDesarrollo,
    this.sugerenciasAcompanamiento = const [],
    this.planDesarrollo,
  });

  factory HollandResults.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    final perfil = (data['perfilVocacional'] as Map<String, dynamic>?) ?? {};

    List<String> toStringList(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return [];
    }

    List<RiasecDimension> parseDimensiones(dynamic v) {
      if (v is List) {
        return v
            .map((e) => RiasecDimension.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (v is Map) {
        // {R: 85, I: 70, ...}
        return v.entries.map((e) {
          return RiasecDimension(
            codigo: e.key,
            nombre: _riasecName(e.key),
            puntuacion: RiasecDimension._toDouble(e.value),
            descripcion: '',
          );
        }).toList();
      }
      return [];
    }

    // resultado puede estar anidado en data.resultado
    final resultado = data['resultado'] is Map
        ? data['resultado'] as Map<String, dynamic>
        : data;
    final perfilR = (resultado['perfilVocacional'] as Map<String, dynamic>?) ?? perfil;

    // Plan de desarrollo
    final planRaw = resultado['planDesarrollo'] ?? resultado['plan_desarrollo'];
    final plan = planRaw is Map<String, dynamic>
        ? PlanDesarrollo.fromJson(planRaw)
        : null;

    // Puntuaciones finales para dimensiones
    final dims = parseDimensiones(
      resultado['dimensiones'] ??
          resultado['puntuaciones'] ??
          data['puntuacionesFinales'] ??
          data['puntuaciones'],
    );

    return HollandResults(
      sesionId: (data['sesionId'] ?? data['sesion_id'] ?? '').toString(),
      codigoHolland: (resultado['codigoHolland'] ?? resultado['codigo_holland'] ?? data['codigoHolland'] ?? '').toString(),
      perfilDominante: (resultado['perfilDominante'] ?? resultado['perfil_dominante'] ?? perfilR['perfilDominante'] ?? '').toString(),
      perfilSecundario: (resultado['perfilSecundario'] ?? resultado['perfil_secundario'] ?? perfilR['perfilSecundario'] ?? '').toString(),
      nivelConfianza: RiasecDimension._toDouble(resultado['nivelConfianza'] ?? resultado['nivel_confianza'] ?? 0),
      dimensiones: dims,
      carrerasRecomendadas: ((resultado['recomendacionesCarreras'] ?? resultado['recomendaciones_carreras'] ?? resultado['carrerasRecomendadas'] ?? data['carrerasRecomendadas']) as List? ?? [])
          .map((e) => CarreraRecomendada.fromJson(e as Map<String, dynamic>))
          .toList(),
      perfilVocacional: perfilR,
      fortalezas: toStringList(perfilR['fortalezas'] ?? resultado['fortalezas']),
      debilidades: toStringList(
        perfilR['debilidadesPotenciales'] ?? perfilR['debilidades'] ?? resultado['debilidades'],
      ),
      oportunidades: toStringList(perfilR['oportunidades'] ?? resultado['oportunidades']),
      areasDesarrollo: toStringList(resultado['areasDesarrollo'] ?? perfilR['areasDesarrollo']),
      sugerenciasAcompanamiento: toStringList(resultado['sugerenciasAcompanamiento'] ?? resultado['sugerencias_acompanamiento']),
      planDesarrollo: plan,
    );
  }

  static String _riasecName(String code) {
    const names = {
      'R': 'Realista',
      'I': 'Investigador',
      'A': 'Artístico',
      'S': 'Social',
      'E': 'Emprendedor',
      'C': 'Convencional',
    };
    return names[code.toUpperCase()] ?? code;
  }
}

// ─── ICO Results ──────────────────────────────────────────────────────────────

class IcoResults {
  final String sesionId;
  final String codigoHolland;
  final String perfilDominante;
  final String perfilSecundario;
  final List<RiasecDimension> dimensiones;
  final String resumen;
  final List<String> fortalezas;
  final List<String> areasExplorar;
  final List<CarreraRecomendada> carrerasRecomendadas;
  final List<String> sugerencias;

  IcoResults({
    required this.sesionId,
    this.codigoHolland = '',
    this.perfilDominante = '',
    this.perfilSecundario = '',
    this.dimensiones = const [],
    required this.resumen,
    required this.fortalezas,
    required this.areasExplorar,
    required this.carrerasRecomendadas,
    required this.sugerencias,
  });

  factory IcoResults.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    final analisis = (data['analisis_llm'] ?? data['analisisLlm']) as Map<String, dynamic>? ?? {};
    final perfil = (analisis['perfilVocacional'] as Map<String, dynamic>?) ??
        (data['perfilVocacional'] as Map<String, dynamic>?) ??
        {};

    List<String> toStringList(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return [];
    }

    List<RiasecDimension> parseDimensiones(dynamic v) {
      if (v is List) {
        return v
            .map((e) => RiasecDimension.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (v is Map) {
        return v.entries.map((e) {
          return RiasecDimension(
            codigo: e.key,
            nombre: HollandResults._riasecName(e.key),
            puntuacion: RiasecDimension._toDouble(e.value),
            descripcion: '',
          );
        }).toList();
      }
      return [];
    }

    // Carreras: priorizar recomendacionesCarreras del root, luego del LLM
    final carrerasRaw = (data['recomendaciones_carreras'] ?? data['recomendacionesCarreras']) as List?;
    final carrerasLlm = (analisis['carrerasRecomendadas']) as List?;
    final carrerasList = carrerasRaw ?? carrerasLlm ?? [];

    return IcoResults(
      sesionId: (data['sesionId'] ?? data['sesion_id'] ?? '').toString(),
      codigoHolland: (data['codigo_holland'] ?? data['codigoHolland'] ?? '').toString(),
      perfilDominante: (data['perfil_dominante'] ?? data['perfilDominante'] ?? '').toString(),
      perfilSecundario: (data['perfil_secundario'] ?? data['perfilSecundario'] ?? '').toString(),
      dimensiones: parseDimensiones(data['puntuaciones_finales'] ?? data['puntuacionesFinales'] ?? data['puntuaciones']),
      resumen: (perfil['resumen'] ?? data['resumen'] ?? '').toString(),
      fortalezas: toStringList(perfil['fortalezas'] ?? data['fortalezas']),
      areasExplorar: toStringList(
        perfil['areasExplorar'] ?? data['areasExplorar'] ?? data['areas_explorar'],
      ),
      carrerasRecomendadas: carrerasList
          .map((e) => CarreraRecomendada.fromJson(e as Map<String, dynamic>))
          .toList(),
      sugerencias: toStringList(
        analisis['sugerenciasAcompanamiento'] ?? data['sugerenciasAcompanamiento'] ?? data['sugerencias'],
      ),
    );
  }
}

// ─── Historial ────────────────────────────────────────────────────────────────

class SesionProgreso {
  final String sesionId;
  final String tipoTest;
  final String estado;
  final String fechaInicio;

  SesionProgreso({
    required this.sesionId,
    required this.tipoTest,
    required this.estado,
    required this.fechaInicio,
  });

  factory SesionProgreso.fromJson(Map<String, dynamic> json) {
    return SesionProgreso(
      sesionId: (json['id'] ?? json['sesionId'] ?? json['sesion_id'] ?? '').toString(),
      tipoTest: (json['tipoTest'] ?? json['tipo_test'] ?? '').toString(),
      estado: (json['estado'] ?? '').toString(),
      fechaInicio: (json['fechaInicio'] ?? json['fecha_inicio'] ?? '').toString(),
    );
  }
}

class SesionCompletada {
  final String sesionId;
  final String tipoTest;
  final String estado;
  final String fechaCompletado;
  final String perfilDominante;

  SesionCompletada({
    required this.sesionId,
    required this.tipoTest,
    required this.estado,
    required this.fechaCompletado,
    required this.perfilDominante,
  });

  factory SesionCompletada.fromJson(Map<String, dynamic> json) {
    return SesionCompletada(
      sesionId: (json['id'] ?? json['sesionId'] ?? json['sesion_id'] ?? '').toString(),
      tipoTest: (json['tipoTest'] ?? json['tipo_test'] ?? '').toString(),
      estado: (json['estado'] ?? '').toString(),
      fechaCompletado: (json['fechaCompletado'] ?? json['fecha_completado'] ?? json['updatedAt'] ?? '').toString(),
      perfilDominante: (json['perfilDominante'] ?? json['perfil_dominante'] ?? '').toString(),
    );
  }
}

class Historial {
  final List<SesionProgreso> sesionesEnProgreso;
  final List<SesionCompletada> sesionesCompletadas;

  Historial({
    required this.sesionesEnProgreso,
    required this.sesionesCompletadas,
  });

  factory Historial.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;

    bool isCompleted(Map<String, dynamic> s) {
      final tieneResultado = s['tiene_resultado'] == true || s['tieneResultado'] == true;
      if (tieneResultado) return true;
      final e = (s['estado'] ?? '').toString().toLowerCase();
      return RegExp(r'finalizada|completada|completed|ronda_2_completada').hasMatch(e);
    }

    final rawHistorial = data['historial'] as List? ?? [];
    final rawEnProgreso = data['sesionesEnProgreso'] as List? ?? [];

    final completadas = rawHistorial
        .cast<Map<String, dynamic>>()
        .where((s) => isCompleted(s))
        .map((s) => SesionCompletada.fromJson(s))
        .toList();

    final enProgreso = rawEnProgreso
        .cast<Map<String, dynamic>>()
        .map((s) => SesionProgreso.fromJson(s))
        .toList();

    // Also check historial for in-progress if sesionesEnProgreso is empty
    if (enProgreso.isEmpty) {
      final fromHistorial = rawHistorial
          .cast<Map<String, dynamic>>()
          .where((s) => !isCompleted(s))
          .map((s) => SesionProgreso.fromJson(s))
          .toList();
      return Historial(
        sesionesEnProgreso: fromHistorial,
        sesionesCompletadas: completadas,
      );
    }

    return Historial(
      sesionesEnProgreso: enProgreso,
      sesionesCompletadas: completadas,
    );
  }
}

// ─── Vocational Profile ───────────────────────────────────────────────────────

class PerfilVocacional {
  final String perfilDominante;
  final String perfilSecundario;
  final String codigoHolland;
  final double nivelConfianza;
  final int totalTests;
  final List<RiasecDimension> dimensiones;
  final List<CarreraRecomendada> carrerasRecomendadas;
  final List<String> fortalezas;
  final List<String> debilidades;
  final List<String> oportunidades;
  final String? ultimaSesionId;
  final String? ultimoTipoTest;

  PerfilVocacional({
    required this.perfilDominante,
    required this.perfilSecundario,
    this.codigoHolland = '',
    this.nivelConfianza = 0,
    required this.totalTests,
    required this.dimensiones,
    required this.carrerasRecomendadas,
    required this.fortalezas,
    required this.debilidades,
    required this.oportunidades,
    this.ultimaSesionId,
    this.ultimoTipoTest,
  });

  factory PerfilVocacional.fromJson(Map<String, dynamic> json) {
    // Response: { data: { resultadoActual: { sesionId, resultado: {...}, puntuacionesFinales }, historial: [...] } }
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;

    // Navigate to resultadoActual.resultado where the actual profile lives
    final resultadoActual = data['resultadoActual'] is Map
        ? data['resultadoActual'] as Map<String, dynamic>
        : <String, dynamic>{};
    final resultado = resultadoActual['resultado'] is Map
        ? resultadoActual['resultado'] as Map<String, dynamic>
        : <String, dynamic>{};

    // puntuacionesFinales is a Map<String, num> at resultadoActual level
    final puntuaciones = resultadoActual['puntuacionesFinales'] is Map
        ? resultadoActual['puntuacionesFinales'] as Map
        : resultado['puntuaciones'] is Map
            ? resultado['puntuaciones'] as Map
            : null;

    // perfilVocacional nested inside resultado
    final perfil = resultado['perfilVocacional'] is Map
        ? resultado['perfilVocacional'] as Map<String, dynamic>
        : <String, dynamic>{};

    // historial for counting total tests + getting last session
    final historial = data['historial'] is List
        ? (data['historial'] as List).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];

    // React uses historial.length (ALL entries) for total count
    final totalHistorial = historial.length;

    // Find last completed session using broad filter (same as Historial.fromJson)
    bool isCompleted(Map<String, dynamic> h) {
      final e = (h['estado'] ?? '').toString().toLowerCase();
      return RegExp(r'finalizada|completada|completed|ronda_2_completada').hasMatch(e);
    }
    final completados = historial.where(isCompleted).toList();

    // Find last completed session
    String? ultimaSesionId = resultadoActual['sesionId']?.toString();
    String? ultimoTipoTest;
    if (completados.isNotEmpty) {
      final ultimo = completados.last;
      ultimaSesionId ??= ultimo['id']?.toString();
      ultimoTipoTest = (ultimo['tipoTest'] ?? ultimo['tipo_test'] ?? '').toString();
    }

    List<String> toStringList(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return [];
    }

    List<RiasecDimension> parseDimensiones(dynamic v) {
      if (v is List) {
        return v
            .map((e) => RiasecDimension.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (v is Map) {
        return v.entries.map((e) {
          return RiasecDimension(
            codigo: e.key.toString(),
            nombre: HollandResults._riasecName(e.key.toString()),
            puntuacion: RiasecDimension._toDouble(e.value),
            descripcion: '',
          );
        }).toList();
      }
      return [];
    }

    // Fallback: if resultadoActual is empty, try flat structure (data directly has fields)
    final src = resultado.isNotEmpty ? resultado : data;
    final perfilSrc = perfil.isNotEmpty ? perfil : data;

    return PerfilVocacional(
      perfilDominante: (src['perfilDominante'] ?? '').toString(),
      perfilSecundario: (src['perfilSecundario'] ?? '').toString(),
      codigoHolland: (src['codigoHolland'] ?? src['codigo_holland'] ?? '').toString(),
      nivelConfianza: RiasecDimension._toDouble(src['nivelConfianza'] ?? src['nivel_confianza'] ?? 0),
      totalTests: totalHistorial > 0 ? totalHistorial : (int.tryParse((data['totalTests'] ?? 0).toString()) ?? 0),
      dimensiones: parseDimensiones(puntuaciones ?? src['dimensiones'] ?? src['puntuaciones']),
      carrerasRecomendadas: (
        src['recomendacionesCarreras'] as List? ??
        src['recomendaciones_carreras'] as List? ??
        src['carrerasRecomendadas'] as List? ??
        []
      ).map((e) => CarreraRecomendada.fromJson(e as Map<String, dynamic>)).toList(),
      fortalezas: toStringList(perfilSrc['fortalezas']),
      debilidades: toStringList(
        perfilSrc['debilidadesPotenciales'] ?? perfilSrc['debilidades'],
      ),
      oportunidades: toStringList(perfilSrc['oportunidades']),
      ultimaSesionId: ultimaSesionId,
      ultimoTipoTest: ultimoTipoTest,
    );
  }
}

// ─── Notification ─────────────────────────────────────────────────────────────

class VocationalNotification {
  final String id;
  final String tipo;
  final String titulo;
  final String mensaje;
  final bool leido;
  final String fecha;
  final String? urlAccion;
  final String? ctaTexto;

  VocationalNotification({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.leido,
    required this.fecha,
    this.urlAccion,
    this.ctaTexto,
  });

  factory VocationalNotification.fromJson(Map<String, dynamic> json) {
    // Backend fields: contenido, leida, fecha_creacion, metadata { url, cta }
    final metadata = json['metadata'] is Map ? json['metadata'] as Map : null;
    return VocationalNotification(
      id: (json['id'] ?? '').toString(),
      tipo: (json['tipo'] ?? 'anuncio').toString(),
      titulo: (json['titulo'] ?? json['title'] ?? '').toString(),
      mensaje: (json['contenido'] ?? json['mensaje'] ?? json['message'] ?? '').toString(),
      leido: json['leida'] == true || json['leido'] == true || json['read'] == true,
      fecha: (json['fecha_creacion'] ?? json['fecha'] ?? json['createdAt'] ?? json['created_at'] ?? '').toString(),
      urlAccion: metadata?['url']?.toString() ?? json['urlAccion']?.toString() ?? json['url']?.toString(),
      ctaTexto: metadata?['cta']?.toString(),
    );
  }
}
