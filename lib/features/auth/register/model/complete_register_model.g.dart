// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_register_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompleteRegisterModel _$CompleteRegisterModelFromJson(
        Map<String, dynamic> json) =>
    CompleteRegisterModel(
      id: json['Id'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['Address'] as String?,
      email: json['Email'] as String?,
      long: (json['Long'] as num?)?.toInt(),
      weight: (json['Weight'] as num?)?.toInt(),
      dailyWork: json['DailyWork'] as String?,
      areYouSmoker: json['AreYouSomker'] as String?,
      aimOfJoin: json['AimOfJoin'] as String?,
      anyPains: json['AnyPains'] as String?,
      allergyOfFood: json['AllergyOfFood'] as String?,
      foodSystem: json['FoodSystem'] as String?,
      numberOfMeals: (json['NumberOfMeals'] as num?)?.toInt(),
      lastExercise: json['LastExercise'] as String?,
      anyInfection: json['AnyInfection'] as String?,
      abilityOfSystemMoney: json['AbilityOfSystemMoney'] as String?,
      numberOfDays: (json['NumberOfDayes'] as num?)?.toInt(),
      gender: json['Gender'] as String?,
    );

Map<String, dynamic> _$CompleteRegisterModelToJson(
        CompleteRegisterModel instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'phoneNumber': instance.phoneNumber,
      'Address': instance.address,
      'Email': instance.email,
      'Long': instance.long,
      'Weight': instance.weight,
      'DailyWork': instance.dailyWork,
      'AreYouSomker': instance.areYouSmoker,
      'AimOfJoin': instance.aimOfJoin,
      'AnyPains': instance.anyPains,
      'AllergyOfFood': instance.allergyOfFood,
      'FoodSystem': instance.foodSystem,
      'NumberOfMeals': instance.numberOfMeals,
      'LastExercise': instance.lastExercise,
      'AnyInfection': instance.anyInfection,
      'AbilityOfSystemMoney': instance.abilityOfSystemMoney,
      'NumberOfDayes': instance.numberOfDays,
      'Gender': instance.gender,
    };
