import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/vocational_models.dart';

class VocationalService {
  final ApiClient _client = ApiClient();

  // ─── Historial ────────────────────────────────────────────────────────────

  Future<Historial> obtenerHistorial() async {
    try {
      final response = await _client.dio.get('/v1/orientacion/historial');
      if (response.statusCode == 200) {
        final data = response.data;
        return Historial.fromJson(data is Map<String, dynamic> ? data : {'historial': [], 'sesionesEnProgreso': []});
      }
      throw Exception('Error al obtener historial: ${response.statusCode}');
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  // ─── Iniciar tests ────────────────────────────────────────────────────────

  Future<IniciarTestResponse> iniciarTestHolland() async {
    try {
      final response = await _client.dio.post(
        '/v1/orientacion/iniciar-test',
        data: {'tipoTest': 'Holland_RIASEC'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return IniciarTestResponse.fromJson(
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : {'data': response.data},
        );
      }
      final msg = (response.data is Map ? response.data['message'] : null) ?? 'Error al iniciar test';
      throw Exception(msg);
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<IniciarTestResponse> iniciarTestIco() async {
    try {
      final response = await _client.dio.post('/v1/orientacion/iniciar-test-ico');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return IniciarTestResponse.fromJson(
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : {'data': response.data},
        );
      }
      final msg = (response.data is Map ? response.data['message'] : null) ?? 'Error al iniciar ICO';
      throw Exception(msg);
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<PreguntasIcoResponse> obtenerPreguntasIco(String sesionId) async {
    try {
      final response = await _client.dio.get('/v1/orientacion/sesion-ico/$sesionId/preguntas');
      if (response.statusCode == 200) {
        return PreguntasIcoResponse.fromJson(
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : {'data': response.data},
        );
      }
      throw Exception('Error al obtener preguntas ICO: ${response.statusCode}');
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Map<String, dynamic>> obtenerSesion(String sesionId) async {
    try {
      final response = await _client.dio.get('/v1/orientacion/sesion/$sesionId');
      if (response.statusCode == 200) {
        return response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : {};
      }
      throw Exception('Error al obtener sesión: ${response.statusCode}');
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  // ─── Guardar respuestas ────────────────────────────────────────────────────

  Future<Ronda1Response> guardarRespuestasRonda1(
    String sesionId,
    List<VocationalAnswer> respuestas,
  ) async {
    try {
      final response = await _client.dio.post(
        '/v1/orientacion/guardar-respuestas-ronda-1',
        data: {
          'sesionId': sesionId,
          'respuestas': respuestas.map((r) => r.toJson()).toList(),
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Ronda1Response.fromJson(
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : {'data': response.data},
        );
      }
      final msg = (response.data is Map ? response.data['message'] : null) ?? 'Error al guardar Ronda 1';
      throw Exception(msg);
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Map<String, dynamic>> guardarRespuestasRonda2(
    String sesionId,
    List<VocationalAnswer> respuestas,
  ) async {
    try {
      final response = await _client.dio.post(
        '/v1/orientacion/guardar-respuestas-ronda-2',
        data: {
          'sesionId': sesionId,
          'respuestas': respuestas.map((r) => r.toJson()).toList(),
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : {};
      }
      final msg = (response.data is Map ? response.data['message'] : null) ?? 'Error al guardar Ronda 2';
      throw Exception(msg);
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Map<String, dynamic>> guardarRespuestasIco(
    String sesionId,
    List<VocationalAnswer> respuestas,
  ) async {
    try {
      final response = await _client.dio.post(
        '/v1/orientacion/guardar-respuestas-ico',
        data: {
          'sesionId': sesionId,
          'respuestas': respuestas.map((r) => r.toJson()).toList(),
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : {};
      }
      final msg = (response.data is Map ? response.data['message'] : null) ?? 'Error al guardar ICO';
      throw Exception(msg);
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  // ─── Resultados ──────────────────────────────────────────────────────────

  Future<HollandResults> obtenerResultados(String sesionId) async {
    try {
      final response = await _client.dio.get(
        '/v1/orientacion/resultados/$sesionId',
      );
      if (response.statusCode == 200) {
        return HollandResults.fromJson(
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : {'data': response.data},
        );
      }
      throw Exception('Error al obtener resultados: ${response.statusCode}');
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<IcoResults> obtenerResultadosIco(String sesionId) async {
    try {
      final response = await _client.dio.get(
        '/v1/orientacion/resultados-ico/$sesionId',
      );
      if (response.statusCode == 200) {
        return IcoResults.fromJson(
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : {'data': response.data},
        );
      }
      throw Exception('Error al obtener resultados ICO: ${response.statusCode}');
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  // ─── Perfil vocacional ────────────────────────────────────────────────────

  Future<PerfilVocacional> obtenerPerfilVocacional() async {
    try {
      final response = await _client.dio.get('/v1/orientacion/mi-perfil-vocacional');
      if (response.statusCode == 200) {
        return PerfilVocacional.fromJson(
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : {'data': response.data},
        );
      }
      throw Exception('Error al obtener perfil: ${response.statusCode}');
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  // ─── Notificaciones ───────────────────────────────────────────────────────

  Future<List<VocationalNotification>> obtenerNotificaciones({int limit = 20}) async {
    try {
      final response = await _client.dio.get(
        '/v1/notificaciones/mis-notificaciones',
        queryParameters: {'limite': limit},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list;
        // Response shape: { data: { notificaciones: [...] } }
        if (data is Map && data['data'] is Map && data['data']['notificaciones'] is List) {
          list = data['data']['notificaciones'] as List;
        } else if (data is Map && data['data'] is List) {
          list = data['data'] as List;
        } else if (data is Map && data['notificaciones'] is List) {
          list = data['notificaciones'] as List;
        } else if (data is List) {
          list = data;
        } else {
          list = [];
        }
        return list
            .map((e) => VocationalNotification.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<void> marcarComoLeida(String notifId) async {
    try {
      await _client.dio.patch('/v1/notificaciones/$notifId/marcar-leida');
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<void> marcarTodasComoLeidas() async {
    try {
      await _client.dio.patch('/v1/notificaciones/marcar-todas-leidas');
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  // ─── Especialista: obtener estudiantes ───────────────────────────────────

  Future<List<Map<String, dynamic>>> obtenerEstudiantesEspecialista() async {
    try {
      final response = await _client.dio.get('/v1/orientacion/historial-especialista');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) return data.cast<Map<String, dynamic>>();
        if (data is Map && data['data'] is List) {
          return (data['data'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      }
      return [];
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  // ─── Citas ────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> obtenerMisCitas() async {
    try {
      final response = await _client.dio.get('/v1/citas');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) return data.cast<Map<String, dynamic>>();
        if (data is Map && data['data'] is List) {
          return (data['data'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      }
      return [];
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Map<String, dynamic>> agendarCita({
    required String estudianteId,
    required String especialistaId,
    required String fecha,
    required String hora,
    required String modalidad,
    required String motivo,
    String? notas,
  }) async {
    try {
      final response = await _client.dio.post('/v1/citas', data: {
        'estudianteId': estudianteId,
        'especialistaId': especialistaId,
        'fecha': fecha,
        'hora': hora,
        'modalidad': modalidad,
        'motivo': motivo,
        if (notas != null) 'notas': notas,
      });
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {};
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<void> actualizarCita(String citaId, String estado) async {
    try {
      await _client.dio.patch('/v1/citas/$citaId', data: {'estado': estado});
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<void> cancelarCita(String citaId) async {
    try {
      await _client.dio.delete('/v1/citas/$citaId');
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> obtenerCitasEstudiante(String userId) async {
    try {
      final response = await _client.dio.get('/v1/citas/estudiante/$userId');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is Map && data['data']['citas'] is List) {
          return (data['data']['citas'] as List).cast<Map<String, dynamic>>();
        }
        if (data is List) return data.cast<Map<String, dynamic>>();
        return [];
      }
      return [];
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  // ─── Trayectoria académica ────────────────────────────────────────────────

  Future<Map<String, dynamic>> obtenerMiTrayectoria() async {
    try {
      final response = await _client.dio.get('/v1/orientacion/trayectoria-academica');
      if (response.statusCode == 200) {
        return response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : {};
      }
      return {};
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Map<String, dynamic>> actualizarMiTrayectoria(Map<String, dynamic> body) async {
    try {
      final response = await _client.dio.put(
        '/v1/orientacion/trayectoria-academica',
        data: body,
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {};
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  // ─── Convertir aspirante a estudiante ──────────────────────────────────────

  Future<Map<String, dynamic>> convertirAspiranteAEstudiante({
    required String email,
    required String carrera,
    required int trimestre,
  }) async {
    try {
      final response = await _client.dio.post(
        '/v1/auth/convertir-aspirante',
        data: {
          'email': email,
          'carrera': carrera,
          'trimestre': trimestre,
        },
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {};
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  // ─── Campañas (especialista) ───────────────────────────────────────────────

  Future<Map<String, dynamic>> obtenerEstadisticasCampanas() async {
    try {
      final response = await _client.dio.get('/v1/campanas/estadisticas');
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {};
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Map<String, dynamic>> enviarGrupoPredefinido(Map<String, dynamic> body) async {
    try {
      final response = await _client.dio.post('/v1/campanas/enviar-grupo', data: body);
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {};
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Map<String, dynamic>> enviarCampana(Map<String, dynamic> body) async {
    try {
      final response = await _client.dio.post('/v1/campanas/enviar', data: body);
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {};
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> segmentarEstudiantes(Map<String, dynamic> filtros) async {
    try {
      final response = await _client.dio.post('/v1/campanas/segmentar', data: filtros);
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return (data['data'] as List).cast<Map<String, dynamic>>();
      }
      if (data is List) return data.cast<Map<String, dynamic>>();
      return [];
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  // ─── Preguntas CRUD (especialista) ──────────────────────────────────────────

  Future<Map<String, dynamic>> listarPreguntas({Map<String, dynamic>? params}) async {
    try {
      final response = await _client.dio.get('/v1/preguntas', queryParameters: params);
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {};
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Map<String, dynamic>> crearPregunta(Map<String, dynamic> body) async {
    try {
      final response = await _client.dio.post('/v1/preguntas', data: body);
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {};
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Map<String, dynamic>> actualizarPregunta(String id, Map<String, dynamic> body) async {
    try {
      final response = await _client.dio.put('/v1/preguntas/$id', data: body);
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {};
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<void> desactivarPregunta(String id) async {
    try {
      await _client.dio.patch('/v1/preguntas/$id/desactivar');
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  // ─── Carreras CRUD (especialista) ──────────────────────────────────────────

  Future<Map<String, dynamic>> crearCareer(Map<String, dynamic> body) async {
    try {
      final response = await _client.dio.post('/careers', data: body);
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {};
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<Map<String, dynamic>> actualizarCareer(String id, Map<String, dynamic> body) async {
    try {
      final response = await _client.dio.put('/careers/$id', data: body);
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {};
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  Future<void> desactivarCareer(String id) async {
    try {
      await _client.dio.patch('/careers/$id/desactivar');
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  // ─── LLM / Chatbot vocacional ─────────────────────────────────────────────

  /// Chat conversacional — POST /v1/llm/chat
  Future<String> chatLLM(
    List<Map<String, String>> mensajes, {
    Map<String, dynamic>? contexto,
  }) async {
    try {
      final response = await _client.dio.post('/v1/llm/chat', data: {
        'mensajes': mensajes,
        if (contexto != null) 'contexto': contexto,
      });
      final d = response.data;
      if (d is Map) {
        return (d['data']?['respuesta'] ?? d['respuesta'] ?? d['message'] ?? '')
            .toString();
      }
      return d?.toString() ?? '';
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  /// Consulta puntual — POST /v1/llm/consulta
  Future<String> consultaLLM(String prompt, {Map<String, dynamic>? context}) async {
    try {
      final response = await _client.dio.post('/v1/llm/consulta', data: {
        'prompt': prompt,
        if (context != null) 'context': context,
      });
      final d = response.data;
      if (d is Map) {
        return (d['data']?['respuesta'] ?? d['respuesta'] ?? d['message'] ?? '')
            .toString();
      }
      return d?.toString() ?? '';
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  /// Recomendaciones IA — POST /v1/llm/recomendaciones
  Future<Map<String, dynamic>> generarRecomendaciones({
    required Map<String, dynamic> perfilEstudiante,
    required List<Map<String, String>> carrerasDisponibles,
  }) async {
    try {
      final response = await _client.dio.post('/v1/llm/recomendaciones', data: {
        'perfilEstudiante': perfilEstudiante,
        'carrerasDisponibles': carrerasDisponibles,
      });
      final d = response.data;
      if (d is Map) {
        final inner = d['data'];
        if (inner is Map) return inner as Map<String, dynamic>;
        return d as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }

  // ─── Perfil auth ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _client.dio.get('/v1/auth/perfil');
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {};
    } on DioException catch (e) {
      throw _client.handleError(e);
    }
  }
}
