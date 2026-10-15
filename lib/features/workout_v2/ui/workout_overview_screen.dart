import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/core/routing/routes.dart';
import '../../work_out/widgets/workout_card.dart';
import '../logic/workout_overview_cubit.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';
import '../repos/workout_repository_v2.dart';
import '../widgets/universal_inline_video_player.dart';
import 'workout_focus_mode_screen.dart';

class WorkoutOverviewScreen extends StatelessWidget {
  final String? initialWorkoutId;

  const WorkoutOverviewScreen({super.key, this.initialWorkoutId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = WorkoutOverviewCubit(getIt<WorkoutRepositoryV2>());
        _loadTraineeWorkout(cubit);
        return cubit;
      },
      child: _WorkoutOverviewContent(isModal: initialWorkoutId != null),
    );
  }

  void _loadTraineeWorkout(WorkoutOverviewCubit cubit) async {
    final userId = await SharedPreferencesHelper.getString(AppConstants.userId);
    cubit.loadOverview(userId ?? 'test_trainee');
  }
}

class _WorkoutOverviewContent extends StatelessWidget {
  final bool isModal;
  const _WorkoutOverviewContent({this.isModal = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 52.h,
        automaticallyImplyLeading: isModal,
        leading: isModal ? const AppBarBackButton(color: AppColors.black) : null,
        title: Text(
          'خطة تدريب اليوم',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: isModal,
        actions: [
          IconButton(
            tooltip: 'خطة التمارين المرفقة (PDF)',
            icon: Container(
              padding: EdgeInsets.all(7.r),
              decoration: BoxDecoration(
                color: AppColors.newPrimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: const Icon(
                Icons.picture_as_pdf_outlined,
                color: AppColors.newPrimaryColor,
                size: 20,
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, Routes.exercise);
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final userId =
              await SharedPreferencesHelper.getString(AppConstants.userId);
          if (context.mounted) {
            context
                .read<WorkoutOverviewCubit>()
                .loadOverview(userId ?? 'test_trainee');
          }
        },
        child: BlocBuilder<WorkoutOverviewCubit, WorkoutOverviewState>(
          builder: (context, state) {
            if (state is WorkoutOverviewLoading) {
              return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.newPrimaryColor),
              );
            }

            if (state is WorkoutOverviewError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          color: Colors.red[400], size: 48.sp),
                      SizedBox(height: 12.h),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () async {
                          final userId =
                              await SharedPreferencesHelper.getString(
                                  AppConstants.userId);
                          if (context.mounted) {
                            context
                                .read<WorkoutOverviewCubit>()
                                .loadOverview(userId ?? 'test_trainee');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.newPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: const Text('إعادة المحاولة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is WorkoutOverviewRecovery) {
              return _buildRecoveryView(context, state);
            }

            if (state is WorkoutOverviewSuccess) {
              return _buildSuccessView(context, state);
            }

            // Empty state fallback with demo preview
            return _buildEmptyState(context);
          },
        ),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, WorkoutOverviewSuccess state) {
    final workout = state.workout;

    // في حال كانت الخطة عبارة عن ملف PDF فقط بدون تمارين تفاعلية
    if (workout.exercises.isEmpty &&
        workout.pdfAttachmentUrl != null &&
        workout.pdfAttachmentUrl!.isNotEmpty) {
      return _buildPdfOnlySuccessView(context, workout);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Hero Card: Target Muscles & Title
          _HeroMuscleCard(workout: workout),

          SizedBox(height: 14.h),

          // إذا كان هناك ملف PDF مرفق مع الخطة التفاعلية (نظام هجين)
          if (workout.pdfAttachmentUrl != null &&
              workout.pdfAttachmentUrl!.isNotEmpty) ...[
            _buildHybridPdfBanner(context, workout.pdfAttachmentUrl!),
            SizedBox(height: 14.h),
          ],

          // 2. Metrics Bar: Total Exercises, Sets, Reps
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'التمارين',
                  value: '${state.totalExercises}',
                  icon: Icons.fitness_center_rounded,
                  color: AppColors.newPrimaryColor,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _MetricCard(
                  title: 'المجموعات',
                  value: '${state.totalSets}',
                  icon: Icons.repeat_rounded,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _MetricCard(
                  title: 'التكرارات',
                  value: state.estimatedReps,
                  icon: Icons.bolt_rounded,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          SizedBox(height: 18.h),

          // 3. البوابة الرئيسية الوحيدة: شاشة التمارين الشاملة والمتكاملة
          InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkoutFocusModeScreen(
                    workout: workout,
                    initialGuidedMode: true,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(18.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.newPrimaryColor, Color(0xFFC84518)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.newPrimaryColor.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.play_circle_filled_rounded,
                        color: Colors.white, size: 28.sp),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'بدء تمرين اليوم 🎬',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'شاشة التمرين الشاملة: فيديوهات التكنيك، تفاصيل التمرين، وتسجيل المجموعات مباشرة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white, size: 16.sp),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // 4. Coach Day Intro Video Card (فيديو توجيه اليوم من الكابتن - يظهر فقط إن وُجد)
          if (workout.introVideoUrl != null &&
              workout.introVideoUrl!.trim().isNotEmpty) ...[
            _DayIntroVideoCard(
              videoUrl: workout.introVideoUrl!.trim(),
              workoutTitle: workout.title,
            ),
            SizedBox(height: 14.h),
          ],

          SizedBox(height: 10.h),

          // 4. Section: Individual Exercises List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'قائمة التمارين (${workout.exercises.length})',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              Text(
                'اضغط لبدء التمرين في الوضع الشامل',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Exercise Cards
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: workout.exercises.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final ex = workout.exercises[index];
              return _ExerciseOverviewTile(
                index: index + 1,
                exercise: ex,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutFocusModeScreen(
                        workout: workout,
                        initialGuidedMode: true,
                        initialScrollToIndex: index,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPdfOnlySuccessView(BuildContext context, WorkoutModel workout) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // كارت الخطة التدريبية المعتمدة بتصميم فخم وراقي
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.newPrimaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                            color: AppColors.newPrimaryColor
                                .withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified_rounded,
                              size: 14.sp, color: AppColors.newPrimaryColor),
                          SizedBox(width: 4.w),
                          Text(
                            'خطة معتمدة من الكابتن',
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
                    Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Colors.red[400],
                      size: 28.sp,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  workout.title.isNotEmpty
                      ? workout.title
                      : 'خطة التمارين الخاصة بك (PDF)',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 19.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                if (workout.targetMuscles.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: workout.targetMuscles.map((m) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          m,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            color: Colors.white70,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(context, Routes.exercise);
                    },
                    icon: const Icon(Icons.menu_book_rounded,
                        color: Colors.white),
                    label: Text(
                      'فتح وتصفح ملف الخطة التدريبية 📄',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.newPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // كارت مميزات الحماية والتصفح السلس
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.newPrimaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.shield_rounded,
                      color: AppColors.newPrimaryColor, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حماية وتخزين محلي فوري',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        'يتم حفظ ملف التمرين على هاتفك تلقائياً لفتحه بدون إنترنت وبحماية كاملة من النسخ.',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHybridPdfBanner(BuildContext context, String url) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, Routes.exercise);
      },
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.picture_as_pdf_rounded,
                  color: Colors.red, size: 20),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرفق لك ملف الخطة الشاملة (PDF) 📄',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    'اضغط هنا لمراجعة الملف الكامل وتفاصيل التمارين والنصائح المرفقة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10.5.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14.sp, color: Colors.red[400]),
          ],
        ),
      ),
    );
  }

  Future<bool> _checkIfTraineeHasAssignedPdf() async {
    final userId =
        await SharedPreferencesHelper.getString(AppConstants.userId);
    if (userId == null || userId.isEmpty) return false;
    final cached = await SharedPreferencesHelper.getString('cached_workout_pdf_path_$userId');
    if (cached != null && cached.isNotEmpty && File(cached).existsSync()) return true;
    final exerciseId =
        await SharedPreferencesHelper.getInt(AppConstants.exerciseId);
    if (exerciseId != null && exerciseId != 0) return true;
    return false;
  }

  Widget _buildEmptyState(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIfTraineeHasAssignedPdf(),
      builder: (context, snapshot) {
        final hasPdf = snapshot.data ?? false;

        if (hasPdf) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const WorkoutCard(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColors.newPrimaryColor.withValues(alpha: 0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: AppColors.newPrimaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.fitness_center_rounded,
                                color: AppColors.newPrimaryColor,
                                size: 22.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'جدول التمارين التفاعلي',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'يمكنك التدرب ومتابعة خطتك بالكامل عبر كارت التمارين المرفق بالأعلى (PDF).\nوبمجرد تفعيل الكابتن للجدول التفاعلي الذكي ستظهر تمارينه اليومية هنا تلقائياً.',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12.sp,
                                      color: AppColors.grey,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pushNamed(context, Routes.exercise);
                          },
                          borderRadius: BorderRadius.circular(14.r),
                          child: Ink(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 14.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.newPrimaryColor,
                                  Color(0xFFD55322),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.newPrimaryColor.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                SizedBox(width: 10.w),
                                Flexible(
                                  child: Text(
                                    'فتح ملف خطة التمارين (PDF)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // في حال عدم وجود أي تمرين أو ملف PDF مخصص للمتدرب
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 40.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(22.r),
                  decoration: BoxDecoration(
                    color: AppColors.newPrimaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fitness_center_rounded,
                    size: 64.sp,
                    color: AppColors.newPrimaryColor,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'أهلاً بك يا بطل! 🏋️‍♂️',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'يقوم الكابتن حالياً بإعداد خطتك التدريبية المخصصة.\nستظهر أيام تمرينك وملفاتك الإرشادية هنا فور اعتمادها وتفعيلها.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.5.sp,
                    color: Colors.grey[600],
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: () async {
                    final userId = await SharedPreferencesHelper.getString(AppConstants.userId);
                    if (context.mounted && userId != null) {
                      context.read<WorkoutOverviewCubit>().loadOverview(userId);
                    }
                  },
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: Text(
                    'تحديث الجدول',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.newPrimaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecoveryView(
      BuildContext context, WorkoutOverviewRecovery state) {
    final hours = state.remainingCooldown.inHours;
    final minutes = state.remainingCooldown.inMinutes % 60;
    final nextWorkout = state.nextWorkout;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. بطاقة الاحتفال بإتمام التمرين
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF102E50), Color(0xFF1A477A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF102E50).withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF10B981),
                    size: 40,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'عاش يا بطل! أنهيت تمرين اليوم بنجاح 💪',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16.5.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'تم حفظ كافة أوزانك وعدّاتك بنجاح في سجلك الرياضي.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // 2. بطاقة العداد التنازلي ووضع الاستشفاء الذكي
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.battery_charging_full_rounded,
                        color: Color(0xFF10B981), size: 24),
                    SizedBox(width: 8.w),
                    Text(
                      'وضع الاستشفاء والبناء العضلي 🔋',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF102E50),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined,
                          color: Color(0xFF10B981), size: 22),
                      SizedBox(width: 8.w),
                      Text(
                        'متبقي: $hours ساعة و $minutes دقيقة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF065F46),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'المدرب يجهز لك جدول يومك القادم، وسيُفتح تلقائياً فور اكتمال فترة راحة العضلات.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5.sp,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // 3. معاينة تمرين الغد القادم
          Container(
            padding: EdgeInsets.all(16.w),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.newPrimaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        color: AppColors.newPrimaryColor,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تمرينك القادم في الجدول:',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            nextWorkout.title,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'اليوم ${state.currentDayIndex + 1} من ${state.totalDaysCount}',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                const Divider(),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    const Icon(Icons.accessibility_new_rounded,
                        size: 16, color: AppColors.newPrimaryColor),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'العضلات المستهدفة: ${nextWorkout.targetMuscles.join("، ")}',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    const Icon(Icons.format_list_numbered_rounded,
                        size: 16, color: AppColors.newPrimaryColor),
                    SizedBox(width: 6.w),
                    Text(
                      'عدد التمارين: ${nextWorkout.exercises.length} تمارين مخصصة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // 4. نصائح الاستشفاء السريعة
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 نصائح أساسية للاستشفاء اليوم:',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF102E50),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                    '💧 احرص على شرب 3 لتر ماء على مدار اليوم لترطيب الأنسجة العضلية.',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5.sp,
                        color: Colors.grey[700])),
                SizedBox(height: 4.h),
                Text(
                    '🥩 استهلك وجبة بروتين متوازنة لدعم إعادة بناء الألياف العضلية.',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5.sp,
                        color: Colors.grey[700])),
                SizedBox(height: 4.h),
                Text(
                    '💤 احرص على النوم لمدة 7-8 ساعات لإفراز هرمون النمو الطبيعي.',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5.sp,
                        color: Colors.grey[700])),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // 5. زر استثنائي لبدء التمرين مبكراً
          OutlinedButton.icon(
            onPressed: () {
              context
                  .read<WorkoutOverviewCubit>()
                  .unlockWorkoutNow(state.nextWorkout);
            },
            icon: const Icon(Icons.bolt_rounded,
                size: 18, color: AppColors.newPrimaryColor),
            label: const Text(
              'بدء تمرين الغد مبكراً الآن (استثنائي) ⚡',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: AppColors.newPrimaryColor,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: AppColors.newPrimaryColor.withValues(alpha: 0.5)),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

class _HeroMuscleCard extends StatelessWidget {
  final WorkoutModel workout;

  const _HeroMuscleCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  workout.title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'نشط اليوم',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'العضلات المستهدفة:',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: workout.targetMuscles.map((muscle) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.newPrimaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  muscle,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.newPrimaryColor,
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

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20.sp, color: color),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10.5.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseOverviewTile extends StatelessWidget {
  final int index;
  final ExerciseModel exercise;
  final VoidCallback onTap;

  const _ExerciseOverviewTile({
    required this.index,
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasVideo = exercise.videoGuideUrl != null &&
        exercise.videoGuideUrl!.trim().isNotEmpty;
    final hasTip =
        exercise.technicalTip != null && exercise.technicalTip!.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: AppColors.newPrimaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.newPrimaryColor,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            exercise.name,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        if (hasVideo) ...[
                          SizedBox(width: 6.w),
                          InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _playYoutubeVideoModal(
                                context,
                                exercise.videoGuideUrl!.trim(),
                                exercise.name,
                              );
                            },
                            borderRadius: BorderRadius.circular(6.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                    color: const Color(0xFFEF4444)
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.play_circle_fill_rounded,
                                      color: const Color(0xFFEF4444),
                                      size: 13.sp),
                                  SizedBox(width: 3.w),
                                  Text(
                                    'فيديو',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 9.5.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFDC2626),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else if (hasTip) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lightbulb_outline_rounded,
                                    color: const Color(0xFFD97706),
                                    size: 11.sp),
                                SizedBox(width: 3.w),
                                Text(
                                  'توجيه',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${exercise.targetSets} مجموعات × ${exercise.targetRepsRange} تكرار • RIR ${exercise.rir}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey[400], size: 22.sp),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayIntroVideoCard extends StatelessWidget {
  final String videoUrl;
  final String workoutTitle;

  const _DayIntroVideoCard({
    required this.videoUrl,
    required this.workoutTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            _playYoutubeVideoModal(
                context, videoUrl, 'توجيهات الحصة: $workoutTitle');
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 30),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 7.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'فيديو من الكابتن 🎬',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'شرح فلسفة وتكنيك اليوم التدريبي',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'اضغط هنا للمشاهدة وفهم التكنيك والتحكم بالأحمال',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.5.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14.sp, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _playYoutubeVideoModal(
    BuildContext context, String url, String title) {
  HapticFeedback.mediumImpact();
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => _InAppUniversalVideoDialog(videoUrl: url, title: title),
  );
}

class _InAppUniversalVideoDialog extends StatelessWidget {
  final String videoUrl;
  final String title;

  const _InAppUniversalVideoDialog({
    required this.videoUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 14.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          color: const Color(0xFF0F172A),
          padding: EdgeInsets.all(10.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              UniversalInlineVideoPlayer(
                videoUrl: videoUrl,
                exerciseName: title,
                isLightMode: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
