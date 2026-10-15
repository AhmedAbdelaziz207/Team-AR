import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import '../models/workout_model.dart';
import 'single_exercise_detail_screen.dart';
import 'workout_focus_mode_screen.dart';

class WorkoutStoryModeScreen extends StatefulWidget {
  final WorkoutModel workout;

  const WorkoutStoryModeScreen({super.key, required this.workout});

  @override
  State<WorkoutStoryModeScreen> createState() => _WorkoutStoryModeScreenState();
}

class _WorkoutStoryModeScreenState extends State<WorkoutStoryModeScreen> {
  int _currentIndex = 0;
  double _currentProgress = 0.0;
  Timer? _timer;
  bool _isPaused = false;
  static const int _storyDurationSec = 7;

  @override
  void initState() {
    super.initState();
    _startStoryTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startStoryTimer() {
    _timer?.cancel();
    _currentProgress = 0.0;
    const intervalMs = 50;
    const totalSteps = (_storyDurationSec * 1000) / intervalMs;

    _timer = Timer.periodic(const Duration(milliseconds: intervalMs), (timer) {
      if (_isPaused) return;

      setState(() {
        _currentProgress += 1.0 / totalSteps;
        if (_currentProgress >= 1.0) {
          _timer?.cancel();
          _nextStory();
        }
      });
    });
  }

  void _nextStory() {
    if (_currentIndex < widget.workout.exercises.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startStoryTimer();
    } else {
      // End of stories -> Close or navigate to Focus Mode
      Navigator.pop(context);
    }
  }

  void _prevStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _startStoryTimer();
    } else {
      setState(() {
        _currentProgress = 0.0;
      });
      _startStoryTimer();
    }
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    setState(() {
      _isPaused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.workout.exercises.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Text('لا توجد تمارين لعرضها',
              style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
        ),
      );
    }

    final ex = widget.workout.exercises[_currentIndex];
    final tipText = (ex.technicalTip != null && ex.technicalTip!.isNotEmpty)
        ? ex.technicalTip!
        : 'HORIZONTAL GRIP!!';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: GestureDetector(
        onLongPressStart: (_) => _pauseTimer(),
        onLongPressEnd: (_) => _resumeTimer(),
        onTapUp: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 3) {
            HapticFeedback.selectionClick();
            _prevStory();
          } else {
            HapticFeedback.selectionClick();
            _nextStory();
          }
        },
        child: Stack(
          children: [
            // Background Video Thumbnail Preview with Gradient
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Subtle Glow Effect
                    Container(
                      width: 140.w,
                      height: 140.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                      ),
                    ),
                    Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white.withValues(alpha: 0.75),
                      size: 80.sp,
                    ),
                  ],
                ),
              ),
            ),

            // Top Segmented Progress Indicators
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Column(
                  children: [
                    Row(
                      children: List.generate(
                        widget.workout.exercises.length,
                        (index) {
                          double value = 0.0;
                          if (index < _currentIndex) {
                            value = 1.0;
                          } else if (index == _currentIndex) {
                            value = _currentProgress;
                          }
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.w),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2.r),
                                child: LinearProgressIndicator(
                                  value: value,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.25),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                  minHeight: 3.h,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Top Bar Info: Close Button + Workout Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6.r),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                              child: const Icon(Icons.fitness_center_rounded,
                                  color: Colors.white, size: 16),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              widget.workout.title,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Center Content: Floating Amber Cue + Exercise Title
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 120.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Floating Amber Technical Cue (مثل الفيديو المرجعي تماماً)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706),
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD97706).withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded,
                            color: Colors.white, size: 16.sp),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            tipText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Exercise Name
                  Text(
                    '${_currentIndex + 1}. ${ex.name}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // 5 Glassmorphism Coach Parameters (Sets, Reps, Rest, RIR, Tempo)
                  Row(
                    children: [
                      _storyParam('المجموعات', '${ex.targetSets}'),
                      SizedBox(width: 8.w),
                      _storyParam('التكرار', ex.targetRepsRange),
                      SizedBox(width: 8.w),
                      _storyParam('الراحة', '${ex.restSeconds}s'),
                      SizedBox(width: 8.w),
                      _storyParam('RIR', '${ex.rir}'),
                      SizedBox(width: 8.w),
                      _storyParam('Tempo', ex.tempo),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Actions: Details or Launch Focus Mode
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 24.h,
              child: Row(
                children: [
                  // View Full Details Button
                  Expanded(
                    flex: 4,
                    child: OutlinedButton(
                      onPressed: () {
                        _pauseTimer();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SingleExerciseDetailScreen(exercise: ex),
                          ),
                        ).then((_) => _resumeTimer());
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text(
                        'تفاصيل التمرين',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 10.w),

                  // Start Focus Mode Button
                  Expanded(
                    flex: 6,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                WorkoutFocusModeScreen(workout: widget.workout),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.newPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded, size: 18.sp),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              'بدء التمرين الآن ⚡',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _storyParam(String label, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 8.5.sp,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
