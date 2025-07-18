import 'package:json_annotation/json_annotation.dart';
part 'register_response.g.dart';
@JsonSerializable()
class RegisterResponse {
  final String? id ;
  final String? role;
  final String? userName ;
  final String? token;
  RegisterResponse({this.userName, this.id, this.role, this.token});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) => _$RegisterResponseFromJson(json);
  toJson() => _$RegisterResponseToJson(this);

}