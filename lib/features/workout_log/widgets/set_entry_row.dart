import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/weight_utils.dart';
import 'package:team_ar/features/workout_log/model/set_log.dart';

/// صف إدخال مجموعة تمرين عالي السرعة والمرونة للرياضيين
class SetEntryRow extends StatefulWidget {
  final int index;
  final TextEditingController weightCtrl;
  final TextEditingController repsCtrl;
  final String unit; // kg or lbs
  final SetLog? previousSetLog;
  final bool isCompleted;
  final ValueChanged<bool>? onToggleComplete;
  final bool canDelete;
  final VoidCallback onDelete;

  const SetEntryRow({
    super.key,
    required this.index,
    required this.weightCtrl,
    required this.repsCtrl,
    required this.unit,
    this.previousSetLog,
    this.isCompleted = false,
    this.onToggleComplete,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  State<SetEntryRow> createState() => _SetEntryRowState();
}

class _SetEntryRowState extends State<SetEntryRow> {
  void _stepWeight(double delta) {
    HapticFeedback.selectionClick();
    double current = double.tryParse(widget.weightCtrl.text.trim()) ?? 0.0;
    current += delta;
    if (current < 0) current = 0;
    widget.weightCtrl.text = current == current.truncateToDouble()
        ? current.toInt().toString()
        : current.toStringAsFixed(1);
    setState(() {});
  }

  void _stepReps(int delta) {
    HapticFeedback.selectionClick();
    int current = int.tryParse(widget.repsCtrl.text.trim()) ?? 0;
    current += delta;
    if (current < 0) current = 0;
    widget.repsCtrl.text = current.toString();
    setState(() {});
  }

  void _copyPrevious() {
    if (widget.previousSetLog == null) return;
    HapticFeedback.mediumImpact();
    final prevW = WeightUtils.fromKg(
      widget.previousSetLog!.weightKg,
      widget.unit,
    );
    widget.weightCtrl.text = prevW == prevW.truncateToDouble()
        ? prevW.toInt().toString()
        : prevW.toStringAsFixed(1);
    widget.repsCtrl.text = widget.previousSetLog!.reps.toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasPrevious = widget.previousSetLog != null;
    final prevWeight = hasPrevious
        ? WeightUtils.fromKg(widget.previousSetLog!.weightKg, widget.unit)
        : null;
    final prevReps = widget.previousSetLog?.reps;
    final stepSize = widget.unit == 'lbs' ? 5.0 : 2.5;

    final isDone = widget.isCompleted;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDone
            ? const Color(0xFF10B981).withValues(alpha: 0.07)
            : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDone
              ? const Color(0xFF10B981).withValues(alpha: 0.4)
              : Colors.grey.withValues(alpha: 0.18),
          width: isDone ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // رقم المجموعة أو شارة الإنجاز
              InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  widget.onToggleComplete?.call(!isDone);
                },
                borderRadius: BorderRadius.circular(20.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFF10B981)
                        : const Color(0xFF102E50),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: isDone
                      ? Icon(Icons.check_rounded, color: Colors.white, size: 18.sp)
                      : Text(
                          '${widget.index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                ),
              ),

              SizedBox(width: 8.w),

              // حقل الوزن مع أزرار الزيادة السريعة
              Expanded(
                flex: 5,
                child: _QuickStepperBox(
                  controller: widget.weightCtrl,
                  label: 'الوزن (${widget.unit})',
                  isDecimal: true,
                  stepSizeText: '±$stepSize',
                  onMinus: () => _stepWeight(-stepSize),
                  onPlus: () => _stepWeight(stepSize),
                  onChanged: () => setState(() {}),
                ),
              ),

              SizedBox(width: 8.w),

              // حقل التكرار مع أزرار الزيادة السريعة
              Expanded(
                flex: 4,
                child: _QuickStepperBox(
                  controller: widget.repsCtrl,
                  label: 'التكرار',
                  isDecimal: false,
                  stepSizeText: '±1',
                  onMinus: () => _stepReps(-1),
                  onPlus: () => _stepReps(1),
                  onChanged: () => setState(() {}),
                ),
              ),

              // زر الحذف
              if (widget.canDelete) ...[
                SizedBox(width: 4.w),
                IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline_rounded,
                    color: Colors.grey[400],
                    size: 20.sp,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.onDelete,
                  tooltip: 'حذف المجموعة',
                ),
              ],
            ],
          ),

          // شريط الأداء السابق السريع (نقرة واحدة للنسخ)
          if (hasPrevious) ...[
            SizedBox(height: 6.h),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8.w,
              runSpacing: 4.h,
              children: [
                InkWell(
                  onTap: _copyPrevious,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF102E50).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: const Color(0xFF102E50).withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 13.sp,
                          color: const Color(0xFF102E50),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'السابق: ${_formatNum(prevWeight!)} ${widget.unit} × $prevReps',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF102E50),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.copy_rounded,
                          size: 11.sp,
                          color: const Color(0xFF102E50).withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isDone)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 13.sp,
                        color: const Color(0xFF10B981),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'مكتملة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatNum(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}

class _QuickStepperBox extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isDecimal;
  final String stepSizeText;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onChanged;

  const _QuickStepperBox({
    required this.controller,
    required this.label,
    required this.isDecimal,
    required this.stepSizeText,
    required this.onMinus,
    required this.onPlus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 6.w, right: 6.w),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Row(
            children: [
              // زر -
              _StepBtn(
                icon: Icons.remove_rounded,
                onTap: onMinus,
              ),

              // حقل الإدخال
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: isDecimal
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.number,
                  inputFormatters: [
                    if (isDecimal)
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    if (!isDecimal) FilteringTextInputFormatter.digitsOnly,
                  ],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF102E50),
                  ),
                  onChanged: (_) => onChanged(),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      color: Colors.grey[400],
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                    border: InputBorder.none,
                  ),
                ),
              ),

              // زر +
              _StepBtn(
                icon: Icons.add_rounded,
                onTap: onPlus,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        width: 26.w,
        height: 26.w,
        margin: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 3,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16.sp, color: const Color(0xFF102E50)),
      ),
    );
  }
}
