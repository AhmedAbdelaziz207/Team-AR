import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/features/plans_screen/model/user_plan.dart';

import '../../auth/register/model/user_model.dart';
import '../../auth/register/repos/register_repository.dart';
import 'confirm_subscription_state.dart';

class ConfirmSubscriptionCubit extends Cubit<ConfirmSubscriptionState> {
  ConfirmSubscriptionCubit() : super(const ConfirmSubscriptionState.initial());
  final RegisterRepository repo = RegisterRepository(getIt<ApiService>());
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isSendImages = false;
  late final UserPlan userPlan;
  final now = DateTime.now();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final trainingDaysController = TextEditingController();
  final smokingController = TextEditingController();
  final lastTrainedController = TextEditingController();
  final painController = TextEditingController();
  final allergyController = TextEditingController();
  final infectionController = TextEditingController();
  final genderController = TextEditingController();

  // final abilityMoneyController = TextEditingController();
  final aimOfJoinController = TextEditingController();
  final dailyWorkController = TextEditingController();
  final foodSystemController = TextEditingController();
  final numberOfMealsController = TextEditingController();

  UserModel getUser() {
    log("User Plan: ${userPlan.duration}");
    log("end date: ${now.add(Duration(days: userPlan.duration!))}");



    return UserModel(
      id: 0,
      // Keep as default or update based on logic
      userName: nameController.text,
      age: int.tryParse(ageController.text) ?? 0,
      address: addressController.text,
      phone: phoneController.text,
      email: emailController.text,
      password: passwordController.text,
      long: int.tryParse(heightController.text) ?? 0,
      weight: int.tryParse(weightController.text) ?? 0,
      dailyWork: dailyWorkController.text,
      areYouSmoker: smokingController.text,
      aimOfJoin: aimOfJoinController.text,
      anyPains: painController.text,
      allergyOfFood: allergyController.text,
      foodSystem: foodSystemController.text,
      numberOfMeals: int.tryParse(numberOfMealsController.text) ?? 0,
      // Replace with user input if needed
      lastExercise: lastTrainedController.text,
      anyInfection: infectionController.text,
      abilityOfSystemMoney: "NA",

      // Replace with user input if needed
      numberOfDays: int.tryParse(trainingDaysController.text) ?? 0,
      gender: genderController.text,

    startPackage: now,
    endPackage: now.add(Duration(days: userPlan.duration!)),

    packageId: userPlan.id, // Replace with user input if needed
    );
  }

  void subscribe() async {
    emit(const ConfirmSubscriptionState.loading());
    final result = await repo.addTrainer(getUser());

    result.when(
      success: (data) => emit(ConfirmSubscriptionState.success(data)),
      failure: (error) => emit(ConfirmSubscriptionState.failure(error)),
    );
  }

  @override
  Future<void> close() {
    // Dispose controllers when Cubit is closed
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    addressController.dispose();
    heightController.dispose();
    weightController.dispose();
    trainingDaysController.dispose();
    smokingController.dispose();
    lastTrainedController.dispose();
    painController.dispose();
    allergyController.dispose();
    infectionController.dispose();
    genderController.dispose();
    return super.close();
  }
}
