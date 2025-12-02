import 'package:dio/dio.dart';
import '../models/user.dart';
import '../models/plaza.dart';
import '../models/becario.dart';
import '../models/becario_compatible.dart';
import 'api_client.dart';

class AdminService {
  final ApiClient _apiClient = ApiClient();

  Future<List<User>> getUsers({
    String? role,
    bool? activo,
    bool? emailVerified,
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (role != null) queryParams['role'] = role;
      if (activo != null) queryParams['activo'] = activo;
      if (emailVerified != null) queryParams['emailVerified'] = emailVerified;
      if (search != null) queryParams['search'] = search;

      final response = await _apiClient.dio.get(
        '/v1/users',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final usuarios = data['usuarios'] as List;

      return usuarios.map((json) => User.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<List<User>> getPendingUsers() async {
    return getUsers(activo: false, emailVerified: false);
  }

  Future<void> approveUser(String userId) async {
    try {
      await _apiClient.dio.patch('/v1/auth/approve/$userId');
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<List<Plaza>> getPlazas({
    String? departamento,
    String? estado,
    bool? disponibles,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (departamento != null) queryParams['departamento'] = departamento;
      if (estado != null) queryParams['estado'] = estado;
      if (disponibles != null) queryParams['disponibles'] = disponibles;

      final response = await _apiClient.dio.get(
        '/v1/plazas',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final plazas = data['plazas'] as List;

      return plazas.map((json) => Plaza.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<List<Becario>> getBecarios({
    String? estado,
    String? programaBeca,
    bool? disponible,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (estado != null) queryParams['estado'] = estado;
      if (programaBeca != null) queryParams['programaBeca'] = programaBeca;
      if (disponible != null) queryParams['disponible'] = disponible;

      final response = await _apiClient.dio.get(
        '/v1/becarios',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final becarios = data['becarios'] as List;

      return becarios.map((json) => Becario.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<void> assignBecarioToPlaza(String becarioId, String plazaId) async {
    try {
      await _apiClient.dio.patch(
        '/v1/becarios/$becarioId/asignar-plaza',
        data: {'plazaId': plazaId},
      );
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<BecariosCompatiblesResponse> getBecariosCompatibles(
    String plazaId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/v1/plazas/$plazaId/becarios-compatibles',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      final data = response.data['data'];
      return BecariosCompatiblesResponse.fromJson(data);
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response =
          await _apiClient.dio.get('/v1/reportes/estadisticas/resumen-general');
      return response.data['data'];
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }
}
