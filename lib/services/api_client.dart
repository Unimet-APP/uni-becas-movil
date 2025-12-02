import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/exceptions.dart';

class ApiClient {
  static const String baseUrl = 'https://srodriguez.intelcondev.org/api';
  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      validateStatus: (status) {
        // Accept any status code to handle it manually
        return status != null && status < 500;
      },
    ));

    // Add logging interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        print('🌐 REQUEST[${options.method}] => PATH: ${options.path}');
        print('📤 Headers: ${options.headers}');
        print('📤 Data: ${options.data}');

        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          print('🔑 Token added to request');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        print('📥 Data: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException error, handler) async {
        print('❌ ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
        print('❌ Message: ${error.message}');
        print('❌ Response: ${error.response?.data}');

        if (error.response?.statusCode == 401) {
          print('🔓 Unauthorized - Clearing tokens');
          await _storage.deleteAll();
        }
        return handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  Future<Map<String, String>> getHeaders() async {
    final token = await _storage.read(key: 'access_token');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Exception handleError(DioException e) {
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 400:
          return ValidationException(
              e.response!.data['message'] ?? 'Datos inválidos');
        case 401:
          return UnauthorizedException();
        case 403:
          return ForbiddenException('No tienes permisos para esta acción');
        case 404:
          return NotFoundException('Recurso no encontrado');
        case 500:
          return ServerException('Error del servidor');
        default:
          return ApiException(
              e.response!.data['message'] ?? 'Error desconocido');
      }
    } else {
      return NetworkException('Error de conexión. Verifica tu internet.');
    }
  }
}
