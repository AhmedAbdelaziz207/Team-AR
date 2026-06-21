import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/features/payment/model/payment_model.dart';
import 'package:team_ar/features/plans_screen/model/user_plan.dart';

class PaymentResultScreen extends StatefulWidget {
  final bool isSuccess;
  final String message;
  final PaymentData? paymentData;
  final UserPlan plan;
  final String? userEmail;
  final bool shouldCreateAccount;
  final Map<String, dynamic>? tempUserData;
  final String? customerPassword;

  const PaymentResultScreen({
    super.key,
    required this.isSuccess,
    required this.message,
    this.paymentData,
    required this.plan,
    this.userEmail,
    this.shouldCreateAccount = false,
    this.tempUserData,
    this.customerPassword,
  });

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isCreatingAccount = false;
  bool _accountCreated = false;
  String? _accountCreationError;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // إنشاء الحساب إذا كان الدفع ناجحاً ومطلوب إنشاء حساب
    if (widget.isSuccess && widget.shouldCreateAccount) {
    } else if (widget.isSuccess) {
      _saveWelcomeMessage();
    }
  }

  Future<void> _saveWelcomeMessage() async {
    await SharedPreferencesHelper.setString(
      'welcome_message',
      'مرحباً بك! تم تفعيل اشتراكك في ${widget.plan.name} بنجاح',
    );
  }

  Future<void> _updateUserPaymentStatus() async {
    try {
      final String? userId =
          await SharedPreferencesHelper.getString(AppConstants.userId);
      log("Upadte user payment status $userId");
      if (userId == null || userId.isEmpty) {
        return;
      }

      final api = getIt<ApiService>();
      await api.updateUserPayment(userId);
      await SharedPreferencesHelper.setData('has_completed_payment_$userId', true);
    } catch (e) {
      debugPrint('Failed to update user payment status: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // شريط علوي بسيط
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'نتيجة الدفع',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),

              // المحتوى القابل للتمرير
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 40.h), // مساحة في الأعلى

                      // أيقونة النتيجة المتحركة
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: _buildResultIcon(),
                          );
                        },
                      ),

                      SizedBox(height: 32.h),

                      // عنوان النتيجة
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildResultTitle(context),
                      ),

                      SizedBox(height: 16.h),

                      // رسالة النتيجة
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildResultMessage(context),
                      ),

                      // معلومات إنشاء الحساب
                      if (widget.isSuccess && widget.shouldCreateAccount)
                        _buildAccountCreationStatus(),

                      // تفاصيل الدفع في حالة النجاح
                      if (widget.isSuccess && widget.paymentData != null) ...[
                        SizedBox(height: 32.h),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildPaymentDetails(context),
                        ),
                      ],

                      SizedBox(height: 40.h), // مساحة في الأسفل
                    ],
                  ),
                ),
              ),

              // أزرار الإجراءات - ثابتة في الأسفل
              Container(
                padding: EdgeInsets.all(24.w),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildActionButtons(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultIcon() {
    Color iconColor;
    IconData iconData;
    Color backgroundColor;

    if (widget.isSuccess) {
      if (widget.shouldCreateAccount && _isCreatingAccount) {
        iconColor = Colors.orange;
        iconData = Icons.hourglass_empty;
        backgroundColor = Colors.orange.withOpacity(0.1);
      } else if (widget.shouldCreateAccount && _accountCreationError != null) {
        iconColor = Colors.red;
        iconData = Icons.error;
        backgroundColor = Colors.red.withOpacity(0.1);
      } else {
        iconColor = Colors.green;
        iconData = Icons.check_circle;
        backgroundColor = Colors.green.withOpacity(0.1);
      }
    } else {
      iconColor = Colors.red;
      iconData = Icons.error;
      backgroundColor = Colors.red.withOpacity(0.1);
    }

    return Container(
      width: 120.w,
      height: 120.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: Border.all(color: iconColor, width: 2),
      ),
      child: _isCreatingAccount
          ? CircularProgressIndicator(color: iconColor)
          : Icon(iconData, size: 60.w, color: iconColor),
    );
  }

  Widget _buildResultTitle(BuildContext context) {
    String title;
    Color titleColor;

    if (widget.isSuccess) {
      if (widget.shouldCreateAccount && _isCreatingAccount) {
        title = 'جاري إنشاء حسابك... ⏳';
        titleColor = Colors.orange;
      } else if (widget.shouldCreateAccount && _accountCreationError != null) {
        title = 'فشل في إنشاء الحساب ❌';
        titleColor = Colors.red;
      } else {
        title = 'تم الدفع بنجاح! 🎉';
        titleColor = Colors.green;
        // Handle is Paid to be true ;
        _updateUserPaymentStatus();
      }
    } else {
      title = 'فشل في عملية الدفع ❌';
      titleColor = Colors.red;
    }

    return Text(
      title,
      style: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: titleColor,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildResultMessage(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(
        widget.message,
        style: TextStyle(
          fontSize: 16.sp,
          color: Colors.grey[700],
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAccountCreationStatus() {
    if (_isCreatingAccount) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          children: [
            const CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 8.h),
            Text(
              'جاري إنشاء حسابك...',
              style: TextStyle(fontSize: 14.sp, color: Colors.orange),
            ),
          ],
        ),
      );
    } else if (_accountCreationError != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Text(
            _accountCreationError!,
            style: TextStyle(fontSize: 14.sp, color: Colors.red[700]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (_accountCreated) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20.w),
              SizedBox(width: 8.w),
              Text(
                'تم إنشاء حسابك بنجاح!',
                style: TextStyle(fontSize: 14.sp, color: Colors.green[700]),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPaymentDetails(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.newPrimaryColor.withOpacity(0.05), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.newPrimaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: AppColors.newPrimaryColor,
                size: 24.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'تفاصيل الدفع',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.newPrimaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildDetailRow(
              'رقم الفاتورة:', widget.paymentData!.invoiceId.toString()),
          _buildDetailRow('الباقة:', widget.plan.name ?? 'غير محدد'),
          _buildDetailRow('المبلغ:',
              '${widget.paymentData!.amount} ${widget.paymentData!.currency}'),
          _buildDetailRow('طريقة الدفع:', _getPaymentMethodName()),
          _buildDetailRow('التاريخ:',
              DateFormat('dd/MM/yyyy HH:mm', 'ar').format(DateTime.now())),
          _buildDetailRow('المدة:', '${widget.plan.duration} يوم'),
          if (widget.paymentData!.fawryCode != null) ...[
            Divider(height: 20.h),
            _buildDetailRow('كود فوري:', widget.paymentData!.fawryCode!,
                isHighlight: true),
          ],
        ],
      ),
    );
  }

  String _getPaymentMethodName() {
    switch (widget.paymentData!.methodType) {
      case PaymentMethodType.visa:
        return 'فيزا';
      case PaymentMethodType.mastercard:
        return 'ماستركارد';
      case PaymentMethodType.fawry:
        return 'فوري';
      case PaymentMethodType.wallet:
        return 'المحفظة الإلكترونية';
      default:
        return 'غير محدد';
    }
  }

  Widget _buildDetailRow(String label, String value,
      {bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                color: isHighlight ? AppColors.newPrimaryColor : Colors.black87,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        if (widget.isSuccess &&
            (_accountCreated || !widget.shouldCreateAccount)) ...[
          // زر تسجيل الدخول
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed:
                  _isCreatingAccount ? null : () => _navigateToLogin(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.newPrimaryColor,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, size: 20.w),
                  SizedBox(width: 8.w),
                  Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // زر العودة للباقات
          TextButton(
            onPressed: () => _navigateToPlans(context),
            child: Text(
              'العودة للباقات',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ] else if (widget.shouldCreateAccount &&
            _accountCreationError != null) ...[
          // زر المحاولة مرة أخرى لإنشاء الحساب
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () => _navigateToPlans(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, size: 20.w),
                  SizedBox(width: 8.w),
                  Text(
                    'إعادة المحاولة لإنشاء الحساب',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // زر الاتصال بالدعم
          TextButton(
            onPressed: () {
              // يمكن إضافة وظيفة الاتصال بالدعم هنا
            },
            child: Text(
              'الاتصال بالدعم',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ] else if (!widget.isSuccess) ...[
          // زر إعادة المحاولة للدفع
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.newPrimaryColor,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, size: 20.w),
                  SizedBox(width: 8.w),
                  Text(
                    'إعادة المحاولة',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // زر العودة للباقات
          TextButton(
            onPressed: () => _navigateToPlans(context),
            child: Text(
              'العودة للباقات',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.login,
      (route) => false,
    );
  }

  void _navigateToPlans(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.plans,
      (route) => false,
    );
  }
}
