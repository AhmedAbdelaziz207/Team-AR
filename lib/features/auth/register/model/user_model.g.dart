// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: (json['id'] as num?)?.toInt(),
      userName: json['userName'] as String?,
      age: (json['age'] as num?)?.toInt(),
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      long: (json['long'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toInt(),
      dailyWork: json['dailyWork'] as String?,
      areYouSmoker: json['areYouSomker'] as String?,
      aimOfJoin: json['aimOfJoin'] as String?,
      anyPains: json['anyPains'] as String?,
      allergyOfFood: json['allergyOfFood'] as String?,
      foodSystem: json['foodSystem'] as String?,
      numberOfMeals: (json['numberOfMeals'] as num?)?.toInt(),
      lastExercise: json['lastExercise'] as String?,
      anyInfection: json['anyInfection'] as String?,
      abilityOfSystemMoney: json['abilityOfSystemMoney'] as String?,
      numberOfDays: (json['numberOfDayes'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      startPackage: json['startPackage'] == null
          ? null
          : DateTime.parse(json['startPackage'] as String),
      endPackage: json['endPackage'] == null
          ? null
          : DateTime.parse(json['endPackage'] as String),
      packageId: (json['packageId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'age': instance.age,
      'address': instance.address,
      'phone': instance.phone,
      'email': instance.email,
      'password': instance.password,
      'long': instance.long,
      'weight': instance.weight,
      'dailyWork': instance.dailyWork,
      'areYouSomker': instance.areYouSmoker,
      'aimOfJoin': instance.aimOfJoin,
      'anyPains': instance.anyPains,
      'allergyOfFood': instance.allergyOfFood,
      'foodSystem': instance.foodSystem,
      'numberOfMeals': instance.numberOfMeals,
      'lastExercise': instance.lastExercise,
      'anyInfection': instance.anyInfection,
      'abilityOfSystemMoney': instance.abilityOfSystemMoney,
      'numberOfDayes': instance.numberOfDays,
      'gender': instance.gender,
      'startPackage': instance.startPackage?.toIso8601String(),
      'endPackage': instance.endPackage?.toIso8601String(),
      'packageId': instance.packageId,
    };
