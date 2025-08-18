import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

// إضافة دوال مساعدة لتحويل DateTime
String? _dateTimeToJson(DateTime? dateTime) {
  return dateTime?.toIso8601String();
}

DateTime? _dateTimeFromJson(String? dateString) {
  if (dateString == null || dateString.isEmpty) return null;
  try {
    return DateTime.parse(dateString);
  } catch (e) {
    print('خطأ في تحويل التاريخ: $e');
    return null;
  }
}

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'Id')
  final int? id;

  @JsonKey(name: 'UserName')
  final String? userName;
  final String? firstName;
  final String? lastName;

  final int? age;
  final String? whatsappNumber;

  final String? phoneNumber;

  @JsonKey(name: 'Address')
  final String? address;

  @JsonKey(name: 'Phone')
  final String? phone;

  @JsonKey(name: 'Email')
  final String? email;

  @JsonKey(name: 'numOfUnReadMessages')
  final int? numOfUnreadMessages;
  @JsonKey(name: 'Password')
  final String? password;

  @JsonKey(name: 'Long')
  final int? long; // Ensure API expects `int`, otherwise change to `double`

  @JsonKey(name: 'Weight')
  final int? weight;

  @JsonKey(name: 'DailyWork')
  final String? dailyWork;

  @JsonKey(name: 'AreYouSomker') // Keeping API typo for consistency
  final String? areYouSmoker;

  @JsonKey(name: 'AimOfJoin')
  final String? aimOfJoin;

  @JsonKey(name: 'AnyPains')
  final String? anyPains;

  @JsonKey(name: 'AllergyOfFood')
  final String? allergyOfFood;

  @JsonKey(name: 'FoodSystem')
  final String? foodSystem;

  @JsonKey(name: 'NumberOfMeals')
  final int? numberOfMeals;

  @JsonKey(name: 'LastExercise')
  final String? lastExercise;

  @JsonKey(name: 'AnyInfection')
  final String? anyInfection;

  @JsonKey(name: 'AbilityOfSystemMoney')
  final String? abilityOfSystemMoney;

  @JsonKey(name: 'NumberOfDayes') // Keeping API typo
  final int? numberOfDays;

  @JsonKey(name: 'Gender')
  final String? gender;

  // تعديل حقول DateTime لاستخدام دوال التحويل المخصصة
  @JsonKey(
      name: 'StartPackage',
      toJson: _dateTimeToJson,
      fromJson: _dateTimeFromJson)
  final DateTime? startPackage;

  @JsonKey(
      name: 'EndPackage', toJson: _dateTimeToJson, fromJson: _dateTimeFromJson)
  final DateTime? endPackage;

  final int? packageId;

  final String? imageUrl;

  UserModel({
    this.id,
    this.imageUrl,
    this.userName,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.whatsappNumber,
    this.numOfUnreadMessages,
    this.age,
    this.address,
    this.phone,
    this.email,
    this.password,
    this.long,
    this.weight,
    this.dailyWork,
    this.areYouSmoker,
    this.aimOfJoin,
    this.anyPains,
    this.allergyOfFood,
    this.foodSystem,
    this.numberOfMeals,
    this.lastExercise,
    this.anyInfection,
    this.abilityOfSystemMoney,
    this.numberOfDays,
    this.gender,
    this.startPackage,
    this.endPackage,
    this.packageId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // إضافة طريقة مساعدة لتحويل النموذج إلى JSON قابل للتخزين في SharedPreferences
  String toJsonString() {
    final Map<String, dynamic> data = toJson();
    // التأكد من تحويل التواريخ إلى سلاسل نصية
    if (startPackage != null) {
      data['StartPackage'] = startPackage!.toIso8601String();
    }
    if (endPackage != null) {
      data['EndPackage'] = endPackage!.toIso8601String();
    }
    return jsonEncode(data);
  }

  // إضافة طريقة مساعدة لإنشاء نموذج من JSON مخزن في SharedPreferences
  static UserModel? fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      return UserModel.fromJson(data);
    } catch (e) {
      print('خطأ في تحليل JSON: $e');
      return null;
    }
  }
}
