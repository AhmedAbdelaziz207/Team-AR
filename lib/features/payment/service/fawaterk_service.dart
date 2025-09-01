import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../model/payment_model.dart';

class FawaterkService {
  static const String baseUrl = 'https://staging.fawaterk.com/api/v2';
  static const String apiKey = 'd83a5d07aaeb8442dcbe259e6dae80a3f2e21a3a581e1a5acd';

  final Dio _dio = Dio();

  FawaterkService() {
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    // تعيين timeout أطول
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
  }

  // الحصول على طرق الدفع المتاحة
  Future<PaymentMethodsResponse> getPaymentMethods() async {
    try {
      debugPrint('=== جاري الحصول على طرق الدفع ===');

      final response = await _dio.get('$baseUrl/getPaymentmethods');
      debugPrint('استجابة طرق الدفع: ${response.data}');

      final result = PaymentMethodsResponse.fromJson(response.data);
      debugPrint('تم تحويل ${result.data?.length ?? 0} طريقة دفع');

      return result;
    } on DioException catch (e) {
      debugPrint('خطأ Dio في الحصول على طرق الدفع: ${e.message}');
      return PaymentMethodsResponse(
        isSuccess: false,
        message: _handleDioError(e),
      );
    }
  }

  // إنشاء فاتورة جديدة -
  Future<PaymentResponse> createPayment(PaymentRequest request) async {
    try {
      debugPrint('=== جاري إنشاء فاتورة جديدة ===');

      // تحضير البيانات تماماً مثل التوثيق
      final requestData = {
        'payment_method_id': request.paymentMethodId,
        'cartTotal': request.cartTotal,
        'currency': request.currency,
        'customer': {
          'first_name': request.customer.firstName,
          'last_name': request.customer.lastName,
          'email': request.customer.email,
          'address': request.customer.address,
        },
        'redirectionUrls': {
          'successUrl': request.redirectionUrls.successUrl,
          'failUrl': request.redirectionUrls.failUrl,
          'pendingUrl': request.redirectionUrls.pendingUrl,
        },
        'cartItems': request.cartItems.map((item) => {
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity,
        }).toList(),
      };

      debugPrint('بيانات الطلب: ${jsonEncode(requestData)}');

      final response = await _dio.post(
        '$baseUrl/invoiceInitPay',
        data: requestData,
      );

      debugPrint('استجابة إنشاء الفاتورة: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = PaymentResponse.fromJson(response.data);
        debugPrint('تم إنشاء الفاتورة بنجاح: ${result.data?.invoiceId}');
        return result;
      } else {
        debugPrint('خطأ في الاستجابة: ${response.statusCode}');
        return PaymentResponse(
          isSuccess: false,
          message: 'خطأ في إنشاء الفاتورة: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('خطأ Dio في إنشاء الفاتورة: ${e.message}');
      debugPrint('Response data: ${e.response?.data}');
      debugPrint('Status Code: ${e.response?.statusCode}');

      return PaymentResponse(
        isSuccess: false,
        message: _handleDioError(e),
      );
    } catch (e) {
      debugPrint('خطأ عام في إنشاء الفاتورة: $e');
      return PaymentResponse(
        isSuccess: false,
        message: 'حدث خطأ غير متوقع: ${e.toString()}',
      );
    }
  }

  Future<PaymentStatusResponse> checkPaymentStatus(
      String paymentId, {
        String keyType = 'InvoiceId',
      }) async {
    try {
      debugPrint('=== جاري التحقق من حالة الدفع ===');
      debugPrint('معرف الدفع: $paymentId');

      try {
        final response = await _dio.post(
          '$baseUrl/GetPaymentStatus',
          data: {
            'Key': paymentId,
            'KeyType': keyType,
          },
        );

        debugPrint('استجابة حالة الدفع: ${response.data}');
        return PaymentStatusResponse.fromJson(response.data);

      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          debugPrint('404 Error - جاري تجربة endpoints بديلة...');
          return await _tryAlternativeStatusEndpoints(paymentId, keyType);
        }
        rethrow;
      }

    } on DioException catch (e) {
      debugPrint('خطأ Dio في التحقق من حالة الدفع: ${e.message}');

      // في حالة وجود خطأ، إرجاع حالة pending للمتابعة
      return PaymentStatusResponse(
        isSuccess: true,
        message: 'جاري التحقق من حالة الدفع...',
        data: PaymentStatusData(status: 'pending'),
      );

    } catch (e) {
      debugPrint('خطأ عام في التحقق من حالة الدفع: $e');
      return PaymentStatusResponse(
        isSuccess: true,
        message: 'جاري التحقق من حالة الدفع...',
        data: PaymentStatusData(status: 'pending'),
      );
    }
  }

  // جرب endpoints بديلة للتحقق من حالة الدفع
  Future<PaymentStatusResponse> _tryAlternativeStatusEndpoints(
      String paymentId,
      String keyType,
      ) async {
    final endpoints = [
      'getPaymentStatus',
      'paymentStatus',
      'checkPayment',
      'invoice/status',
    ];

    for (String endpoint in endpoints) {
      try {
        debugPrint('جاري تجربة: $baseUrl/$endpoint');

        final response = await _dio.post(
          '$baseUrl/$endpoint',
          data: {
            'Key': paymentId,
            'KeyType': keyType,
          },
        );

        debugPrint('نجح الـ endpoint: $endpoint');
        return PaymentStatusResponse.fromJson(response.data);

      } catch (e) {
        debugPrint('فشل $endpoint: $e');
        continue;
      }
    }

    // إذا فشلت جميع المحاولات، إرجاع pending
    debugPrint('فشلت جميع endpoints، إرجاع حالة pending');
    return PaymentStatusResponse(
      isSuccess: true,
      message: 'جاري معالجة الدفع...',
      data: PaymentStatusData(status: 'pending'),
    );
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'انتهت مهلة الاتصال';
      case DioExceptionType.sendTimeout:
        return 'انتهت مهلة إرسال البيانات';
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة استقبال البيانات';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        if (statusCode == 401) {
          return 'غير مصرح بالوصول - تحقق من API Key';
        } else if (statusCode == 400) {
          return 'بيانات غير صحيحة: ${responseData?.toString() ?? ""}';
        } else if (statusCode == 404) {
          return 'الخدمة غير متوفرة حالياً';
        } else if (statusCode == 500) {
          return 'خطأ في الخادم';
        }
        return 'خطأ HTTP: $statusCode';
      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب';
      case DioExceptionType.connectionError:
        return 'خطأ في الاتصال';
      default:
        return 'حدث خطأ: ${e.message}';
    }
  }
}
