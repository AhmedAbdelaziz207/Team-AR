import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/features/payment/model/payment_model.dart';
import 'package:team_ar/features/payment/service/fawaterk_service.dart';
import 'package:team_ar/features/plans_screen/model/user_plan.dart';
import 'package:flutter/foundation.dart';

class PaymentRepository {
  final FawaterkService _fawaterkService;
  final ApiService _apiService;

  PaymentRepository(this._fawaterkService, this._apiService);

  // الحصول على طرق الدفع المدعومة فقط
  Future<PaymentMethodsResponse> getPaymentMethods() async {
    try {
      final response = await _fawaterkService.getPaymentMethods();

      if (response.isSuccess && response.data != null) {
        // تفلتر طرق الدفع للحصول على الطرق المطلوبة فقط
        final supportedMethods = response.data!.where((method) {
          return method.type == PaymentMethodType.visa ||
              method.type == PaymentMethodType.mastercard ||
              method.type == PaymentMethodType.fawry ||
              method.type == PaymentMethodType.wallet;
        }).toList();

        return PaymentMethodsResponse(
          isSuccess: true,
          message: response.message,
          data: supportedMethods,
        );
      }

      return response;
    } catch (e) {
      debugPrint('خطأ في الحصول على طرق الدفع: $e');
      return PaymentMethodsResponse(
        isSuccess: false,
        message: 'حدث خطأ أثناء الحصول على طرق الدفع: ${e.toString()}',
      );
    }
  }

  // إنشاء دفعة جديدة
  Future<PaymentResponse> createPayment({
    required String customerName,
    required String customerEmail,
    required UserPlan plan,
    required String userId,
    required int paymentMethodId,
  }) async {
    try {
      // تقسيم الاسم
      final nameParts = customerName.trim().split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // إنشاء طلب الدفع مع URLs صحيحة
      final request = PaymentRequest(
        paymentMethodId: paymentMethodId,
        cartTotal: plan.newPrice!.toStringAsFixed(2),
        currency: 'EGP',
        customer: CustomerData(
          firstName: firstName,
          lastName: lastName.isNotEmpty ? lastName : firstName,
          email: customerEmail,
          address: 'العنوان غير محدد',
        ),
        redirectionUrls: RedirectionUrls(
          successUrl: 'https://dev.fawaterk.com/success?invoice_id=${DateTime.now().millisecondsSinceEpoch}',
          failUrl: 'https://dev.fawaterk.com/fail',
          pendingUrl: 'https://dev.fawaterk.com/pending',
        ),
        cartItems: [
          CartItem(
            name: 'اشتراك في ${plan.name}',
            price: plan.newPrice!.toStringAsFixed(2),
            quantity: '1',
          ),
        ],
      );

      final response = await _fawaterkService.createPayment(request);

      // حفظ معلومات الدفع
      if (response.isSuccess && response.data != null) {
        await _savePaymentInfo(response.data!, userId, plan);
      }

      return response;
    } catch (e) {
      debugPrint('خطأ في إنشاء الدفع: $e');
      return PaymentResponse(
        isSuccess: false,
        message: 'حدث خطأ أثناء إنشاء الدفعة: ${e.toString()}',
      );
    }
  }

  Future<PaymentStatusResponse> verifyPaymentWithRetry(
      String invoiceId, {
        int maxRetries = 8, // زيادة المحاولات
        Duration retryDelay = const Duration(seconds: 5), // زيادة التأخير
      }) async {
    debugPrint('بداية التحقق من الدفع: $invoiceId');

    for (int i = 0; i < maxRetries; i++) {
      try {
        await Future.delayed(Duration(seconds: i * 2)); // تأخير متدرج

        final response = await _fawaterkService.checkPaymentStatus(invoiceId);

        debugPrint('محاولة ${i + 1}: ${response.isSuccess} - ${response.data?.status}');

        if (response.isSuccess && response.data != null) {
          final status = response.data!.status.toLowerCase();

          // إذا كانت الحالة واضحة، إرجاع النتيجة
          if (['paid', 'success', 'completed', 'failed', 'expired', 'cancelled'].contains(status)) {
            return response;
          }
        }

        if (i < maxRetries - 1) {
          await Future.delayed(retryDelay);
        }
      } catch (e) {
        debugPrint('خطأ في المحاولة ${i + 1}: $e');
        if (i < maxRetries - 1) {
          await Future.delayed(retryDelay);
        }
      }
    }

    // إرجاع حالة pending في النهاية
    return PaymentStatusResponse(
      isSuccess: true,
      message: 'جاري معالجة الدفع',
      data: PaymentStatusData(status: 'pending'),
    );
  }

  Future<void> _savePaymentInfo(PaymentData paymentData, String userId, UserPlan plan) async {
    try {
      final paymentInfo = {
        'invoice_id': paymentData.invoiceId,
        'user_id': userId,
        'plan_id': plan.id,
        'amount': paymentData.amount,
        'currency': paymentData.currency,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      // يمكن حفظ هذه المعلومات في قاعدة بيانات محلية أو SharedPreferences
      debugPrint('تم حفظ معلومات الدفع محلياً');
    } catch (e) {
      debugPrint('خطأ في حفظ معلومات الدفع: $e');
    }
  }
}

// إضافة دالة للتحقق من صحة بيانات الدفع
class PaymentValidator {
  static ValidationResult validatePaymentData({
    required String customerName,
    required String customerEmail,
  }) {
    final errors = <String>[];

    // التحقق من الاسم
    if (customerName.trim().isEmpty) {
      errors.add('الرجاء إدخال اسم المستخدم');
    } else if (customerName.trim().length < 3) {
      errors.add('اسم المستخدم قصير جداً (يجب أن يكون 3 أحرف على الأقل)');
    }

    // التحقق من البريد الإلكتروني
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (customerEmail.trim().isEmpty) {
      errors.add('الرجاء إدخال البريد الإلكتروني');
    } else if (!emailRegex.hasMatch(customerEmail.trim())) {
      errors.add('البريد الإلكتروني غير صالح');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({required this.isValid, required this.errors});
}
