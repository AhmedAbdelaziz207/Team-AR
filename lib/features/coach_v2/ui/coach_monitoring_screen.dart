import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import '../../workout_v2/models/exercise_log_model.dart';
import '../../workout_v2/models/workout_model.dart';
import '../../workout_v2/repos/workout_repository_v2.dart';

class CoachMonitoringScreen extends StatefulWidget {
  final String traineeId;
  final String traineeName;

  const CoachMonitoringScreen({
    super.key,
    required this.traineeId,
    required this.traineeName,
  });

  @override
  State<CoachMonitoringScreen> createState() => _CoachMonitoringScreenState();
}

class _CoachMonitoringScreenState extends State<CoachMonitoringScreen> {
  int _activeTab = 0; // 0: الخطة التدريبية | 1: سجل الأداء
  bool _isLoading = true;
  List<ExerciseLogModel> _logs = [];
  List<WorkoutModel> _workouts = [];
  SmartWorkoutResult? _smartStatus;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final repo = getIt<WorkoutRepositoryV2>();
    final logs = await repo.getTraineeHistory(widget.traineeId);
    final workouts = await repo.getAllWorkoutsForTrainee(widget.traineeId);
    final smart = await repo.getSmartActiveWorkout(widget.traineeId);

    if (mounted) {
      setState(() {
        _logs = logs;
        _workouts = workouts;
        _smartStatus = smart;
        _isLoading = false;
      });
    }
  }

  void _confirmDeleteWorkout(WorkoutModel workout) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('حذف هذا اليوم التدريبي؟',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: Text(
          'هل أنت متأكد من حذف "${workout.title}" من جدول المتدرب؟ لن يتمكن المتدرب من رؤيته.',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              final repo = getIt<WorkoutRepositoryV2>();
              final success = await repo.deleteWorkout(workout.id);
              if (success) {
                await _fetchData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف اليوم التدريبي بنجاح 🗑️'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                setState(() => _isLoading = false);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('حدث خطأ أثناء محاولة الحذف'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF102E50),
        elevation: 0,
        leading: const AppBarBackButton(color: Colors.white),
        title: Text(
          'متابعة المتدرب: ${widget.traineeName}',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'تحديث البيانات',
            onPressed: _fetchData,
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط التبديل بين الخطة التدريبية وسجل الأداء
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _activeTab = 0),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 9.h),
                        decoration: BoxDecoration(
                          color: _activeTab == 0
                              ? const Color(0xFF102E50)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'الخطة المفعلة (${_workouts.length})',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.bold,
                            color: _activeTab == 0 ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _activeTab = 1),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 9.h),
                        decoration: BoxDecoration(
                          color: _activeTab == 1
                              ? const Color(0xFF102E50)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'سجل الأداء (${_logs.length})',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.bold,
                            color: _activeTab == 1 ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF102E50)),
                  )
                : _activeTab == 0
                    ? _buildWorkoutsTab()
                    : _buildLogsTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutsTab() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        children: [
          // 1. بطاقة الحالة الذكية للمتدرب (Recovery vs Active)
          if (_smartStatus != null && _workouts.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: _smartStatus!.isRecoveryMode
                      ? const Color(0xFF10B981)
                      : AppColors.newPrimaryColor,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: _smartStatus!.isRecoveryMode
                          ? const Color(0xFF10B981).withValues(alpha: 0.12)
                          : AppColors.newPrimaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _smartStatus!.isRecoveryMode
                          ? Icons.battery_charging_full_rounded
                          : Icons.fitness_center_rounded,
                      color: _smartStatus!.isRecoveryMode
                          ? const Color(0xFF10B981)
                          : AppColors.newPrimaryColor,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _smartStatus!.isRecoveryMode
                              ? 'المتدرب في فترة استشفاء حالياً 🔋'
                              : 'المتدرب جاهز للتمرين الآن 🟢',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF102E50),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _smartStatus!.isRecoveryMode
                              ? 'متبقي ${_smartStatus!.remainingCooldown?.inHours ?? 0} ساعة لفتح (${_smartStatus!.activeWorkout?.title ?? ""})'
                              : 'اليوم الفعال المتاح له: ${_smartStatus!.activeWorkout?.title ?? ""}',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.5.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
          ],

          // 2. ترويسة مع زر إضافة يوم جديد
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'البرنامج التدريبي الأسبوعي (${_workouts.length})',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    Routes.workoutBuilder,
                    arguments: widget.traineeId,
                  ).then((_) => _fetchData());
                },
                icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                label: Text(
                  'إضافة يوم ➕',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.newPrimaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // 3. قائمة أيام الخطة أو الحالة الفارغة
          if (_workouts.isEmpty)
            Container(
              padding: EdgeInsets.all(28.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  Icon(Icons.assignment_late_outlined,
                      size: 44.sp, color: Colors.grey[400]),
                  SizedBox(height: 10.h),
                  Text(
                    'لم يتم إسناد أي جدول تدريبي لهذا المتدرب بعد',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'اضغط على زر "إضافة يوم" لإنشاء وإسناد جدول تدريبي فوري له.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Cairo', color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          else
            ..._workouts.asMap().entries.map((entry) {
              final idx = entry.key;
              final workout = entry.value;
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: AppColors.newPrimaryColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  workout.dayOfWeek ?? 'اليوم ${idx + 1}',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.newPrimaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Text(
                                  workout.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.red, size: 20),
                          tooltip: 'حذف هذا اليوم',
                          onPressed: () => _confirmDeleteWorkout(workout),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '${workout.exercises.length} تمارين • ${workout.targetMuscles.join("، ")}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (workout.exercises.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      const Divider(),
                      SizedBox(height: 4.h),
                      ...workout.exercises.take(3).map((ex) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded,
                                    size: 14, color: Color(0xFF10B981)),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    '${ex.name} (${ex.targetSets} مجموعات × ${ex.targetRepsRange})',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11.5.sp,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      if (workout.exercises.length > 3)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            '+ ${workout.exercises.length - 3} تمارين إضافية...',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10.5.sp,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    if (_logs.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history_rounded, size: 48.sp, color: Colors.grey[400]),
              SizedBox(height: 12.h),
              Text(
                'لم يقم المتدرب بتسجيل أي تمارين حتى الآن',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF102E50),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      itemCount: _logs.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final log = _logs[index];
        return _TraineeLogCard(log: log);
      },
    );
  }
}

class _TraineeLogCard extends StatelessWidget {
  final ExerciseLogModel log;

  const _TraineeLogCard({required this.log});

  String _formatDate(DateTime dt) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
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
          // Header: Date & Effort Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 14.sp, color: Colors.grey[600]),
                  SizedBox(width: 6.w),
                  Text(
                    _formatDate(log.date),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF102E50).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _effortLabel(log.effortRating),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF102E50),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Sets Summary Chips
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: log.sets.map((s) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Text(
                  'م ${s.setNumber}: ${s.weight} ${s.weightUnit} × ${s.reps} تكرار',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF102E50),
                  ),
                ),
              );
            }).toList(),
          ),

          // Notes if present
          if (log.coachFeedbackNotes != null &&
              log.coachFeedbackNotes!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '💬 ملاحظة المتدرب: ${log.coachFeedbackNotes}',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.sp,
                  color: const Color(0xFF92400E),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _effortLabel(String rating) {
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
        return '💪 متوسط';
    }
  }
}
