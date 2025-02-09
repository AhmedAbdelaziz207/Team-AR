import 'package:json_annotation/json_annotation.dart';
part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  final int? id;
  final String? userName;
  final int? age;
  final String? address;
  final String? phone;
  final String? email;
  final String? password;
  final int? long;
  final int? weight;
  final String? dailyWork;
  @JsonKey(name: 'areYouSomker')
  final String? areYouSmoker;
  final String? aimOfJoin;
  final String? anyPains;
  final String? allergyOfFood;
  final String? foodSystem;
  final int? numberOfMeals;
  final String? lastExercise;
  final String? anyInfection;
  final String? abilityOfSystemMoney;
  @JsonKey(name: 'numberOfDayes')
  final int? numberOfDays;
  final String? gender;
  final DateTime? startPackage;
  final DateTime? endPackage;
  final int? packageId;

  UserModel({
    this.id,
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

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
