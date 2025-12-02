import 'package:dio/dio.dart';
import '../models/becario.dart';
import '../models/plaza.dart';
import '../models/periodo_config.dart';
import '../models/reporte_semanal.dart';
import 'api_client.dart';

class BecarioService {
  final ApiClient _apiClient = ApiClient();

  /// GET /v1/becarios/me
  /// Obtiene la información del becario actual (estudiante logueado)
  Future<Becario> getBecarioInfo() async {
    try {
      print('📡 Fetching becario info...');
      final response = await _apiClient.dio.get('/v1/becarios/me');

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to get becario info');
      }

      final data = response.data['data'];
      if (data == null) {
        throw Exception('Becario data is null');
      }

      print('✅ Becario info retrieved successfully');
      return Becario.fromJson(data);
    } on DioException catch (e) {
      print('❌ Error getting becario info: ${e.response?.data}');
      throw _apiClient.handleError(e);
    } catch (e) {
      print('❌ General error getting becario info: $e');
      rethrow;
    }
  }

  /// GET /v1/configuracion/periodo-actual
  /// Obtiene el período académico actual y las semanas habilitadas
  Future<PeriodoConfig> getPeriodoActual() async {
    try {
      print('📡 Fetching current period...');
      final response = await _apiClient.dio.get('/v1/configuracion/periodo-actual');

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

      print('✅ Period info retrieved successfully');
      return PeriodoConfig.fromJson(data);
    } on DioException catch (e) {
      print('❌ Error getting period: ${e.response?.data}');
      throw _apiClient.handleError(e);
    } catch (e) {
      print('❌ General error getting period: $e');
      rethrow;
    }
  }

  /// GET /v1/plazas?ayudanteId={userId}
  /// Obtiene la plaza asignada al estudiante
  Future<Plaza?> getPlazaAsignada(String userId) async {
    try {
      print('📡 Fetching assigned plaza for user: $userId');
      final response = await _apiClient.dio.get(
        '/v1/plazas',
        queryParameters: {'ayudanteId': userId},
      );

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to get plaza');
      }

      final data = response.data['data'];
      if (data == null || (data is List && data.isEmpty)) {
        print('⚠️ No plaza assigned');
        return null;
      }

      // If data is a list, get the first plaza
      final plazaData = data is List ? data.first : data;

      print('✅ Plaza info retrieved successfully');
      return Plaza.fromJson(plazaData);
    } on DioException catch (e) {
      print('❌ Error getting plaza: ${e.response?.data}');
      throw _apiClient.handleError(e);
    } catch (e) {
      print('❌ General error getting plaza: $e');
      rethrow;
    }
  }

  /// GET /v1/reportes-semanales
  /// Obtiene todos los reportes semanales del becario
  Future<List<ReporteSemanal>> getReportes() async {
    try {
      print('📡 Fetching weekly reports...');
      final response = await _apiClient.dio.get('/v1/reportes-semanales');

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to get reports');
      }

      final data = response.data['data'];
      if (data == null) {
        return [];
      }

      final List<dynamic> reportesList = data is List ? data : [data];

      print('✅ Retrieved ${reportesList.length} reports');
      return reportesList
          .map((json) => ReporteSemanal.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('❌ Error getting reports: ${e.response?.data}');
      throw _apiClient.handleError(e);
    } catch (e) {
      print('❌ General error getting reports: $e');
      rethrow;
    }
  }

  /// POST /v1/reportes-semanales
  /// Crea un nuevo reporte semanal
  Future<ReporteSemanal> submitReporte({
    required int semana,
    required double horasTrabajadas,
    required String descripcionActividades,
  }) async {
    try {
      print('📡 Submitting weekly report for week $semana...');
      final response = await _apiClient.dio.post(
        '/v1/reportes-semanales',
        data: {
          'semana': semana,
          'horasTrabajadas': horasTrabajadas,
          'descripcionActividades': descripcionActividades,
        },
      );

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to submit report');
      }

      final data = response.data['data'];
      if (data == null) {
        throw Exception('Report data is null');
      }

      print('✅ Report submitted successfully');
      return ReporteSemanal.fromJson(data);
    } on DioException catch (e) {
      print('❌ Error submitting report: ${e.response?.data}');
      throw _apiClient.handleError(e);
    } catch (e) {
      print('❌ General error submitting report: $e');
      rethrow;
    }
  }

  /// GET /v1/reportes-semanales/semana/{numeroSemana}
  /// Obtiene un reporte específico por número de semana
  Future<ReporteSemanal?> getReporteBySemana(int numeroSemana) async {
    try {
      print('📡 Fetching report for week $numeroSemana...');
      final response = await _apiClient.dio.get(
        '/v1/reportes-semanales/semana/$numeroSemana',
      );

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      if (response.data['success'] != true) {
        // Si no existe, retornar null en lugar de error
        if (response.statusCode == 404) {
          return null;
        }
        throw Exception(response.data['message'] ?? 'Failed to get report');
      }

      final data = response.data['data'];
      if (data == null) {
        return null;
      }

      print('✅ Report retrieved successfully');
      return ReporteSemanal.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      print('❌ Error getting report: ${e.response?.data}');
      throw _apiClient.handleError(e);
    } catch (e) {
      print('❌ General error getting report: $e');
      rethrow;
    }
  }

  /// Obtiene estadísticas del becario
  /// Calculadas a partir de los reportes
  Future<Map<String, dynamic>> getEstadisticas() async {
    try {
      final reportes = await getReportes();

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
        'reportesPendientes': reportes.where((r) => r.estado == EstadoReporte.pendiente).length,
        'reportesRechazados': reportes.where((r) => r.estado == EstadoReporte.rechazada).length,
      };
    } catch (e) {
      print('❌ Error calculating statistics: $e');
      rethrow;
    }
  }
}
