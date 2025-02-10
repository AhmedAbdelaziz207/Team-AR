// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TraineeModel _$TraineeModelFromJson(Map<String, dynamic> json) => TraineeModel(
      id: json['id'] as String,
      userName: json['userName'] as String,
      email: json['email'] as String,
      long: (json['long'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      age: (json['age'] as num).toInt(),
      startPackage: DateTime.parse(json['startPackage'] as String),
      endPackage: DateTime.parse(json['endPackage'] as String),
      name: json['name'] as String,
      duration: (json['duration'] as num).toInt(),
      oldPrice: (json['oldPrice'] as num).toDouble(),
      newPrice: (json['newPrice'] as num).toDouble(),
      gender: json['gender'] as String,
    );

Map<String, dynamic> _$TraineeModelToJson(TraineeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'email': instance.email,
      'long': instance.long,
      'weight': instance.weight,
      'age': instance.age,
      'startPackage': instance.startPackage.toIso8601String(),
      'endPackage': instance.endPackage.toIso8601String(),
      'name': instance.name,
      'duration': instance.duration,
      'oldPrice': instance.oldPrice,
      'newPrice': instance.newPrice,
      'gender': instance.gender,
    };
