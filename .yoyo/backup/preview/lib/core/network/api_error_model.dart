import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';

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
    log("errors: $errors , message: $message");
    if (errors == null || errors!.isEmpty) {
      if (message?.toLowerCase() == "Internal Server Error".toLowerCase()) {
        return  AppLocalKeys.unexpectedError.tr();
      }
      return message;
    }

    // Convert the map of errors into a single string
    final errorMessages = errors!.entries
        .map((entry) => entry.value.join('\n')) // Join list of errors for each field
        .join('\n'); // Join all field errors into a single string

    log("errorMessages: $errorMessages , message: $message");
    return errorMessages == 'Internal Server Error' ? "Some thing went wrong" : errorMessages;
  }
}