import 'dart:developer';

import 'package:json_annotation/json_annotation.dart';

part 'trainee_model.g.dart';

@JsonSerializable()
class TraineeModel {
  final String? id;
  final String? userName;
  final String? email;
  final int? long;
  final int? weight;
  final int? age;
  final DateTime? startPackage;
  final DateTime? endPackage;
  final String? name;
  final int? duration;
  final int? oldPrice;
  final int? newPrice;
  @JsonKey(name: "Role")
  final String? role;
  final int? exerciseId;
  final String? gender;
  @JsonKey(name: 'imageURL')
  final String? image;
  @JsonKey(name: 'phoneNumber')
  final String? phone;
  @JsonKey(name: 'PhoneNumber')
  final String? phoneNumber;
  @JsonKey(name: 'reminderOfPackage')
  final int? remindDays;
  final String? password;
  final String? address;
  final String? status;
  final int? packageId;

  TraineeModel({
    this.phoneNumber,
    this.status,
    this.role,
    this.exerciseId,
    this.password,
    this.packageId,
    this.address,
    this.remindDays,
    this.image,
    this.phone,
    required this.id,
    required this.userName,
    required this.email,
    required this.long,
    required this.weight,
    required this.age,
    required this.startPackage,
    required this.endPackage,
    required this.name,
    required this.duration,
    required this.oldPrice,
    required this.newPrice,
    required this.gender,
  });

  factory TraineeModel.fromJson(Map<String, dynamic> json) =>
      _$TraineeModelFromJson(json);

  Map<String, dynamic> toJson() => _$TraineeModelToJson(this);

  double getPackageProgress() {
    if (startPackage == null || endPackage == null || remindDays == null) {
      return 0;
    }

    int? totalDays = endPackage?.difference(startPackage!).inDays;
    if (totalDays == null || totalDays <= 0) {
      return 0;
    }

    log("totalDays : $totalDays");

    double remainingRatio = remindDays! / totalDays;
    return (remainingRatio * 10).clamp(0.0, 10.0);
  }
}
