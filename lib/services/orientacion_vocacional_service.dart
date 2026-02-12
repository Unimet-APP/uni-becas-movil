import 'package:dio/dio.dart';
import '../models/orientacion_vocacional.dart';
import 'api_client.dart';

class OrientacionVocacionalService {
  final ApiClient _apiClient = ApiClient();

  // ==================== TESTS ====================

  /// Iniciar un nuevo test Holland RIASEC
  Future<Map<String, dynamic>> iniciarTest(TipoTest tipoTest) async {
    final response = await _apiClient.dio.post(
      '/v1/orientacion/iniciar-test',
      data: {'tipoTest': tipoTest.value},
    );
    return response.data;
  }

  /// Iniciar un nuevo test ICO
  Future<Map<String, dynamic>> iniciarTestIco() async {
    final response = await _apiClient.dio.post(
      '/v1/orientacion/iniciar-test-ico',
    );
    return response.data;
  }

  /// Obtener preguntas del test ICO
  Future<List<Pregunta>> obtenerPreguntasIco(String sesionId) async {
    final response = await _apiClient.dio.get(
      '/v1/orientacion/sesion-ico/$sesionId/preguntas',
    );
    final preguntas = (response.data['data']?['preguntas'] as List?) ?? [];
    return preguntas.map((e) => Pregunta.fromJson(e)).toList();
  }

  /// Guardar respuestas de Ronda 1
  Future<Map<String, dynamic>> guardarRespuestasRonda1(
    String sesionId,
    List<RespuestaPregunta> respuestas,
  ) async {
    final response = await _apiClient.dio.post(
      '/v1/orientacion/guardar-respuestas-ronda-1',
      data: {
        'sesionId': sesionId,
        'respuestas': respuestas.map((r) => r.toJson()).toList(),
      },
    );
    return response.data;
  }

  /// Guardar respuestas de Ronda 2
  Future<Map<String, dynamic>> guardarRespuestasRonda2(
    String sesionId,
    List<RespuestaPregunta> respuestas,
  ) async {
    final response = await _apiClient.dio.post(
      '/v1/orientacion/guardar-respuestas-ronda-2',
      data: {
        'sesionId': sesionId,
        'respuestas': respuestas.map((r) => r.toJson()).toList(),
      },
    );
    return response.data;
  }

  /// Guardar respuestas del test ICO
  Future<Map<String, dynamic>> guardarRespuestasIco(
    String sesionId,
    List<RespuestaIcoBody> respuestas,
  ) async {
    final response = await _apiClient.dio.post(
      '/v1/orientacion/guardar-respuestas-ico',
      data: {
        'sesionId': sesionId,
        'respuestas': respuestas.map((r) => r.toJson()).toList(),
      },
    );
    return response.data;
  }

  /// Obtener información de una sesión
  Future<Map<String, dynamic>> obtenerSesion(String sesionId) async {
    final response = await _apiClient.dio.get(
      '/v1/orientacion/sesion/$sesionId',
    );
    return response.data;
  }

  /// Obtener resultados de una sesión Holland
  Future<Map<String, dynamic>> obtenerResultados(String sesionId) async {
    final response = await _apiClient.dio.get(
      '/v1/orientacion/resultados/$sesionId',
    );
    return response.data;
  }

  /// Obtener resultados de una sesión ICO
  Future<Map<String, dynamic>> obtenerResultadosIco(String sesionId) async {
    final response = await _apiClient.dio.get(
      '/v1/orientacion/resultados-ico/$sesionId',
    );
    return response.data;
  }

  // ==================== HISTORIAL Y PERFIL ====================

