import 'package:dio/dio.dart';
import '../models/becario.dart';
import '../models/reporte_semanal.dart';
import '../models/reportes_global_response.dart';
import '../models/plaza.dart';
import 'api_client.dart';

class SupervisorService {
  final ApiClient _apiClient = ApiClient();

  /// GET /v1/supervisores/{id}/ayudantes - Obtiene ayudantes de un supervisor específico
  Future<Map<String, dynamic>> getAyudantesBySupervisorId(String supervisorId) async {
    try {
      print('📡 Fetching ayudantes for supervisor: $supervisorId');
      final response = await _apiClient.dio.get(
        '/v1/supervisores/$supervisorId/ayudantes',
      );

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to get ayudantes');
      }

      final data = response.data['data'];
      if (data == null) {
        throw Exception('Ayudantes data is null');
      }

      print('✅ Ayudantes retrieved: ${data['total']} ayudantes');

      final ayudantesList = (data['ayudantes'] as List<dynamic>?)
              ?.map((e) => Becario.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      return {
        'supervisor': data['supervisor'],
        'ayudantes': ayudantesList,
        'total': data['total'] ?? 0,
      };
    } on DioException catch (e) {
      print('❌ Error getting ayudantes: ${e.response?.data}');
      throw _apiClient.handleError(e);
    }
  }

  /// GET /v1/becarios/supervisor/mis-ayudantes - Endpoint antiguo (mantener por compatibilidad)
  Future<List<Becario>> getMyAssistants({String? estado}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (estado != null) queryParams['estado'] = estado;

      final response = await _apiClient.dio.get(
        '/v1/becarios/supervisor/mis-ayudantes',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final ayudantes = data['ayudantes'] as List;

      return ayudantes.map((json) => Becario.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<List<ReporteSemanal>> getReportsForAssistant(
    String estudianteBecarioId, {
    String? estado,
    String? periodoAcademico,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (estado != null) queryParams['estado'] = estado;
      if (periodoAcademico != null) {
        queryParams['periodoAcademico'] = periodoAcademico;
      }

      final response = await _apiClient.dio.get(
        '/v1/ayudantias/$estudianteBecarioId/reportes',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final reportes = data['reportes'] as List;

      return reportes.map((json) => ReporteSemanal.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<List<ReporteSemanal>> getPendingReports() async {
    try {
      final assistants = await getMyAssistants();
      List<ReporteSemanal> allPendingReports = [];

      for (var assistant in assistants) {
        final reports = await getReportsForAssistant(
          assistant.id,
          estado: 'Pendiente',
        );
        allPendingReports.addAll(reports);
      }

      return allPendingReports;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> approveReport(
    String becarioId,
    String reporteId, {
    String? observaciones,
  }) async {
    try {
      await _apiClient.dio.patch(
        '/v1/ayudantias/$becarioId/reportes/$reporteId/aprobar',
        data: observaciones != null ? {'observaciones': observaciones} : null,
      );
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<void> rejectReport(
    String becarioId,
    String reporteId,
    String motivo,
  ) async {
    try {
      await _apiClient.dio.patch(
        '/v1/ayudantias/$becarioId/reportes/$reporteId/rechazar',
        data: {'motivo': motivo},
      );
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<Becario> getAssistantById(String becarioId) async {
    try {
      final response = await _apiClient.dio.get('/v1/becarios/$becarioId');
      return Becario.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  /// GET /v1/reportes/all?supervisorId={id} - Obtiene reportes filtrados por supervisor
  Future<ReportesGlobalResponse> getReportesBySupervisorId(
    String supervisorId, {
    String? estado,
    String? periodoAcademico,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      print('📡 Fetching reportes for supervisor: $supervisorId');
      final queryParams = <String, dynamic>{
        'supervisorId': supervisorId,
        'limit': limit,
        'offset': offset,
      };
      if (estado != null) queryParams['estado'] = estado;
      if (periodoAcademico != null) queryParams['periodoAcademico'] = periodoAcademico;

      final response = await _apiClient.dio.get(
        '/v1/reportes/all',
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to get reportes');
      }

      final data = response.data['data'];
      if (data == null) {
        throw Exception('Reportes data is null');
      }

      print('✅ Reportes retrieved: ${data['total']} reportes');
      return ReportesGlobalResponse.fromJson(data);
    } on DioException catch (e) {
      print('❌ Error getting reportes: ${e.response?.data}');
      throw _apiClient.handleError(e);
    }
  }

  /// GET /v1/plazas/{id} - Obtiene una plaza por ID
  Future<Plaza?> getPlazaById(String plazaId) async {
    try {
      print('📡 Fetching plaza by ID: $plazaId');
      final response = await _apiClient.dio.get('/v1/plazas/$plazaId');

      if (response.data == null) {
        print('⚠️ No plaza data found');
        return null;
      }

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to get plaza');
      }

      final data = response.data['data'];
      if (data == null) {
        print('⚠️ No plaza data in response');
        return null;
      }

      print('✅ Plaza info retrieved successfully');
      return Plaza.fromJson(data);
    } on DioException catch (e) {
      print('❌ Error getting plaza: ${e.response?.data}');
      throw _apiClient.handleError(e);
    } catch (e) {
      print('❌ General error getting plaza: $e');
      rethrow;
    }
  }
}
