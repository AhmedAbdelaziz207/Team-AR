import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/core/network/dio_factory.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/features/auth/register/model/user_model.dart';
import 'package:team_ar/features/auth/register/repos/register_repository.dart';
import 'package:team_ar/features/payment/logic/payment_cubit.dart';
import 'package:team_ar/features/payment/model/payment_model.dart';
import 'package:team_ar/features/payment/repository/payment_repository.dart';
import 'package:team_ar/features/payment/screens/payment_result_screen.dart';
import 'package:team_ar/features/plans_screen/model/user_plan.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final UserPlan plan;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final bool isNewUser;

  const PaymentScreen({
    super.key,
    required this.plan,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    this.isNewUser = false,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late PaymentCubit _paymentCubit;
  String? _userId;
  Map<String, dynamic>? _tempUserData;
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    debugPrint('=== بداية تهيئة شاشة الدفع ===');
    _paymentCubit = PaymentCubit(getIt<PaymentRepository>());
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    debugPrint('=== بداية تحميل بيانات المستخدم ===');

    try {
      if (widget.isNewUser) {
        await _loadTempUserData();
      } else {
        await _loadExistingUserData();
      }
    } catch (e) {
      debugPrint('خطأ في تحميل بيانات المستخدم: $e');
      _showErrorAndNavigate('حدث خطأ في تحميل بيانات المستخدم');
    } finally {
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

  Future<void> _loadTempUserData() async {
    debugPrint('تحميل بيانات المستخدم المؤقت');

    final prefs = await SharedPreferences.getInstance();
    final tempUserJson = prefs.getString('temp_user') ??
        await SharedPreferencesHelper.getString('temp_user');

    if (tempUserJson != null && tempUserJson.isNotEmpty) {
      try {
        final tempData = jsonDecode(tempUserJson);

        // التحقق من صحة البيانات وإصلاحها إذا لزم الأمر
        if (tempData['Id'] == null || tempData['Id'] == 0) {
          tempData['Id'] = DateTime.now().millisecondsSinceEpoch;
          await _saveTempUserData(tempData);
        }

        setState(() {
          _tempUserData = tempData;
        });
        debugPrint('تم تحميل بيانات المستخدم المؤقت بنجاح');
      } catch (e) {
        debugPrint('خطأ في تحليل بيانات المستخدم المؤقت: $e');
        _showErrorAndNavigate('بيانات التسجيل غير صحيحة، يرجى إعادة التسجيل');
      }
    } else {
      _showErrorAndNavigate('لم يتم العثور على بيانات التسجيل');
    }
  }

  Future<void> _loadExistingUserData() async {
    final userId = await SharedPreferencesHelper.getString(AppConstants.userId);

    if (userId != null && userId.isNotEmpty) {
      setState(() {
        _userId = userId;
      });
      debugPrint('تم تحميل معرف المستخدم: $userId');
    } else {
      _showErrorAndNavigate('يرجى تسجيل الدخول أولاً');
    }
  }

  Future<void> _saveTempUserData(Map<String, dynamic> data) async {
    try {
      final jsonString = jsonEncode(data);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('temp_user', jsonString);
      await SharedPreferencesHelper.setString('temp_user', jsonString);
    } catch (e) {
      debugPrint('خطأ في حفظ البيانات المؤقتة: $e');
    }
  }

  void _showErrorAndNavigate(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          if (widget.isNewUser) {
            Navigator.pushNamedAndRemoveUntil(
                context, Routes.register, (route) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(
                context, Routes.login, (route) => false);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        shouldCreateAccount: true,
        tempUserData: state.tempUserData,
        customerEmail: state.customerEmail,
        customerPassword: state.customerPassword,
      );
    } else if (state is PaymentFailed) {
      _navigateToPaymentResult(
        isSuccess: false,
        message: state.message,
        paymentData: state.paymentData,
        plan: state.plan,
      );
    } else if (state is PaymentExpired) {
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
        plan: widget.plan,
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
    bool shouldCreateAccount = false,
    Map<String, dynamic>? tempUserData,
    String? customerEmail,
    String? customerPassword,
  }) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentResultScreen(
          isSuccess: isSuccess,
          message: message,
          paymentData: paymentData,
          plan: plan ?? widget.plan,
          userEmail: customerEmail ?? widget.customerEmail,
          shouldCreateAccount: shouldCreateAccount,
          tempUserData: tempUserData,
          customerPassword: customerPassword,
        ),
      ),
    );
  }

  void _createPaymentWithMethod(int paymentMethodId) {
    final userId = _getUserId();
    if (userId == null) return;

    debugPrint('إنشاء دفع بطريقة: $paymentMethodId');

    // حفظ البيانات المؤقتة في PaymentCubit
    if (widget.isNewUser && _tempUserData != null) {
      _paymentCubit.setTempUserData(
        _tempUserData!,
        widget.customerEmail,
        // استخراج كلمة السر من البيانات المؤقتة
        _tempUserData!['Password'] ?? '',
      );
    }

    _paymentCubit.createPayment(
      customerName: widget.customerName,
      customerEmail: widget.customerEmail,
      customerPhone: widget.customerPhone,
      plan: widget.plan,
      userId: userId,
      paymentMethodId: paymentMethodId,
    );
  }

  Widget _buildPaymentContent(BuildContext context, PaymentState state) {
    if (state is PaymentLoading || state is PaymentVerifying) {
      return _buildLoadingWidget();
    } else if (state is PaymentCreated) {
      return _buildPaymentWebView(state.paymentData);
    } else if (state is PaymentMethodsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is PaymentMethodsLoaded) {
      return _buildPaymentMethodsScreen(state.paymentMethods);
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlanDetailsCard(),
          SizedBox(height: 24.h),
          _buildCustomerInfoCard(),
          SizedBox(height: 32.h),
          _buildPaymentButton(),
        ],
      ),
    );
  }

  Widget _buildPlanDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل الاشتراك',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.newPrimaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            _buildInfoRow('الباقة:', widget.plan.name ?? 'غير محدد'),
            _buildInfoRow('المدة:', '${widget.plan.duration} يوم'),
            _buildInfoRow('السعر:', '${widget.plan.newPrice} جنيه'),
            if (widget.plan.oldPrice != null &&
                widget.plan.oldPrice! > widget.plan.newPrice!)
              _buildInfoRow('الخصم:',
                  '${widget.plan.oldPrice! - widget.plan.newPrice!} جنيه'),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات العميل',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.newPrimaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            _buildInfoRow('الاسم:', widget.customerName),
            _buildInfoRow('البريد الإلكتروني:', widget.customerEmail),
            _buildInfoRow('رقم الهاتف:', widget.customerPhone),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton() {
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
  }

  Widget _buildPaymentMethodsScreen(List<PaymentMethod> paymentMethods) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر طريقة الدفع',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.newPrimaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          ...paymentMethods.map((method) => _buildPaymentMethodCard(method)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: () => _createPaymentWithMethod(method.id),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              _buildPaymentMethodIcon(method),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (method.redirect)
                      Text(
                        'يتطلب إعادة توجيه',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 20.w,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodIcon(PaymentMethod method) {
    if (method.logo != null && method.logo!.isNotEmpty) {
      return Image.network(
        method.logo!,
        width: 40.w,
        height: 40.h,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.payment,
            size: 40.w,
            color: AppColors.newPrimaryColor,
          );
        },
      );
    }
    return Icon(
      Icons.payment,
      size: 40.w,
      color: AppColors.newPrimaryColor,
    );
  }

  String? _getUserId() {
    if (widget.isNewUser && _tempUserData != null) {
      final userId = _tempUserData!['Id']?.toString();
      if (userId == null || userId.isEmpty || userId == '0') {
        _showErrorAndNavigate('معرف المستخدم غير صحيح');
        return null;
      }
      return userId;
    } else if (!widget.isNewUser && _userId != null && _userId!.isNotEmpty) {
      return _userId;
    } else {
      _showErrorAndNavigate(widget.isNewUser
          ? 'يرجى إكمال التسجيل أولاً'
          : 'يرجى تسجيل الدخول أولاً');
      return null;
    }
  }

