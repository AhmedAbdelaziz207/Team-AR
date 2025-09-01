// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_admin_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterAdminRequest _$RegisterAdminRequestFromJson(
        Map<String, dynamic> json) =>
    RegisterAdminRequest(
      userName: json['userName'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      startPackage: DateTime.parse(json['startPackage'] as String),
      endPackage: DateTime.parse(json['endPackage'] as String),
      packageId: (json['packageId'] as num).toInt(),
    );

Map<String, dynamic> _$RegisterAdminRequestToJson(
        RegisterAdminRequest instance) =>
    <String, dynamic>{
      'userName': instance.userName,
      'email': instance.email,
      'password': instance.password,
      'startPackage': instance.startPackage.toIso8601String(),
      'endPackage': instance.endPackage.toIso8601String(),
      'packageId': instance.packageId,
    };
