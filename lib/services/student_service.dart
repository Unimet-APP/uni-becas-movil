import 'package:dio/dio.dart';
import '../models/becario.dart';
import '../models/plaza.dart';
import '../models/reporte_semanal.dart';
import '../models/periodo_config.dart';
import '../models/reportes_global_response.dart';
import 'api_client.dart';

class StudentService {
  final ApiClient _apiClient = ApiClient();

  /// GET /v1/becarios/me - Obtiene info del becario actual (token-based)
  Future<Becario?> getMyBecario(String userId) async {
    try {
      print('📡 Fetching becario info for user: $userId');
      final response = await _apiClient.dio.get('/v1/becarios/me');

      if (response.data == null) {
        print('⚠️ No becario data found');
        return null;
      }

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to get becario');
      }

      final data = response.data['data'];
      if (data == null) {
        return null;
      }

      print('✅ Becario info retrieved');
      return Becario.fromJson(data);
    } on DioException catch (e) {
      print('❌ Error getting becario: ${e.response?.data}');
      throw _apiClient.handleError(e);
    } catch (e) {
      print('❌ General error: $e');
      rethrow;
    }
  }

  /// GET /v1/plazas/{id} - Obtiene plaza por ID
  Future<Plaza?> getPlazaById(String plazaId) async {
    try {
      print('📡 Fetching plaza by ID: $plazaId');
      final response = await _apiClient.dio.get('/v1/plazas/$plazaId');

      if (response.data == null) {
        return null;
      }

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to get plaza');
      }

      final data = response.data['data'];
      if (data == null) {
        print('⚠️ No plaza found');
        return null;
      }

      print('✅ Plaza retrieved: ${data['materia']}');
      return Plaza.fromJson(data);
    } on DioException catch (e) {
      print('❌ Error getting plaza: ${e.response?.data}');
      throw _apiClient.handleError(e);
    } catch (e) {
      print('❌ General error: $e');
      rethrow;
    }
  }

  /// GET /v1/plazas?ayudanteId={userId} - Obtiene plaza asignada
  Future<Plaza?> getMyPlaza(String userId) async {
    try {
      print('📡 Fetching plaza for user: $userId');
      final response = await _apiClient.dio.get(
        '/v1/plazas',
        queryParameters: {'ayudanteId': userId},
      );

      if (response.data == null) {
        return null;
      }

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to get plaza');
      }

      final data = response.data['data'];
      if (data == null) {
        print('⚠️ No plaza assigned');
        return null;
      }

      // El API retorna { plazas: [], total, limit, offset }
      final plazasList = data['plazas'] as List?;
      if (plazasList == null || plazasList.isEmpty) {
        print('⚠️ No plaza assigned');
        return null;
      }

      final plazaData = plazasList.first as Map<String, dynamic>;
      print('✅ Plaza retrieved: ${plazaData['nombre']}');
      return Plaza.fromJson(plazaData);
    } on DioException catch (e) {
      print('❌ Error getting plaza: ${e.response?.data}');
      throw _apiClient.handleError(e);
    } catch (e) {
      print('❌ General error: $e');
      rethrow;
    }
  }

  /// GET /v1/ayudantias/{becarioId}/reportes - Obtiene reportes del ayudante
  /// Endpoint correcto para estudiantes
  Future<Map<String, dynamic>> getMyReportsForStudent(
    String estudianteBecarioId, {
    String? periodoAcademico,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      print('📡 Fetching reports for becario: $estudianteBecarioId');

      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (periodoAcademico != null) {
        queryParams['periodoAcademico'] = periodoAcademico;
      }

      final response = await _apiClient.dio.get(
        '/v1/ayudantias/$estudianteBecarioId/reportes',
        queryParameters: queryParams,
      );

      if (response.data == null || response.data['success'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to get reports');
      }

      final data = response.data['data'];
      if (data == null) {
        throw Exception('Reports data is null');
      }

      final List<dynamic> reportesList = data['reportes'] as List<dynamic>? ?? [];
      final reportes = reportesList
          .map((json) => ReporteSemanal.fromJson(json as Map<String, dynamic>))
          .toList();

      print('✅ Retrieved ${reportes.length} reports');

      return {
        'reportes': reportes,
        'total': data['total'] ?? 0,
        'horasTotalesAprobadas': data['horasTotalesAprobadas'] ?? 0.0,
        'limit': data['limit'] ?? limit,
        'offset': data['offset'] ?? offset,
        'totalPages': data['totalPages'] ?? 1,
      };
    } on DioException catch (e) {
      print('❌ Error getting reports: ${e.response?.data}');
      throw _apiClient.handleError(e);
    }
  }

  /// GET /v1/reportes/all?estudianteId={id} - Obtiene reportes del estudiante
  /// Este método ahora usa getReportesGlobales internamente
  Future<List<ReporteSemanal>> getMyReports(String estudianteId) async {
    try {
      print('📡 Fetching reports for student: $estudianteId');

      // Primero obtener el becario para tener el becarioId
      final becario = await getMyBecario(estudianteId);
      
      if (becario == null) {
        print('⚠️ No becario found, returning empty list');
        return [];
      }

      // Usar el endpoint correcto para estudiantes
      final data = await getMyReportsForStudent(
        becario.id.toString(),
        limit: 100,
      );

      print('✅ Retrieved ${data['reportes'].length} reports');
      return data['reportes'] as List<ReporteSemanal>;
    } catch (e) {
      print('❌ Error getting reports: $e');
      // Retornar lista vacía en caso de error para no romper la app
      return [];
    }
  }

  /// POST /v1/reportes - Crea nuevo reporte semanal
  /// El sistema busca automáticamente el registro de beca activo del usuario autenticado
  Future<ReporteSemanal> createReport({
    required int semana,
    required String periodoAcademico,
    required String fecha,
    required double horasTrabajadas,
    String? objetivosPeriodo,
    String? metasEspecificas,
    String? actividadesProgramadas,
    String? actividadesRealizadas,
    String? descripcionActividades,
    String? observaciones,
  }) async {
    try {
      print('📡 Creating report for week $semana, period $periodoAcademico');
      final response = await _apiClient.dio.post(
        '/v1/reportes',
        data: {
          'semana': semana,
          'periodoAcademico': periodoAcademico,
          'fecha': fecha,
          'horasTrabajadas': horasTrabajadas,
          if (objetivosPeriodo != null) 'objetivosPeriodo': objetivosPeriodo,
          if (metasEspecificas != null) 'metasEspecificas': metasEspecificas,
          if (actividadesProgramadas != null)
            'actividadesProgramadas': actividadesProgramadas,
          if (actividadesRealizadas != null)
            'actividadesRealizadas': actividadesRealizadas,
          if (descripcionActividades != null)
            'descripcionActividades': descripcionActividades,
          if (observaciones != null) 'observaciones': observaciones,
        },
      );

      if (response.data == null || response.data['success'] != true) {
        throw Exception(response.data?['message'] ?? 'Failed to create report');
      }

      print('✅ Report created successfully');
      return ReporteSemanal.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('❌ Error creating report: ${e.response?.data}');
      throw _apiClient.handleError(e);
    }
  }

  /// GET /v1/configuracion/periodo-actual - Obtiene período académico actual
  Future<PeriodoConfig> getCurrentPeriod() async {
    try {
      print('📡 Fetching current period');
      final response =
          await _apiClient.dio.get('/v1/configuracion/periodo-actual');

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to get period');
      }

      final data = response.data['data'];
      if (data == null) {
        throw Exception('Period data is null');
      }

      print('✅ Period retrieved');
      return PeriodoConfig.fromJson(data);
    } on DioException catch (e) {
      print('❌ Error getting period: ${e.response?.data}');
      throw _apiClient.handleError(e);
    }
  }

  /// GET /v1/reportes/all?estudianteId={userId} - Obtiene reportes globales del estudiante
  Future<ReportesGlobalResponse> getReportesGlobales(String estudianteId) async {
    try {
      print('📡 Fetching global reports for student: $estudianteId');
      final response = await _apiClient.dio.get(
        '/v1/reportes/all',
        queryParameters: {'estudianteId': estudianteId},
      );

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to get global reports');
      }

      final data = response.data['data'];
      if (data == null) {
        throw Exception('Reports data is null');
      }

      print('✅ Global reports retrieved');
      return ReportesGlobalResponse.fromJson(data);
    } on DioException catch (e) {
      print('❌ Error getting global reports: ${e.response?.data}');
      throw _apiClient.handleError(e);
    }
  }

  /// Obtiene estadísticas calculadas de reportes
  Future<Map<String, dynamic>> getEstadisticas(String estudianteId) async {
    try {
      final reportes = await getMyReports(estudianteId);

      final horasRegistradas = reportes.fold<double>(
        0.0,
        (sum, reporte) => sum + reporte.horasTrabajadas,
      );

      final reportesAprobados = reportes.where(
        (r) => r.estado == EstadoReporte.aprobada,
      ).toList();

      final horasAprobadas = reportesAprobados.fold<double>(
        0.0,
        (sum, reporte) => sum + reporte.horasTrabajadas,
      );

      // Horas de esta semana (última semana reportada)
      final reporteActual = reportes.isNotEmpty
          ? reportes.reduce((a, b) => a.semana > b.semana ? a : b)
          : null;

      final horasEstaSemana = reporteActual?.horasTrabajadas ?? 0.0;

      // Porcentaje de aprobación
      final porcentajeAprobacion = reportes.isEmpty
          ? 0.0
          : (reportesAprobados.length / reportes.length) * 100;

      return {
        'horasRegistradas': horasRegistradas,
        'horasAprobadas': horasAprobadas,
        'horasEstaSemana': horasEstaSemana,
        'porcentajeAprobacion': porcentajeAprobacion,
        'totalReportes': reportes.length,
        'reportesAprobados': reportesAprobados.length,
        'reportesPendientes':
            reportes.where((r) => r.estado == EstadoReporte.pendiente).length,
        'reportesRechazados':
            reportes.where((r) => r.estado == EstadoReporte.rechazada).length,
      };
    } catch (e) {
      print('❌ Error calculating statistics: $e');
      rethrow;
    }
  }

  /// Enriquece el objeto becario con información del supervisor desde los reportes
  Future<Becario?> enrichBecarioWithSupervisor(
    Becario? becario,
    List<ReporteSemanal> reportes,
  ) async {
    if (becario == null || reportes.isEmpty) {
      return becario;
    }

    try {
      // Buscar el primer reporte que tenga supervisor asignado
      final reporteConSupervisor = reportes.firstWhere(
        (r) => r.supervisor != null,
        orElse: () => reportes.first,
      );

      if (reporteConSupervisor.supervisor != null) {
        print('✅ Found supervisor from reports: ${reporteConSupervisor.supervisor!.fullName}');

        // Crear un nuevo objeto Becario con el supervisor incluido
        return Becario(
          id: becario.id,
          usuarioId: becario.usuarioId,
          supervisorId: reporteConSupervisor.supervisorId,
          plazaAsignada: becario.plazaAsignada,
          tipoBeca: becario.tipoBeca,
          estado: becario.estado,
          periodoInicio: becario.periodoInicio,
          periodoFin: becario.periodoFin,
          horasRequeridas: becario.horasRequeridas,
          horasCompletadas: becario.horasCompletadas,
          descuentoAplicado: becario.descuentoAplicado,
          usuario: becario.usuario,
          supervisor: reporteConSupervisor.supervisor,
          plaza: becario.plaza,
        );
      }
    } catch (e) {
      print('⚠️ Could not extract supervisor from reports: $e');
    }

    return becario;
  }
}
