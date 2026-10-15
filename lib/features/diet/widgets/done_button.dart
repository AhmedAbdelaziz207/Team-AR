import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DoneButton extends StatefulWidget {
  final bool isDone;
  final VoidCallback onTap;

  const DoneButton({
    super.key,
    required this.isDone,
    required this.onTap,
  });

  @override
  State<DoneButton> createState() => _DoneButtonState();
}

class _DoneButtonState extends State<DoneButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  DateTime _lastTap = DateTime(2000);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Debounce 400ms
    final now = DateTime.now();
    if (now.difference(_lastTap).inMilliseconds < 400) return;
    _lastTap = now;

    HapticFeedback.mediumImpact();
    _animController.forward().then((_) {
      _animController.reverse();
    });

    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(24.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
            decoration: BoxDecoration(
              gradient: widget.isDone
                  ? const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.isDone ? null : Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: widget.isDone
                    ? Colors.transparent
                    : const Color(0xFF102E50).withValues(alpha: 0.25),
                width: 1.2,
              ),
              boxShadow: widget.isDone
                  ? [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    widget.isDone
                        ? Icons.check_circle_rounded
                        : Icons.check_circle_outline_rounded,
                    key: ValueKey(widget.isDone),
                    size: 16.sp,
                    color: widget.isDone
                        ? Colors.white
                        : const Color(0xFF102E50),
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  widget.isDone ? "مكتملة" : "تم الأكل",
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: widget.isDone
                        ? Colors.white
                        : const Color(0xFF102E50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
