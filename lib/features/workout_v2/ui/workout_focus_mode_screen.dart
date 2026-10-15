import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import '../logic/focus_mode_cubit.dart';
import '../models/exercise_model.dart';
import '../models/exercise_set_log_model.dart';
import '../models/workout_model.dart';
import '../repos/workout_repository_v2.dart';
import '../widgets/universal_inline_video_player.dart';

/// ═══════════════════════════════════════════════════════════════════════════════
/// WORKOUT FOCUS MODE SCREEN — DARK ATHLETIC PRO COCKPIT (وضع التركيز الرياضي الاحترافي)
/// مصمم وفق أعلى معايير تطبيقات كمال الأجسام العالمية (Hevy, Strong, Apple Fitness+)
/// ═══════════════════════════════════════════════════════════════════════════════
class WorkoutFocusModeScreen extends StatelessWidget {
  final WorkoutModel workout;
  final bool initialGuidedMode;
  final int? initialScrollToIndex;

  const WorkoutFocusModeScreen({
    super.key,
    required this.workout,
    this.initialGuidedMode = true,
    this.initialScrollToIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = FocusModeCubit(
          getIt<WorkoutRepositoryV2>(),
          workout,
          initialGuidedMode: initialGuidedMode,
        );
        _initTrainee(cubit);
        return cubit;
      },
      child: _WorkoutFocusModeContent(
        initialScrollToIndex: initialScrollToIndex,
      ),
    );
  }

  void _initTrainee(FocusModeCubit cubit) async {
    final userId = await SharedPreferencesHelper.getString(AppConstants.userId);
    cubit.initSession(userId ?? 'test_trainee');
  }
}

class _WorkoutFocusModeContent extends StatefulWidget {
  final int? initialScrollToIndex;
  const _WorkoutFocusModeContent({this.initialScrollToIndex});

  @override
  State<_WorkoutFocusModeContent> createState() =>
      _WorkoutFocusModeContentState();
}

