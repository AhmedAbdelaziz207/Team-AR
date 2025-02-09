import 'package:json_annotation/json_annotation.dart';
part 'trainee_model.g.dart';

@JsonSerializable()
class TraineeModel {
  final String id;
  final String userName;
  final String email;
  final double long;
  final double weight;
  final int age;
  final DateTime startPackage;
  final DateTime endPackage;
  final String name;
  final int duration;
  final double oldPrice;
  final double newPrice;
  final String gender;

  TraineeModel({
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

  factory TraineeModel.fromJson(Map<String, dynamic> json) => _$TraineeModelFromJson(json);

  Map<String, dynamic> toJson() => _$TraineeModelToJson(this);
}
