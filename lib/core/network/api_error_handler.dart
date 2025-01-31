import 'package:dio/dio.dart';
import 'package:team_ar/core/network/api_error_model.dart';

class ApiErrorHandler {

  static ApiErrorModel handle(dynamic error) {
    if(error is DioException ){
      switch(error.type){
        case DioExceptionType.cancel:
          return ApiErrorModel(message: 'Request to API server was cancelled',);
        case DioExceptionType.connectionTimeout:
          return ApiErrorModel(message: 'Connection timeout with API server',);
        case DioExceptionType.sendTimeout:
          return ApiErrorModel(message: 'Send timeout in connection with API server',);
        case DioExceptionType.receiveTimeout:
          return ApiErrorModel(message: 'Receive timeout in connection with API server',);
        case DioExceptionType.badCertificate:
          return ApiErrorModel(message: 'Bad certificate',);
        case DioExceptionType.badResponse:
          return handleError(error.response!);
        case DioExceptionType.connectionError:
          return ApiErrorModel(message: 'Connection error',);
        case DioExceptionType.unknown:
          return ApiErrorModel(message: 'Unknown error',);

      }


    }else{
      return ApiErrorModel(message: 'Unexpected error',);
    }

  }

  static ApiErrorModel handleError(Response response) {
   return ApiErrorModel(
     message: response.data['message'],
     errors: response.data['errors'],
     statusCode: response.data['code'],
   );
  }


}