import 'dart:developer';
import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';

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

  final bool _isCreatingAccount = false;
  final bool _accountCreated = false;
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
                      AppLocalKeys.paymentResultTitle.tr(),
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
        title = AppLocalKeys.creatingAccountLoading.tr();
        titleColor = Colors.orange;
      } else if (widget.shouldCreateAccount && _accountCreationError != null) {
        title = AppLocalKeys.creatingAccountFailed.tr();
        titleColor = Colors.red;
      } else {
        title = AppLocalKeys.paymentSuccessEmoji.tr();
        titleColor = Colors.green;
        // Handle is Paid to be true ;
        _updateUserPaymentStatus();
      }
    } else {
      title = AppLocalKeys.paymentFailedEmoji.tr();
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
              AppLocalKeys.creatingAccountLoading.tr(),
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
                AppLocalKeys.accountCreatedSuccessfully.tr(),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.newPrimaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppColors.newPrimaryColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.newPrimaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(18.r),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: AppColors.newPrimaryColor,
                  size: 24.w,
                ),
                SizedBox(width: 10.w),
                Text(
                  AppLocalKeys.transactionDetails.tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.newPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                _buildDetailRow(
                    AppLocalKeys.invoiceId.tr(), widget.paymentData!.invoiceId.toString()),
                _buildDetailRow(AppLocalKeys.planLabel.tr(), widget.plan.name ?? AppLocalKeys.notSpecified.tr()),
                _buildDetailRow(AppLocalKeys.paidAmount.tr(),
                    '${widget.paymentData!.amount} ${widget.paymentData!.currency}'),
                _buildDetailRow(AppLocalKeys.paymentMethodTitle.tr(), _getPaymentMethodName()),
                _buildDetailRow(AppLocalKeys.date.tr(),
                    DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())),
                _buildDetailRow(AppLocalKeys.durationLabel.tr(), '${widget.plan.duration} ${AppLocalKeys.daysAgo.tr()}'),
                if (widget.paymentData!.fawryCode != null) ...[
                  Divider(height: 20.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: _buildDetailRow(AppLocalKeys.fawryCode.tr(), widget.paymentData!.fawryCode!,
                        isHighlight: true),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodName() {
    switch (widget.paymentData!.methodType) {
      case PaymentMethodType.visa:
        return AppLocalKeys.visa.tr();
      case PaymentMethodType.mastercard:
        return AppLocalKeys.mastercard.tr();
      case PaymentMethodType.fawry:
        return AppLocalKeys.fawry.tr();
      case PaymentMethodType.wallet:
        return AppLocalKeys.wallet.tr();
      default:
        return AppLocalKeys.notSpecified.tr();
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
                    AppLocalKeys.login.tr(),
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
              AppLocalKeys.backToPlans.tr(),
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
                    AppLocalKeys.retryCreateAccount.tr(),
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
              AppLocalKeys.contactSupport.tr(),
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
                    AppLocalKeys.tryAgainButton.tr(),
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
              AppLocalKeys.backToPlans.tr(),
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
