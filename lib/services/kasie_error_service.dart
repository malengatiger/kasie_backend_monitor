import 'package:dio/dio.dart';
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/kasie_error.dart';
import 'package:kasie_transie_library/utils/parsers.dart';

class ErrorService {
  final Dio _dio;
  static const mm = '🌸🌸🌸 ErrorService 🌸';
  ErrorService() : _dio = Dio();

  Future<List<KasieError>> getKasieErrors(String startDate) async {
    try {
      final token = await appAuth.getAuthToken();
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final url = '${KasieEnvironment.getUrl()}getKasieErrors';
      pp('$mm ... sending request: $url');
      final response = await _dio.get(url, queryParameters: {
        'startDate': startDate,
      });

      final List<dynamic> data = response.data;
      final List<KasieError> errors = data
          .map((json) => KasieError.fromJson(json))
          .toList();

      return errors;
    } catch (e) {
      // Handle error
      pp('Error occurred while fetching errors: $e');
      rethrow;
    }
  }
  Future<List<AppError>> getAppErrors(String startDate) async {
    try {
      final url = '${KasieEnvironment.getUrl()}getAppErrors';
      pp('$mm ... sending request: $url');
      final response = await _dio.get(url, queryParameters: {
        'startDate': startDate,
      });

      final List<dynamic> data = response.data;
      final List<AppError> errors = data
          .map((json) => buildAppError(json))
          .toList();

      return errors;
    } catch (e) {
      // Handle error
      pp('$mm Error occurred while fetching errors: $e');
      rethrow;
    }
  }

  Future<void> saveError(KasieError error) async {
    try {
      await _dio.post('/errors', data: error.toJson());
    } catch (e) {
      // Handle error
      pp('$mm Error occurred while saving error: $e');
      rethrow;
    }
  }
}