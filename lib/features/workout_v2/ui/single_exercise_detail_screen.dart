import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../logic/single_exercise_cubit.dart';
import '../models/exercise_model.dart';
import '../models/exercise_set_log_model.dart';
import '../repos/workout_repository_v2.dart';

class SingleExerciseDetailScreen extends StatelessWidget {
  final ExerciseModel exercise;

  const SingleExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit =
            SingleExerciseCubit(getIt<WorkoutRepositoryV2>(), exercise);
        _initTrainee(cubit);
        return cubit;
      },
      child: const _SingleExerciseContent(),
    );
  }

  void _initTrainee(SingleExerciseCubit cubit) async {
    final userId = await SharedPreferencesHelper.getString(AppConstants.userId);
    cubit.initExercise(userId ?? 'test_trainee');
  }
}

class _SingleExerciseContent extends StatefulWidget {
  const _SingleExerciseContent();

  @override
  State<_SingleExerciseContent> createState() => _SingleExerciseContentState();
}

class _SingleExerciseContentState extends State<_SingleExerciseContent> {
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SingleExerciseCubit, SingleExerciseState>(
      listener: (context, state) {
        if (state.isSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تسجيل التمرين بنجاح يا بطل! 💪'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          Navigator.pop(context);
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red[700],
            ),
          );
        }
      },
      builder: (context, state) {
        final ex = state.exercise;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: const AppBarBackButton(color: AppColors.black),
            title: Text(
              ex.name,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            centerTitle: true,
            actions: [
              // Weight Unit Toggle (kg / lbs)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _unitPill(context, 'kg', state.unit == 'kg'),
                        _unitPill(context, 'lbs', state.unit == 'lbs'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.newPrimaryColor),
                )
              : SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Technique Video & Technical Tip Banner
                      _buildVideoAndTipSection(ex),

                      SizedBox(height: 14.h),

                      // 2. Coach Target Parameters Card
                      _buildCoachTargetsCard(ex),

                      SizedBox(height: 14.h),

                      // 3. Previous History Card
                      if (state.previousLog != null)
                        _buildPreviousHistoryCard(state),

                      SizedBox(height: 16.h),

                      // 4. Current Sets Input Table
                      _buildSetsTable(context, state),

                      SizedBox(height: 18.h),

                      // 5. Effort Rating Selector
                      _buildEffortSelector(context, state),

                      SizedBox(height: 14.h),

                      // 6. Optional Notes to Coach
                      TextField(
                        controller: _notesCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'ملاحظة للمدرب (اختياري)...',
                          hintStyle: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.2)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.2)),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // 7. Save Exercise CTA
                      SizedBox(
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: state.isSaving
                              ? null
                              : () async {
                                  final userId =
                                      await SharedPreferencesHelper.getString(
                                          AppConstants.userId);
                                  if (context.mounted) {
                                    context
                                        .read<SingleExerciseCubit>()
                                        .saveExercise(
                                          userId ?? 'test_trainee',
                                          notes: _notesCtrl.text.isNotEmpty
                                              ? _notesCtrl.text
                                              : null,
                                        );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.newPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            elevation: 2,
                          ),
                          child: state.isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                        Icons.check_circle_outline_rounded,
                                        color: Colors.white),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'حفظ تمرين اليوم 💪',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _unitPill(BuildContext context, String unit, bool selected) {
    return InkWell(
      onTap: () => context.read<SingleExerciseCubit>().toggleUnit(unit),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.newPrimaryColor
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          unit,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : AppColors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoAndTipSection(ExerciseModel ex) {
    final tipText = (ex.technicalTip != null && ex.technicalTip!.isNotEmpty)
        ? ex.technicalTip!
        : 'HORIZONTAL GRIP!!';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // In-App Embedded Video Player with Floating Amber Cue or Smart Fallback
          _ExerciseVideoPlayerWidget(
            videoUrl: ex.videoGuideUrl,
            tipText: tipText,
            exerciseName: ex.name,
          ),

          // Technical Tip Bottom Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(16.r)),
              border: Border(
                top: BorderSide(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_rounded,
                    color: const Color(0xFFD97706), size: 18.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'توجيه المدرب: $tipText',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // كبسولات المعايير الخمسة بتصميم زجاجي مطابق ومطور عن الفيديو المرجعي
  Widget _buildCoachTargetsCard(ExerciseModel ex) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded,
                  color: AppColors.newPrimaryColor, size: 16.sp),
              SizedBox(width: 6.w),
              Text(
                'معايير الحمل المحددة من المدرب',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _glassParamPill(
                  label: 'المجموعات',
                  value: '${ex.targetSets}',
                  icon: Icons.layers_rounded,
                  accentColor: const Color(0xFF3B82F6),
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: _glassParamPill(
                  label: 'التكرار',
                  value: ex.targetRepsRange,
                  icon: Icons.repeat_rounded,
                  accentColor: const Color(0xFF10B981),
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: _glassParamPill(
                  label: 'الراحة',
                  value: '${ex.restSeconds}s',
                  icon: Icons.timer_outlined,
                  accentColor: const Color(0xFFF59E0B),
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: _glassParamPill(
                  label: 'RIR',
                  value: '${ex.rir}',
                  icon: Icons.speed_rounded,
                  accentColor: const Color(0xFF8B5CF6),
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: _glassParamPill(
                  label: 'Tempo',
                  value: ex.tempo,
                  icon: Icons.timelapse_rounded,
                  accentColor: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _glassParamPill({
    required String label,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: accentColor),
          SizedBox(height: 4.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousHistoryCard(SingleExerciseState state) {
    final prev = state.previousLog!;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.newPrimaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: AppColors.newPrimaryColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.history_rounded,
                      color: AppColors.newPrimaryColor, size: 18.sp),
                  SizedBox(width: 6.w),
                  Text(
                    'أداء الجلسة السابقة (المرجع)',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              Text(
                _effortEmoji(prev.effortRating),
                style: TextStyle(fontSize: 15.sp),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // عرض المجموعات السابقة
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: prev.sets.map((s) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border:
                      Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                ),
                child: Text(
                  'م ${s.setNumber}: ${s.weight} ${s.weightUnit} × ${s.reps}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 12.h),

          // زر النسخ الفوري بلمسة واحدة (1-Tap Copy Previous Performance)
          Builder(
            builder: (ctx) {
              return InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ctx.read<SingleExerciseCubit>().copyPreviousPerformance();
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'تم نسخ أداء الجلسة السابقة إلى مجموعات اليوم! 📋'),
                      backgroundColor: AppColors.newPrimaryColor,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.newPrimaryColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.copy_rounded,
                          color: Colors.white, size: 15.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'نسخ الأداء السابق بلمسة واحدة 📋',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _effortEmoji(String rating) {
    switch (rating) {
      case 'easy':
        return '😊 سهل';
      case 'moderate':
        return '💪 متوسط';
      case 'hard':
        return '🔥 صعب';
      case 'max_effort':
        return '⚡ أقصى مجهود';
      default:
        return '💪';
    }
  }

  Widget _buildSetsTable(BuildContext context, SingleExerciseState state) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المجموعات الحالية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              TextButton.icon(
                onPressed: () => context.read<SingleExerciseCubit>().addSet(),
                icon: Icon(Icons.add_circle_outline_rounded,
                    color: const Color(0xFF10B981), size: 18.sp),
                label: Text(
                  'أضف مجموعة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.sets.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (context, i) {
              final s = state.sets[i];
              return _SetInputRow(
                index: i,
                setLog: s,
                unit: state.unit,
                canDelete: state.sets.length > 1,
                onWeightChanged: (w) =>
                    context.read<SingleExerciseCubit>().updateSet(i, weight: w),
                onRepsChanged: (r) =>
                    context.read<SingleExerciseCubit>().updateSet(i, reps: r),
                onDelete: () =>
                    context.read<SingleExerciseCubit>().removeSet(i),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEffortSelector(BuildContext context, SingleExerciseState state) {
    final options = [
      {'key': 'easy', 'label': 'سهل', 'emoji': '😊'},
      {'key': 'moderate', 'label': 'متوسط', 'emoji': '💪'},
      {'key': 'hard', 'label': 'صعب', 'emoji': '🔥'},
      {'key': 'max_effort', 'label': 'أقصى', 'emoji': '⚡'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كان إحساسك إيه في التمرين؟',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: options.map((opt) {
            final isSel = state.effortRating == opt['key'];
            return Expanded(
              child: GestureDetector(
                onTap: () => context
                    .read<SingleExerciseCubit>()
                    .setEffortRating(opt['key']!),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSel
                        ? AppColors.newPrimaryColor.withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isSel
                          ? AppColors.newPrimaryColor
                          : Colors.grey.withValues(alpha: 0.2),
                      width: isSel ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(opt['emoji']!, style: TextStyle(fontSize: 16.sp)),
                      SizedBox(height: 2.h),
                      Text(
                        opt['label']!,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.sp,
                          fontWeight:
                              isSel ? FontWeight.bold : FontWeight.normal,
                          color: isSel
                              ? AppColors.newPrimaryColor
                              : Colors.grey[700],
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

class _SetInputRow extends StatelessWidget {
  final int index;
  final ExerciseSetLogModel setLog;
  final String unit;
  final bool canDelete;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<int> onRepsChanged;
  final VoidCallback onDelete;

  const _SetInputRow({
    required this.index,
    required this.setLog,
    required this.unit,
    required this.canDelete,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Container(
            width: 26.w,
            height: 26.w,
            decoration: const BoxDecoration(
              color: AppColors.newPrimaryColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // Weight Stepper
          Expanded(
            flex: 5,
            child: _stepperBox(
              label: 'الوزن ($unit)',
              value: '${setLog.weight}',
              onMinus: () {
                HapticFeedback.selectionClick();
                onWeightChanged((setLog.weight - 2.5).clamp(0.0, 500.0));
              },
              onPlus: () {
                HapticFeedback.selectionClick();
                onWeightChanged(setLog.weight + 2.5);
              },
              quickAdd: () {
                HapticFeedback.lightImpact();
                onWeightChanged(setLog.weight + 5.0);
              },
            ),
          ),

          SizedBox(width: 8.w),

          // Reps Stepper
          Expanded(
            flex: 4,
            child: _stepperBox(
              label: 'التكرار',
              value: '${setLog.reps}',
              onMinus: () {
                HapticFeedback.selectionClick();
                onRepsChanged((setLog.reps - 1).clamp(0, 100));
              },
              onPlus: () {
                HapticFeedback.selectionClick();
                onRepsChanged(setLog.reps + 1);
              },
            ),
          ),

          if (canDelete) ...[
            SizedBox(width: 4.w),
            IconButton(
              icon: Icon(Icons.remove_circle_outline_rounded,
                  color: Colors.red[300], size: 20.sp),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                HapticFeedback.lightImpact();
                onDelete();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _stepperBox({
    required String label,
    required String value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
    VoidCallback? quickAdd,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onMinus,
                borderRadius: BorderRadius.circular(6.r),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Icon(Icons.remove_rounded,
                      size: 16.sp, color: AppColors.newPrimaryColor),
                ),
              ),
              Column(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 8.5.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onPlus,
                borderRadius: BorderRadius.circular(6.r),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Icon(Icons.add_rounded,
                      size: 16.sp, color: AppColors.newPrimaryColor),
                ),
              ),
            ],
          ),
          if (quickAdd != null) ...[
            SizedBox(height: 2.h),
            InkWell(
              onTap: quickAdd,
              borderRadius: BorderRadius.circular(4.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '+5 سريع',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExerciseVideoPlayerWidget extends StatefulWidget {
  final String? videoUrl;
  final String tipText;
  final String exerciseName;

  const _ExerciseVideoPlayerWidget({
    required this.videoUrl,
    required this.tipText,
    required this.exerciseName,
  });

  @override
  State<_ExerciseVideoPlayerWidget> createState() =>
      _ExerciseVideoPlayerWidgetState();
}

class _ExerciseVideoPlayerWidgetState
    extends State<_ExerciseVideoPlayerWidget> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant _ExerciseVideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _youtubeController?.dispose();
      _youtubeController = null;
      _initController();
    }
  }

  void _initController() {
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl!);
      if (videoId != null && videoId.isNotEmpty) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            disableDragSeek: false,
            loop: false,
            enableCaption: false,
            forceHD: true,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_youtubeController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            YoutubePlayer(
              controller: _youtubeController!,
              showVideoProgressIndicator: true,
              progressColors: const ProgressBarColors(
                playedColor: AppColors.newPrimaryColor,
                handleColor: AppColors.newPrimaryColor,
              ),
            ),
            // Floating Amber Technical Cue Overlay on top of player
            Positioned(
              top: 10.h,
              right: 10.w,
              child: _buildAmberCue(widget.tipText),
            ),
          ],
        ),
      );
    }

    // Smart Fallback when no coach video is provided (no fake play button)
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAmberCue(widget.tipText),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified_rounded,
                        color: const Color(0xFF10B981), size: 12.sp),
                    SizedBox(width: 4.w),
                    Text('تكنيك معتمد',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10.sp,
                            color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Center(
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                border: Border.all(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.25)),
              ),
              child: Icon(Icons.fitness_center_rounded,
                  color: const Color(0xFF38BDF8), size: 32.sp),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            widget.exerciseName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'اتبع التوجيهات الفنية والـ Tempo والـ RIR المحددة من الكابتن بالأسفل',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Cairo', fontSize: 11.sp, color: Colors.white60),
          ),
          SizedBox(height: 14.h),
          // زر البحث الذكي الفوري في يوتيوب
          InkWell(
            onTap: () async {
              HapticFeedback.lightImpact();
              final query = '${widget.exerciseName} form tutorial';
              final uri = Uri.parse(
                  'https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_rounded,
                      color: Colors.red[300], size: 16.sp),
                  SizedBox(width: 6.w),
                  Text(
                    'مشاهدة شروحات إضافية للتمرين على YouTube 🔍',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmberCue(String tipText) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFD97706),
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, color: Colors.white, size: 14.sp),
          SizedBox(width: 4.w),
          Text(
            tipText,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
