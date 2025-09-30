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
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
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

  Widget _buildIcon() {
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
}
