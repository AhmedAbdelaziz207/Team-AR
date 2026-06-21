import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';

class ApiErrorModel {
  final String? message;
  final int? statusCode;
  // errors can be a List<dynamic> or Map<String, dynamic> depending on the endpoint
  final dynamic errors;

  ApiErrorModel({this.message, this.statusCode, this.errors});

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    return ApiErrorModel(
      message: json['message'] as String?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'statusCode': statusCode,
    'errors': errors,
  };

  String? getErrorsMessage() {
    log("errors: $errors , message: $message");

    // Handle List<dynamic> errors e.g. ["Username 'x' is already taken."]
    if (errors is List) {
      final list = errors as List;
      if (list.isNotEmpty) {
        final msg = list.map((e) => e.toString()).join('\n');
        log("errorMessages (list): $msg");
        return msg;
      }
    }

    // Handle Map<String, dynamic> errors e.g. {"field": ["error"]}
    if (errors is Map) {
      final map = errors as Map;
      if (map.isNotEmpty) {
        final errorMessages = map.entries.map((entry) {
          final val = entry.value;
          if (val is List) return val.join('\n');
          return val.toString();
        }).join('\n');
        log("errorMessages (map): $errorMessages");
        return errorMessages == 'Internal Server Error'
            ? AppLocalKeys.unexpectedError.tr()
            : errorMessages;
      }
    }

    // Fallback to message field
    if (message?.toLowerCase() == "internal server error") {
      return AppLocalKeys.unexpectedError.tr();
    }
    return message;
  }
}