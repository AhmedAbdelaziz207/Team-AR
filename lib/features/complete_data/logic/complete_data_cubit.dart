import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_error_handler.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/features/auth/register/model/complete_register_model.dart';

enum CompleteDataStatus { initial, loading, success, failure }

class CompleteDataState {
  final CompleteDataStatus status;
  final String? error;
  const CompleteDataState(
      {this.status = CompleteDataStatus.initial, this.error});

  CompleteDataState copyWith({CompleteDataStatus? status, String? error}) =>
      CompleteDataState(status: status ?? this.status, error: error);
}

class CompleteDataCubit extends Cubit<CompleteDataState> {
  CompleteDataCubit() : super(const CompleteDataState());

  final formKey = GlobalKey<FormState>();

  // Controllers matching CompleteRegisterModel fields we collect from UI
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final heightController = TextEditingController(); // maps to Long
  final weightController = TextEditingController();
  final dailyWorkController = TextEditingController();
  final areYouSmokerController = TextEditingController();
  final aimOfJoinController = TextEditingController();
  final anyPainsController = TextEditingController();
  final allergyOfFoodController = TextEditingController();
  final foodSystemController = TextEditingController();
  final numberOfMealsController = TextEditingController();
  final lastExerciseController = TextEditingController();
  final anyInfectionController = TextEditingController();
  final abilityOfSystemMoneyController = TextEditingController();
  final numberOfDaysController = TextEditingController();
  final genderController = TextEditingController();

  Future<void> submit() async {
    // 1. Explicit validation of essential fields
    if (phoneController.text.trim().isEmpty) {
      emit(state.copyWith(
        status: CompleteDataStatus.failure,
        error: "يرجى إدخال رقم الهاتف",
      ));
      return;
    }
    if (addressController.text.trim().isEmpty) {
      emit(state.copyWith(
        status: CompleteDataStatus.failure,
        error: "يرجى إدخال العنوان",
      ));
      return;
    }
    if (heightController.text.trim().isEmpty ||
        weightController.text.trim().isEmpty) {
      emit(state.copyWith(
        status: CompleteDataStatus.failure,
        error: "يرجى إدخال الطول والوزن",
      ));
      return;
    }
    if (aimOfJoinController.text.trim().isEmpty) {
      emit(state.copyWith(
        status: CompleteDataStatus.failure,
        error: "يرجى إدخال الهدف من الاشتراك",
      ));
      return;
    }
    if (numberOfDaysController.text.trim().isEmpty) {
      emit(state.copyWith(
        status: CompleteDataStatus.failure,
        error: "يرجى إدخال عدد أيام التمرين",
      ));
      return;
    }
    if (numberOfMealsController.text.trim().isEmpty) {
      emit(state.copyWith(
        status: CompleteDataStatus.failure,
        error: "يرجى إدخال عدد الوجبات",
      ));
      return;
    }

    final userId = await SharedPreferencesHelper.getString(AppConstants.userId);
    if (userId == null || userId.isEmpty) {
      emit(state.copyWith(
        status: CompleteDataStatus.failure,
        error: "تعذر العثور على معرف المستخدم، يرجى تسجيل الدخول مجدداً",
      ));
      return;
    }

    emit(state.copyWith(status: CompleteDataStatus.loading, error: null));
    try {
      final model = CompleteRegisterModel(
        id: userId,
        address: addressController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        email: emailController.text.trim(),
        long: int.tryParse(heightController.text.trim()) ?? 0,
        weight: int.tryParse(weightController.text.trim()) ?? 0,
        dailyWork: dailyWorkController.text.trim().isEmpty
            ? "لا يوجد"
            : dailyWorkController.text.trim(),
        areYouSmoker: areYouSmokerController.text.trim().isEmpty
            ? "No"
            : areYouSmokerController.text.trim(),
        aimOfJoin: aimOfJoinController.text.trim(),
        anyPains: anyPainsController.text.trim().isEmpty
            ? "لا"
            : anyPainsController.text.trim(),
        allergyOfFood: allergyOfFoodController.text.trim().isEmpty
            ? "لا"
            : allergyOfFoodController.text.trim(),
        foodSystem: foodSystemController.text.trim().isEmpty
            ? "لا يوجد تفضيل معين"
            : foodSystemController.text.trim(),
        numberOfMeals: int.tryParse(numberOfMealsController.text.trim()) ?? 3,
        lastExercise: lastExerciseController.text.trim().isEmpty
            ? "لا يوجد"
            : lastExerciseController.text.trim(),
        anyInfection: anyInfectionController.text.trim().isEmpty
            ? "لا"
            : anyInfectionController.text.trim(),
        abilityOfSystemMoney:
            abilityOfSystemMoneyController.text.trim().isEmpty
                ? "متوسطة"
                : abilityOfSystemMoneyController.text.trim(),
        numberOfDays:
            int.tryParse(numberOfDaysController.text.trim()) ?? 3,
        gender: genderController.text.trim().isEmpty
            ? "Male"
            : genderController.text.trim(),
      );

      final Map<String, dynamic> jsonMap = model.toJson();
      if (model.phoneNumber != null) {
        jsonMap['PhoneNumber'] = model.phoneNumber;
      }

      final form = FormData.fromMap(jsonMap);
      await getIt<ApiService>().completeUserData(form);
      // Mark profile as completed for future app starts
      await SharedPreferencesHelper.setData(AppConstants.dataCompleted, true);
      emit(state.copyWith(status: CompleteDataStatus.success));
    } catch (e) {
      emit(state.copyWith(
          status: CompleteDataStatus.failure,
          error: ApiErrorHandler.handle(e).message));
    }
  }

  @override
  Future<void> close() {
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    heightController.dispose();
    weightController.dispose();
    dailyWorkController.dispose();
    areYouSmokerController.dispose();
    aimOfJoinController.dispose();
    anyPainsController.dispose();
    allergyOfFoodController.dispose();
    foodSystemController.dispose();
    numberOfMealsController.dispose();
    lastExerciseController.dispose();
    anyInfectionController.dispose();
    abilityOfSystemMoneyController.dispose();
    numberOfDaysController.dispose();
    genderController.dispose();
    return super.close();
  }
}
