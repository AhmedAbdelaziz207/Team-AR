import 'package:freezed_annotation/freezed_annotation.dart';
part 'complete_register_model.g.dart';

@JsonSerializable()
class CompleteRegisterModel {
  @JsonKey(name: 'Id')
  String? id;
  final String? phoneNumber;

  @JsonKey(name: 'Address')
  final String? address;

  @JsonKey(name: 'Email')
  final String? email;

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

  CompleteRegisterModel({
    this.id,
    this.phoneNumber,
    this.address,
    this.email,
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
  });

  factory CompleteRegisterModel.fromJson(Map<String, dynamic> json) =>
      _$CompleteRegisterModelFromJson(json);

  Map<String, dynamic> toJson() => _$CompleteRegisterModelToJson(this);
}
