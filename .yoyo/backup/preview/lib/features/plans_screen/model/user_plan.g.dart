// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPlan _$UserPlanFromJson(Map<String, dynamic> json) => UserPlan(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      newPrice: (json['newPrice'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      isActive: json['isActive'] as bool?,
      oldPrice: (json['oldPrice'] as num?)?.toInt(),
      packageType: json['packageType'] as String?,
    );

Map<String, dynamic> _$UserPlanToJson(UserPlan instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'newPrice': instance.newPrice,
      'oldPrice': instance.oldPrice,
      'duration': instance.duration,
      'isActive': instance.isActive,
      'packageType': instance.packageType,
    };
