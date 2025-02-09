import'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/network/api_error_model.dart';
import '../model/user_plan.dart';
part 'user_plans_state.freezed.dart';
@freezed
class UserPlansState with _$UserPlansState {
  const factory UserPlansState.initial() = _Initial;

  const factory UserPlansState.plansLoading() = UserPlansLoading;

  const factory UserPlansState.plansLoaded(List<UserPlan> plans) = UserPlansLoaded;

  const factory UserPlansState.plansFailure(ApiErrorModel errorModel) = UserPlansFailure;



}
