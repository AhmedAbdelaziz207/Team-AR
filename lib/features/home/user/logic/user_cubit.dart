import 'dart:developer';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/core/network/dio_factory.dart';
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
    log("=== UPDATE USER PACKAGE ===");
    log("User ID: $userId");
    log("Package ID: $packageId");

    final result = await repo.updateUserPackage({
      "userId": userId,
      "packageId": packageId,
    });

    if (isClosed) return;

    result.when(
      success: (data) async {
        log("Package update successful, now updating payment status...");

        // After successfully updating the package, also update payment status
        final paymentResult = await repo.updateUserPayment(userId);

        if (isClosed) return;

        paymentResult.when(
          success: (_) {
            log("Payment status updated successfully - user is now paid");
            emit(const UserState.updateUserSuccess());
          },
          failure: (error) {
            // Even if payment update fails, we still show success for package update
            // but log the payment error
            log("Payment update failed: ${error.getErrorsMessage()}");
            print("Payment update failed: ${error.getErrorsMessage()}");
            emit(const UserState.updateUserSuccess());
          },
        );
      },
      failure: (error) {
        log("Package update failed: ${error.getErrorsMessage()}");
        emit(UserState.updateUserFailure(error.getErrorsMessage() ?? ""));
      },
    );
  }

  Future<bool> deleteUser(String id) async {
    final dio = await DioFactory.getDio();

    bool isSuccess = false;

    if (isClosed) return false;

    try {
      final response =
          await dio.delete('${ApiEndPoints.baseUrl}api/Account/RemoeAccount');
      if (response.statusCode == 200) {
        isSuccess = true;
      }
    } catch (error) {
      log("Delete user failed: ${error.toString()}");
      isSuccess = false;
    }

    return isSuccess;
  }
}
