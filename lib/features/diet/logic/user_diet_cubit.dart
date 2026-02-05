import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/features/diet/logic/user_diet_state.dart';
import 'package:team_ar/features/diet/model/user_diet.dart';
import 'package:team_ar/features/diet/repos/user_diet_repository.dart';

class UserDietCubit extends Cubit<UserDietState> {
  UserDietCubit() : super(const UserDietState.initial());
  final UserDietRepository repo = UserDietRepository(getIt<ApiService>());

  // طريقة لتحميل البيانات المخزنة محلياً
  Future<void> loadCachedDiet() async {
    final cachedDietJson =
        await SharedPreferencesHelper.getString(AppConstants.userDiet);
    if (cachedDietJson != null && cachedDietJson.isNotEmpty) {
      try {
        final List<dynamic> dietList = jsonDecode(cachedDietJson);
        final List<UserDiet> userDiet =
            dietList.map((item) => UserDiet.fromJson(item)).toList();
        emit(UserDietState.success(userDiet));
      } catch (e) {
        // في حالة حدوث خطأ في تحليل البيانات المخزنة، نتجاهل الخطأ ونستمر في تحميل البيانات من الخادم
      }
    }
  }

  void getUserDiet({String? userId}) async {
    // لا تقم بإصدار حالة التحميل إذا كانت هناك بيانات بالفعل
    if (state is! UserDietSuccess) {
      emit(const UserDietState.loading());
    }

    final result = await repo.getUserDiet(id: userId);

    result?.when(
      success: (data) {
        // تخزين البيانات محلياً
        // تخزين البيانات محلياً
        if (data.isNotEmpty) {
          try {
            SharedPreferencesHelper.setString(
              AppConstants.userDiet,
              jsonEncode(data.map((diet) => diet.toJson()).toList()),
            );
          } catch (e) {
            // Log error but do not crash app
            print("Error caching user diet: $e");
          }
        }
        emit(UserDietState.success(data));
      },
      failure: (error) => {
        if (!isClosed) emit(UserDietState.failure(error)),
      },
    );
  }

  void removeUserDiet(String userId) async {
    emit(const UserDietState.loading());
    final result = await repo.removeUserDiet(userId);
    result.when(
      success: (data) {
        getUserDiet(userId: userId);
      },
      failure: (error) => emit(UserDietState.failure(error)),
    );
  }
}
