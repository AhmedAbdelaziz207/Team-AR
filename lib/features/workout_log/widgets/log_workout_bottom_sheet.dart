import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/utils/weight_utils.dart';
import 'package:team_ar/features/workout_log/logic/workout_log_cubit.dart';
import 'package:team_ar/features/workout_log/logic/workout_log_state.dart';
import 'package:team_ar/features/workout_log/model/set_log.dart';
import 'package:team_ar/features/workout_log/widgets/feeling_selector.dart';
import 'package:team_ar/features/workout_log/widgets/pr_celebration_dialog.dart';
import 'package:team_ar/features/workout_log/widgets/set_entry_row.dart';
import 'package:team_ar/features/workout_log/widgets/workout_summary_card.dart';

class LogWorkoutBottomSheet extends StatefulWidget {
  final int exerciseId;
  final String exerciseName;

  const LogWorkoutBottomSheet({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });

  static Future<void> show(
    BuildContext context, {
    required int exerciseId,
    required String exerciseName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => getIt<WorkoutLogCubit>()
          ..loadPreviousSession(exerciseId: exerciseId),
        child: LogWorkoutBottomSheet(
          exerciseId: exerciseId,
          exerciseName: exerciseName,
        ),
      ),
    );
  }

  @override
  State<LogWorkoutBottomSheet> createState() => _LogWorkoutBottomSheetState();
}

class _LogWorkoutBottomSheetState extends State<LogWorkoutBottomSheet> {
  // حالة الـ UI
  String _unit = 'kg'; // kg أو lbs
  int? _feeling;
  final TextEditingController _noteCtrl = TextEditingController();
  final List<TextEditingController> _weightCtrs = [];
  final List<TextEditingController> _repsCtrs = [];
  final List<bool> _completedSets = [];

  // مؤقت الراحة بين المجموعات (Rest Timer)
  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  int _selectedRestDuration = 60; // 60s default

