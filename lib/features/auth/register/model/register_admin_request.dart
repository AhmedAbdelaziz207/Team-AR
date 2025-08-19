import 'package:freezed_annotation/freezed_annotation.dart';
part 'register_admin_request.g.dart';

@JsonSerializable(explicitToJson: true)
class RegisterAdminRequest {
  final String userName;
  final String email;
  final String password;
  final DateTime startPackage;
  final DateTime endPackage;
  final int packageId;

  RegisterAdminRequest({
    required this.userName,
    required this.email,
    required this.password,
    required this.startPackage,
    required this.endPackage,
    required this.packageId,
  });

  factory RegisterAdminRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterAdminRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterAdminRequestToJson(this);
}
