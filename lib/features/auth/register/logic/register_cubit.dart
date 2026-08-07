import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/core/network/api_error_model.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/features/auth/register/logic/register_state.dart';
import 'package:team_ar/features/auth/register/model/user_model.dart';
import 'package:team_ar/features/auth/register/repos/register_repository.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this.registerRepository) : super(const RegisterState.initial());
  final RegisterRepository registerRepository;

  TextEditingController nameController =
      TextEditingController(); // إضافة متحكم الاسم
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void addTrainer() async {
    // التحقق من صحة الفورم أولاً
    if (!formKey.currentState!.validate()) return;

    // التحقق من تطابق كلمتي المرور
    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      emit(RegisterState.failure(
        ApiErrorModel(message: 'كلمة المرور غير متطابقة', statusCode: 0),
      ));
      return;
    }

    emit(const RegisterState.loading());

    // بناء نموذج المستخدم من البيانات الفعلية المدخلة في الفورم
    final realUser = UserModel(
      userName: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      // القيم الافتراضية للحقول التي يكملها المستخدم لاحقاً في CompleteData
      long: 0,
      weight: 0,
      dailyWork: "",
      areYouSmoker: "No",
      aimOfJoin: "",
      anyPains: "None",
      allergyOfFood: "None",
      foodSystem: "",
      numberOfMeals: 3,
      lastExercise: "",
      anyInfection: "No",
      abilityOfSystemMoney: "",
      numberOfDays: 30,
      gender: "Male",
      startPackage: DateTime.now(),
      endPackage: DateTime.now().add(const Duration(days: 30)),
      packageId: 1,
    );

    final result = await registerRepository.addTrainer(realUser);

    result.when(
      success: (data) => emit(RegisterState.success(data)),
      failure: (error) => emit(RegisterState.failure(error)),
    );
  }

  // نقل دالة navigateToPlans داخل الفئة (محتفظ بها للاستخدام المستقبلي)
  Future<void> navigateToPlans(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      Navigator.pushNamed(context, Routes.subscriptionPlans);
    }
  }
}
