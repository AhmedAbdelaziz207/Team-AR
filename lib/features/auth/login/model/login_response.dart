import 'package:freezed_annotation/freezed_annotation.dart';
part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  final String? token;
  final String? userName;
  final String? role;
  final String? id;
  final bool? isPaid;
  @JsonKey(name: "dataCompleted")
  final bool? isDataCompleted;

  LoginResponse({
    this.token,
    this.userName,
    this.role,
    this.id,
    this.isPaid,
    this.isDataCompleted,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
