// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: (json['Id'] as num?)?.toInt(),
      imageUrl: json['imageUrl'] as String?,
      userName: json['UserName'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      whatsappNumber: json['whatsappNumber'] as String?,
      numOfUnreadMessages: (json['numOfUnReadMessages'] as num?)?.toInt(),
      age: (json['age'] as num?)?.toInt(),
      address: json['Address'] as String?,
      phone: json['Phone'] as String?,
      email: json['Email'] as String?,
      password: json['Password'] as String?,
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
      startPackage: json['StartPackage'] == null
          ? null
          : DateTime.parse(json['StartPackage'] as String),
      endPackage: json['EndPackage'] == null
          ? null
          : DateTime.parse(json['EndPackage'] as String),
      packageId: (json['packageId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'Id': instance.id,
      'UserName': instance.userName,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'age': instance.age,
      'whatsappNumber': instance.whatsappNumber,
      'phoneNumber': instance.phoneNumber,
      'Address': instance.address,
      'Phone': instance.phone,
      'Email': instance.email,
      'numOfUnReadMessages': instance.numOfUnreadMessages,
      'Password': instance.password,
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
      'StartPackage': instance.startPackage?.toIso8601String(),
      'EndPackage': instance.endPackage?.toIso8601String(),
      'packageId': instance.packageId,
      'imageUrl': instance.imageUrl,
    };
