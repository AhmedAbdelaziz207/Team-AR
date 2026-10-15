import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/weight_utils.dart';
import 'package:team_ar/features/workout_log/model/set_log.dart';

/// بطاقة ملخص ما تم تسجيله (تظهر بعد الحفظ بنجاح بتصميم ناصع وفخم)
class WorkoutSummaryCard extends StatelessWidget {
  final List<SetLog> sets;
  final String unit;

  const WorkoutSummaryCard({
    super.key,
    required this.sets,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    if (sets.isEmpty) return const SizedBox.shrink();

    final maxWeight =
        sets.map((s) => s.weightKg).reduce((a, b) => a > b ? a : b);
    final totalReps = sets.fold<int>(0, (sum, s) => sum + s.reps);

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة النجاح
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: const Color(0xFF10B981),
                  size: 34.sp,
                ),
              ),

              SizedBox(height: 10.h),

              Text(
                'عاش يا بطل! تم تسجيل تمرينك بنجاح 💪',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF102E50),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),

              SizedBox(height: 14.h),

              // ملخص كل مجموعة
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                ),
                child: Column(
                  children: sets.asMap().entries.map((entry) {
                    final i = entry.key;
                    final s = entry.value;
                    final w = WeightUtils.format(s.weightKg, unit);
                    final isLast = i == sets.length - 1;

                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                      decoration: BoxDecoration(
                        border: isLast
                            ? null
                            : Border(
                                bottom: BorderSide(
                                  color: Colors.grey.withValues(alpha: 0.12),
                                ),
                              ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'مجموعة ${s.setNumber}',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13.sp,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '$w × ${s.reps} تكرار',
                            style: TextStyle(
                              color: const Color(0xFF102E50),
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 14.h),

            // إحصائيات سريعة
            Row(
              children: [
                Expanded(
                  child: _StatChip(
                    label: 'أعلى وزن',
                    value: WeightUtils.format(maxWeight, unit),
                    color: const Color(0xFF102E50),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _StatChip(
                    label: 'إجمالي التكرارات',
                    value: '$totalReps',
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
 }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11.sp,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}
