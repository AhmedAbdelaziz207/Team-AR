// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TraineeModel _$TraineeModelFromJson(Map<String, dynamic> json) => TraineeModel(
      phoneNumber: json['PhoneNumber'] as String?,
      status: json['status'] as String?,
      role: json['Role'] as String?,
      exerciseId: (json['exerciseId'] as num?)?.toInt(),
      password: json['password'] as String?,
      packageId: (json['packageId'] as num?)?.toInt(),
      address: json['address'] as String?,
      remindDays: (json['reminderOfPackage'] as num?)?.toInt(),
      image: json['imageURL'] as String?,
      phone: json['phoneNumber'] as String?,
      id: json['id'] as String?,
      userName: json['userName'] as String?,
      email: json['email'] as String?,
      long: (json['long'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toInt(),
      age: (json['age'] as num?)?.toInt(),
      startPackage: json['startPackage'] == null
          ? null
          : DateTime.parse(json['startPackage'] as String),
      endPackage: json['endPackage'] == null
          ? null
          : DateTime.parse(json['endPackage'] as String),
      name: json['name'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      oldPrice: (json['oldPrice'] as num?)?.toInt(),
      newPrice: (json['newPrice'] as num?)?.toInt(),
      gender: json['gender'] as String?,
    );

Map<String, dynamic> _$TraineeModelToJson(TraineeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'email': instance.email,
      'long': instance.long,
      'weight': instance.weight,
      'age': instance.age,
      'startPackage': instance.startPackage?.toIso8601String(),
      'endPackage': instance.endPackage?.toIso8601String(),
      'name': instance.name,
      'duration': instance.duration,
      'oldPrice': instance.oldPrice,
      'newPrice': instance.newPrice,
      'Role': instance.role,
      'exerciseId': instance.exerciseId,
      'gender': instance.gender,
      'imageURL': instance.image,
      'phoneNumber': instance.phone,
      'PhoneNumber': instance.phoneNumber,
      'reminderOfPackage': instance.remindDays,
      'password': instance.password,
      'address': instance.address,
      'status': instance.status,
      'packageId': instance.packageId,
    };
