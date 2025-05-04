import 'package:json_annotation/json_annotation.dart';

part 'workout_system_model.g.dart';

@JsonSerializable()
class WorkoutSystemModel {
  final int? id;
  final String? name;
  final String? url;

  const WorkoutSystemModel({
    this.id,
    this.name,
    this.url,
  });

  factory WorkoutSystemModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSystemModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutSystemModelToJson(this);
}
