import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/utils/app_constants.dart';

class DioFactory {
  /// private constructor as I don't want to allow creating an instance of this class
  DioFactory._();

  static Dio? dio;

  static Future<Dio> getDio() async {
    const Duration timeOut = Duration(seconds: 120);

    if (dio == null) {
      dio = Dio();
      dio!
        ..options.connectTimeout = timeOut
        ..options.receiveTimeout = timeOut
        ..options.headers = {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        };
      _addTokenInterceptor();
      _addLoggerInterceptor();
    }

    return dio!;
  }

  /// Called right after login to also set the token in memory for immediate use.
  static void setTokenIntoHeaderAfterLogin(String token) {
    dio?.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Interceptor that injects the latest token from SharedPreferences
  /// before every request. This ensures multipart and all other requests
  /// always carry the correct Authorization header.
  static void _addTokenInterceptor() {
    dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token =
              await SharedPreferencesHelper.getString(AppConstants.token);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static void _addLoggerInterceptor() {
    dio?.interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        requestHeader: true,
        responseHeader: true,
      ),
    );
  }
}