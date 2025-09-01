import 'package:flutter/material.dart';

class PaymentMethod {
  final int id;
  final String nameEn;
  final String nameAr;
  final bool redirect;
  final String? logo;
  final PaymentMethodType type;

  PaymentMethod({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.redirect,
    this.logo,
    required this.type,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    final id = json['paymentId'] as int;
    final nameEn = json['name_en'] as String;
    final nameAr = json['name_ar'] as String;

    // تحديد نوع طريقة الدفع بناءً على الاسم أو المعرف
    PaymentMethodType type = _determinePaymentType(id, nameEn, nameAr);

    return PaymentMethod(
      id: id,
      nameEn: nameEn,
      nameAr: nameAr,
      redirect: json['redirect'] == 'true',
      logo: json['logo'] as String?,
      type: type,
    );
  }

  static PaymentMethodType _determinePaymentType(
      int id, String nameEn, String nameAr) {
    final name = nameEn.toLowerCase();
    final nameArabic = nameAr.toLowerCase();

    if (name.contains('visa') || nameArabic.contains('فيزا')) {
      return PaymentMethodType.visa;
    } else if (name.contains('mastercard') ||
        name.contains('master') ||
        nameArabic.contains('ماستر')) {
      return PaymentMethodType.mastercard;
    } else if (name.contains('fawry') || nameArabic.contains('فوري')) {
      return PaymentMethodType.fawry;
    } else if (name.contains('wallet') ||
        nameArabic.contains('محفظة') ||
        name.contains('vodafone') ||
        name.contains('etisalat') ||
        name.contains('orange')) {
      return PaymentMethodType.wallet;
    }
    return PaymentMethodType.unknown;
  }

  String get name => nameAr.isNotEmpty ? nameAr : nameEn;

  IconData get icon {
    switch (type) {
      case PaymentMethodType.visa:
        return Icons.credit_card;
      case PaymentMethodType.mastercard:
        return Icons.credit_card;
      case PaymentMethodType.fawry:
        return Icons.store;
      case PaymentMethodType.wallet:
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }
}

enum PaymentMethodType { visa, mastercard, fawry, wallet, unknown }

class PaymentData {
  final int invoiceId;
  final String invoiceKey;
  final String status;
  final String? redirectTo;
  final String? fawryCode;
  final String? expireDate;
  final String? walletReference;
  final double amount;
  final String currency;
  final PaymentMethodType methodType;

  PaymentData({
    required this.invoiceId,
    required this.invoiceKey,
    required this.status,
    this.redirectTo,
    this.fawryCode,
    this.expireDate,
    this.walletReference,
    required this.amount,
    required this.currency,
    required this.methodType,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    final paymentData = json['payment_data'] as Map<String, dynamic>?;

    // تحديد نوع طريقة الدفع
    PaymentMethodType methodType = PaymentMethodType.unknown;
    if (paymentData?['redirectTo'] != null) {
      methodType = PaymentMethodType.visa;
    } else if (paymentData?['fawryCode'] != null) {
      methodType = PaymentMethodType.fawry;
    } else if (paymentData?['walletReference'] != null) {
      methodType = PaymentMethodType.wallet;
    }

    // محاولة الحصول على المبلغ من مصادر متعددة
    double amount = 0.0;

    // جرب الحصول على المبلغ من المواقع المختلفة في الاستجابة
    if (json['amount'] != null) {
      amount = double.tryParse(json['amount'].toString()) ?? 0.0;
    } else if (json['cartTotal'] != null) {
      amount = double.tryParse(json['cartTotal'].toString()) ?? 0.0;
    } else if (paymentData?['amount'] != null) {
      amount = double.tryParse(paymentData!['amount'].toString()) ?? 0.0;
    } else if (json['total'] != null) {
      amount = double.tryParse(json['total'].toString()) ?? 0.0;
    }

    return PaymentData(
      invoiceId: json['invoice_id'] as int,
      invoiceKey: json['invoice_key'] as String,
      status: json['status'] ?? 'pending',
      redirectTo: paymentData?['redirectTo'] as String?,
      fawryCode: paymentData?['fawryCode'] as String?,
      expireDate: paymentData?['expireDate'] as String?,
      walletReference: paymentData?['walletReference'] as String?,
      amount: amount,
      currency: json['currency'] ?? 'EGP',
      methodType: methodType,
    );
  }
}

enum PaymentStatus { pending, paid, failed, expired, cancelled }

class PaymentStatusData {
  final String status;
  final String? transactionId;
  final DateTime? paidAt;
  final Map<String, dynamic>? metadata;

  PaymentStatusData({
    required this.status,
    this.transactionId,
    this.paidAt,
    this.metadata,
  });

  factory PaymentStatusData.fromJson(Map<String, dynamic> json) {
    return PaymentStatusData(
      status: json['status'] as String,
      transactionId: json['transaction_id'] as String?,
      paidAt:
          json['paid_at'] != null ? DateTime.tryParse(json['paid_at']) : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  PaymentStatus get paymentStatus {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'success':
      case 'completed':
        return PaymentStatus.paid;
      case 'failed':
      case 'error':
        return PaymentStatus.failed;
      case 'expired':
        return PaymentStatus.expired;
      case 'cancelled':
        return PaymentStatus.cancelled;
      default:
        return PaymentStatus.pending;
    }
  }
}

class PaymentMethodsResponse {
  final bool isSuccess;
  final String message;
  final List<PaymentMethod>? data;

  PaymentMethodsResponse({
    required this.isSuccess,
    required this.message,
    this.data,
  });

  factory PaymentMethodsResponse.fromJson(Map<String, dynamic> json) {
    return PaymentMethodsResponse(
      isSuccess: json['status'] == 'success',
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => PaymentMethod.fromJson(item))
              .toList()
          : null,
    );
  }
}

class CustomerData {
  final String firstName;
  final String lastName;
  final String email;
  final String address;

CustomerData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'address': address,
    };
  }
}

class PaymentRequest {
  final int paymentMethodId;
  final String cartTotal;
  final String currency;
  final CustomerData customer;
  final RedirectionUrls redirectionUrls;
  final List<CartItem> cartItems;

