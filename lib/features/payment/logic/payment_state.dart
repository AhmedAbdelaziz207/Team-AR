part of 'payment_cubit.dart';

abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

// حالات طرق الدفع
class PaymentMethodsLoading extends PaymentState {}

class PaymentMethodsLoaded extends PaymentState {
  final List<PaymentMethod> paymentMethods;
  PaymentMethodsLoaded(this.paymentMethods);
}

class PaymentMethodsError extends PaymentState {
  final String message;
  PaymentMethodsError(this.message);
}

// حالات إنشاء الدفع
class PaymentLoading extends PaymentState {}

class PaymentCreated extends PaymentState {
  final PaymentData paymentData;
  PaymentCreated(this.paymentData);
}

// حالات التحقق من الدفع
class PaymentVerifying extends PaymentState {}

// حالات النجاح
class PaymentSuccess extends PaymentState {}

class PaymentSuccessWithData extends PaymentState {
  final PaymentData paymentData;
  final UserPlan plan;
  final Map<String, dynamic>? tempUserData;
  final String? customerEmail;
  final String? customerPassword;

  PaymentSuccessWithData(
      this.paymentData,
      this.plan,
      this.tempUserData,
      this.customerEmail,
      this.customerPassword,
      );
}

// حالات الفشل والإلغاء المحسنة
class PaymentFailed extends PaymentState {
  final String message;
  final PaymentData? paymentData;
  final UserPlan? plan;

  PaymentFailed(this.message, this.paymentData, this.plan);
}

class PaymentExpired extends PaymentState {
  final String message;
  final PaymentData? paymentData;
  final UserPlan? plan;

  PaymentExpired(this.message, this.paymentData, this.plan);
}

class PaymentCancelled extends PaymentState {
  final String message;
  final PaymentData? paymentData;
  final UserPlan? plan;

  PaymentCancelled(this.message, this.paymentData, this.plan);
}

class PaymentTimedOut extends PaymentState {
  final String message;
  PaymentTimedOut(this.message);
}

class PaymentError extends PaymentState {
  final String message;
  PaymentError(this.message);
}
