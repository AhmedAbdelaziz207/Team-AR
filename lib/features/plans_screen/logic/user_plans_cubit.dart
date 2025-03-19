import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/features/plans_screen/logic/user_plans_state.dart';
import '../model/user_plan.dart';
import '../repos/user_plans_repository.dart';

class UserPlansCubit extends Cubit<UserPlansState> {
  UserPlansCubit(this._plansRepository) : super(const UserPlansState.initial());
  final UserPlansRepository _plansRepository;

  void getUserPlans() async {
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

  void addPlan(UserPlan plan) async {

    emit(const UserPlansState.addingPlan());

    final result = await _plansRepository.addPlan(plan);

    if (isClosed) return;

    result.when(
      success: (data) {
        if (!isClosed) emit(const UserPlansState.planAdded());
      },
      failure: (error) {
        if (!isClosed) emit(UserPlansState.plansFailure(error));
      },
    );
  }

  void editPlan(UserPlan plan) async {

    final result = await _plansRepository.updatePlan(plan);
    result.when(
      success: (data) {
        if (!isClosed) emit(const UserPlansState.planEdited());
      },
      failure: (error) {
        if (!isClosed) emit(UserPlansState.plansFailure(error));
      },
    );
  }

  void deletePlan(int id ) async {

    final result = await _plansRepository.deletePlan(id);

    if (isClosed) return;

    result.when(
      success: (data) {
        // if (!isClosed) emit(const UserPlansState.planDeleted());
      },
      failure: (error) {
        if (!isClosed) emit(UserPlansState.plansFailure(error));
      },
    );
  }
}