  /// Obtener historial de tests realizados
  Future<Map<String, List<HistorialItem>>> obtenerHistorial() async {
    final response = await _apiClient.dio.get('/v1/orientacion/historial');
    final data = response.data;

    List<HistorialItem> historial = [];
    List<HistorialItem> sesionesEnProgreso = [];

    if (data is Map && data['data'] != null) {
      final d = data['data'];
      if (d is Map) {
        if (d['historial'] is List) {
          historial = (d['historial'] as List)
              .map((e) => HistorialItem.fromJson(e))
              .toList();
        }
        if (d['sesionesEnProgreso'] is List) {
          sesionesEnProgreso = (d['sesionesEnProgreso'] as List)
              .map((e) => HistorialItem.fromJson(e))
              .toList();
        }
        // If only flat array
        if (historial.isEmpty && sesionesEnProgreso.isEmpty) {
          final arr = _extractArray(d);
          historial = arr.where((s) => s.isCompleted).toList();
          sesionesEnProgreso = arr.where((s) => !s.isCompleted).toList();
        }
      } else if (d is List) {
        final arr = d.map((e) => HistorialItem.fromJson(e)).toList();
        historial = arr.where((s) => s.isCompleted).toList();
        sesionesEnProgreso = arr.where((s) => !s.isCompleted).toList();
      }
    } else if (data is List) {
      final arr = data.map((e) => HistorialItem.fromJson(e)).toList();
      historial = arr.where((s) => s.isCompleted).toList();
      sesionesEnProgreso = arr.where((s) => !s.isCompleted).toList();
    }

    return {
      'historial': historial,
      'sesionesEnProgreso': sesionesEnProgreso,
    };
  }

  List<HistorialItem> _extractArray(Map<dynamic, dynamic> d) {
    for (final key in ['historial', 'sesiones', 'data']) {
      if (d[key] is List) {
        return (d[key] as List)
            .map((e) => HistorialItem.fromJson(e))
            .toList();
      }
    }
    // Find first array
    for (final val in d.values) {
      if (val is List) {
        return val.map((e) => HistorialItem.fromJson(e)).toList();
      }
    }
    return [];
  }

  /// Obtener perfil vocacional consolidado
  Future<Map<String, dynamic>?> obtenerPerfilVocacional() async {
    try {
      final response =
          await _apiClient.dio.get('/v1/orientacion/mi-perfil-vocacional');
      return response.data?['data'];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  // ==================== TRAYECTORIA ACADEMICA ====================

  /// Obtener trayectoria académica
  Future<TrayectoriaBody> obtenerTrayectoria() async {
    try {
      final response =
          await _apiClient.dio.get('/v1/orientacion/trayectoria-academica');
      return TrayectoriaBody.fromJson(response.data?['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return TrayectoriaBody();
      rethrow;
    }
  }

  /// Actualizar trayectoria académica
  Future<void> actualizarTrayectoria(TrayectoriaBody body) async {
    await _apiClient.dio.put(
      '/v1/orientacion/trayectoria-academica',
      data: body.toJson(),
    );
  }

  // ==================== NOTIFICACIONES ====================

  /// Obtener notificaciones del usuario
  Future<List<Notificacion>> obtenerNotificaciones({int limit = 10}) async {
    final response = await _apiClient.dio.get(
      '/v1/notificaciones/mis-notificaciones',
      queryParameters: {'limit': limit},
    );
    final notifs = response.data?['data']?['notificaciones'];
    if (notifs is List) {
      return notifs.map((e) => Notificacion.fromJson(e)).toList();
    }
    return [];
  }

  /// Marcar notificación como leída
  Future<void> marcarNotificacionLeida(String notificacionId) async {
    await _apiClient.dio.patch(
      '/v1/notificaciones/$notificacionId/leida',
    );
  }

  /// Marcar todas como leídas
  Future<void> marcarTodasLeidas() async {
    await _apiClient.dio.patch('/v1/notificaciones/marcar-todas-leidas');
  }

  // ==================== CITAS ====================

  /// Obtener citas del estudiante
  Future<List<Cita>> obtenerCitas(String userId) async {
    final response = await _apiClient.dio.get('/v1/citas/estudiante/$userId');
    final citas = response.data?['data']?['citas'];
    if (citas is List) {
      return citas.map((e) => Cita.fromJson(e)).toList();
    }
    return [];
  }

  /// Confirmar una cita
  Future<void> confirmarCita(String citaId) async {
    await _apiClient.dio.patch(
      '/v1/citas/$citaId',
      data: {'estado': 'confirmada'},
    );
  }

  /// Cancelar una cita
  Future<void> cancelarCita(String citaId) async {
    await _apiClient.dio.delete('/v1/citas/$citaId');
  }
}
