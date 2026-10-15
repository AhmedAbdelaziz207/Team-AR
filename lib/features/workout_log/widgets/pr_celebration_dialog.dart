import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/weight_utils.dart';

/// ديالوج احتفال بالرقم القياسي الجديد (PR)
class PrCelebrationDialog extends StatefulWidget {
  final double weightKg;
  final String unit;
  final VoidCallback onDone;

  const PrCelebrationDialog({
    super.key,
    required this.weightKg,
    required this.unit,
    required this.onDone,
  });

  @override
  State<PrCelebrationDialog> createState() => _PrCelebrationDialogState();
}

class _PrCelebrationDialogState extends State<PrCelebrationDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late AnimationController _particleCtrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();

    _scale = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    _opacity =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _scaleCtrl,
      curve: const Interval(0.0, 0.5),
    ));

    _scaleCtrl.forward();
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _opacity,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Particle effect background
                SizedBox(
                  height: 100.h,
                  child: AnimatedBuilder(
                    animation: _particleCtrl,
                    builder: (_, __) => CustomPaint(
                      painter: _ParticlePainter(_particleCtrl.value),
                      size: Size(double.infinity, 100.h),
                    ),
                  ),
                ),

                Text(
                  '🏆',
                  style: TextStyle(fontSize: 56.sp),
                ),

                SizedBox(height: 12.h),

                Text(
                  'رقم قياسي جديد!',
                  style: TextStyle(
                    color: const Color(0xFFFFD700),
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  WeightUtils.format(widget.weightKg, widget.unit),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),

                SizedBox(height: 4.h),

                Text(
                  'أعلى وزن رفعته في هذا التمرين',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12.sp,
                    fontFamily: 'Cairo',
                  ),
                ),

                SizedBox(height: 28.h),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'رائع! 🎉',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

class _ParticlePainter extends CustomPainter {
  final double progress;
  static final _rng = Random(42);
  static final _particles = List.generate(
    20,
    (i) => [
      _rng.nextDouble(), // x ratio
      _rng.nextDouble(), // y start ratio
      _rng.nextDouble() * 4 + 2, // size
    ],
  );

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFFF6B6B),
      const Color(0xFF4FC3F7),
      const Color(0xFF81C784),
    ];

    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      final x = p[0] * size.width;
      final yBase = p[1] * size.height;
      final y = (yBase - progress * size.height * 1.2) % size.height;
      final radius = p[2];
      final paint = Paint()
        ..color = colors[i % colors.length]
            .withOpacity((1 - progress) * 0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
