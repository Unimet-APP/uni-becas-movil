import 'package:dio/dio.dart';
import '../models/configuracion_beca.dart';
import 'api_client.dart';

class ConfiguracionService {
  final ApiClient _apiClient = ApiClient();

  Future<ConfiguracionBeca?> getConfiguracion(
    String tipoBeca, [
    String? subtipoExcelencia,
  ]) async {
    try {
      final params = <String, dynamic>{'tipoBeca': tipoBeca};
      if (subtipoExcelencia != null) {
        params['subtipoExcelencia'] = subtipoExcelencia;
      }

      final response = await _apiClient.dio.get(
        '/v1/configuracion/becas',
        queryParameters: params,
      );

      if (response.data['data'] != null &&
          response.data['data']['configuraciones'] != null &&
          (response.data['data']['configuraciones'] as List).isNotEmpty) {
        final config = response.data['data']['configuraciones'][0];
        return ConfiguracionBeca.fromJson(config);
      }

      return null;
    } on DioException catch (e) {
      print('Error getting configuración: ${e.message}');
      throw _apiClient.handleError(e);
    }
  }
}
