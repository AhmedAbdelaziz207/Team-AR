import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import '../theme/app_colors.dart';
import 'dart:ui' as ui;

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    this.formKey,
    this.validator,
    this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.obscureText,
    this.textDirection,
  });

  final GlobalKey<FormState>? formKey;
  final String? Function(String?)? validator;
  final String? hintText;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final bool? obscureText;
  final TextDirection? textDirection;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: TextFormField(
        obscureText: widget.obscureText ?? false,
        validator: widget.validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return AppLocalKeys.fieldRequired.tr();
              }
              return null;
            },
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          hintText: widget.hintText,
          // Use EasyLocalization for dynamic hints.
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.black.withOpacity(.3)),
          suffixIcon: Icon(widget.suffixIcon, color: Colors.grey),
          // prefixIcon: Icon(widget.prefixIcon, color: Colors.grey),
          filled: true,
          fillColor: AppColors.darkLavender.withOpacity(.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.sp),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
