// إنشاء خدمة لأمان عمليات الدفع
import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/utils/app_constants.dart';

class PaymentSecurityService {
  final _key = Key.fromLength(32); // مفتاح 256 بت
  final _iv = IV.fromLength(16); // متجه التهيئة
  late final Encrypter _encrypter;

  PaymentSecurityService() {
    _encrypter = Encrypter(AES(_key));
  }

  // تشفير البيانات الحساسة
  String encryptSensitiveData(String data) {
    return _encrypter.encrypt(data, iv: _iv).base64;
  }

  // فك تشفير البيانات
  String decryptSensitiveData(String encryptedData) {
    return _encrypter.decrypt64(encryptedData, iv: _iv);
  }

  // التحقق من صحة جلسة المستخدم قبل الدفع
  Future<bool> validateUserSession() async {
    final token = await SharedPreferencesHelper.getString(AppConstants.token);
    if (token == null) return false;

    // يمكن إضافة المزيد من التحققات هنا
    // مثل التحقق من صلاحية الرمز أو طلب إعادة تسجيل الدخول

    return true;
  }

  // إنشاء رمز تحقق لتأكيد عملية الدفع
  String generateVerificationCode() {
    // إنشاء رمز عشوائي من 6 أرقام
    return (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
        .toString();
  }

  // حفظ بيانات الدفع بشكل آمن
  Future<void> securelyStorePaymentInfo(
      Map<String, dynamic> paymentInfo) async {
    // تشفير البيانات الحساسة
    final encryptedData = encryptSensitiveData(jsonEncode(paymentInfo));

    // حفظ البيانات المشفرة
    await SharedPreferencesHelper.setString(
        'secure_payment_info', encryptedData);
  }
}
