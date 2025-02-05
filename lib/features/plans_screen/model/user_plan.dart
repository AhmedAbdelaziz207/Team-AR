import 'package:json_annotation/json_annotation.dart';
part 'user_plan.g.dart';
@JsonSerializable()
class UserPlan {
  int? id;
  String? name;
  int? newPrice;
  int? oldPrice;
  int? duration;
  bool? isActive;
  String? packageType;

  UserPlan({
    this.id,
    this.name,
    this.newPrice,
    this.duration,
    this.isActive,
    this.packageType,
  });

  factory UserPlan.fromJson(Map<String, dynamic> json) =>
      _$UserPlanFromJson(json);

  Map<String, dynamic> toJson() => _$UserPlanToJson(this);
}
