import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/network/api_error_model.dart';
import '../../auth/register/model/register_response.dart';
part 'confirm_subscription_state.freezed.dart';
@freezed
class ConfirmSubscriptionState with _$ConfirmSubscriptionState{
  const factory ConfirmSubscriptionState.initial() = _Initial;

  const factory ConfirmSubscriptionState.loading() = SubscriptionLoading;

  const factory ConfirmSubscriptionState.success(RegisterResponse data) = SubscriptionSuccess;

  const factory ConfirmSubscriptionState.failure(ApiErrorModel errorModel) = SubscriptionFailure;

}