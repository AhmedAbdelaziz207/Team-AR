import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/features/plans_screen/logic/user_plans_state.dart';
import '../model/user_plan.dart';
import '../repos/user_plans_repository.dart';

class UserPlansCubit extends Cubit<UserPlansState> {
  UserPlansCubit() : super(const UserPlansState.initial());
  final UserPlansRepository _plansRepository = UserPlansRepository(
    getIt<ApiService>(),
  );

  void getUserPlans() async {
    emit(const UserPlansState.plansLoading());

    log("State is ${const UserPlansState.plansLoading()}");
    final result = await _plansRepository.getPlans();

    if (isClosed) return;

    result.when(
      success: (data) {
        log("State is ${UserPlansState.plansLoaded(data)}");
        if (!isClosed) emit(UserPlansState.plansLoaded(data));
      },
      failure: (error) {
        log("State is ${UserPlansState.plansFailure(error)}");
        if (!isClosed) emit(UserPlansState.plansFailure(error));
      },
    );
  }

  void getUserPlan(id) async {
    emit(const UserPlansState.plansLoading());

    log("State is ${const UserPlansState.plansLoading()}");
    final result = await _plansRepository.getPlan(id);

    if (isClosed) return;

    result.when(
      success: (data) {
        if (!isClosed) emit(UserPlansState.plansLoaded([data]));
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

  void deletePlan(int id) async {
    // 1. Snapshot current state for optimistic update
    List<UserPlan> oldPlans = [];
    if (state is UserPlansLoaded) {
      oldPlans = (state as UserPlansLoaded).plans;

      // 2. Emit new list immediately (Optimistic UI)
      final newPlans = oldPlans.where((plan) => plan.id != id).toList();
      emit(UserPlansState.plansLoaded(newPlans));
    }

    final result = await _plansRepository.deletePlan(id);

    if (isClosed) return;

    result.when(
      success: (data) {
        // Success: List is already updated optimistically.
        // potentially show a snackbar via listener if needed, but UI is already correct.
      },
      failure: (error) {
        // Failure: Revert the list and show error
        if (oldPlans.isNotEmpty) {
          emit(UserPlansState.plansLoaded(oldPlans));
        }
        emit(UserPlansState.plansFailure(error));
      },
    );
  }
}
