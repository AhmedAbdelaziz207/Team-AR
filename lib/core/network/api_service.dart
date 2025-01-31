import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:team_ar/features/auth/login/model/login_request_body.dart';
import 'package:team_ar/features/auth/login/model/login_response.dart';

import 'api_endpoints.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: "http://gymapp.runasp.net/")
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST("api/Account/Login")
  Future<LoginResponse> login(
   @Body() LoginRequestBody body
  );


}
