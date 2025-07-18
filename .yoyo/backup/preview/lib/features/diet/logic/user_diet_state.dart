import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team_ar/core/network/api_error_model.dart';
import 'package:team_ar/features/diet/model/user_diet.dart';

part 'user_diet_state.freezed.dart';

@freezed
class UserDietState with _$UserDietState {
  const factory UserDietState.initial() = _Initial;

  const factory UserDietState.loading() = UserDietLoading;

  const factory UserDietState.success(List<UserDiet> diet) = UserDietSuccess;

  const factory UserDietState.failure(ApiErrorModel errorMessage) =
      UserDietFailure;
}
