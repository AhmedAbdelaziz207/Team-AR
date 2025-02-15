
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/features/plans_screen/logic/user_plans_state.dart';
import '../repos/user_plans_repository.dart';

class UserPlansCubit extends Cubit<UserPlansState> {
  UserPlansCubit(this._plansRepository) : super(const UserPlansState.initial());
  final UserPlansRepository _plansRepository;

  void getUserPlans() async {
    if (isClosed) return; // Prevent emitting states after closing

    emit(const UserPlansState.plansLoading());

    final result = await _plansRepository.getPlans();

    if (isClosed) return;

    result.when(
      success: (data) {
        if (!isClosed) emit(UserPlansState.plansLoaded(data));
      },
      failure: (error) {
        if (!isClosed) emit(UserPlansState.plansFailure(error));
      },
    );
  }



}