class _WorkoutFocusModeContentState extends State<_WorkoutFocusModeContent> {
  late final ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    if (widget.initialScrollToIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          final targetOffset = (widget.initialScrollToIndex! * 420.0).clamp(
            0.0,
            _scrollCtrl.position.maxScrollExtent,
          );
          _scrollCtrl.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FocusModeCubit, FocusModeState>(
      listener: (context, state) {
        if (state.isFinished) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              content: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.white),
                  SizedBox(width: 8.w),
                  const Expanded(
                    child: Text(
                      'عاش يا بطل! أداء أسطوري اليوم وتم حفظ الجلسة بنجاح 💪',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
          Navigator.pop(context);
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              content: Text(
                state.errorMessage!,
                style: const TextStyle(fontFamily: 'Cairo', color: Colors.white),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Stack(
              children: [
                // Main Content Column
                Column(
                  children: [
                    // 1. Sticky Top HUD: Stopwatch + Sets Progress + Dedicated Focus Mode Trigger + Finish Button
                    _StickyHeaderHUD(
                      elapsedTime: state.formattedElapsedTime,
                      totalVolumeLifted: state.totalVolumeLifted,
                      completedSets: state.completedSetsCount,
                      totalSets: state.totalSetsCount,
                      overallProgress: state.overallProgress,
                      onOpenFocusMode: () => _openFocusMode(context),
                      onFinish: () => _showCelebrationModal(context, state),
                      onExit: () => _confirmExitSession(context),
                      isSaving: state.isSaving,
                    ),

                    // 2. Sequential Scrollable Exercises List (Always Guided View with Videos & Technique)
                    Expanded(
                      child: state.items.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFE86231),
                              ),
                            )
                          : ListView.separated(
                              controller: _scrollCtrl,
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                14.w,
                                14.h,
                                14.w,
                                (state.isRestTimerActive ||
                                        state.isRestCompletedAlert)
                                    ? 140.h
                                    : 30.h,
                              ),
                              itemCount: state.items.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 16.h),
                              itemBuilder: (context, exIndex) {
                                final item = state.items[exIndex];
                                return _GuidedExerciseCard(
                                  exerciseIndex: exIndex,
                                  item: item,
                                );
                              },
                            ),
                    ),
                  ],
                ),

                // 3. Floating Rest Timer Dock (Overlay at Bottom)
                if (state.isRestTimerActive)
                  Positioned(
                    left: 12.w,
                    right: 12.w,
                    bottom: 12.h,
                    child: _FloatingRestTimerBar(
                      remainingSeconds: state.restSecondsRemaining,
                      totalSeconds: state.restTotalSeconds,
                      exerciseName: state.activeExerciseName ?? 'التمرين الحالي',
                      progress: state.restProgress,
                      isLongRest: state.isLongRest,
                      nextTargetName: state.nextExerciseOrSetName,
                      onAdd15: () =>
                          context.read<FocusModeCubit>().adjustRestTime(15),
                      onAdd30: () =>
                          context.read<FocusModeCubit>().adjustRestTime(30),
                      onMinus15: () =>
                          context.read<FocusModeCubit>().adjustRestTime(-15),
                      onSkip: () =>
                          context.read<FocusModeCubit>().skipRestTimer(),
                    ),
                  ),

                // 4. Rest Completed Alarm & Celebration Banner (When Timer Hits 0)
                if (state.isRestCompletedAlert)
                  Positioned(
                    left: 12.w,
                    right: 12.w,
                    bottom: 12.h,
                    child: _RestCompletedBanner(
                      isLongRest: state.isLongRest,
                      targetName: state.nextExerciseOrSetName,
                      onStart: () {
                        HapticFeedback.heavyImpact();
                        context.read<FocusModeCubit>().dismissRestAlert();
                      },
                      onDismiss: () {
                        context.read<FocusModeCubit>().dismissRestAlert();
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openFocusMode(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<FocusModeCubit>(),
          child: const WorkoutFocusCockpitScreen(),
        ),
      ),
    );
  }

  void _confirmExitSession(BuildContext context) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161F30),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFF59E0B), size: 24),
            SizedBox(width: 8.w),
            const Text(
              'مغادرة التمرين؟',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: const Text(
          'هل تريد الخروج من وضع التركيز؟ لن يتم حفظ التغييرات غير المسجلة.',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: Color(0xFF94A3B8),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('البقاء بالتمرين',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
              elevation: 0,
            ),
            child: const Text('مغادرة',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

void _showCelebrationModal(BuildContext context, FocusModeState state) {
  HapticFeedback.heavyImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _WorkoutCelebrationModal(
      elapsedTime: state.formattedElapsedTime,
      totalVolume: state.totalVolumeLifted,
      completedSets: state.completedSetsCount,
      totalSets: state.totalSetsCount,
      completedExercises: state.completedExercisesCount,
      totalExercises: state.items.length,
      isSaving: state.isSaving,
      onConfirmFinish: () async {
        Navigator.pop(ctx);
        final userId =
            await SharedPreferencesHelper.getString(AppConstants.userId);
        if (context.mounted) {
          context
              .read<FocusModeCubit>()
              .finishSession(userId ?? 'test_trainee');
        }
      },
    ),
  );
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// 1. STICKY TOP HUD HEADER (قمرة القيادة العلوية للتركيز)
/// ═══════════════════════════════════════════════════════════════════════════════
class _StickyHeaderHUD extends StatelessWidget {
  final String elapsedTime;
  final double totalVolumeLifted;
  final int completedSets;
  final int totalSets;
  final double overallProgress;
  final VoidCallback onOpenFocusMode;
  final VoidCallback onFinish;
  final VoidCallback onExit;
  final bool isSaving;

  const _StickyHeaderHUD({
    required this.elapsedTime,
    required this.totalVolumeLifted,
    required this.completedSets,
    required this.totalSets,
    required this.overallProgress,
    required this.onOpenFocusMode,
    required this.onFinish,
    required this.onExit,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Glowing Linear Workout Progress Line
          LinearProgressIndicator(
            value: overallProgress,
            backgroundColor: Colors.grey.withValues(alpha: 0.12),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFFE86231),
            ),
            minHeight: 3.5.h,
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 8.h),
            child: Row(
              children: [
                // Exit / Back Icon Button
                InkWell(
                  onTap: onExit,
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.all(7.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: const Color(0xFF475569),
                      size: 18.sp,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // Digital Stopwatch HUD
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7.w,
                        height: 7.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        elapsedTime,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),

                // Sets counter pill
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    '$completedSets/$totalSets مجموعة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),

                const Spacer(),

                // Dedicated Focus Mode Button ⚡ (Opens Focus Mode in its own separate screen!)
                InkWell(
                  onTap: onOpenFocusMode,
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded,
                            color: const Color(0xFF10B981), size: 15.sp),
                        SizedBox(width: 4.w),
                        Text(
                          'وضع التركيز ⚡',
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
                SizedBox(width: 6.w),

                // Finish Workout CTA Button
                ElevatedButton(
                  onPressed: isSaving ? null : onFinish,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    elevation: 1,
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'إنهاء',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// 1B. DEDICATED FOCUS COCKPIT SCREEN (شاشة وضع التركيز السريع المستقلة تماماً)
/// شاشة مظلمة منفصلة مصممة خصيصاً للتسجيل السريع والأداء المركز بدون فيديوهات
/// ═══════════════════════════════════════════════════════════════════════════════
class WorkoutFocusCockpitScreen extends StatelessWidget {
  const WorkoutFocusCockpitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FocusModeCubit, FocusModeState>(
      listener: (context, state) {
        if (state.isFinished) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF0B101B),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // Top Cockpit Bar
                    _CockpitHeaderHUD(
                      elapsedTime: state.formattedElapsedTime,
                      completedSets: state.completedSetsCount,
                      totalSets: state.totalSetsCount,
                      overallProgress: state.overallProgress,
                      onBackToGuided: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      onFinish: () => _showCelebrationModal(context, state),
                      isSaving: state.isSaving,
                    ),

                    // Sequential Dark Focus Exercise List
                    Expanded(
                      child: state.items.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF10B981),
                              ),
                            )
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                14.w,
                                14.h,
                                14.w,
                                (state.isRestTimerActive ||
                                        state.isRestCompletedAlert)
                                    ? 140.h
                                    : 30.h,
                              ),
                              itemCount: state.items.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 14.h),
                              itemBuilder: (context, exIndex) {
                                final item = state.items[exIndex];
                                return _FocusExerciseCard(
                                  exerciseIndex: exIndex,
                                  item: item,
                                );
                              },
                            ),
                    ),
                  ],
                ),

                // Floating Rest Timer Dock
                if (state.isRestTimerActive)
                  Positioned(
                    left: 12.w,
                    right: 12.w,
                    bottom: 12.h,
                    child: _FloatingRestTimerBar(
                      remainingSeconds: state.restSecondsRemaining,
                      totalSeconds: state.restTotalSeconds,
                      exerciseName: state.activeExerciseName ?? 'التمرين الحالي',
                      progress: state.restProgress,
                      isLongRest: state.isLongRest,
                      nextTargetName: state.nextExerciseOrSetName,
                      onAdd15: () =>
                          context.read<FocusModeCubit>().adjustRestTime(15),
                      onAdd30: () =>
                          context.read<FocusModeCubit>().adjustRestTime(30),
                      onMinus15: () =>
                          context.read<FocusModeCubit>().adjustRestTime(-15),
                      onSkip: () =>
                          context.read<FocusModeCubit>().skipRestTimer(),
                    ),
                  ),

                // Rest Completed Alarm Banner
                if (state.isRestCompletedAlert)
                  Positioned(
                    left: 12.w,
                    right: 12.w,
                    bottom: 12.h,
                    child: _RestCompletedBanner(
                      isLongRest: state.isLongRest,
                      targetName: state.nextExerciseOrSetName,
                      onStart: () {
                        HapticFeedback.heavyImpact();
                        context.read<FocusModeCubit>().dismissRestAlert();
                      },
                      onDismiss: () {
                        context.read<FocusModeCubit>().dismissRestAlert();
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CockpitHeaderHUD extends StatelessWidget {
  final String elapsedTime;
  final int completedSets;
  final int totalSets;
  final double overallProgress;
  final VoidCallback onBackToGuided;
  final VoidCallback onFinish;
  final bool isSaving;

  const _CockpitHeaderHUD({
    required this.elapsedTime,
    required this.completedSets,
    required this.totalSets,
    required this.overallProgress,
    required this.onBackToGuided,
    required this.onFinish,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121A2B),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF1E2A40), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: overallProgress,
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            minHeight: 3.5.h,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
            child: Row(
              children: [
                // Back to Guided Screen button
                InkWell(
                  onTap: onBackToGuided,
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 12.sp),
                        SizedBox(width: 4.w),
                        Text(
                          'الوضع الشامل 🎬',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // Digital Stopwatch
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2438),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7.w,
                        height: 7.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        elapsedTime,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),

                // Sets pill
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    '$completedSets/$totalSets مجموعة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),

                const Spacer(),

                // Finish Workout CTA Button
                ElevatedButton(
                  onPressed: isSaving ? null : onFinish,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    elevation: 2,
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'إنهاء',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
}


/// ═══════════════════════════════════════════════════════════════════════════════
/// GUIDED ALL-IN-ONE EXERCISE CARD (بطاقة التمرين في الوضع الشامل التفاعلي)
/// شاشة واحدة بسكرول كامل: تفاصيل التمرين، فيديو التكنيك، وتسجيل المجموعات مباشرة
/// مع تمييز بصري احتفالي مذهل عند إتمام كافة مجموعات التمرين بنجاح
/// ═══════════════════════════════════════════════════════════════════════════════
class _GuidedExerciseCard extends StatelessWidget {
  final int exerciseIndex;
  final FocusExerciseItem item;

  const _GuidedExerciseCard({
    required this.exerciseIndex,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final ex = item.exercise;
    final completedCount = item.sets.where((s) => s.isCompleted).length;
    final isAllCompleted =
        item.sets.isNotEmpty && completedCount == item.sets.length;
    final hasVideo =
        ex.videoGuideUrl != null && ex.videoGuideUrl!.trim().isNotEmpty;
    final hasTip =
        ex.technicalTip != null && ex.technicalTip!.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isAllCompleted
              ? const Color(0xFF10B981)
              : const Color(0xFFE2E8F0),
          width: isAllCompleted ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isAllCompleted
                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. التمييز البصري الفخم: شريط الاحتفال والإنجاز يظهر أعلى التمرين المكتمل فقط
          if (isAllCompleted)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded,
                        color: const Color(0xFF10B981), size: 14.sp),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'أحسنت يا بطل! تم إكمال جميع مجموعات هذا التمرين 💪',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'مكتمل 100% ✓',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 2. ترويسة التمرين وتفاصيله (الاسم، العضلات، والأهداف)
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // رقم التمرين
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: isAllCompleted
                            ? const Color(0xFF10B981).withValues(alpha: 0.15)
                            : AppColors.newPrimaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isAllCompleted
                              ? const Color(0xFF10B981).withValues(alpha: 0.4)
                              : AppColors.newPrimaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${exerciseIndex + 1}',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isAllCompleted
                              ? const Color(0xFF10B981)
                              : AppColors.newPrimaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),

                    // اسم التمرين
                    Expanded(
                      child: Text(
                        ex.name,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // شارة حالة الإنجاز (قيد التدريب vs مكتمل)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isAllCompleted
                            ? const Color(0xFF10B981).withValues(alpha: 0.12)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isAllCompleted
                              ? const Color(0xFF10B981).withValues(alpha: 0.4)
                              : const Color(0xFFBFDBFE),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAllCompleted
                                ? Icons.verified_rounded
                                : Icons.fitness_center_rounded,
                            size: 13.sp,
                            color: isAllCompleted
                                ? const Color(0xFF10B981)
                                : const Color(0xFF2563EB),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            isAllCompleted
                                ? 'مكتمل 🏆'
                                : '$completedCount / ${item.sets.length}',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: isAllCompleted
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // شريط أهداف التكرار والراحة والـ RIR
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: [
                    _lightChip(
                      icon: Icons.track_changes_rounded,
                      label: 'هدف: ${ex.targetRepsRange} تكرار',
                      color: const Color(0xFF0284C7),
                      bgColor: const Color(0xFFE0F2FE),
                    ),
                    _lightChip(
                      icon: Icons.timer_outlined,
                      label: 'راحة: ${ex.restSeconds}ث',
                      color: const Color(0xFF059669),
                      bgColor: const Color(0xFFD1FAE5),
                    ),
                    _lightChip(
                      icon: Icons.bolt_rounded,
                      label: 'RIR ${ex.rir}',
                      color: const Color(0xFFD97706),
                      bgColor: const Color(0xFFFEF3C7),
                    ),
                    if (ex.tempo.isNotEmpty)
                      _lightChip(
                        icon: Icons.speed_rounded,
                        label: 'سرعة: ${ex.tempo}',
                        color: const Color(0xFF7C3AED),
                        bgColor: const Color(0xFFEDE9FE),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // 3. توجيه الكابتن وتكنيك الأداء (إن وُجد)
          if (hasTip)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_rounded,
                      color: const Color(0xFFD97706), size: 18.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'توجيه الكابتن وتكنيك الأداء 💡',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFB45309),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          ex.technicalTip!,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            color: const Color(0xFF78350F),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // 4. مشغل الفيديو الذكي المباشر في مكانه أسفل التمرين
          if (hasVideo)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              child: UniversalInlineVideoPlayer(
                videoUrl: ex.videoGuideUrl!,
                exerciseName: ex.name,
                exerciseIndex: exerciseIndex,
                isLightMode: true,
                isCurrentlyActive: context
                        .watch<FocusModeCubit>()
                        .state
                        .currentlyPlayingExerciseIndex ==
                    exerciseIndex,
                onPlayStarted: () {
                  context
                      .read<FocusModeCubit>()
                      .setPlayingExerciseVideo(exerciseIndex);
                },
              ),
            ),

          // 5. ترويسة قسم المجموعات التدريبية
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تسجيل المجموعات والأوزان',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF334155),
                  ),
                ),
                Text(
                  '${item.sets.length} مجموعات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // 6. قائمة المجموعات بالأزرار الكبيرة 36x36 dp والأرقام الواضحة
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            itemCount: item.sets.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, setIndex) {
              final setLog = item.sets[setIndex];
              ExerciseSetLogModel? prevSet;
              if (item.previousLog != null &&
                  setIndex < item.previousLog!.sets.length) {
                prevSet = item.previousLog!.sets[setIndex];
              }

              return _FocusSetRow(
                setLog: setLog,
                prevSet: prevSet,
                canDelete: item.sets.length > 1,
                isLightMode: true,
                onDeleteSet: () {
                  HapticFeedback.lightImpact();
                  context
                      .read<FocusModeCubit>()
                      .removeSetFromExercise(exerciseIndex, setIndex);
                },
                onToggleComplete: (val) {
                  context.read<FocusModeCubit>().toggleSetComplete(
                        exerciseIndex,
                        setIndex,
                        val,
                      );
                },
                onWeightChanged: (w) {
                  context.read<FocusModeCubit>().updateSetValues(
                        exerciseIndex,
                        setIndex,
                        weight: w,
                      );
                },
                onRepsChanged: (r) {
                  context.read<FocusModeCubit>().updateSetValues(
                        exerciseIndex,
                        setIndex,
                        reps: r,
                      );
                },
              );
            },
          ),

          // 7. زر إضافة مجموعة جديدة
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 14.h),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context
                    .read<FocusModeCubit>()
                    .addSetToExercise(exerciseIndex);
              },
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 9.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        size: 15.sp, color: AppColors.newPrimaryColor),
                    SizedBox(width: 6.w),
                    Text(
                      'إضافة مجموعة جديدة +',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.newPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 8. اختيار تقييم المجهود في هذا التمرين
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 14.h),
            child: _ExerciseEffortSelector(
              exerciseIndex: exerciseIndex,
              currentRating: item.effortRating,
              isLightMode: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lightChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// EXERCISE EFFORT SELECTOR (منتقي تقييم المجهود والإحساس لكل تمرين على حدة)
/// ═══════════════════════════════════════════════════════════════════════════════
class _ExerciseEffortSelector extends StatelessWidget {
  final int exerciseIndex;
  final String currentRating;
  final bool isLightMode;

  const _ExerciseEffortSelector({
    required this.exerciseIndex,
    required this.currentRating,
    this.isLightMode = true,
  });

  static const _options = [
    {
      'key': 'easy',
      'label': 'سهل',
      'emoji': '😊',
      'color': Color(0xFF10B981),
    },
    {
      'key': 'moderate',
      'label': 'متوسط',
      'emoji': '💪',
      'color': Color(0xFF3B82F6),
    },
    {
      'key': 'hard',
      'label': 'صعب',
      'emoji': '🔥',
      'color': Color(0xFFF59E0B),
    },
    {
      'key': 'max_effort',
      'label': 'أقصى',
      'emoji': '⚡',
      'color': Color(0xFFEF4444),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isLightMode
            ? const Color(0xFFF8FAFC)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isLightMode
              ? const Color(0xFFE2E8F0)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.speed_rounded,
                size: 15.sp,
                color: isLightMode
                    ? const Color(0xFF475569)
                    : const Color(0xFF94A3B8),
              ),
              SizedBox(width: 6.w),
              Text(
                'تقييم المجهود في هذا التمرين:',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.bold,
                  color: isLightMode
                      ? const Color(0xFF1E293B)
                      : Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: _options.map((opt) {
              final isSel = currentRating == opt['key'];
              final color = opt['color'] as Color;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context
                        .read<FocusModeCubit>()
                        .updateExerciseEffort(exerciseIndex, opt['key'] as String);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    padding: EdgeInsets.symmetric(vertical: 7.h),
                    decoration: BoxDecoration(
                      color: isSel
                          ? color.withValues(alpha: isLightMode ? 0.15 : 0.22)
                          : (isLightMode
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.04)),
                      borderRadius: BorderRadius.circular(9.r),
                      border: Border.all(
                        color: isSel
                            ? color
                            : (isLightMode
                                ? const Color(0xFFCBD5E1)
                                : Colors.white.withValues(alpha: 0.12)),
                        width: isSel ? 1.6 : 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          opt['emoji'] as String,
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          opt['label'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10.5.sp,
                            fontWeight:
                                isSel ? FontWeight.bold : FontWeight.w600,
                            color: isSel
                                ? color
                                : (isLightMode
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF94A3B8)),
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
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// 2. EXERCISE CARD (بطاقة التمرين التفاعلية المظلمة - لوضع التركيز)
/// ═══════════════════════════════════════════════════════════════════════════════
class _FocusExerciseCard extends StatelessWidget {
  final int exerciseIndex;
  final FocusExerciseItem item;

  const _FocusExerciseCard({
    required this.exerciseIndex,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final ex = item.exercise;
    final completedCount = item.sets.where((s) => s.isCompleted).length;
    final isAllCompleted =
        item.sets.isNotEmpty && completedCount == item.sets.length;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131B2A),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isAllCompleted
              ? const Color(0xFF10B981).withValues(alpha: 0.4)
              : const Color(0xFF1F293D),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Exercise Header
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Exercise Index Badge
                    Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color:
                              const Color(0xFF38BDF8).withValues(alpha: 0.3),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${exerciseIndex + 1}',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),

                    // Exercise Name
                    Expanded(
                      child: Text(
                        ex.name,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Progress Status Pill
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isAllCompleted
                            ? const Color(0xFF10B981).withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isAllCompleted
                              ? const Color(0xFF10B981).withValues(alpha: 0.35)
                              : Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isAllCompleted) ...[
                            Icon(Icons.check_circle_rounded,
                                size: 12.sp, color: const Color(0xFF10B981)),
                            SizedBox(width: 4.w),
                          ],
                          Text(
                            isAllCompleted
                                ? 'مكتمل 🏆'
                                : '$completedCount / ${item.sets.length}',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: isAllCompleted
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Coach Targets Strip + Technique Sheet Trigger
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: [
                          _darkChip(
                            icon: Icons.track_changes_rounded,
                            label: 'هدف: ${ex.targetRepsRange} تكرار',
                            color: const Color(0xFF38BDF8),
                          ),
                          _darkChip(
                            icon: Icons.timer_outlined,
                            label: 'راحة: ${ex.restSeconds}ث',
                            color: const Color(0xFF10B981),
                          ),
                          _darkChip(
                            icon: Icons.bolt_rounded,
                            label: 'RIR ${ex.rir}',
                            color: const Color(0xFFF59E0B),
                          ),
                          _darkChip(
                            icon: Icons.speed_rounded,
                            label: 'Tempo: ${ex.tempo}',
                            color: const Color(0xFFA855F7),
                          ),
                        ],
                      ),
                    ),
                    if (ex.videoGuideUrl != null || ex.technicalTip != null) ...[
                      SizedBox(width: 6.w),
                      InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showExerciseGuide(context, ex);
                        },
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFF59E0B).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.ondemand_video_rounded,
                                  size: 13.sp,
                                  color: const Color(0xFFF59E0B)),
                              SizedBox(width: 4.w),
                              Text(
                                'التكنيك',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Coach Technical Tip (if present)
                if (ex.technicalTip != null && ex.technicalTip!.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_rounded,
                            size: 13.sp, color: const Color(0xFFF59E0B)),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            ex.technicalTip!,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10.5.sp,
                              color: const Color(0xFFFDE68A),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Video Guide Inline Player for Dark Focus Card
          if (ex.videoGuideUrl != null && ex.videoGuideUrl!.trim().isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              child: UniversalInlineVideoPlayer(
                videoUrl: ex.videoGuideUrl!,
                exerciseName: ex.name,
                exerciseIndex: exerciseIndex,
                isLightMode: false,
                isCurrentlyActive: context
                        .watch<FocusModeCubit>()
                        .state
                        .currentlyPlayingExerciseIndex ==
                    exerciseIndex,
                onPlayStarted: () {
                  context
                      .read<FocusModeCubit>()
                      .setPlayingExerciseVideo(exerciseIndex);
                },
              ),
            ),

          // Sets Section Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المجموعات التدريبية',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  '${item.sets.length} مجموعات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Sets List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            itemCount: item.sets.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, setIndex) {
              final setLog = item.sets[setIndex];
              ExerciseSetLogModel? prevSet;
              if (item.previousLog != null &&
                  setIndex < item.previousLog!.sets.length) {
                prevSet = item.previousLog!.sets[setIndex];
              }

              return _FocusSetRow(
                setLog: setLog,
                prevSet: prevSet,
                canDelete: item.sets.length > 1,
                onDeleteSet: () {
                  HapticFeedback.lightImpact();
                  context
                      .read<FocusModeCubit>()
                      .removeSetFromExercise(exerciseIndex, setIndex);
                },
                onToggleComplete: (val) {
                  context.read<FocusModeCubit>().toggleSetComplete(
                        exerciseIndex,
                        setIndex,
                        val,
                      );
                },
                onWeightChanged: (w) {
                  context.read<FocusModeCubit>().updateSetValues(
                        exerciseIndex,
                        setIndex,
                        weight: w,
                      );
                },
                onRepsChanged: (r) {
                  context.read<FocusModeCubit>().updateSetValues(
                        exerciseIndex,
                        setIndex,
                        reps: r,
                      );
                },
              );
            },
          ),

          // Add Set Button
          Padding(
            padding: EdgeInsets.fromLTRB(10.w, 4.h, 10.w, 10.h),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context
                    .read<FocusModeCubit>()
                    .addSetToExercise(exerciseIndex);
              },
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    style: BorderStyle.solid,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        size: 14.sp, color: const Color(0xFF38BDF8)),
                    SizedBox(width: 6.w),
                    Text(
                      'إضافة مجموعة جديدة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF38BDF8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Exercise Effort Selector
          Padding(
            padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 14.h),
            child: _ExerciseEffortSelector(
              exerciseIndex: exerciseIndex,
              currentRating: item.effortRating,
              isLightMode: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _darkChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.5.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showExerciseGuide(BuildContext context, ExerciseModel ex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExerciseGuideSheet(exercise: ex),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// 3. INTERACTIVE SET ROW (صف المجموعة الاحترافي مع الإدخال السريع)
/// ═══════════════════════════════════════════════════════════════════════════════
class _FocusSetRow extends StatelessWidget {
  final ExerciseSetLogModel setLog;
  final ExerciseSetLogModel? prevSet;
  final bool canDelete;
  final bool isLightMode;
  final VoidCallback onDeleteSet;
  final ValueChanged<bool> onToggleComplete;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<int> onRepsChanged;

  const _FocusSetRow({
    required this.setLog,
    required this.prevSet,
    required this.canDelete,
    this.isLightMode = false,
    required this.onDeleteSet,
    required this.onToggleComplete,
    required this.onWeightChanged,
    required this.onRepsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = setLog.isCompleted;
    final prev = prevSet;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDone
            ? (isLightMode
                ? const Color(0xFFECFDF5)
                : const Color(0xFF10B981).withValues(alpha: 0.12))
            : (isLightMode ? Colors.white : const Color(0xFF161E2E)),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDone
              ? const Color(0xFF10B981)
                  .withValues(alpha: isLightMode ? 0.8 : 0.5)
              : (isLightMode
                  ? const Color(0xFFE2E8F0)
                  : const Color(0xFF243249)),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: isDone
                ? const Color(0xFF10B981)
                    .withValues(alpha: isLightMode ? 0.08 : 0.12)
                : (isLightMode
                    ? Colors.black.withValues(alpha: 0.03)
                    : Colors.black.withValues(alpha: 0.25)),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Header (Set Badge + Previous Performance + Delete if allowed + Completion Check)
          Row(
            children: [
              // Set Number Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isDone
                      ? const Color(0xFF10B981)
                      : (isLightMode
                          ? const Color(0xFFE86231)
                          : const Color(0xFF26354D)),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'المجموعة ${setLog.setNumber}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // Previous Performance + 1-Tap Copy
              Expanded(
                child: prev != null
                    ? InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onWeightChanged(prev.weight);
                          onRepsChanged(prev.reps);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(milliseconds: 800),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: const Color(0xFF1E293B),
                              content: Text(
                                'تم نسخ السابق (${prev.weight} كجم × ${prev.reps}) ✅',
                                style: const TextStyle(
                                    fontFamily: 'Cairo', color: Colors.white),
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(6.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B)
                                .withValues(alpha: isLightMode ? 0.12 : 0.1),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: isLightMode ? 0.4 : 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.history_rounded,
                                  size: 13.sp, color: const Color(0xFFF59E0B)),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: Text(
                                  'السابق: ${prev.weight} × ${prev.reps}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(Icons.copy_rounded,
                                  size: 11.sp, color: const Color(0xFFF59E0B)),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox(width: 8.w),

              // Delete button (if canDelete)
              if (canDelete) ...[
                IconButton(
                  onPressed: onDeleteSet,
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFF94A3B8)),
                  iconSize: 18.sp,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'حذف المجموعة',
                ),
                SizedBox(width: 10.w),
              ],

              // Big Touch-Friendly Completion Toggle
              InkWell(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  onToggleComplete(!isDone);
                },
                borderRadius: BorderRadius.circular(10.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFF10B981)
                        : (isLightMode
                            ? const Color(0xFFF1F5F9)
                            : Colors.white.withValues(alpha: 0.08)),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isDone
                          ? const Color(0xFF10B981)
                          : (isLightMode
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF475569)),
                      width: 1.5,
                    ),
                    boxShadow: isDone
                        ? [
                            BoxShadow(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDone
                            ? Icons.check_circle_rounded
                            : Icons.check_rounded,
                        color: isDone
                            ? Colors.white
                            : (isLightMode
                                ? const Color(0xFF475569)
                                : Colors.white),
                        size: 16.sp,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        isDone ? 'تمت' : 'إكمال',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: isDone
                              ? Colors.white
                              : (isLightMode
                                  ? const Color(0xFF475569)
                                  : Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Row 2: Two Large, Spacious, Ergonomic Controllers Side-by-Side
          Row(
            children: [
              // Weight Controller
              Expanded(
                child: _proController(
                  context: context,
                  title: 'الوزن (كجم)',
                  displayValue: '${setLog.weight}',
                  unit: 'كجم',
                  stepValue: 2.5,
                  isWeight: true,
                  numericDouble: setLog.weight,
                  onMinus: () {
                    HapticFeedback.selectionClick();
                    onWeightChanged((setLog.weight - 2.5).clamp(0.0, 500.0));
                  },
                  onPlus: () {
                    HapticFeedback.selectionClick();
                    onWeightChanged(setLog.weight + 2.5);
                  },
                  onDirectEdit: onWeightChanged,
                ),
              ),
              SizedBox(width: 10.w),

              // Reps Controller
              Expanded(
                child: _proController(
                  context: context,
                  title: 'التكرارات',
                  displayValue: '${setLog.reps}',
                  unit: 'تكرار',
                  stepValue: 1.0,
                  isWeight: false,
                  numericInt: setLog.reps,
                  onMinus: () {
                    HapticFeedback.selectionClick();
                    onRepsChanged((setLog.reps - 1).clamp(0, 150));
                  },
                  onPlus: () {
                    HapticFeedback.selectionClick();
                    onRepsChanged(setLog.reps + 1);
                  },
                  onDirectEdit: (val) => onRepsChanged(val.toInt()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _proController({
    required BuildContext context,
    required String title,
    required String displayValue,
    required String unit,
    required double stepValue,
    required bool isWeight,
    double? numericDouble,
    int? numericInt,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
    required ValueChanged<double> onDirectEdit,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isLightMode
            ? (setLog.isCompleted
                ? const Color(0xFFF0FDF4)
                : const Color(0xFFF8FAFC))
            : const Color(0xFF0F1626),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isLightMode
              ? (setLog.isCompleted
                  ? const Color(0xFFA7F3D0)
                  : const Color(0xFFE2E8F0))
              : const Color(0xFF25344C),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title Label
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w600,
                color: isLightMode
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ),
          SizedBox(height: 4.h),

          // Stepper Row with Big Chunky 36x36 Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Minus Button (Chunky & Tactile)
              InkWell(
                onTap: onMinus,
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: isLightMode
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isLightMode
                          ? const Color(0xFFCBD5E1)
                          : Colors.white.withValues(alpha: 0.12),
                    ),
                    boxShadow: isLightMode
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.remove_rounded,
                    size: 20.sp,
                    color:
                        isLightMode ? const Color(0xFF0F172A) : Colors.white,
                  ),
                ),
              ),

              // Central Value (Spacious, bold, NEVER wraps!)
              Expanded(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showDirectEditSheet(
                      context,
                      title: isWeight ? 'تعديل الوزن (كجم)' : 'تعديل التكرار',
                      initialValue: isWeight
                          ? (numericDouble ?? 0.0)
                          : (numericInt?.toDouble() ?? 0.0),
                      isWeight: isWeight,
                      onConfirm: onDirectEdit,
                    );
                  },
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        displayValue,
                        softWrap: false,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: isLightMode
                              ? (isWeight
                                  ? const Color(0xFFE86231)
                                  : const Color(0xFF0284C7))
                              : const Color(0xFF38BDF8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Plus Button (Chunky & Tactile)
              InkWell(
                onTap: onPlus,
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: isLightMode
                        ? (isWeight
                            ? const Color(0xFFE86231).withValues(alpha: 0.12)
                            : const Color(0xFF0284C7).withValues(alpha: 0.12))
                        : const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isLightMode
                          ? (isWeight
                              ? const Color(0xFFE86231).withValues(alpha: 0.35)
                              : const Color(0xFF0284C7).withValues(alpha: 0.35))
                          : const Color(0xFF38BDF8).withValues(alpha: 0.35),
                    ),
                    boxShadow: isLightMode
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.add_rounded,
                    size: 20.sp,
                    color: isLightMode
                        ? (isWeight
                            ? const Color(0xFFE86231)
                            : const Color(0xFF0284C7))
                        : const Color(0xFF38BDF8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDirectEditSheet(
    BuildContext context, {
    required String title,
    required double initialValue,
    required bool isWeight,
    required ValueChanged<double> onConfirm,
  }) {
    final controller = TextEditingController(
      text: isWeight
          ? (initialValue % 1 == 0
              ? initialValue.toInt().toString()
              : initialValue.toString())
          : initialValue.toInt().toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _QuickValueEditSheet(
        title: title,
        controller: controller,
        isWeight: isWeight,
        onSave: (val) {
          onConfirm(val);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// 4. QUICK VALUE EDIT SHEET (نافذة التعديل السريع المباشر للأوزان والتكرارات)
/// ═══════════════════════════════════════════════════════════════════════════════
class _QuickValueEditSheet extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final bool isWeight;
  final ValueChanged<double> onSave;

  const _QuickValueEditSheet({
    required this.title,
    required this.controller,
    required this.isWeight,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: const Color(0xFF161F30),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: const Border(
            top: BorderSide(color: Color(0xFF2B3A54), width: 1.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Main Input
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: isWeight
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF38BDF8),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF0F172A),
                hintText: isWeight ? '0.0 كجم' : '0 تكرار',
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: 'Cairo',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 2),
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // Quick Increments Bar
            Wrap(
              spacing: 8.w,
              alignment: WrapAlignment.center,
              children: isWeight
                  ? [
                      _chipOption('+1.25', 1.25),
                      _chipOption('+2.5', 2.5),
                      _chipOption('+5', 5.0),
                      _chipOption('+10', 10.0),
                      _chipOption('+20', 20.0),
                    ]
                  : [
                      _chipOption('+1', 1.0),
                      _chipOption('+2', 2.0),
                      _chipOption('+5', 5.0),
                      _chipOption('+10', 10.0),
                    ],
            ),
            SizedBox(height: 18.h),

            // Confirm Button
            ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                final parsed = double.tryParse(controller.text) ?? 0.0;
                onSave(parsed);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size.zero,
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'تأكيد وحفظ',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipOption(String label, double add) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        final current = double.tryParse(controller.text) ?? 0.0;
        final res = current + add;
        controller.text = isWeight
            ? (res % 1 == 0 ? res.toInt().toString() : res.toString())
            : res.toInt().toString();
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// 5. FLOATING REST TIMER DOCK (منصة مؤقت الراحة العائمة الفاخرة)
/// ═══════════════════════════════════════════════════════════════════════════════
class _FloatingRestTimerBar extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final String exerciseName;
  final double progress;
  final bool isLongRest;
  final String? nextTargetName;
  final VoidCallback onAdd15;
  final VoidCallback onAdd30;
  final VoidCallback onMinus15;
  final VoidCallback onSkip;

  const _FloatingRestTimerBar({
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.exerciseName,
    required this.progress,
    this.isLongRest = false,
    this.nextTargetName,
    required this.onAdd15,
    required this.onAdd30,
    required this.onMinus15,
    required this.onSkip,
  });

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131D2E),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isLongRest
              ? const Color(0xFFF59E0B).withValues(alpha: 0.6)
              : const Color(0xFF10B981).withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: isLongRest
                ? const Color(0xFFF59E0B).withValues(alpha: 0.25)
                : const Color(0xFF10B981).withValues(alpha: 0.2),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Linear countdown indicator top cap
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                isLongRest ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
              ),
              minHeight: 3.5.h,
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Tier: Countdown Timer + Exercise Name + Skip Button
                Row(
                  children: [
                    // Glowing Circular Rest Countdown Badge
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isLongRest
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                            : const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isLongRest
                              ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
                              : const Color(0xFF10B981).withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLongRest
                                ? Icons.emoji_events_rounded
                                : Icons.timer_outlined,
                            size: 15.sp,
                            color: isLongRest
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF10B981),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            _formatTime(remainingSeconds),
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: isLongRest
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF10B981),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10.w),

                    // Exercise Title & Status (takes full remaining width comfortably!)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  isLongRest
                                      ? 'راحة بين التمارين ⏱️'
                                      : 'وقت الراحة ⏱️',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (isLongRest) ...[
                                SizedBox(width: 4.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5.w, vertical: 1.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B)
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    'راحة كبرى',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 8.5.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFF59E0B),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            nextTargetName ?? exerciseName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10.sp,
                              color: isLongRest
                                  ? const Color(0xFFFDE68A)
                                  : const Color(0xFF94A3B8),
                              fontWeight: isLongRest
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Skip Button
                    ElevatedButton(
                      onPressed: onSkip,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 7.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'تخطي',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Icon(Icons.fast_forward_rounded, size: 13.sp),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Bottom Tier: Quick Time Adjustments (-15s, +15s, +30s)
                Row(
                  children: [
                    Expanded(
                      child: _btnRestPill(label: '-15 ثانية', onTap: onMinus15),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: _btnRestPill(label: '+15 ثانية', onTap: onAdd15),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: _btnRestPill(label: '+30 ثانية', onTap: onAdd30),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _btnRestPill({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10.5.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// 5B. REST COMPLETED BANNER (تنبيه مرئي وصوتي بانتهاء وقت الراحة)
/// ═══════════════════════════════════════════════════════════════════════════════
class _RestCompletedBanner extends StatelessWidget {
  final bool isLongRest;
  final String? targetName;
  final VoidCallback onStart;
  final VoidCallback onDismiss;

  const _RestCompletedBanner({
    required this.isLongRest,
    required this.targetName,
    required this.onStart,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF13231E),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isLongRest ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isLongRest ? const Color(0xFFF59E0B) : const Color(0xFF10B981))
                .withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Glowing Pulse Alarm Icon
          Container(
            padding: EdgeInsets.all(9.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isLongRest ? const Color(0xFFF59E0B) : const Color(0xFF10B981))
                  .withValues(alpha: 0.2),
              border: Border.all(
                color: isLongRest
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF10B981),
                width: 1.5,
              ),
            ),
            child: Icon(
              isLongRest
                  ? Icons.emoji_events_rounded
                  : Icons.notifications_active_rounded,
              color: isLongRest
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF10B981),
              size: 22.sp,
            ),
          ),
          SizedBox(width: 10.w),

          // Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLongRest
                      ? '🏆 انتهت الراحة الكبيرة!'
                      : '⚡ انتهى وقت الراحة!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  targetName ?? 'حان وقت المجموعة التالية!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    color: isLongRest
                        ? const Color(0xFFFDE68A)
                        : const Color(0xFF34D399),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),

          // Ready Button
          ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: isLongRest
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 4,
            ),
            child: Text(
              'جاهز! 💪',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 4.w),

          // Close Icon
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
            iconSize: 18.sp,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// 6. EXERCISE TECHNIQUE & VIDEO GUIDE SHEET (شيت استعراض التكنيك والفيديو)
/// ═══════════════════════════════════════════════════════════════════════════════
class _ExerciseGuideSheet extends StatefulWidget {
  final ExerciseModel exercise;

  const _ExerciseGuideSheet({required this.exercise});

  @override
  State<_ExerciseGuideSheet> createState() => _ExerciseGuideSheetState();
}

class _ExerciseGuideSheetState extends State<_ExerciseGuideSheet> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    final url = widget.exercise.videoGuideUrl;
    if (url != null && url.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null && videoId.isNotEmpty) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            disableDragSeek: false,
            loop: false,
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
    final ex = widget.exercise;

    return Container(
      constraints: BoxConstraints(maxHeight: 0.85.sh),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: const Border(
          top: BorderSide(color: Color(0xFF26354D), width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ex.name,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Video Player (if available)
                  if (_youtubeController != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: YoutubePlayer(
                        controller: _youtubeController!,
                        showVideoProgressIndicator: true,
                        progressColors: const ProgressBarColors(
                          playedColor: Color(0xFF10B981),
                          handleColor: Color(0xFF10B981),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                  ] else if (ex.videoGuideUrl != null &&
                      ex.videoGuideUrl!.isNotEmpty) ...[
                    ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(ex.videoGuideUrl!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('فتح فيديو التكنيك الخارجي'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        backgroundColor: const Color(0xFF38BDF8),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 14.h),
                  ] else ...[
                    // خيار البحث الذكي الفوري في يوتيوب في حال لم يضع الكابتن رابطاً
                    InkWell(
                      onTap: () async {
                        final query = '${ex.name} form tutorial';
                        final uri = Uri.parse(
                            'https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_rounded,
                                color: Color(0xFFEF4444), size: 18),
                            SizedBox(width: 8.w),
                            Text(
                              'بحث عن فيديو تكنيك التمرين في YouTube 🔍',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                  ],

                  // Coach Technical Tip Box
                  if (ex.technicalTip != null && ex.technicalTip!.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.tips_and_updates_rounded,
                                  color: const Color(0xFFF59E0B), size: 18.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'نصيحة الكوتش للتكنيك',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            ex.technicalTip!,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                  ],

                  // Coach Target Specs Grid
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFF233148)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مواصفات التمرين المستهدفة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _specPill('التكرار المستهدف', ex.targetRepsRange),
                            _specPill('الراحة الموصى بها', '${ex.restSeconds}ث'),
                            _specPill('جهد RIR', '${ex.rir}'),
                            _specPill('سرعة Tempo', ex.tempo),
                          ],
                        ),
                      ],
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

  Widget _specPill(String title, String val) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10.sp,
            color: const Color(0xFF94A3B8),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          val,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.5.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF38BDF8),
          ),
        ),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════════
/// 7. WORKOUT CELEBRATION MODAL (شيت الاحتفال الملحمي بإنهاء التمرين)
/// ═══════════════════════════════════════════════════════════════════════════════
class _WorkoutCelebrationModal extends StatelessWidget {
  final String elapsedTime;
  final double totalVolume;
  final int completedSets;
  final int totalSets;
  final int completedExercises;
  final int totalExercises;
  final bool isSaving;
  final VoidCallback onConfirmFinish;

  const _WorkoutCelebrationModal({
    required this.elapsedTime,
    required this.totalVolume,
    required this.completedSets,
    required this.totalSets,
    required this.completedExercises,
    required this.totalExercises,
    required this.isSaving,
    required this.onConfirmFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: const Color(0xFF141D2D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        border: const Border(
          top: BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 16.h),

          // Trophy Badge
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Icon(Icons.emoji_events_rounded,
                size: 40.sp, color: const Color(0xFF10B981)),
          ),
          SizedBox(height: 12.h),

          Text(
            'عاش يا بطل! أداء استثنائي اليوم 💪',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'ملخص إنجازك في جلسة اليوم التدريبية',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              color: const Color(0xFF94A3B8),
            ),
          ),
          SizedBox(height: 20.h),

          // 4 Metric Highlight Cards Grid
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  icon: Icons.timer_outlined,
                  color: const Color(0xFF38BDF8),
                  title: 'الوقت المستغرق',
                  val: elapsedTime,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _metricCard(
                  icon: Icons.fitness_center_rounded,
                  color: const Color(0xFF10B981),
                  title: 'الحجم المرفوع',
                  val: '${totalVolume.toInt()} كجم',
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  icon: Icons.check_circle_outline_rounded,
                  color: const Color(0xFFF59E0B),
                  title: 'المجموعات المنجزة',
                  val: '$completedSets / $totalSets',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _metricCard(
                  icon: Icons.sports_gymnastics_rounded,
                  color: const Color(0xFFA855F7),
                  title: 'التمارين المكتملة',
                  val: '$completedExercises / $totalExercises',
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),

          // Primary Finish & Save Action
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: isSaving ? null : onConfirmFinish,
              style: ElevatedButton.styleFrom(
                minimumSize: Size.zero,
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 3,
                shadowColor: const Color(0xFF10B981).withValues(alpha: 0.4),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_upload_rounded),
                        SizedBox(width: 8.w),
                        Text(
                          'حفظ الجلسة وإتمام الإنجاز 🚀',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 10.h),

          // Cancel / Back to Workout
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'الرجوع لمتابعة التمرين',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.5.sp,
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required Color color,
    required String title,
    required String val,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFF223147)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: color),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.5.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            val,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
