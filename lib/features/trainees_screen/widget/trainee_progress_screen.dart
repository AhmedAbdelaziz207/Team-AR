import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/features/diet/repos/meal_log_repository.dart';
import 'package:team_ar/features/diet/services/meal_reminder_service.dart';
import 'package:team_ar/features/home/admin/data/trainee_model.dart';
import 'package:team_ar/features/workout_log/model/workout_session.dart';
import 'package:team_ar/features/workout_log/repos/workout_log_repository.dart';

class TraineeProgressScreen extends StatefulWidget {
  final TraineeModel trainee;

  const TraineeProgressScreen({super.key, required this.trainee});

  @override
  State<TraineeProgressScreen> createState() => _TraineeProgressScreenState();
}

class _TraineeProgressScreenState extends State<TraineeProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final WorkoutLogRepository _workoutRepo = getIt<WorkoutLogRepository>();
  final MealLogRepository _mealRepo = getIt<MealLogRepository>();

  bool _loadingWorkouts = true;
  List<WorkoutSession> _sessions = [];

  bool _loadingMeals = true;
  Map<int, int> _weeklyCompliance = {};
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userId = widget.trainee.id ?? '';
    if (userId.isEmpty) {
      setState(() {
        _loadingWorkouts = false;
        _loadingMeals = false;
      });
      return;
    }

    // Load workouts
    _workoutRepo.getSessionsForTrainee(userId: userId, limit: 30).then((data) {
      if (mounted) {
        setState(() {
          _sessions = data;
          _loadingWorkouts = false;
        });
      }
    });

    // Load meals compliance and streak
    Future.wait([
      _mealRepo.getWeeklyCompliance(userId),
      _mealRepo.calculateStreak(userId),
    ]).then((results) {
      if (mounted) {
        setState(() {
          _weeklyCompliance = results[0] as Map<int, int>;
          _streak = results[1] as int;
          _loadingMeals = false;
        });
      }
    });
  }

  String _getFeelingLabel(int? feeling) {
    switch (feeling) {
      case 1:
        return 'سهل 😊';
      case 2:
        return 'متوسط 💪';
      case 3:
        return 'صعب 🔥';
      case 4:
        return 'أقصى حد ⚡';
      default:
        return '';
    }
  }

  Color _getFeelingColor(int? feeling) {
    switch (feeling) {
      case 1:
        return const Color(0xFF10B981);
      case 2:
        return const Color(0xFF3B82F6);
      case 3:
        return const Color(0xFFF59E0B);
      case 4:
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final traineeName = widget.trainee.userName ?? 'المتدرب';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF102E50),
        elevation: 0,
        leading: const AppBarBackButton(color: AppColors.white),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'سجل الأداء (المدرب)',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              traineeName,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          indicatorWeight: 3,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.fitness_center_rounded),
              text: 'سجل التمارين',
            ),
            Tab(
              icon: Icon(Icons.restaurant_menu_rounded),
              text: 'الالتزام بالوجبات',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWorkoutsTab(),
          _buildMealsTab(),
        ],
      ),
    );
  }

  // ─── تاب سجل التمارين والأوزان ─────────────────────────────
  Widget _buildWorkoutsTab() {
    if (_loadingWorkouts) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF102E50)),
      );
    }

    if (_sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: const Color(0xFF102E50).withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fitness_center_outlined,
                size: 54.sp,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'لم يسجل المتدرب أي جلسات تمرين حتى الآن',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: EdgeInsets.all(16.sp),
        itemCount: _sessions.length,
        separatorBuilder: (_, __) => SizedBox(height: 14.h),
        itemBuilder: (context, index) {
          final session = _sessions[index];
          final sets = session.sets;

          return Container(
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
                // رأس الجلسة: التاريخ + عدد المجموعات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: Color(0xFF102E50),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          session.date.toIso8601String().split('T').first,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: const Color(0xFF102E50),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF102E50).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${sets.length} مجموعات',
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
                SizedBox(height: 12.h),

                // جدول المجموعات
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFC),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    children: [
                      // Header Row
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 32.w,
                              child: Text(
                                '#',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'الوزن',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'التكرار',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'الإحساس',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Set Rows
                      ...sets.asMap().entries.map((entry) {
                        final i = entry.key;
                        final set = entry.value;
                        final feelingText = _getFeelingLabel(set.feeling);
                        final feelingColor = _getFeelingColor(set.feeling);

                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32.w,
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF102E50),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${set.weightKg} كجم',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${set.reps} تكرار',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13.sp,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  feelingText,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: feelingColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // ملاحظات المتدرب (إن وجدت)
                if (session.notes != null && session.notes!.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10.sp),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'ملاحظة المتدرب: ${session.notes}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        color: Colors.amber[900],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── تاب الالتزام بالوجبات ─────────────────────────────────
  Widget _buildMealsTab() {
    if (_loadingMeals) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF102E50)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: EdgeInsets.all(16.sp),
        children: [
          // بطاقة سلسلة الأيام والالتزام
          Container(
            padding: EdgeInsets.all(20.sp),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF102E50), Color(0xFF1F4E79)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF102E50).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 32)),
                    SizedBox(height: 4.h),
                    Text(
                      '$_streak أيام',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    Text(
                      'سلسلة الالتزام',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 60.h,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                Column(
                  children: [
                    const Text('🥗', style: TextStyle(fontSize: 32)),
                    SizedBox(height: 4.h),
                    Text(
                      '7 أيام',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    Text(
                      'نطاق التقييم',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'التزام الوجبات خلال آخر 7 أيام',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 10.h),

          ...List.generate(6, (index) {
            final mealId = index + 1;
            final daysCompleted = _weeklyCompliance[mealId] ?? 0;
            final ratio = (daysCompleted / 7.0).clamp(0.0, 1.0);
            final mealTitle = MealReminderService.getMealTitle(mealId);

            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(14.sp),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mealTitle,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '$daysCompleted من 7 أيام',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: ratio >= 0.7
                              ? const Color(0xFF10B981)
                              : ratio >= 0.4
                                  ? Colors.amber[800]
                                  : Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8.h,
                      backgroundColor: Colors.grey.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ratio >= 0.7
                            ? const Color(0xFF10B981)
                            : ratio >= 0.4
                                ? Colors.amber
                                : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
