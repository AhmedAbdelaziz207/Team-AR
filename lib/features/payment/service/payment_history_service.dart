// // إنشاء خدمة لتسجيل عمليات الدفع
// import 'package:team_ar/core/network/api_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// class PaymentHistoryService {
//   final ApiService _apiService;
//   final SharedPreferences _prefs;
  
//   PaymentHistoryService(this._apiService, this._prefs);
  
//   // تسجيل عملية دفع جديدة
//   Future<void> recordPayment(PaymentRecord record) async {
//     // استخدام الطريقة الصحيحة للإرسال إلى الخادم
//     try {
//       // حفظ في التخزين المحلي
//       final records = await getPaymentHistory();
//       records.add(record);
//       await _saveLocalRecords(records);
      
//       // مزامنة مع الخادم - استخدام الطريقة الصحيحة
//       await _apiService.request(
//         endpoint: '/payments/history',
//         method: 'POST',
//         data: record.toJson(),
//       );
//     } catch (e) {
//       print('خطأ في تسجيل عملية الدفع: $e');
//       // حفظ محلياً على الأقل حتى لو فشلت المزامنة
//       _saveFailedSyncRecord(record);
//     }
//   }
  
//   // الحصول على سجل عمليات الدفع
//   Future<List<PaymentRecord>> getPaymentHistory() async {
//     try {
//       final String? recordsJson = _prefs.getString('payment_history');
//       if (recordsJson == null) return [];
      
//       final List<dynamic> recordsList = jsonDecode(recordsJson);
//       return recordsList.map((json) => PaymentRecord.fromJson(json)).toList();
//     } catch (e) {
//       print('خطأ في قراءة سجل الدفع: $e');
//       return [];
//     }
//   }
  
//   // حفظ السجلات محلياً
//   Future<void> _saveLocalRecords(List<PaymentRecord> records) async {
//     final recordsJson = jsonEncode(records.map((r) => r.toJson()).toList());
//     await _prefs.setString('payment_history', recordsJson);
//   }
  
//   // حفظ السجلات التي فشلت مزامنتها للمحاولة لاحقاً
//   Future<void> _saveFailedSyncRecord(PaymentRecord record) async {
//     final String? failedJson = _prefs.getString('failed_sync_payments');
//     final List<dynamic> failedList = failedJson != null ? jsonDecode(failedJson) : [];
//     failedList.add(record.toJson());
//     await _prefs.setString('failed_sync_payments', jsonEncode(failedList));
//   }
// }

// // نموذج لسجل الدفع
// class PaymentRecord {
//   final String id;
//   final String userId;
//   final String planId;
//   final String planName;
//   final double amount;
//   final DateTime timestamp;
//   final String status;
//   final String? invoiceId;
  
//   PaymentRecord({
//     required this.id,
//     required this.userId,
//     required this.planId,
//     required this.planName,
//     required this.amount,
//     required this.timestamp,
//     required this.status,
//     this.invoiceId,
//   });
  
//   factory PaymentRecord.fromJson(Map<String, dynamic> json) {
//     return PaymentRecord(
//       id: json['id'],
//       userId: json['userId'],
//       planId: json['planId'],
//       planName: json['planName'],
//       amount: json['amount'],
//       timestamp: DateTime.parse(json['timestamp']),
//       status: json['status'],
//       invoiceId: json['invoiceId'],
//     );
//   }
  
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'userId': userId,
//       'planId': planId,
//       'planName': planName,
//       'amount': amount,
//       'timestamp': timestamp.toIso8601String(),
//       'status': status,
//       'invoiceId': invoiceId,
//     };
//   }
// }