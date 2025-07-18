import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/network/api_error_model.dart';
import '../model/register_response.dart';

part 'register_state.freezed.dart';
@freezed
class RegisterState with _$RegisterState {
  const factory RegisterState.initial() = _Initial;

  const factory RegisterState.loading() = RegisterLoading;

  const factory RegisterState.success(RegisterResponse data) = RegisterSuccess;

  const factory RegisterState.failure(ApiErrorModel errorModel) = RegisterFailure;

}