import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/auth_tokens.dart';
import 'api_client.dart';

class LoginResponse {
  final User user;
  final AuthTokens tokens;

  LoginResponse({required this.user, required this.tokens});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: User.fromJson(json['user']),
      tokens: AuthTokens.fromJson(json['tokens']),
    );
  }
}

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<LoginResponse> login(String email, String password) async {
    try {
      print('🔐 Attempting login for: $email');
      print('📡 API URL: ${ApiClient.baseUrl}/v1/auth/login');

      final response = await _apiClient.dio.post(
        '/v1/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      print('✅ Response status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Login failed');
      }

      final data = response.data['data'];
      if (data == null) {
        throw Exception('Response data.data is null');
      }

      print('👤 User data: ${data['user']}');
      print('🔑 Tokens received: ${data['tokens'] != null}');

      final loginResponse = LoginResponse.fromJson(data);

      // Store tokens securely
      await _storage.write(
        key: 'access_token',
        value: loginResponse.tokens.accessToken,
      );
      await _storage.write(
        key: 'refresh_token',
        value: loginResponse.tokens.refreshToken,
      );
      await _storage.write(
        key: 'user_data',
        value: jsonEncode(loginResponse.user.toJson()),
      );

      print('✅ Login successful! User: ${loginResponse.user.nombre}');

      return loginResponse;
    } on DioException catch (e) {
      print('❌ DioException occurred');
      print('❌ Error type: ${e.type}');
      print('❌ Error message: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      print('❌ Status code: ${e.response?.statusCode}');

      if (e.response?.data != null) {
        final errorMessage = e.response!.data['message'] ?? 'Error de conexión';
        throw Exception(errorMessage);
      }

      throw _apiClient.handleError(e);
    } catch (e) {
      print('❌ General Exception: $e');
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String cedula,
    required String telefono,
    required String role,
    String? carrera,
    int? trimestre,
    String? departamento,
    String? cargo,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/v1/auth/register',
        data: {
          'email': email,
          'password': password,
          'nombre': nombre,
          'apellido': apellido,
          'cedula': cedula,
          'telefono': telefono,
          'role': role,
          if (carrera != null) 'carrera': carrera,
          if (trimestre != null) 'trimestre': trimestre,
          if (departamento != null) 'departamento': departamento,
          if (cargo != null) 'cargo': cargo,
        },
      );

      // Check if the response indicates failure
      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorMessage =
            response.data?['message'] ?? 'Error en el registro';
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      // Extract the error message from the response
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw _apiClient.handleError(e);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _apiClient.dio.post(
        '/v1/auth/forgot-password',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _apiClient.dio.post(
        '/v1/auth/reset-password',
        data: {
          'token': token,
          'nuevaPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      await _apiClient.dio.put(
        '/v1/auth/change-password',
        data: {
          'passwordActual': currentPassword,
          'nuevaPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }

  Future<User?> getCurrentUser() async {
    final userData = await _storage.read(key: 'user_data');
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }
}
