import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/features/home/admin/data/trainee_model.dart';
import 'package:team_ar/features/home/admin/repos/trainees_repository.dart';
import 'package:team_ar/features/home/user/logic/user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const UserState.initial());
  final TraineesRepository repo = TraineesRepository(getIt<ApiService>());

  // إضافة متغير لتخزين بيانات المستخدم
  TraineeModel? _cachedUserData;
  bool _isDataLoaded = false;

  void getUser(String id) async {
    // التحقق مما إذا كانت البيانات محملة مسبقًا
    if (_isDataLoaded && _cachedUserData != null) {
      emit(UserState.success(_cachedUserData!));
      return;
    }

    emit(const UserState.loading());

    final result = await repo.getLoggedUser(id);

    result.when(
      success: (data) {
        // تخزين البيانات في الذاكرة المؤقتة
        _cachedUserData = data;
        _isDataLoaded = true;
        if (!isClosed) {
          emit(UserState.success(data));
        }
      },
      failure: (error) =>
          emit(UserState.failure(error.getErrorsMessage() ?? "")),
    );
  }

  // إضافة دالة لإعادة تحميل البيانات عند الحاجة
  void refreshUserData(String id) async {
    _isDataLoaded = false;
    getUser(id);
  }

  void getTrainee(String id) async {
    emit(const UserState.loading());

    final result = await repo.getTrainer(id);

    result.when(
      success: (data) {
        if (!isClosed) {
          emit(UserState.getTrainee(data));
        }
      },
      failure: (error) {
        if (!isClosed) {
          emit(UserState.failure(error.getErrorsMessage() ?? ""));
        }
      },
    );
  }

  void updateImage(String userId, File userImage) async {
    final result = await repo.updateUserImage(userImage, userId);

    if (isClosed) return;

    result.when(
      success: (data) => emit(const UserState.updateImageSuccess()),
      failure: (error) => emit(
        UserState.updateImageFailure(error.getErrorsMessage() ?? ""),
      ),
    );
  }

  updateUserPackage(userId, packageId) async {
    final result = await repo.updateUserPackage({
      "userId": userId,
      "packageId": packageId,
    });

    if (isClosed) return;

    result.when(
      success: (data) => emit(const UserState.updateUserSuccess()),
      failure: (error) => emit(
        UserState.updateUserFailure(error.getErrorsMessage() ?? ""),
      ),
    );
  }

  void deleteUser(String id) async {
    final response = await repo.deleteUser(id);
  }
}
