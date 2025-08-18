// // إنشاء خدمة لإعادة محاولة الدفع
// import 'dart:async';
// import 'package:team_ar/features/payment/repository/payment_repository.dart';
// import 'package:team_ar/features/payment/model/payment_model.dart';

// class PaymentRetryService {
//   final PaymentRepository _repository;
//   final Map<String, RetryInfo> _pendingRetries = {};
  
//   PaymentRetryService(this._repository);
  
//   // إضافة عملية دفع لإعادة المحاولة
//   Future<void> addRetry({
//     required String retryId,
//     required PaymentRequest request,
//     int maxRetries = 3,
//   }) async {
//     _pendingRetries[retryId] = RetryInfo(
//       request: request,
//       attemptsLeft: maxRetries,
//       lastAttempt: DateTime.now(),
//     );
    
//     // محاولة فورية
//     await retry(retryId);
//   }
  
//   // إعادة محاولة الدفع
//   // تعديل استخدام PaymentRequest في PaymentRetryService
//   Future<PaymentResponse?> retry(String retryId) async {
//     final retryInfo = _pendingRetries[retryId];
//     if (retryInfo == null || retryInfo.attemptsLeft <= 0) {
//       return null;
//     }
    
//     try {
//       // تحديث معلومات المحاولة
//       _pendingRetries[retryId] = retryInfo.copyWith(
//         attemptsLeft: retryInfo.attemptsLeft - 1,
//         lastAttempt: DateTime.now(),
//       );
      
//       // محاولة الدفع
//       final response = await _repository.createPayment(
//         customerName: retryInfo.request.customerName,
//         customerEmail: retryInfo.request.customerEmail,
//         customerPhone: retryInfo.request.customerPhone,
//         plan: retryInfo.request.plan,
//         userId: retryInfo.request.userId,
//       );
      
//       // إذا نجحت، إزالة من قائمة الانتظار
//       if (response.isSuccess) {
//         _pendingRetries.remove(retryId);
//       } else if (retryInfo.attemptsLeft > 0) {
//         // جدولة محاولة أخرى بعد فترة
//         _scheduleRetry(retryId);
//       }
      
//       return response;
//     } catch (e) {
//       print('خطأ في إعادة محاولة الدفع: $e');
//       if (retryInfo.attemptsLeft > 0) {
//         _scheduleRetry(retryId);
//       }
//       return null;
//     }
//   }
  
//   // جدولة إعادة محاولة بعد فترة
//   void _scheduleRetry(String retryId) {
//     final retryInfo = _pendingRetries[retryId];
//     if (retryInfo == null) return;
    
//     // زيادة الفترة بين المحاولات (exponential backoff)
//     final delay = Duration(seconds: (4 - retryInfo.attemptsLeft) * 5);
    
//     Timer(delay, () {
//       retry(retryId);
//     });
//   }
  
//   // الحصول على قائمة العمليات المعلقة
//   List<String> getPendingRetryIds() {
//     return _pendingRetries.keys.toList();
//   }
  
//   // إلغاء محاولة إعادة الدفع
//   void cancelRetry(String retryId) {
//     _pendingRetries.remove(retryId);
//   }
// }

// // نموذج لمعلومات إعادة المحاولة
// class RetryInfo {
//   final PaymentRequest request;
//   final int attemptsLeft;
//   final DateTime lastAttempt;
  
//   RetryInfo({
//     required this.request,
//     required this.attemptsLeft,
//     required this.lastAttempt,
//   });
  
//   RetryInfo copyWith({
//     PaymentRequest? request,
//     int? attemptsLeft,
//     DateTime? lastAttempt,
//   }) {
//     return RetryInfo(
//       request: request ?? this.request,
//       attemptsLeft: attemptsLeft ?? this.attemptsLeft,
//       lastAttempt: lastAttempt ?? this.lastAttempt,
//     );
//   }
// }