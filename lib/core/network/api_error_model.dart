import 'package:json_annotation/json_annotation.dart';

part 'api_error_model.g.dart';

@JsonSerializable()
class ApiErrorModel {
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? errors; // Change this to Map<String, dynamic>

  ApiErrorModel({this.message, this.statusCode, this.errors});

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorModelFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorModelToJson(this);

  String? getErrorsMessage() {
    if (errors == null || errors!.isEmpty) {
      return message;
    }

    // Convert the map of errors into a single string
    final errorMessages = errors!.entries
        .map((entry) => entry.value.join('\n')) // Join list of errors for each field
        .join('\n'); // Join all field errors into a single string

    return errorMessages;
  }
}