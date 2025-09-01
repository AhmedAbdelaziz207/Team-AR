import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import '../theme/app_colors.dart';
import 'dart:ui' as ui;

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField(
      {super.key,
      this.formKey,
      this.readOnly,
      this.validator,
      this.hintText,
      this.suffixIcon,
      this.prefixIcon,
      this.obscureText,
      this.textDirection,
      this.controller,
      this.isMultiline = false,
      this.keyboardType,
      this.onFieldSubmitted,
      this.iconColor,
      this.onChanged,
      this.onSaved,
      this.isAdmin = false});

  final GlobalKey<FormState>? formKey;
  final String? Function(String?)? validator;
  final String? hintText;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final bool? obscureText;
  final TextDirection? textDirection;
  final TextEditingController? controller;
  final bool isMultiline;
  final TextInputType? keyboardType;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final Color? iconColor;
  final bool? isAdmin;
  final bool? readOnly;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _hasError = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Directionality(
          textDirection: ui.TextDirection.rtl,
          child: TextFormField(
            onFieldSubmitted: widget.onFieldSubmitted,
            readOnly: widget.readOnly ?? false,
            style: TextStyle(
              color: AppColors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              fontFamily: "Cairo",
            ),
            onChanged: (value) {
              // إعادة التحقق عند تغيير القيمة
              if (_hasError) {
                setState(() {
                  _hasError = false;
                  _errorText = null;
                });
              }
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            },
            onSaved: widget.onSaved,
            keyboardType: widget.keyboardType,
            maxLines: widget.isMultiline ? 3 : 1,
            controller: widget.controller,
            obscureText: widget.obscureText ?? false,
            validator: (value) {
              final validatorFn = widget.validator ??
                  (val) {
                    if (val == null || val.isEmpty) {
                      return AppLocalKeys.fieldRequired.tr();
                    }
                    return null;
                  };

              final result = validatorFn(value);
              setState(() {
                _hasError = result != null;
                _errorText = result;
              });
              return result;
            },
            textDirection: ui.TextDirection.ltr,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.black.withOpacity(.3),
                  ),
              prefixIcon: Icon(
                widget.prefixIcon,
                color: _hasError
                    ? AppColors.red
                    : (widget.iconColor ?? Colors.grey),
              ),
              suffixIcon: _hasError
                  ? Icon(
                      Icons.error_outline,
                      color: AppColors.red,
                    )
                  : Icon(
                      widget.suffixIcon,
                      color: widget.iconColor ?? Colors.grey,
                    ),
              filled: true,
              fillColor: _hasError
                  ? AppColors.red.withOpacity(0.1)
                  : (widget.isAdmin!
                      ? AppColors.primaryColor.withOpacity(.055)
                      : AppColors.copperColor.withOpacity(.055)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.sp),
                borderSide: _hasError
                    ? const BorderSide(color: AppColors.red, width: 1.0)
                    : BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.sp),
                borderSide: _hasError
                    ? const BorderSide(color: AppColors.red, width: 1.0)
                    : BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.sp),
                borderSide: _hasError
                    ? const BorderSide(color: AppColors.red, width: 1.5)
                    : const BorderSide(
                        color: AppColors.copperColor, width: 1.5),
              ),
            ),
          ),
        ),
        if (_hasError && _errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h, right: 12.w),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.red,
                  size: 14.sp,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    _errorText!,
                    style: TextStyle(
                      color: AppColors.red,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
