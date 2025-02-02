import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team_ar/core/network/api_error_model.dart';

part 'login_state.freezed.dart';

@freezed
class LoginState<T> with _$LoginState<T> {
  const factory LoginState.loginInitial() = _LoginInitial;

  const factory LoginState.loginLoading() = LoginLoading;

  const factory LoginState.loginSuccess(T data) = LoginSuccess;

  const factory LoginState.loginFailure(ApiErrorModel message) = LoginFailure;
}
