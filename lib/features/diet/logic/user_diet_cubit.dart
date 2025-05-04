import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/features/diet/logic/user_diet_state.dart';
import 'package:team_ar/features/diet/repos/user_diet_repository.dart';

class UserDietCubit extends Cubit<UserDietState> {
  UserDietCubit() : super(const UserDietState.initial());
  final UserDietRepository repo = UserDietRepository(getIt<ApiService>());

  void getUserDiet({String? userId}) async {
    emit(const UserDietState.loading());

    final result = await repo.getUserDiet(id: userId);

    result?.when(
      success: (data) => emit(UserDietState.success(data)),
      failure: (error) => emit(UserDietState.failure(error)),
    );
  }
}
