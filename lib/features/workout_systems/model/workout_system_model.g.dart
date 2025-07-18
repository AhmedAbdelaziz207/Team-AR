// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_system_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutSystemModel _$WorkoutSystemModelFromJson(Map<String, dynamic> json) =>
    WorkoutSystemModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$WorkoutSystemModelToJson(WorkoutSystemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
    };
