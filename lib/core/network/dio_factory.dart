import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioFactory {
  /// Private constructor to prevent instantiation of this class
  DioFactory._();

  static Dio? dio;

  /// Get singleton instance of [Dio]
  static getDio() {
   Duration timeout = const Duration(seconds: 30);


    if (dio == null) {
      dio = Dio();
      dio!
        ..options.connectTimeout = timeout
        ..options.receiveTimeout = timeout
        ..interceptors.add(PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
        ));
    }
    return dio;
  }
}
