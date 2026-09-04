import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ديالوج تأكيد عصري وفاخر موحد للاستخدام في كافة عمليات الحذف والتأكيد في التطبيق
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = "حذف",
    this.cancelText = "إلغاء",
    this.confirmColor = const Color(0xFFDC2626),
    this.icon = Icons.delete_forever_rounded,
    this.isDangerous = true,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;
  final IconData icon;
  final bool isDangerous;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.grey.withOpacity(0.12), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة دائرية بتأثير لوني هادئ وعصري
            Container(
              width: 68.r,
              height: 68.r,
              decoration: BoxDecoration(
                color: confirmColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: confirmColor.withOpacity(0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: confirmColor,
                    size: 28.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 18.h),

            // عنوان الديالوج
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.5.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
                fontFamily: "Cairo",
                height: 1.3,
              ),
            ),
            SizedBox(height: 10.h),

            // نص الرسالة التوضيحية
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                  fontFamily: "Cairo",
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // أزرار التحكم (إلغاء و حذف) واضحة وبارزة وعصرية
            Row(
              children: [
                // زر "إلغاء" واضح وكبير وذو تباين مريح وسهل القراءة
                Expanded(
                  child: Material(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14.r),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(false),
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            width: 1.3,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          cancelText,
                          style: TextStyle(
                            fontSize: 15.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF334155),
                            fontFamily: "Cairo",
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // زر "حذف" بتصميم جذاب وبارز
                Expanded(
                  child: Material(
                    color: confirmColor,
                    borderRadius: BorderRadius.circular(14.r),
                    elevation: 3,
                    shadowColor: confirmColor.withOpacity(0.4),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(true),
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isDangerous) ...[
                              Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                              SizedBox(width: 6.w),
                            ],
                            Text(
                              confirmText,
                              style: TextStyle(
                                fontSize: 15.5.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: "Cairo",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// دالة مساعدة لفتح ديالوج التأكيد العصري الموحد
Future<bool?> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = "حذف",
  String cancelText = "إلغاء",
  Color confirmColor = const Color(0xFFDC2626),
  IconData icon = Icons.delete_forever_rounded,
  bool isDangerous = true,
}) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => AppConfirmDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      confirmColor: confirmColor,
      icon: icon,
      isDangerous: isDangerous,
    ),
  );
}
