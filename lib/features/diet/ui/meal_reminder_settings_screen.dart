import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/meal_time_defaults.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/features/diet/logic/meal_confirmation_cubit.dart';
import 'package:team_ar/features/diet/logic/meal_confirmation_state.dart';
import 'package:team_ar/features/diet/services/meal_reminder_service.dart';

class MealReminderSettingsScreen extends StatelessWidget {
  final Set<int> presentMealIds;

  const MealReminderSettingsScreen({
    super.key,
    required this.presentMealIds,
  });

  String _formatTime(TimeOfDay tod) {
    final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final minute = tod.minute.toString().padLeft(2, '0');
    final period = tod.period == DayPeriod.am ? 'ص' : 'م';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF102E50),
        elevation: 0,
        leading: const AppBarBackButton(color: AppColors.white),
        centerTitle: true,
        title: Text(
          'إعدادات تذكير الوجبات',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<MealConfirmationCubit, MealConfirmationState>(
        builder: (context, state) {
          final cubit = context.read<MealConfirmationCubit>();
          final mealList = presentMealIds.isNotEmpty
              ? presentMealIds.toList()
              : [1, 2, 3, 4, 5, 6];
          mealList.sort();

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            children: [
              // ─── مفتاح التفعيل العام ─────────────────────────
              Container(
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.sp),
                          decoration: BoxDecoration(
                            color: const Color(0xFF102E50).withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_active_rounded,
                            color: const Color(0xFF102E50),
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تفعيل التنبيهات',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF102E50),
                              ),
                            ),
                            Text(
                              'تذكيرك بعد موعد كل وجبة بساعة',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: state.remindersEnabled,
                      activeColor: const Color(0xFF102E50),
                      onChanged: (val) {
                        cubit.toggleReminders(val, presentMealIds: presentMealIds);
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // ─── بطاقة ساعات الهدوء ───────────────────────────
              Container(
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bedtime_rounded,
                          color: Colors.indigo[700],
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'ساعات الهدوء (عدم الإزعاج)',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'لن يتم إرسال أي إشعارات بين ${state.quietHoursStart} ليلاً و ${state.quietHoursEnd} صباحاً للحفاظ على نومك.',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // ─── قسم مواعيد الوجبات ─────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'مواعيد وجباتك المعتادة (اضغط للتعديل)',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              ...mealList.map((mId) {
                final tod = MealTimeDefaults.getTimeForMeal(
                  mId,
                  state.customMealTimes,
                );
                final mealName = MealReminderService.getMealTitle(mId);

                return Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.15),
                    ),
                  ),
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    title: Text(
                      mealName,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'التذكير: ${_formatTime(tod.replacing(hour: (tod.hour + 1) % 24))}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                    trailing: InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: tod,
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF102E50),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (picked != null) {
                          cubit.updateMealTime(
                            mId,
                            picked,
                            presentMealIds: presentMealIds,
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF102E50)
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14.sp,
                              color: const Color(0xFF102E50),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _formatTime(tod),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF102E50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