  PaymentRequest({
    required this.paymentMethodId,
    required this.cartTotal,
    required this.currency,
    required this.customer,
    required this.redirectionUrls,
    required this.cartItems,
  });

  Map<String, dynamic> toJson() {
    return {
      'payment_method_id': paymentMethodId,
      'cartTotal': cartTotal,
      'currency': currency,
      'customer': customer.toJson(),
      'redirectionUrls': redirectionUrls.toJson(),
      'cartItems': cartItems.map((item) => item.toJson()).toList(),
    };
  }
}

class RedirectionUrls {
  final String successUrl;
  final String failUrl;
  final String pendingUrl;

  RedirectionUrls({
    required this.successUrl,
    required this.failUrl,
    required this.pendingUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'successUrl': successUrl,
      'failUrl': failUrl,
      'pendingUrl': pendingUrl,
    };
  }
}

class CartItem {
  final String name;
  final String price;
  final String quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}

class PaymentResponse {
  final bool isSuccess;
  final String message;
  final PaymentData? data;

  PaymentResponse({
    required this.isSuccess,
    required this.message,
    this.data,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      isSuccess: json['status'] == 'success',
      message: json['message'] ?? '',
      data: json['data'] != null ? PaymentData.fromJson(json['data']) : null,
    );
  }
}

class PaymentStatusResponse {
  final bool isSuccess;
  final String message;
  final PaymentStatusData? data;

  PaymentStatusResponse({
    required this.isSuccess,
    required this.message,
    this.data,
  });

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    return PaymentStatusResponse(
      isSuccess: json['status'] == 'success',
      message: json['message'] ?? '',
      data: json['data'] != null
          ? PaymentStatusData.fromJson(json['data'])
          : null,
    );
  }
}