// payment_screen.dart - تحديث دالة _buildPaymentWebView
  Widget _buildPaymentWebView(PaymentData paymentData) {
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
                  plan: widget.plan,
                  shouldCreateAccount: widget.isNewUser,
                  tempUserData: _tempUserData,
                  customerEmail: widget.customerEmail,
                  customerPassword: _tempUserData?['Password'] ?? '',
                );
              });
            } else if (lowerUrl.contains('fail') || lowerUrl.contains('error')) {
              debugPrint('تم اكتشاف فشل الدفع: $url');
              _navigateToPaymentResult(
                isSuccess: false,
                message: 'فشلت عملية الدفع',
                paymentData: paymentData,
                plan: widget.plan,
              );
            } else if (lowerUrl.contains('cancel')) {
              debugPrint('تم إلغاء الدفع: $url');
              _navigateToPaymentResult(
                isSuccess: false,
                message: 'تم إلغاء عملية الدفع',
                paymentData: paymentData,
                plan: widget.plan,
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
                _buildInfoRow('رقم الفاتورة:', paymentData.invoiceId.toString()),
                _buildInfoRow('المبلغ:', '${paymentData.amount} ${paymentData.currency}'),
                if (paymentData.expireDate != null)
                  _buildInfoRow('تنتهي في:', paymentData.expireDate!),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // تعليمات خاصة بكل طريقة دفع
          if (paymentData.fawryCode != null) _buildFawryInstructions(paymentData),

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
                      plan: widget.plan,
                      shouldCreateAccount: widget.isNewUser,
                      tempUserData: _tempUserData,
                      customerEmail: widget.customerEmail,
                      customerPassword: _tempUserData?['Password'] ?? '',
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
                      plan: widget.plan,
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16.sp),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePaymentSuccess() async {
    debugPrint('=== بداية معالجة نجاح الدفع ===');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم الدفع بنجاح! جاري تفعيل الاشتراك...'),
        backgroundColor: Colors.green,
      ),
    );

    if (widget.isNewUser && _tempUserData != null) {
      await _completeUserRegistration();
    } else {
      // للمستخدم الحالي، العودة إلى الشاشة الرئيسية
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _completeUserRegistration() async {
    try {
      final registerRepo = RegisterRepository(getIt<ApiService>());
      final oldUser = UserModel.fromJson(_tempUserData!);

      final now = DateTime.now();
      final user = UserModel(
        id: oldUser.id,
        userName: oldUser.userName,
        email: oldUser.email,
        password: oldUser.password,
        age: oldUser.age,
        address: oldUser.address,
        phone: oldUser.phone,
        long: oldUser.long,
        weight: oldUser.weight,
        dailyWork: oldUser.dailyWork,
        areYouSmoker: oldUser.areYouSmoker,
        aimOfJoin: oldUser.aimOfJoin,
        anyPains: oldUser.anyPains,
        allergyOfFood: oldUser.allergyOfFood,
        foodSystem: oldUser.foodSystem,
        numberOfMeals: oldUser.numberOfMeals,
        lastExercise: oldUser.lastExercise,
        anyInfection: oldUser.anyInfection,
        abilityOfSystemMoney: oldUser.abilityOfSystemMoney,
        numberOfDays: oldUser.numberOfDays,
        gender: oldUser.gender,
        packageId: widget.plan.id,
        startPackage: now,
        endPackage: now.add(Duration(days: widget.plan.duration!)),
      );

      final result = await registerRepo.addTrainer(user);

      result.when(
        success: (data) async {
          // حفظ بيانات المستخدم
          await SharedPreferencesHelper.setString(
              AppConstants.userId, data.id.toString());
          await SharedPreferencesHelper.setString(
              AppConstants.userName, data.userName ?? '');
          await SharedPreferencesHelper.setString(
              AppConstants.token, data.token ?? '');
          await SharedPreferencesHelper.setString(
              AppConstants.userRole, 'user');

          if (data.token != null) {
            DioFactory.setTokenIntoHeaderAfterLogin(data.token!);
          }

          // حذف البيانات المؤقتة
          await SharedPreferencesHelper.remove('temp_user');
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('temp_user');

          // التوجيه إلى الشاشة الرئيسية
          Navigator.pushNamedAndRemoveUntil(
              context, Routes.rootScreen, (route) => false);
        },
        failure: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل إكمال التسجيل: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('خطأ في إكمال التسجيل: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في إكمال التسجيل: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
