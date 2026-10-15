import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// اختيار الإحساس: سهل / متوسط / صعب / مجهود أقصى بتصميم متناسق ونظيف
class FeelingSelector extends StatelessWidget {
  final int? selected;
  final ValueChanged<int> onSelected;

  const FeelingSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const _feelings = [
    _FeelingOption(value: 1, label: 'سهل', emoji: '😊', color: Color(0xFF10B981)),
    _FeelingOption(value: 2, label: 'متوسط', emoji: '💪', color: Color(0xFF3B82F6)),
    _FeelingOption(value: 3, label: 'صعب', emoji: '🔥', color: Color(0xFFF59E0B)),
    _FeelingOption(value: 4, label: 'أقصى', emoji: '⚡', color: Color(0xFFEF4444)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحساس الجلسة',
          style: TextStyle(
            color: const Color(0xFF102E50),
            fontSize: 13.sp,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          children: _feelings.map((f) {
            final isSelected = selected == f.value;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelected(f.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? f.color.withValues(alpha: 0.12)
                        : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isSelected
                          ? f.color
                          : Colors.grey.withValues(alpha: 0.18),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(f.emoji, style: TextStyle(fontSize: 18.sp)),
                      SizedBox(height: 2.h),
                      Text(
                        f.label,
                        style: TextStyle(
                          color: isSelected ? f.color : Colors.grey[700],
                          fontSize: 11.sp,
                          fontFamily: 'Cairo',
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _FeelingOption {
  final int value;
  final String label;
  final String emoji;
  final Color color;

  const _FeelingOption({
    required this.value,
    required this.label,
    required this.emoji,
    required this.color,
  });
}
