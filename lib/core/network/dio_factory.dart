import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/utils/app_constants.dart';

class DioFactory {
  /// Private constructor to prevent instantiation of this class
  DioFactory._();

  static Dio? dio;

  /// Get singleton instance of [Dio]
  static getDio() async {
    Duration timeout = const Duration(seconds: 30);

    if (dio == null) {
      // Get User Token For Header
      String token = await getUserToken();

      dio = Dio();
      dio!
        ..options.connectTimeout = timeout
        ..options.receiveTimeout = timeout
        ..interceptors.add(
          PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            responseHeader: false,
            error: true,
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              options.headers['Authorization'] = 'Bearer $token';
              return handler.next(options);
            }
          ),
        );
    }
    return dio;
  }

  static getUserToken() {
    return SharedPreferencesHelper.getString(AppConstants.token);
  }
}
