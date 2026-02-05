import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/features/home/admin/data/trainee_model.dart'
    as admin_user;
import 'package:team_ar/features/payment/logic/payment_cubit.dart';
import 'package:team_ar/features/payment/model/payment_model.dart';
import 'package:team_ar/features/payment/repository/payment_repository.dart';
import 'package:team_ar/features/payment/screens/payment_result_screen.dart';
import 'package:team_ar/features/payment/widgets/customer_info_card.dart';
import 'package:team_ar/features/payment/widgets/info_row.dart';
import 'package:team_ar/features/payment/widgets/payment_methods_list.dart';
import 'package:team_ar/features/payment/widgets/plan_details_card.dart';
import 'package:team_ar/features/plans_screen/model/user_plan.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/utils/app_constants.dart';

class PaymentScreen extends StatefulWidget {
  final String userId;

  const PaymentScreen({super.key, required this.userId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late PaymentCubit _paymentCubit;
  bool _isLoadingUserData = true;
  admin_user.TraineeModel? _userData;
  UserPlan? _planData;

  @override
  void initState() {
    super.initState();
    debugPrint('=== بداية تهيئة شاشة الدفع ===');
    _paymentCubit = PaymentCubit(getIt<PaymentRepository>());
    _fetchUserAndPlan(widget.userId).whenComplete(() {
      if (mounted) {
        setState(() {
          _isLoadingUserData = false;
        });
      }
    });
  }

  Future<void> _fetchUserAndPlan(String userId) async {
    try {
      final api = getIt<ApiService>();
      final user = await api.getLoggedUserData(userId);
      setState(() {
        _userData = user;
      });
      // If no plan passed, and user has packageId, fetch plan
      final pkgId = user.packageId;
      debugPrint('Fetched user. packageId=$pkgId');
      if (pkgId != null) {
        try {
          final plan = await api.getPlan(pkgId);
          setState(() {
            _planData = plan;
          });
        } catch (e) {
          debugPrint('فشل في جلب تفاصيل الباقة: $e');
        }
      }
    } catch (e) {
      debugPrint('فشل في جلب بيانات المستخدم: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    log("Open Payment Screen");

    return BlocProvider(
      create: (context) => _paymentCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الدفع'),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: SafeArea(
          child: _isLoadingUserData
              ? const Center(child: CircularProgressIndicator())
              : BlocConsumer<PaymentCubit, PaymentState>(
                  listener: _handlePaymentStateChanges,
                  builder: _buildPaymentContent,
                ),
        ),
      ),
    );
  }

  void _handlePaymentStateChanges(BuildContext context, PaymentState state) {
    if (state is PaymentError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } else if (state is PaymentSuccessWithData) {
      _navigateToPaymentResult(
        isSuccess: true,
        message: 'تم الدفع بنجاح! جاري إنشاء حسابك...',
        paymentData: state.paymentData,
        plan: state.plan,
      );
    } else if (state is PaymentFailed) {
      _navigateToPaymentResult(
        isSuccess: false,
        message: state.message,
        paymentData: state.paymentData,
        plan: state.plan,
      );
    } else if (state is PaymentCancelled) {
      _navigateToPaymentResult(
        isSuccess: false,
        message: state.message,
        paymentData: state.paymentData,
        plan: state.plan,
      );
    } else if (state is PaymentTimedOut) {
      _navigateToPaymentResult(
        isSuccess: false,
        message: state.message,
        paymentData: null,
        plan: _planData,
      );
    } else if (state is PaymentMethodsError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _navigateToPaymentResult({
    required bool isSuccess,
    required String message,
    PaymentData? paymentData,
    UserPlan? plan,
  }) {
    final UserPlan? effectivePlan = plan ?? _planData;
    final String effectiveEmail = _userData?.email ?? '';
    if (effectivePlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد باقة لعرض نتيجة الدفع')),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentResultScreen(
          isSuccess: isSuccess,
          message: message,
          paymentData: paymentData,
          plan: effectivePlan,
          userEmail: effectiveEmail,
        ),
      ),
    );
  }

  void _createPaymentWithMethod(int paymentMethodId) {
    log("_createPaymentWithMethod: $paymentMethodId");
    final effectivePlan = _planData;
    // if (effectivePlan == null) {
    //   // No plan available: navigate user to plans screen to select one
    //   Navigator.pushNamed(context, Routes.subscriptionPlans);
    //   return;
    // }
    final userId = widget.userId;

    debugPrint('إنشاء دفع بطريقة: $paymentMethodId');

    // Resolve reliable customer data
    Future<void> proceedWith(String name, String email) async {
      _paymentCubit.createPayment(
        customerName: name,
        customerEmail: email,
        plan: effectivePlan!,
        userId: userId,
        paymentMethodId: paymentMethodId,
      );
    }

    String name = _userData?.name ?? _userData?.userName ?? '';
    String email = _userData?.email ?? '';

    // If missing, try fetching user data once more
    if (name.isEmpty || email.isEmpty) {
      getIt<ApiService>().getLoggedUserData(userId).then((user) {
        setState(() {
          _userData = user;
        });
        final fallbackName = user.name ?? user.userName ?? '';
        final fallbackEmail = user.email ?? '';
        if (fallbackName.isEmpty || fallbackEmail.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'تعذر الحصول على بيانات العميل. يرجى المحاولة مرة أخرى.'),
            ),
          );
          return;
        }
        proceedWith(fallbackName, fallbackEmail);
      }).catchError((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('تعذر الحصول على بيانات العميل. يرجى المحاولة مرة أخرى.'),
          ),
        );
      });
    } else {
      proceedWith(name, email);
    }
  }

  Widget _buildPaymentContent(BuildContext context, PaymentState state) {
    log("_buildPaymentContent: $state");
    if (state is PaymentLoading || state is PaymentVerifying) {
      return _buildLoadingWidget();
    } else if (state is PaymentCreated) {
      return _buildPaymentWebView(state.paymentData);
    } else if (state is PaymentMethodsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is PaymentMethodsLoaded) {
      return PaymentMethodsList(
        methods: state.paymentMethods,
        onSelect: (m) => _createPaymentWithMethod(m.id),
      );
    } else {
      return _buildInitialScreen();
    }
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('جاري معالجة الدفع...'),
        ],
      ),
    );
  }

  Widget _buildInitialScreen() {
    final UserPlan? effectivePlan = _planData;
    final String name = _userData?.name ?? _userData?.userName ?? '';
    final String email = _userData?.email ?? '';
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (effectivePlan != null) PlanDetailsCard(plan: effectivePlan),
          SizedBox(height: 24.h),
          CustomerInfoCard(
            customerName: name,
            customerEmail: email,
          ),
          SizedBox(height: 32.h),
          _buildPaymentButton(),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return FutureBuilder<bool>(
      future: SharedPreferencesHelper.getBool(AppConstants.isReleased),
      builder: (context, snapshot) {
        final isReleased = snapshot.data ?? false;
        if (!isReleased) {
          return SizedBox(
              height: 50.h,
              child: Center(
                  child: Text('الاشتراك متاح عبر الإدارة فقط',
                      style: TextStyle(color: Colors.grey, fontSize: 16.sp))));
          // return const SizedBox.shrink(); // Or strictly hidden
        }
        return SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: () {
              debugPrint('=== تم النقر على زر الدفع ===');
              _paymentCubit.getPaymentMethods();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.newPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'اختيار طريقة الدفع',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentWebView(PaymentData paymentData) {
    log("Redirect to url:  ${paymentData.redirectTo}");
    if (paymentData.redirectTo == null || paymentData.redirectTo!.isEmpty) {
      return _buildPaymentInstructions(paymentData);
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('WebView بدأ تحميل: $url');
          },
          onPageFinished: (String url) {
            debugPrint('WebView انتهى من تحميل: $url');
            final lowerUrl = url.toLowerCase();

            // فحص مبسط للـ URLs بناءً على الاتفاق مع Fawaterk
            if (lowerUrl.contains('success')) {
              debugPrint('تم اكتشاف نجاح الدفع: $url');
              Future.delayed(const Duration(seconds: 1), () {
                _navigateToPaymentResult(
                  isSuccess: true,
                  message: 'تم الدفع بنجاح!',
                  paymentData: paymentData,
                  plan: _planData,
                );
              });
            } else if (lowerUrl.contains('fail') ||
                lowerUrl.contains('error')) {
              debugPrint('تم اكتشاف فشل الدفع: $url');
              _navigateToPaymentResult(
                isSuccess: false,
                message: 'فشلت عملية الدفع',
                paymentData: paymentData,
                plan: _planData,
              );
            } else if (lowerUrl.contains('cancel')) {
              debugPrint('تم إلغاء الدفع: $url');
              _navigateToPaymentResult(
                isSuccess: false,
                message: 'تم إلغاء عملية الدفع',
                paymentData: paymentData,
                plan: _planData,
              );
            } else if (lowerUrl.contains('pending')) {
              debugPrint('الدفع قيد المعالجة: $url');
              // لا نفعل شيء - نتركه للمستخدم ليقرر
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('خطأ في WebView: ${error.description}');
            // لا نحاول التحقق من API - فقط نظهر رسالة خطأ
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('حدث خطأ في تحميل صفحة الدفع'),
                backgroundColor: Colors.orange,
                action: SnackBarAction(
                  label: 'إعادة المحاولة',
                  onPressed: () {
                    // controller.reload();
                  },
                ),
              ),
            );
          },
        ),
      );

    log("Redirect to url:  ${paymentData.redirectTo}");
    // تحميل الرابط
    controller.loadRequest(Uri.parse(paymentData.redirectTo!));
    return WebViewWidget(controller: controller);
  }

  Widget _buildPaymentInstructions(PaymentData paymentData) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 64.w,
            color: AppColors.newPrimaryColor,
          ),
          SizedBox(height: 24.h),
          Text(
            'تعليمات الدفع',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          // معلومات الفاتورة
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                InfoRow(
                    label: 'رقم الفاتورة:',
                    value: paymentData.invoiceId.toString()),
                InfoRow(
                    label: 'المبلغ:',
                    value: '${paymentData.amount} ${paymentData.currency}'),
                if (paymentData.expireDate != null)
                  InfoRow(label: 'تنتهي في:', value: paymentData.expireDate!),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // تعليمات خاصة بكل طريقة دفع
          if (paymentData.fawryCode != null)
            _buildFawryInstructions(paymentData),

          SizedBox(height: 32.h),

          // أزرار التحكم للمستخدم
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  'بعد إكمال الدفع، اختر النتيجة المناسبة:',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16.h),

              // زر النجاح
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    _navigateToPaymentResult(
                      isSuccess: true,
                      message: 'تم الدفع بنجاح!',
                      paymentData: paymentData,
                      plan: _planData,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 20.w),
                      SizedBox(width: 8.w),
                      Text(
                        'تم الدفع بنجاح',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // زر الفشل
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    _navigateToPaymentResult(
                      isSuccess: false,
                      message: 'فشل في عملية الدفع',
                      paymentData: paymentData,
                      plan: _planData,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 20.w),
                      SizedBox(width: 8.w),
                      Text(
                        'فشل الدفع',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // زر الإلغاء
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء العملية والعودة',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFawryInstructions(PaymentData paymentData) {
    return Column(
      children: [
        Text(
          'توجه إلى أقرب نقطة فوري واستخدم الكود التالي:',
          style: TextStyle(fontSize: 16.sp),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.newPrimaryColor),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            paymentData.fawryCode!,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.newPrimaryColor,
            ),
          ),
        ),
        if (paymentData.expireDate != null)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              'ينتهي في: ${paymentData.expireDate}',
              style: TextStyle(fontSize: 14.sp, color: Colors.red),
            ),
          ),
      ],
    );
  }
}
