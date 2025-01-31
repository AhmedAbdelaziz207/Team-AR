import 'package:freezed_annotation/freezed_annotation.dart';
part 'login_response.g.dart';
@JsonSerializable()
class LoginResponse{
  final String? token;
  @JsonKey(name: 'expiration')
  final String? expirationDate;
  @JsonKey(name: 'userId')
  final String ? userId;

  LoginResponse({this.token, this.expirationDate, this.userId});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

}