  static const int _initialSets = 3;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _initialSets; i++) {
      _weightCtrs.add(TextEditingController());
      _repsCtrs.add(TextEditingController());
      _completedSets.add(false);
    }
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _noteCtrl.dispose();
    for (final c in _weightCtrs) {
      c.dispose();
    }
    for (final c in _repsCtrs) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── التحكم في مؤقت الراحة ──────────────────────────────
  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedRestDuration = seconds;
      _restSecondsRemaining = seconds;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining <= 1) {
        timer.cancel();
        HapticFeedback.heavyImpact();
        if (mounted) {
          setState(() => _restSecondsRemaining = 0);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('انتهى وقت الراحة! جاهز للمجموعة التالية 🔥',
                  style: TextStyle(fontFamily: 'Cairo')),
              backgroundColor: Color(0xFF102E50),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() => _restSecondsRemaining--);
        }
      }
    });
  }

  void _stopRestTimer() {
    _restTimer?.cancel();
    setState(() => _restSecondsRemaining = 0);
  }

  // ─── نسخ جميع أوزان آخر تمرين بنقرة واحدة (1-Tap Copy) ───
  void _copyAllPreviousSets(List<SetLog> previousSets) {
    if (previousSets.isEmpty) return;
    HapticFeedback.heavyImpact();

    // نسوي عدد الحقول بعدد المجموعات السابقة
    while (_weightCtrs.length < previousSets.length) {
      _weightCtrs.add(TextEditingController());
      _repsCtrs.add(TextEditingController());
      _completedSets.add(false);
    }
    while (_weightCtrs.length > previousSets.length && _weightCtrs.length > 1) {
      _weightCtrs.removeLast().dispose();
      _repsCtrs.removeLast().dispose();
      _completedSets.removeLast();
    }

    for (int i = 0; i < previousSets.length; i++) {
      final prevW = WeightUtils.fromKg(previousSets[i].weightKg, _unit);
      _weightCtrs[i].text = prevW == prevW.truncateToDouble()
          ? prevW.toInt().toString()
          : prevW.toStringAsFixed(1);
      _repsCtrs[i].text = previousSets[i].reps.toString();
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚡ تم نسخ أوزان وتكرارات آخر تمرين بنجاح!',
            style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── إضافة مجموعة ذكية مع نسخ تلقائي للمجموعة السابقة ─────
  void _addSet() {
    HapticFeedback.selectionClick();
    String lastWeight = '';
    String lastReps = '';
    if (_weightCtrs.isNotEmpty) {
      lastWeight = _weightCtrs.last.text;
      lastReps = _repsCtrs.last.text;
    }

    setState(() {
      _weightCtrs.add(TextEditingController(text: lastWeight));
      _repsCtrs.add(TextEditingController(text: lastReps));
      _completedSets.add(false);
    });
  }

  void _removeSet(int index) {
    if (_weightCtrs.length <= 1) return;
    HapticFeedback.selectionClick();
    setState(() {
      _weightCtrs[index].dispose();
      _repsCtrs[index].dispose();
      _weightCtrs.removeAt(index);
      _repsCtrs.removeAt(index);
      _completedSets.removeAt(index);
    });
  }

  List<SetLog>? _buildSets() {
    final sets = <SetLog>[];
    for (int i = 0; i < _weightCtrs.length; i++) {
      final w = double.tryParse(_weightCtrs[i].text.trim());
      final r = int.tryParse(_repsCtrs[i].text.trim());
      if (w == null || r == null || w <= 0 || r <= 0) return null;
      sets.add(SetLog(
        exerciseId: widget.exerciseId,
        exerciseName: widget.exerciseName,
        setNumber: i + 1,
        weightKg: WeightUtils.toKg(w, _unit),
        reps: r,
        feeling: _feeling,
      ));
    }
    return sets;
  }

  void _onSave() {
    final sets = _buildSets();
    if (sets == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('أدخل الوزن والتكرارات لكل المجموعات',
              style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    context.read<WorkoutLogCubit>().saveSession(
          exerciseId: widget.exerciseId,
          exerciseName: widget.exerciseName,
          sets: sets,
          notes: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutLogCubit, WorkoutLogState>(
      listener: (context, state) {
        if (state is WorkoutLogSaved) {
          if (state.isNewPR) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => PrCelebrationDialog(
                weightKg: state.bestWeightKg,
                unit: _unit,
                onDone: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            );
          }
        } else if (state is WorkoutLogSavedOffline) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  '✅ تم الحفظ محليًا — سيتزامن عند عودة الإنترنت',
                  style: TextStyle(fontFamily: 'Cairo')),
              backgroundColor: Colors.orange.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is WorkoutLogError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message,
                  style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isSaving = state is WorkoutLogSaving;
        final isSaved = state is WorkoutLogSaved;
        final isLoading = state is WorkoutLogLoadingPrevious;

        List<SetLog> previousSets = [];
        double previousPR = 0.0;
        if (state is WorkoutLogReady) {
          previousSets = state.previousSets;
          previousPR = state.previousPR;
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (ctx, controller) {
              return Column(
                children: [
                  // شريط السحب الرمادي
                  Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.exerciseName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: const Color(0xFF102E50),
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              if (previousPR > 0)
                                Text(
                                  'أفضل وزن سابق: ${WeightUtils.format(previousPR, _unit)} ⭐',
                                  style: TextStyle(
                                    color: Colors.amber[800],
                                    fontSize: 11.5.sp,
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // تبديل الوحدة kg / lbs
                        Container(
                          padding: EdgeInsets.all(3.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _UnitBtn(
                                label: 'كجم',
                                isSelected: _unit == 'kg',
                                onTap: () => setState(() => _unit = 'kg'),
                              ),
                              _UnitBtn(
                                label: 'باوند',
                                isSelected: _unit == 'lbs',
                                onTap: () => setState(() => _unit = 'lbs'),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 8.w),

                        // زر الإغلاق
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.grey[600],
                            size: 24.sp,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // شريط مؤقت الراحة بين المجموعات (Rest Timer)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: _restSecondsRemaining > 0
                          ? const Color(0xFF102E50).withValues(alpha: 0.08)
                          : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: _restSecondsRemaining > 0
                            ? const Color(0xFF102E50).withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 16.sp,
                              color: _restSecondsRemaining > 0
                                  ? const Color(0xFF102E50)
                                  : Colors.grey[700],
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              _restSecondsRemaining > 0
                                  ? 'راحة: $_restSecondsRemaining ثانية'
                                  : 'مؤقت الراحة:',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: _restSecondsRemaining > 0
                                    ? const Color(0xFF102E50)
                                    : Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        if (_restSecondsRemaining > 0)
                          InkWell(
                            onTap: _stopRestTimer,
                            child: Text(
                              'إلغاء ✕',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                          )
                        else
                          Row(
                            children: [60, 90, 120].map((s) {
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3.w),
                                child: InkWell(
                                  onTap: () => _startRestTimer(s),
                                  borderRadius: BorderRadius.circular(6.r),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 3.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6.r),
                                      border: Border.all(
                                        color: Colors.grey.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Text(
                                      '$s ث',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 10.5.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF102E50),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),

                  // زر نسخ أوزان آخر تمرين (إذا توفرت)
                  if (previousSets.isNotEmpty && !isSaved)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                      child: InkWell(
                        onTap: () => _copyAllPreviousSets(previousSets),
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: const Color(0xFF10B981).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.bolt_rounded,
                                  color: Color(0xFF10B981), size: 18),
                              SizedBox(width: 4.w),
                              Text(
                                'نسخ أوزان وتكرارات آخر تمرين بنقرة واحدة',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const Divider(height: 16),

                  // Body
                  Expanded(
                    child: isSaved
                        ? WorkoutSummaryCard(
                            sets: state.savedSets,
                            unit: _unit,
                          )
                        : isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF102E50),
                                ),
                              )
                            : ListView(
                                controller: controller,
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                children: [
                                  // قائمة المجموعات
                                  ...List.generate(_weightCtrs.length, (i) {
                                    final prev = i < previousSets.length
                                        ? previousSets[i]
                                        : null;

                                    return SetEntryRow(
                                      index: i,
                                      weightCtrl: _weightCtrs[i],
                                      repsCtrl: _repsCtrs[i],
                                      unit: _unit,
                                      previousSetLog: prev,
                                      isCompleted: _completedSets[i],
                                      onToggleComplete: (done) {
                                        setState(() {
                                          _completedSets[i] = done;
                                        });
                                        if (done && _selectedRestDuration > 0) {
                                          _startRestTimer(_selectedRestDuration);
                                        }
                                      },
                                      canDelete: _weightCtrs.length > 1,
                                      onDelete: () => _removeSet(i),
                                    );
                                  }),

                                  SizedBox(height: 8.h),

                                  // زر إضافة مجموعة ذكية
                                  OutlinedButton.icon(
                                    onPressed: _addSet,
                                    icon: const Icon(Icons.add_rounded),
                                    label: const Text('إضافة مجموعة جديدة'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF102E50),
                                      side: BorderSide(
                                        color: const Color(0xFF102E50)
                                            .withValues(alpha: 0.3),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 10.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      textStyle: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 16.h),

                                  // منتقي الإحساس
                                  FeelingSelector(
                                    selected: _feeling,
                                    onSelected: (v) =>
                                        setState(() => _feeling = v),
                                  ),

                                  SizedBox(height: 16.h),

                                  // ملاحظة سريعة
                                  TextField(
                                    controller: _noteCtrl,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 13.sp,
                                      color: Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'ملاحظة للمدرب (اختياري)...',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 12.sp,
                                        color: Colors.grey[400],
                                      ),
                                      prefixIcon: Icon(
                                        Icons.edit_note_rounded,
                                        color: Colors.grey[500],
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF8F9FA),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12.w, vertical: 10.h),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withValues(alpha: 0.2),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withValues(alpha: 0.2),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF102E50),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 24.h),
                                ],
                              ),
                  ),

                  // Bottom Save Action
                  if (!isSaved)
                    SafeArea(
                      top: false,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 54.h,
                          child: ElevatedButton(
                            onPressed: isSaving ? null : _onSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF102E50),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: Colors.white,
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'حفظ وإنهاء تمرين اليوم 💪',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _UnitBtn extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnitBtn({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF102E50) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 11.5.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}
