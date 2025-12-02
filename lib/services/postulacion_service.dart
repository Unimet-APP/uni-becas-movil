import 'dart:io';
import 'package:dio/dio.dart';
import '../models/postulacion.dart';
import 'api_client.dart';

class PostulacionService {
  final ApiClient _apiClient = ApiClient();

  /// PASO 1: Crear postulación
  /// POST /v1/postulaciones
  Future<String> crearPostulacion(Postulacion postulacion) async {
    try {
      print('📤 Creating postulación: ${postulacion.toJson()}');

      final response = await _apiClient.dio.post(
        '/v1/postulaciones',
        data: postulacion.toJson(),
      );

      print('✅ Postulación created: ${response.data}');

      if (response.data['success'] == true && response.data['data'] != null) {
        final postulacionId = response.data['data']['id'];
        if (postulacionId != null) {
          return postulacionId.toString();
        }
      }

      throw Exception('No se recibió el ID de la postulación');
    } on DioException catch (e) {
      print('❌ Error creating postulación: ${e.response?.data}');

      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }

      throw _apiClient.handleError(e);
    }
  }

  /// PASO 2: Subir documento
  /// POST /v1/documents/upload
  Future<void> subirDocumento(
    String postulacionId,
    String tipoDocumento,
    File file,
  ) async {
    try {
      print('📤 Uploading document: $tipoDocumento for postulación $postulacionId');

      // Crear FormData
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'tipoDocumento': tipoDocumento,
        'postulacionId': postulacionId,
      });

      final response = await _apiClient.dio.post(
        '/v1/documents/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('✅ Document uploaded: ${response.data}');

      if (response.data['success'] != true) {
        throw Exception('Error al subir documento: ${response.data['message']}');
      }
    } on DioException catch (e) {
      print('❌ Error uploading document: ${e.response?.data}');

      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }

      throw _apiClient.handleError(e);
    }
  }

  /// PASO 3: Verificar documentos asociados
  /// GET /v1/documents/public/postulacion/{postulacionId}
  Future<List<Map<String, dynamic>>> verificarDocumentos(
    String postulacionId,
  ) async {
    try {
      print('📤 Verifying documents for postulación $postulacionId');

      final response = await _apiClient.dio.get(
        '/v1/documents/public/postulacion/$postulacionId',
      );

      print('✅ Documents verified: ${response.data}');

      if (response.data['data'] != null &&
          response.data['data']['documentos'] != null) {
        return List<Map<String, dynamic>>.from(
          response.data['data']['documentos'],
        );
      }

      return [];
    } on DioException catch (e) {
      print('❌ Error verifying documents: ${e.response?.data}');
      throw _apiClient.handleError(e);
    }
  }

  /// Obtener postulaciones del usuario actual
  Future<List<Postulacion>> getMisPostulaciones() async {
    try {
      final response = await _apiClient.dio.get('/v1/postulaciones/mis-postulaciones');

      if (response.data['data'] != null) {
        final List<dynamic> postulaciones = response.data['data'];
        return postulaciones
            .map((json) => Postulacion.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      print('❌ Error getting postulaciones: ${e.response?.data}');
      throw _apiClient.handleError(e);
    }
  }

  /// Verificar postulaciones por email (endpoint público)
  /// GET /v1/postulaciones/verificar?email=...
  Future<List<Map<String, dynamic>>> verificarPostulacionesPorEmail(String email) async {
    try {
      print('📤 Verificando postulaciones para email: $email');

      final response = await _apiClient.dio.get(
        '/v1/postulaciones/verificar',
        queryParameters: {'email': email},
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      print('✅ Postulaciones verificadas: ${response.data}');

      if (response.data['success'] == true && response.data['data'] != null) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }

      return [];
    } on DioException catch (e) {
      print('❌ Error verificando postulaciones: ${e.response?.statusCode} - ${e.response?.data}');
      // Si no hay postulaciones (404), retornar lista vacía en lugar de error
      if (e.response?.statusCode == 404) {
        print('ℹ️ No se encontraron postulaciones (404) - esto es normal');
        return [];
      }
      // Re-lanzar el error para que se maneje en el UI
      throw e;
    } catch (e) {
      print('❌ Error general verificando postulaciones: $e');
      rethrow;
    }
  }
}
