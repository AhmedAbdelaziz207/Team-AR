import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/features/payment/model/payment_model.dart';

class PaymentMethodsList extends StatelessWidget {
  final List<PaymentMethod> methods;
  final void Function(PaymentMethod method) onSelect;
  const PaymentMethodsList(
      {super.key, required this.methods, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment_rounded, color: AppColors.newPrimaryColor, size: 28.sp),
              SizedBox(width: 10.w),
              Text(
                'اختر طريقة الدفع',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ...methods.map(
              (m) => _PaymentMethodCard(method: m, onTap: () => onSelect(m)))
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final VoidCallback onTap;
  const _PaymentMethodCard({
    required this.method,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          splashColor: AppColors.newPrimaryColor.withValues(alpha: 0.1),
          highlightColor: AppColors.newPrimaryColor.withValues(alpha: 0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Row(
              children: [
                _buildIcon(),
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
                          color: Colors.black87,
                        ),
                      ),
                      if (method.redirect)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            'سيتم توجيهك لصفحة الدفع',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.newPrimaryColor.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16.w,
                    color: AppColors.newPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: method.logo != null && method.logo!.isNotEmpty
          ? Image.network(
              method.logo!,
              width: 32.w,
              height: 32.h,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _defaultIcon();
              },
            )
          : _defaultIcon(),
    );
  }

  Widget _defaultIcon() {
    return Icon(
      Icons.credit_card,
      size: 32.w,
      color: AppColors.newPrimaryColor,
    );
  }
}
