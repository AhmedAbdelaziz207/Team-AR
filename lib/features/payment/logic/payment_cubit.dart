import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/features/payment/model/payment_model.dart';
import 'package:team_ar/features/payment/repository/payment_repository.dart';
import 'package:team_ar/features/plans_screen/model/user_plan.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository _repository;
  Timer? _verificationTimer;
  PaymentData? _currentPaymentData;
  UserPlan? _currentPlan;
  String? _currentUserId;
  double? _originalAmount;


  // إعدادات المهلة الزمنية المحسنة
  static const Duration _defaultPollInterval = Duration(seconds: 5);
  static const Duration _maxVerificationDuration = Duration(minutes: 5);

  // متغيرات لتتبع عملية إنشاء الحساب
  Map<String, dynamic>? _tempUserData;
  String? _customerEmail;
  String? _customerPassword;

  PaymentCubit(this._repository) : super(PaymentInitial());

  // حفظ بيانات المستخدم المؤقتة لاستخدامها بعد نجاح الدفع
  void setTempUserData(Map<String, dynamic> userData, String email, String password) {
    _tempUserData = userData;
    _customerEmail = email;
    _customerPassword = password;
    debugPrint('تم حفظ بيانات المستخدم المؤقتة');
  }

  // الحصول على طرق الدفع المدعومة
  Future<void> getPaymentMethods({bool forceRefresh = false}) async {
    if (state is PaymentMethodsLoading && !forceRefresh) return;

    emit(PaymentMethodsLoading());

    try {
      final response = await _repository.getPaymentMethods();

      if (response.isSuccess &&
          response.data != null &&
          response.data!.isNotEmpty) {
        debugPrint('تم تحميل ${response.data!.length} طريقة دفع مدعومة');

        // Filter to MasterCard only
        final masterOnly = _filterToMastercard(response.data!);
        if (masterOnly.isEmpty) {
          emit(PaymentMethodsError('طريقة الدفع MasterCard غير متاحة حالياً'));
          return;
        }

        final sortedMethods = _sortPaymentMethods(masterOnly);
        emit(PaymentMethodsLoaded(sortedMethods));
      } else {
        final errorMessage = response.message.isNotEmpty
            ? response.message
            : 'لا توجد طرق دفع متاحة حالياً';
        emit(PaymentMethodsError(errorMessage));
      }
    } catch (e) {
      debugPrint('خطأ في الحصول على طرق الدفع: $e');
      emit(PaymentMethodsError(
          'حدث خطأ أثناء تحميل طرق الدفع. يرجى المحاولة مرة أخرى'));
    }
  }

  List<PaymentMethod> _sortPaymentMethods(List<PaymentMethod> methods) {
    final priority = {
      PaymentMethodType.visa: 1,
      PaymentMethodType.mastercard: 2,
      PaymentMethodType.wallet: 3,
      PaymentMethodType.fawry: 4,
    };

    methods.sort((a, b) {
      final aPriority = priority[a.type] ?? 999;
      final bPriority = priority[b.type] ?? 999;
      return aPriority.compareTo(bPriority);
    });

    return methods;
  }

  // إظهار MasterCard فقط
  List<PaymentMethod> _filterToMastercard(List<PaymentMethod> methods) {
    return methods.where((m) {
      if (m.type == PaymentMethodType.mastercard) return true;
      final nEn = m.nameEn.toLowerCase();
      final nAr = m.nameAr.toLowerCase();
      return nEn.contains('mastercard') || nEn.contains('master') || nAr.contains('ماستر');
    }).toList();
  }

  Future<void> createPayment({
    required String customerName,
    required String customerEmail,
    required UserPlan plan,
    required String userId,
    required int paymentMethodId,
  }) async {
    // إيقاف أي تحقق سابق
    _cancelVerificationTimer();
    _originalAmount = plan.newPrice?.toDouble();

    final validationResult = PaymentValidator.validatePaymentData(
      customerName: customerName,
      customerEmail: customerEmail,
    );

    if (!validationResult.isValid) {
      emit(PaymentError(validationResult.errors.join('\n')));
      return;
    }

    emit(PaymentLoading());

    try {
      _currentPlan = plan;
      _currentUserId = userId;

      final response = await _repository.createPayment(
        customerName: customerName.trim(),
        customerEmail: customerEmail.trim(),
        plan: plan,
        userId: userId,
        paymentMethodId: paymentMethodId,
      );

      if (response.isSuccess && response.data != null) {
        _currentPaymentData = response.data!;

        // التأكد من أن المبلغ صحيح
        if (_currentPaymentData!.amount == 0.0 && _originalAmount != null) {
          _currentPaymentData = PaymentData(
            invoiceId: _currentPaymentData!.invoiceId,
            invoiceKey: _currentPaymentData!.invoiceKey,
            status: _currentPaymentData!.status,
            redirectTo: _currentPaymentData!.redirectTo,
            fawryCode: _currentPaymentData!.fawryCode,
            expireDate: _currentPaymentData!.expireDate,
            walletReference: _currentPaymentData!.walletReference,
            amount: _originalAmount!, // استخدام المبلغ الأصلي
            currency: _currentPaymentData!.currency,
            methodType: _currentPaymentData!.methodType,
          );
        }
        emit(PaymentCreated(_currentPaymentData!));
      } else {
        final errorMessage = response.message.isNotEmpty ? response.message : 'فشل في إنشاء الفاتورة';
        emit(PaymentError(errorMessage));
      }
    } catch (e) {
      debugPrint('خطأ في إنشاء الدفع: $e');
      emit(PaymentError('حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى'));
    }
  }

  bool _requiresRedirect(PaymentData paymentData) {
    return paymentData.redirectTo != null && paymentData.redirectTo!.isNotEmpty;
  }

  //
  // Future<void> verifyPaymentWithPolling(
  //     String invoiceId, {
  //       Duration pollInterval = const Duration(seconds: 8),
  //       Duration? maxDuration,
  //     }) async {
  //   debugPrint('=== بداية التحقق الدوري من الدفع ===');
  //
  //   _cancelVerificationTimer();
  //
  //   final effectiveMaxDuration = maxDuration ?? Duration(minutes: 8); // زيادة الوقت
  //
  //   emit(PaymentVerifying());
  //
  //   int attempts = 0;
  //   final startTime = DateTime.now();
  //
  //   _verificationTimer = Timer.periodic(pollInterval, (timer) async {
  //     attempts++;
  //     final elapsed = DateTime.now().difference(startTime);
  //
  //     debugPrint('محاولة التحقق رقم: $attempts (مر ${elapsed.inSeconds}s)');
  //
  //     if (elapsed >= effectiveMaxDuration) {
  //       timer.cancel();
  //       emit(PaymentTimedOut('استغرقت عملية التحقق وقتاً أطول من المتوقع.\n'
  //           'إذا تم خصم المبلغ، سيتم تفعيل الاشتراك تلقائياً خلال 24 ساعة'));
  //       return;
  //     }
  //
  //     try {
  //       final response = await _repository.verifyPaymentWithRetry(invoiceId);
  //
  //       if (response.isSuccess && response.data != null) {
  //         final paymentStatus = response.data!.paymentStatus;
  //         debugPrint('حالة الدفع: $paymentStatus');
  //
  //         if (paymentStatus == PaymentStatus.paid) {
  //           timer.cancel();
  //           await _handleSuccessfulPayment();
  //           return;
  //         } else if (paymentStatus == PaymentStatus.failed) {
  //           timer.cancel();
  //           emit(PaymentFailed('فشلت عملية الدفع', _currentPaymentData, _currentPlan));
  //           return;
  //         }
  //
  //         // للحالات الأخرى، استمر في المحاولة
  //       }
  //     } catch (e) {
  //       debugPrint('خطأ في محاولة التحقق $attempts: $e');
  //     }
  //   });
  // }
  //
  //
  // // التحقق الفوري من الدفع (للاستخدام مع WebView)
  // Future<void> verifyPayment(String invoiceId) async {
  //   debugPrint('=== التحقق الفوري من الدفع ===');
  //
  //   emit(PaymentVerifying());
  //
  //   try {
  //     final response = await _repository.verifyPaymentWithRetry(invoiceId);
  //
  //     if (response.isSuccess && response.data != null) {
  //       final paymentStatus = response.data!.paymentStatus;
  //       debugPrint('حالة الدفع الفورية: $paymentStatus');
  //
  //       await _handleSinglePaymentStatus(paymentStatus);
  //     } else {
  //       emit(PaymentError('فشل في التحقق من حالة الدفع'));
  //     }
  //   } catch (e) {
  //     debugPrint('خطأ في التحقق الفوري: $e');
  //     emit(PaymentError('حدث خطأ أثناء التحقق من الدفع'));
  //   }
  // }
  //
  // // معالجة موحدة لحالات الدفع في التحقق الدوري
  // Future<void> _handlePaymentStatus(
  //     PaymentStatus paymentStatus,
  //     Timer timer,
  //     int attempts,
  //     int maxAttempts,
  //     Duration pollInterval,
  //     ) async {
  //   switch (paymentStatus) {
  //     case PaymentStatus.paid:
  //       timer.cancel();
  //       await _handleSuccessfulPayment();
  //       break;
  //     case PaymentStatus.failed:
  //       timer.cancel();
  //       emit(PaymentFailed(
  //         'فشلت عملية الدفع. يرجى المحاولة مرة أخرى أو استخدام طريقة دفع أخرى',
  //         _currentPaymentData,
  //         _currentPlan,
  //       ));
  //       break;
  //     case PaymentStatus.expired:
  //       timer.cancel();
  //       emit(PaymentExpired(
  //         'انتهت صلاحية الفاتورة. يرجى إنشاء فاتورة جديدة',
  //         _currentPaymentData,
  //         _currentPlan,
  //       ));
  //       break;
  //     case PaymentStatus.cancelled:
  //       timer.cancel();
  //       emit(PaymentCancelled(
  //         'تم إلغاء عملية الدفع',
  //         _currentPaymentData,
  //         _currentPlan,
  //       ));
  //       break;
  //     case PaymentStatus.pending:
  //       if (attempts >= maxAttempts) {
  //         timer.cancel();
  //         emit(PaymentTimedOut('استغرقت عملية التحقق وقتاً أطول من المتوقع.\n'
  //             'يرجى التحقق من حالة الدفع لاحقاً أو الاتصال بالدعم إذا تم خصم المبلغ'));
  //       } else {
  //         debugPrint(
  //             'الدفع ما زال قيد المعالجة... محاولة أخرى في ${pollInterval.inSeconds} ثانية');
  //       }
  //       break;
  //   }
  // }



  // معالجة حالات الدفع في التحقق الفوري
  Future<void> _handleSinglePaymentStatus(PaymentStatus paymentStatus) async {
    switch (paymentStatus) {
      case PaymentStatus.paid:
        await _handleSuccessfulPayment();
        break;
      case PaymentStatus.pending:
      // بدء التحقق التلقائي
        if (_currentPaymentData != null) {
          // await verifyPaymentWithPolling(_currentPaymentData!.invoiceId.toString());
        }
        break;
      case PaymentStatus.failed:
        emit(PaymentFailed(
          'فشلت عملية الدفع. يرجى المحاولة مرة أخرى',
          _currentPaymentData,
          _currentPlan,
        ));
        break;
      case PaymentStatus.expired:
        emit(PaymentExpired(
          'انتهت صلاحية الفاتورة. يرجى إنشاء فاتورة جديدة',
          _currentPaymentData,
          _currentPlan,
        ));
        break;
      case PaymentStatus.cancelled:
        emit(PaymentCancelled(
          'تم إلغاء عملية الدفع',
          _currentPaymentData,
          _currentPlan,
        ));
        break;
    }
  }

  Future<void> _handleSuccessfulPayment() async {
    debugPrint('=== معالجة نجاح الدفع ===');

    if (_currentPaymentData == null || _currentPlan == null) {
      emit(PaymentError('معلومات الدفع غير مكتملة'));
      return;
    }

    try {
      debugPrint('تم الدفع بنجاح - معرف الفاتورة: ${_currentPaymentData!.invoiceId}');

      // إرسال حالة النجاح مع البيانات المطلوبة لإنشاء الحساب
      emit(PaymentSuccessWithData(
        _currentPaymentData!,
        _currentPlan!,
        _tempUserData,
        _customerEmail,
        _customerPassword,
      ));
    } catch (e) {
      debugPrint('خطأ في معالجة نجاح الدفع: $e');
      emit(PaymentError('تم الدفع بنجاح لكن حدث خطأ تقني.\n'
          'يرجى الاتصال بالدعم مع رقم الفاتورة: ${_currentPaymentData!.invoiceId}'));
    }
  }

  // إيقاف آمن للـ Timer
  void _cancelVerificationTimer() {
    if (_verificationTimer != null) {
      _verificationTimer!.cancel();
      _verificationTimer = null;
      debugPrint('تم إلغاء Timer التحقق');
    }
  }

  void stopVerification() {
    _cancelVerificationTimer();
    debugPrint('تم إيقاف التحقق التلقائي بواسطة المستخدم');
  }

  void resetState() {
    _cancelVerificationTimer();
    _currentPaymentData = null;
    _currentPlan = null;
    _currentUserId = null;
    _tempUserData = null;
    _customerEmail = null;
    _customerPassword = null;
    emit(PaymentInitial());
    debugPrint('تم إعادة تعيين حالة PaymentCubit');
  }

  @override
  Future<void> close() {
    debugPrint('إغلاق PaymentCubit...');
    _cancelVerificationTimer();
    return super.close();
  }
}
