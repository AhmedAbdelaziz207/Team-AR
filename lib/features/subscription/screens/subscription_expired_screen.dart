import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/services/subscription_service.dart';
import 'package:team_ar/core/services/logger_service.dart';

class SubscriptionExpiredScreen extends StatefulWidget {
  const SubscriptionExpiredScreen({super.key});

  @override
  State<SubscriptionExpiredScreen> createState() => _SubscriptionExpiredScreenState();
}

class _SubscriptionExpiredScreenState extends State<SubscriptionExpiredScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  final LoggerService _logger = LoggerService();

  @override
  void initState() {
    super.initState();
    _logger.info('Subscription expired screen opened');
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
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
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // أيقونة التحذير المتحركة
                        Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Colors.red.withOpacity(0.1),
                                Colors.red.withOpacity(0.05),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            size: 60.sp,
                            color: Colors.red,
                          ),
                        ),

                        SizedBox(height: 30.h),

                        // عنوان رئيسي
                        Text(
                          'انتهى الاشتراك',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                            fontFamily: "Cairo",
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 15.h),

                        // رسالة توضيحية
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1.w,
                            ),
                          ),
                          child: Text(
                            'عذراً، لقد انتهت صلاحية اشتراكك ولن تتمكن من استخدام التطبيق حتى تجديد الاشتراك.',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.grey,
                              fontFamily: "Cairo",
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: 40.h),

                        // زر تجديد الاشتراك
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: () {
                              _logger.info('User clicked renew subscription');
                              // Navigator.pushNamedAndRemoveUntil(
                              //   context,
                              //   Routes.PlansScreen,
                              //       (route) => false,
                              // );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.newPrimaryColor,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              elevation: 3,
                              shadowColor: AppColors.newPrimaryColor.withOpacity(0.3),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.refresh,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'تجديد الاشتراك',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Cairo",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 15.h),

                        // زر إغلاق التطبيق
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: OutlinedButton(
                            onPressed: () {
                              _logger.info('User clicked close app');
                              _showCloseConfirmationDialog();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.grey, width: 1.w),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.exit_to_app,
                                  size: 20.sp,
                                  color: AppColors.grey,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'إغلاق التطبيق',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.grey,
                                    fontFamily: "Cairo",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 30.h),

                        // معلومات الدعم
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.newPrimaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'تحتاج مساعدة؟',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.newPrimaryColor,
                                  fontFamily: "Cairo",
                                ),
                              ),
                              SizedBox(height: 5.h),
                              GestureDetector(
                                onTap: () {
                                  _logger.info('User clicked support');
                                  // فتح صفحة الدعم
                                },
                                child: Text(
                                  'تواصل مع فريق الدعم',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.newPrimaryColor,
                                    fontFamily: "Cairo",
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCloseConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'إغلاق التطبيق',
          style: TextStyle(
            fontFamily: "Cairo",
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في إغلاق التطبيق؟',
          style: TextStyle(
            fontFamily: "Cairo",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: "Cairo",
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SubscriptionService.closeApp();
            },
            child: const Text(
              'إغلاق',
              style: TextStyle(
                fontFamily: "Cairo",
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



























// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:team_ar/core/theme/app_colors.dart';
// import '../../../core/services/subscription_service.dart';
//
// class SubscriptionExpiredScreen extends StatelessWidget {
//   const SubscriptionExpiredScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async => false, // منع الرجوع
//       child: Scaffold(
//         backgroundColor: AppColors.white,
//         body: SafeArea(
//           child: Padding(
//             padding: EdgeInsets.all(20.w),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // أيقونة التحذير
//                 Container(
//                   width: 120.w,
//                   height: 120.w,
//                   decoration: BoxDecoration(
//                     color: Colors.red.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.warning_amber_rounded,
//                     size: 60.sp,
//                     color: Colors.red,
//                   ),
//                 ),
//
//                 SizedBox(height: 30.h),
//
//                 // عنوان رئيسي
//                 Text(
//                   'انتهى الاشتراك',
//                   style: TextStyle(
//                     fontSize: 28.sp,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.black,
//                     fontFamily: "Cairo",
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//
//                 SizedBox(height: 15.h),
//
//                 // رسالة توضيحية
//                 Text(
//                   'عذراً، لقد انتهت صلاحية اشتراكك ولن تتمكن من استخدام التطبيق حتى تجديد الاشتراك.',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     color: AppColors.grey,
//                     fontFamily: "Cairo",
//                     height: 1.5,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//
//                 SizedBox(height: 40.h),
//
//                 // زر تجديد الاشتراك
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50.h,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Navigator.pushNamedAndRemoveUntil(
//                       //   context,
//                       //   Routes.PlansScreen(), // مسار شاشة الباقات
//                       //       (route) => false,
//                       // );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.newPrimaryColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10.r),
//                       ),
//                       elevation: 2,
//                     ),
//                     child: Text(
//                       'تجديد الاشتراك',
//                       style: TextStyle(
//                         fontSize: 18.sp,
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.white,
//                         fontFamily: "Cairo",
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 SizedBox(height: 15.h),
//
//                 // زر إغلاق التطبيق
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50.h,
//                   child: OutlinedButton(
//                     onPressed: () {
//                       SubscriptionService.closeApp();
//                     },
//                     style: OutlinedButton.styleFrom(
//                       side: BorderSide(color: AppColors.grey, width: 1.w),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10.r),
//                       ),
//                     ),
//                     child: Text(
//                       'إغلاق التطبيق',
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.grey,
//                         fontFamily: "Cairo",
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }