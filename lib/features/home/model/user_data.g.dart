// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
      name: json['name'] as String?,
      email: json['email'] as String?,
      imageUrl: json['imageUrl'] as String?,
      role: json['role'] as String?,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      age: json['age'] as String?,
      weight: json['weight'] as String?,
      long: json['long'] as String?,
      packageId: (json['packageId'] as num?)?.toInt(),
      startPackage: json['startPackage'] as String?,
      endPackage: json['endPackage'] as String?,
      reminderOfPackage: (json['reminderOfPackage'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'imageUrl': instance.imageUrl,
      'role': instance.role,
      'gender': instance.gender,
      'address': instance.address,
      'phoneNumber': instance.phoneNumber,
      'age': instance.age,
      'weight': instance.weight,
      'long': instance.long,
      'packageId': instance.packageId,
      'startPackage': instance.startPackage,
      'endPackage': instance.endPackage,
      'reminderOfPackage': instance.reminderOfPackage,
    };
