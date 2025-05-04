import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'Id')
  final int? id;

  @JsonKey(name: 'UserName')
  final String? userName;

  final int? age;

  @JsonKey(name: 'Address')
  final String? address;

  @JsonKey(name: 'Phone')
  final String? phone;

  @JsonKey(name: 'Email')
  final String? email;

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

  @JsonKey(name: 'StartPackage')
  final DateTime? startPackage;

  @JsonKey(name: 'EndPackage')
  final DateTime? endPackage;

  final int? packageId;

  final String? imageUrl;

  UserModel({
    this.id,
    this.imageUrl,
    this.userName,
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
}
