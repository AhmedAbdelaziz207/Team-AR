import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/features/auth/register/logic/register_state.dart';
import 'package:team_ar/features/auth/register/model/user_model.dart';
import 'package:team_ar/features/auth/register/repos/register_repository.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this.registerRepository) : super(const RegisterState.initial());
  final RegisterRepository registerRepository;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void addTrainer() async {
    emit(const RegisterState.loading());
    final result = await registerRepository.addTrainer(user);

    result.when(
      success: (data) => emit(RegisterState.success(data)),
      failure: (error) => emit(RegisterState.failure(error)),
    );
  }

  UserModel user = UserModel(
    id: 1,
    userName: "JohnDoe",
    age: 25,
    address: "123 Main St, New York",
    phone: "+1234567890",
    email: "johndoe@example.com",
    password: "9[R9gpZTm)!v,8dosC?z*tX[zOlOof&Z?|&7EC/%>B&FF/mDZ",
    long: 175, // Assuming "long" is height in cm
    weight: 70,
    dailyWork: "Software Developer",
    areYouSmoker: "No",
    aimOfJoin: "Weight Loss",
    anyPains: "None",
    allergyOfFood: "Peanuts",
    foodSystem: "Balanced Diet",
    numberOfMeals: 3,
    lastExercise: "Running",
    anyInfection: "No",
    abilityOfSystemMoney: "Affordable",
    numberOfDays: 30,
    gender: "Male",
    startPackage: DateTime.parse("2025-02-06T04:39:09.322Z"),
    endPackage: DateTime.parse("2025-03-06T04:39:09.322Z"),
    packageId: 1,
  );



}
