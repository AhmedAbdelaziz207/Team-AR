import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:team_ar/core/network/api_error_model.dart';

import '../utils/app_local_keys.dart';

class ApiErrorHandler {
  static ApiErrorModel handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.cancel:
          return ApiErrorModel(message: tr(AppLocalKeys.requestCancelled));
        case DioExceptionType.connectionTimeout:
          return ApiErrorModel(message: tr(AppLocalKeys.connectionTimeout));
        case DioExceptionType.sendTimeout:
          return ApiErrorModel(message: tr(AppLocalKeys.sendTimeout));
        case DioExceptionType.receiveTimeout:
          return ApiErrorModel(message: tr(AppLocalKeys.receiveTimeout));
        case DioExceptionType.badCertificate:
          return ApiErrorModel(message: tr(AppLocalKeys.badCertificate));
        case DioExceptionType.badResponse:
          return handleError(error.response!);
        case DioExceptionType.connectionError:
          return ApiErrorModel(message: tr(AppLocalKeys.connectionError));
        case DioExceptionType.unknown:
          return ApiErrorModel(message: tr(AppLocalKeys.unknownError));
      }
    } else {
      return ApiErrorModel(message: tr(AppLocalKeys.unexpectedError));
    }
  }

  static ApiErrorModel handleError(Response response) {
    try {
      final Map<String, dynamic> data = response.data;
      return ApiErrorModel(
        message: data['message'],
        statusCode: data['statusCode'],
        errors: data['errors'],
      );
    } catch (e) {
      return ApiErrorModel(message: AppLocalKeys.unexpectedError.tr());
    }
  }


}