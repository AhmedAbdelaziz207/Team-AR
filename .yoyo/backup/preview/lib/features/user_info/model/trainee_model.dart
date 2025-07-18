import 'package:json_annotation/json_annotation.dart';

part 'trainee_model.g.dart';

@JsonSerializable()
class TrainerModel {
  final String? id;
  final String? userName;
  final int? age;
  final String? imageURL;
  final String? image;
  final String? address;
  final String? phone;
  final String? email;
  final String? password;
  final int? long;
  final int? weight;
  final String? dailyWork;
  final String? role;

  final String? exerciseId;

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

  TrainerModel({
    this.role,
    this.exerciseId,
    this.id,
    this.userName,
    this.age,
    this.imageURL,
    this.image,
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

  factory TrainerModel.fromJson(Map<String, dynamic> json) =>
      _$TrainerModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrainerModelToJson(this);
}
