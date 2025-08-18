import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
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
    emit(const RegisterState.loading());
    final result = await registerRepository.addTrainer(user);

    result.when(
      success: (data) => emit(RegisterState.success(data)),
      failure: (error) => emit(RegisterState.failure(error)),
    );
  }

  // نقل دالة navigateToPlans داخل الفئة
  Future<void> navigateToPlans(BuildContext context) async {
    // حفظ بيانات المستخدم مؤقتًا
    if (formKey.currentState!.validate()) {
      // التحقق من تطابق كلمة المرور
      if (passwordController.text != confirmPasswordController.text) {
        // عرض رسالة خطأ
        return;
      }

      try {
        // إنشاء معرف مؤقت فريد
        final tempId = DateTime.now().millisecondsSinceEpoch;

        // حفظ بيانات المستخدم في التخزين المؤقت
        final tempUser = UserModel(
          id: tempId, // استخدام معرف فريد بناءً على timestamp
          userName: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          long: 175,
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
          startPackage: DateTime.now(),
          endPackage: DateTime.now().add(Duration(days: 30)),
          packageId: 1,
        );

        final tempUserJson = jsonEncode(tempUser.toJson());
        print('بيانات المستخدم المؤقت قبل الحفظ: $tempUserJson');
        print('معرف المستخدم المؤقت: ${tempUser.id}');

        // حفظ البيانات باستخدام طريقتين للتأكد من النجاح
        print('🔄 جاري حفظ البيانات المؤقتة...');
        await SharedPreferencesHelper.setString('temp_user', tempUserJson);

        // التحقق الإضافي والحفظ المباشر للضمان
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('temp_user', tempUserJson);

        // انتظار قصير لضمان الحفظ
        await Future.delayed(const Duration(milliseconds: 100));

        // التحقق النهائي من الحفظ
        final savedJson = prefs.getString('temp_user');
        print(
            'بيانات المستخدم المؤقت بعد الحفظ: ${savedJson != null ? "موجودة (${savedJson.length} حرف)" : "غير موجودة"}');
        print('جميع المفاتيح المخزنة: ${prefs.getKeys()}');

        if (savedJson == null || savedJson.isEmpty) {
          print('❌ خطأ حرج: فشل في حفظ بيانات المستخدم المؤقت!');
          // محاولة أخيرة بطريقة مختلفة
          await prefs.setString('temp_user_backup', tempUserJson);
          final backupSaved = prefs.getString('temp_user_backup');
          if (backupSaved != null) {
            print('✅ تم حفظ البيانات في النسخة الاحتياطية');
          } else {
            throw Exception('فشل نهائياً في حفظ البيانات المؤقتة');
          }
        } else {
          print('✅ تم حفظ البيانات المؤقتة بنجاح');
        }

        // التوجيه إلى صفحة الباقات
        Navigator.pushNamed(context, Routes.subscriptionPlans);
      } catch (e) {
        print('خطأ أثناء حفظ بيانات المستخدم المؤقت: $e');
        // يمكن إضافة معالجة الخطأ هنا
      }
    }
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
