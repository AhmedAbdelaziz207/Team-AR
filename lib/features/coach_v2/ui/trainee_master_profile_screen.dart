import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/features/chat/model/chat_user_model.dart';
import 'package:team_ar/features/diet_v2/models/diet_plan_model.dart';
import 'package:team_ar/features/diet_v2/models/meal_model.dart';
import 'package:team_ar/features/diet_v2/repos/diet_repository_v2.dart';
import 'package:team_ar/features/home/admin/data/trainee_model.dart';
import 'package:team_ar/features/work_out/ui/exercise_screen.dart';
import 'package:team_ar/features/workout_systems/model/workout_system_model.dart';
import 'package:team_ar/features/workout_systems/repo/workout_system_repository.dart';
import 'package:team_ar/features/workout_v2/models/exercise_model.dart';
import 'package:team_ar/features/workout_v2/models/workout_model.dart';
import 'package:team_ar/features/workout_v2/repos/workout_repository_v2.dart';
import 'workout_builder_screen.dart';

/// الشاشة الشاملة لإدارة وتخصيص المتدرب بالكامل للمدرب (Trainee Master Profile)
/// تتيح للمدرب استعراض والتحكم وإلغاء أي عنصر:
/// 1. أيام التمارين الذكية وتفاصيل كل تمرين
/// 2. ملف الـ PDF المعتمد (معاينة، استبدال، إلغاء)
/// 3. الخطة الغذائية والوجبات (إلغاء وجبة، إلغاء الخطة كاملة، تعديل)
class TraineeMasterProfileScreen extends StatefulWidget {
  final TraineeModel trainee;

  const TraineeMasterProfileScreen({super.key, required this.trainee});

  @override
  State<TraineeMasterProfileScreen> createState() =>
      _TraineeMasterProfileScreenState();
}

class _TraineeMasterProfileScreenState
    extends State<TraineeMasterProfileScreen> {
  // 0: التمارين الذكية 🏋️‍♂️ | 1: ملف الـ PDF المعتمد 📄 | 2: الخطة الغذائية والوجبات 🥗
  int _selectedTab = 0;

  bool _isLoading = true;

  // 1. التمارين الذكية المسندة للمتدرب
  List<WorkoutModel> _assignedWorkouts = [];

  // 2. حالة ملف الـ PDF
  String? _assignedPdfUrl;
  String? _assignedPdfName;
  int? _legacyExerciseId;

  // 3. الخطة الغذائية
  DietPlanModel? _dietPlan;
  List<dynamic> _legacyFoods = [];

  // قائمة ملفات المكتبة المركزية المتاحة للإسناد السريع
  List<WorkoutSystemModel> _availablePdfSystems = [];

  @override
  void initState() {
    super.initState();
    _loadAllTraineeData();
  }

  Future<void> _loadAllTraineeData() async {
    setState(() => _isLoading = true);
    final traineeId = widget.trainee.id ?? '';

    try {
      // 1. جلب التمارين الذكية من Supabase
      final workoutRepo = getIt<WorkoutRepositoryV2>();
      final workouts = await workoutRepo.getAllWorkoutsForTrainee(traineeId);

      // فحص هل يوجد ملف PDF في خطط Supabase
      String? pdfUrl;
      String? pdfName;
      for (final w in workouts) {
        if (w.pdfAttachmentUrl != null && w.pdfAttachmentUrl!.isNotEmpty) {
          pdfUrl = w.pdfAttachmentUrl;
          pdfName = w.title;
          break;
        }
      }

      // 2. جلب الملف من السيرفر القديم إذا لم يوجد أو للتطابق
      int? exerciseId = widget.trainee.exerciseId;
      try {
        final api = getIt<ApiService>();
        final freshUser = await api.getLoggedUserData(traineeId);
        if (freshUser.exerciseId != null && freshUser.exerciseId != 0) {
          exerciseId = freshUser.exerciseId;
        }
      } catch (_) {}

      if (exerciseId != null && exerciseId != 0) {
        try {
          final legacyRepo = getIt<WorkoutSystemRepository>();
          final legRes = await legacyRepo.getWorkout(exerciseId);
          legRes.when(
            success: (model) {
              if (pdfUrl == null) {
                pdfUrl = model.url;
                pdfName = model.name;
              }
            },
            failure: (_) {},
          );
        } catch (_) {}
      }

      // 3. جلب الدايت من Supabase
      final dietRepo = getIt<DietRepositoryV2>();
      final diet = await dietRepo.getDietPlanForTrainee(traineeId);

      // 4. جلب وجبات السيرفر القديم
      List<dynamic> legacyFoodsList = [];
      try {
        final api = getIt<ApiService>();
        final foods = await api.getLoggedUserDiet(traineeId);
        legacyFoodsList = foods;
      } catch (_) {}

      // 5. جلب قائمة ملفات الـ PDF المتاحة للإسناد
      try {
        final legacyRepo = getIt<WorkoutSystemRepository>();
        final systemsRes = await legacyRepo.getWorkoutSystems();
        systemsRes.when(
          success: (list) => _availablePdfSystems = list,
          failure: (_) {},
        );
      } catch (_) {}

      if (mounted) {
        setState(() {
          _assignedWorkouts = workouts;
          _assignedPdfUrl = pdfUrl;
          _assignedPdfName = pdfName ?? 'خطة تدريبية معتمدة';
          _legacyExerciseId = exerciseId;
          _dietPlan = diet;
          _legacyFoods = legacyFoodsList;
          _isLoading = false;
        });
      }
    } catch (e) {
      log('Error loading trainee master profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── إجراءات التمارين الذكية ──────────────────────────────

  Future<void> _deleteWorkout(WorkoutModel workout) async {
    final confirmed = await _showConfirmDialog(
      title: 'إلغاء هذا اليوم التدريبي',
      message:
          'هل أنت متأكد من رغبتك في حذف وإلغاء جدول "${workout.title}" لهذا المتدرب نهائياً؟\nسيتم حذف جميع تمارينه المسندة.',
      confirmButtonText: 'حذف اليوم التدريبي',
      isDestructive: true,
    );

    if (confirmed == true) {
      final ok = await getIt<WorkoutRepositoryV2>().deleteWorkout(workout.id);
      if (ok) {
        setState(() {
          _assignedWorkouts.removeWhere((w) => w.id == workout.id);
        });
        _showSuccessSnackbar('تم حذف جدول "${workout.title}" بنجاح 🗑️');
      } else {
        _showErrorSnackbar('حدث خطأ أثناء محاولة حذف اليوم التدريبي');
      }
    }
  }

  // ─── إجراءات ملف الـ PDF ──────────────────────────────────

  Future<void> _cancelPdfAttachment() async {
    final confirmed = await _showConfirmDialog(
      title: 'إلغاء وسحب ملف الـ PDF',
      message:
          'هل أنت متأكد من إلغاء وسحب ملف الـ PDF المخصص لهذا المتدرب؟\nلن يظهر له أي ملف تدريبي بعد الآن حتى تقوم بتعيين ملف جديد.',
      confirmButtonText: 'إلغاء وسحب الملف',
      isDestructive: true,
    );

    if (confirmed == true) {
      final traineeId = widget.trainee.id ?? '';
      // 1. مسح من Supabase
      await getIt<WorkoutRepositoryV2>()
          .clearPdfAttachmentForTrainee(traineeId);

      // 2. مسح الكاش المحلي الخاص بهذا المتدرب
      await SharedPreferencesHelper.remove(
          'cached_workout_pdf_path_$traineeId');
      await SharedPreferencesHelper.remove('cached_workout_pdf_url_$traineeId');

      setState(() {
        _assignedPdfUrl = null;
        _assignedPdfName = null;
        _legacyExerciseId = null;
      });

      _showSuccessSnackbar('تم سحب وإلغاء ملف الـ PDF للمتدرب بنجاح 🗑️');
    }
  }

  void _openAssignPdfSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: 0.7.sh,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 45.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                const Icon(Icons.picture_as_pdf_rounded,
                    color: Color(0xFFE11D48)),
                SizedBox(width: 8.w),
                Text(
                  'اختيار ملف PDF للمتدرب من المكتبة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (_availablePdfSystems.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'لا توجد ملفات PDF في المكتبة حالياً',
                    style:
                        TextStyle(fontFamily: 'Cairo', color: Colors.grey[600]),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _availablePdfSystems.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (c, idx) {
                    final item = _availablePdfSystems[idx];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.15)),
                      ),
                      leading: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.picture_as_pdf_rounded,
                            color: Color(0xFFE11D48), size: 20),
                      ),
                      title: Text(
                        item.name ?? 'ملف تدريبي',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5.sp,
                        ),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _assignPdfSystemToTrainee(item);
                        },
                        child: Text(
                          'إسناد للمتدرب',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.5.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _assignPdfSystemToTrainee(WorkoutSystemModel system) async {
    final traineeId = widget.trainee.id ?? '';
    // 1. السيرفر القديم
    try {
      if (system.id != null) {
        await getIt<WorkoutSystemRepository>().addWorkoutForUser(
          workoutId: system.id!,
          userId: traineeId,
        );
      }
    } catch (_) {}

    // 2. تحديث Supabase
    if (system.url != null) {
      await getIt<WorkoutRepositoryV2>()
          .updatePdfAttachmentForTrainee(traineeId, system.url!);
    }

    setState(() {
      _assignedPdfUrl = system.url;
      _assignedPdfName = system.name;
      _legacyExerciseId = system.id;
    });

    _showSuccessSnackbar('تم إسناد ملف "${system.name}" للمتدرب بنجاح 📄✅');
  }

  // ─── إجراءات الخطة الغذائية ──────────────────────────────

  Future<void> _deleteEntireDiet() async {
    final confirmed = await _showConfirmDialog(
      title: 'إلغاء الخطة الغذائية بالكامل',
      message:
          'هل أنت متأكد من إلغاء وحذف الخطة الغذائية بالكامل لهذا المتدرب؟\nسيتم حذف جميع الوجبات والمكونات المحددة له.',
      confirmButtonText: 'إلغاء الخطة الغذائية',
      isDestructive: true,
    );

    if (confirmed == true) {
      final traineeId = widget.trainee.id ?? '';

      // 1. حذف من Supabase
      if (_dietPlan != null) {
        await getIt<DietRepositoryV2>().deleteDietPlan(_dietPlan!.id);
      }
      await getIt<DietRepositoryV2>().deleteDietPlanForTrainee(traineeId);

      // 2. حذف من السيرفر القديم
      try {
        final api = getIt<ApiService>();
        await api.removeAllUserFoods(traineeId);
      } catch (_) {}

      setState(() {
        _dietPlan = null;
        _legacyFoods.clear();
      });

      _showSuccessSnackbar('تم إلغاء الخطة الغذائية بالكامل للمتدرب 🥗🗑️');
    }
  }

  Future<void> _deleteMeal(MealModel meal) async {
    final confirmed = await _showConfirmDialog(
      title: 'إلغاء وجبة (${_getMealTitle(meal.mealType)})',
      message: 'هل أنت متأكد من حذف هذه الوجبة ومكوناتها من جدول هذا المتدرب؟',
      confirmButtonText: 'حذف الوجبة',
      isDestructive: true,
    );

    if (confirmed == true) {
      final ok = await getIt<DietRepositoryV2>().deleteMeal(meal.id);
      if (ok) {
        setState(() {
          if (_dietPlan != null) {
            _dietPlan!.meals.removeWhere((m) => m.id == meal.id);
          }
        });
        _showSuccessSnackbar('تم حذف الوجبة بنجاح 🗑️');
      } else {
        _showErrorSnackbar('حدث خطأ أثناء محاولة حذف الوجبة');
      }
    }
  }

  // ─── بناء الواجهات ──────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const AppBarBackButton(color: AppColors.black),
        title: Text(
          'الملف التدريبي الشامل 📋',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'تحديث البيانات',
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.newPrimaryColor),
            onPressed: _loadAllTraineeData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppColors.newPrimaryColor))
          : RefreshIndicator(
              onRefresh: _loadAllTraineeData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                children: [
                  // 1. بطاقة المتدرب الملوكية في رأس الصفحة
                  _buildTraineeHeroCard(),

                  SizedBox(height: 14.h),

                  // 2. شريط التبديل الثلاثي الأنيق (Segmented Switcher)
                  _buildSegmentedTabSwitcher(),

                  SizedBox(height: 16.h),

                  // 3. المحتوى حسب التبويب المختار
                  if (_selectedTab == 0) _buildSmartWorkoutsSection(),
                  if (_selectedTab == 1) _buildPdfPlanSection(),
                  if (_selectedTab == 2) _buildDietPlanSection(),

                  SizedBox(height: 30.h),
                ],
              ),
            ),
    );
  }

  // ─── 1. بطاقة المتدرب البصرية الملوكية ──────────────────────
  Widget _buildTraineeHeroCard() {
    final t = widget.trainee;
    final initialChar =
        (t.userName != null && t.userName!.isNotEmpty) ? t.userName![0] : 'U';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF102E50),
            Color(0xFF1A477A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF102E50).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // صورة المتدرب
              Container(
                width: 54.r,
                height: 54.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: (t.image != null && t.image!.isNotEmpty)
                      ? Image.network(
                          '${ApiEndPoints.usersImagesBaseUrl}${t.image!}',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildAvatarFallback(initialChar),
                        )
                      : _buildAvatarFallback(initialChar),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.userName ?? 'المتدرب',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16.5.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      t.email ?? 'لا يوجد بريد إلكتروني',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5.sp,
                        color: Colors.white70,
                      ),
                    ),
                    if (t.phone != null && t.phone!.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        '📞 ${t.phone}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // شارة الباقة
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  t.name ?? 'باقة نشطة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.5.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),
          const Divider(color: Colors.white24, height: 1),
          SizedBox(height: 12.h),

          // شريط أزرار الإجراءات السريعة للمتدرب
          Row(
            children: [
              // زر المحادثة الفورية
              Expanded(
                child: InkWell(
                  onTap: _openChatWithTrainee,
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 6.w),
                        Text(
                          'محادثة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // زر سجل الأداء
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.traineeProgress,
                      arguments: widget.trainee,
                    );
                  },
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.analytics_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 6.w),
                        Text(
                          'سجل الأداء',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String initialChar) {
    return Container(
      color: AppColors.newPrimaryColor,
      alignment: Alignment.center,
      child: Text(
        initialChar,
        style: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  void _openChatWithTrainee() {
    final t = widget.trainee;
    Navigator.pushNamed(
      context,
      Routes.chat,
      arguments: ChatUserModel(
        id: t.id ?? '',
        userName: t.userName ?? 'المتدرب',
        phoneNumber: t.phoneNumber ?? t.phone,
      ),
    );
  }

  // ─── 2. شريط التبديل الثلاثي ──────────────────────────────
  Widget _buildSegmentedTabSwitcher() {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          _buildSegmentItem(
            index: 0,
            icon: Icons.fitness_center_rounded,
            title: 'التمارين (${_assignedWorkouts.length})',
            activeColor: AppColors.newPrimaryColor,
          ),
          _buildSegmentItem(
            index: 1,
            icon: Icons.picture_as_pdf_rounded,
            title: _assignedPdfUrl != null ? 'ملف الـ PDF ✅' : 'ملف الـ PDF',
            activeColor: const Color(0xFFE11D48),
          ),
          _buildSegmentItem(
            index: 2,
            icon: Icons.restaurant_menu_rounded,
            title: 'الدايت (${_dietPlan?.meals.length ?? _legacyFoods.length})',
            activeColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentItem({
    required int index,
    required IconData icon,
    required String title,
    required Color activeColor,
  }) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15.sp,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 3. تبويب التمارين الذكية ──────────────────────────────
  Widget _buildSmartWorkoutsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الأيام التدريبية المسندة (${_assignedWorkouts.length})',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkoutBuilderScreen(
                        targetTraineeId: widget.trainee.id),
                  ),
                );
                _loadAllTraineeData();
              },
              icon:
                  const Icon(Icons.add_rounded, size: 16, color: Colors.white),
              label: Text(
                'إضافة تمرين',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.newPrimaryColor,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        if (_assignedWorkouts.isEmpty)
          Container(
            padding: EdgeInsets.all(28.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                Icon(Icons.fitness_center_rounded,
                    size: 44.sp, color: Colors.grey[400]),
                SizedBox(height: 10.h),
                Text(
                  'لا توجد أيام تدريبية مسندة لهذا المتدرب',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'اضغط على زر "إضافة تمرين" بالأعلى لتصميم خطة تفاعلية للمتدرب.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontFamily: 'Cairo', color: Colors.grey[600]),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _assignedWorkouts.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, idx) {
              final w = _assignedWorkouts[idx];
              return _buildWorkoutDayCard(w, idx);
            },
          ),
      ],
    );
  }

  Widget _buildWorkoutDayCard(WorkoutModel workout, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: index == 0,
          tilePadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          leading: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.newPrimaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: AppColors.newPrimaryColor,
                fontSize: 14.sp,
              ),
            ),
          ),
          title: Text(
            workout.title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.5.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),
              Text(
                '${workout.exercises.length} تمارين • ${workout.targetMuscles.join("، ")}',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.5.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // زر تعديل اليوم التدريبي
              IconButton(
                tooltip: 'تعديل هذا اليوم التدريبي',
                icon: const Icon(Icons.edit_note_rounded,
                    color: AppColors.newPrimaryColor, size: 22),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutBuilderScreen(
                        targetTraineeId: widget.trainee.id,
                      ),
                    ),
                  );
                  _loadAllTraineeData();
                },
              ),
              // زر حذف اليوم
              IconButton(
                tooltip: 'إلغاء هذا اليوم التدريبي',
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 22),
                onPressed: () => _deleteWorkout(workout),
              ),
              const Icon(Icons.expand_more_rounded, color: Colors.grey),
            ],
          ),
          children: [
            const Divider(height: 1, color: Color(0xFFF1F3F5)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...workout.exercises.map((e) => _buildExerciseRow(e)),
                  SizedBox(height: 10.h),
                  // زر إلغاء صريح أسفل اليوم
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    onPressed: () => _deleteWorkout(workout),
                    icon: const Icon(Icons.delete_forever_rounded, size: 18),
                    label: Text(
                      'إلغاء وحذف جدول "${workout.title}" من المتدرب 🗑️',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5.sp,
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

  Widget _buildExerciseRow(ExerciseModel ex) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: const Icon(Icons.fitness_center_rounded,
                size: 16, color: Colors.black54),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ex.name,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${ex.targetSets} مجموعات × ${ex.targetRepsRange} عَدة • راحة ${ex.restSeconds}s • RIR: ${ex.rir}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.5.sp,
                    color: Colors.grey[600],
                  ),
                ),
                if (ex.technicalTip != null && ex.technicalTip!.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    '💡 ${ex.technicalTip}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10.sp,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 4. تبويب ملف الـ PDF المعتمد ──────────────────────────
  Widget _buildPdfPlanSection() {
    final hasPdf = _assignedPdfUrl != null && _assignedPdfUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ملف الخطة التدريبية المعتمدة (PDF)',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 10.h),
        if (hasPdf) ...[
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: const Color(0xFFE11D48).withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.picture_as_pdf_rounded,
                          color: Color(0xFFE11D48), size: 28),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _assignedPdfName ?? 'ملف الخطة التدريبية',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            _legacyExerciseId != null
                                ? 'نظام رقم #$_legacyExerciseId • معتمد للمتدرب حالياً 📄'
                                : 'ملف PDF فعال ومعتمد للمتدرب حالياً 📄',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11.5.sp,
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // أزرار التحكم بالـ PDF
                Row(
                  children: [
                    // زر معاينة الملف
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ExerciseScreen(pdfUrl: _assignedPdfUrl),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility_rounded,
                            size: 16, color: Colors.white),
                        label: Text(
                          'معاينة الملف',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.newPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // زر استبدال الملف
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openAssignPdfSheet,
                        icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                        label: Text(
                          'استبدال الملف',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF102E50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                // زر إلغاء وسحب الملف
                ElevatedButton.icon(
                  onPressed: _cancelPdfAttachment,
                  icon: const Icon(Icons.delete_forever_rounded,
                      size: 18, color: Colors.white),
                  label: Text(
                    'إلغاء وسحب ملف الـ PDF من المتدرب 🗑️',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: EdgeInsets.all(26.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                Icon(Icons.picture_as_pdf_outlined,
                    size: 46.sp, color: Colors.grey[400]),
                SizedBox(height: 12.h),
                Text(
                  'لا يوجد ملف PDF مخصص لهذا المتدرب حالياً',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'يمكنك إسناد ملف خطة معتمدة للمتدرب بنقرة واحدة من المكتبة.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontFamily: 'Cairo', color: Colors.grey[600]),
                ),
                SizedBox(height: 16.h),
                ElevatedButton.icon(
                  onPressed: _openAssignPdfSheet,
                  icon: const Icon(Icons.upload_file_rounded,
                      color: Colors.white, size: 18),
                  label: Text(
                    'إسناد ملف PDF من المكتبة الآن 📄',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ─── 5. تبويب الخطة الغذائية والوجبات ─────────────────────────
  Widget _buildDietPlanSection() {
    final hasDiet = _dietPlan != null && _dietPlan!.meals.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الخطة الغذائية والوجبات 🥗',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            if (hasDiet)
              TextButton.icon(
                onPressed: _deleteEntireDiet,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 18),
                label: Text(
                  'إلغاء الخطة كاملة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 10.h),
        if (!hasDiet && _legacyFoods.isEmpty)
          Container(
            padding: EdgeInsets.all(26.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                Icon(Icons.restaurant_menu_rounded,
                    size: 46.sp, color: Colors.grey[400]),
                SizedBox(height: 10.h),
                Text(
                  'لا توجد خطة غذائية مسندة للمتدرب حالياً',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'يمكنك تعيين وجبات وماكروز للمتدرب من شاشة إدارة الدايت.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontFamily: 'Cairo', color: Colors.grey[600]),
                ),
                SizedBox(height: 16.h),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      Routes.adminUserMeals,
                      arguments: widget.trainee.id,
                    ).then((_) => _loadAllTraineeData());
                  },
                  icon: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 18),
                  label: Text(
                    'تعيين وجبات للمتدرب الآن 🥗',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          )
        else ...[
          // بطاقة ملخص الماكروز إذا كان موجوداً في Supabase
          if (_dietPlan != null) ...[
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMacroCapsule(
                      'سعرات',
                      '${_dietPlan!.targetCalories.toInt()} kcal',
                      const Color(0xFFF59E0B)),
                  _buildMacroCapsule(
                      'بروتين',
                      '${_dietPlan!.targetProtein.toStringAsFixed(0)}g',
                      const Color(0xFFEF4444)),
                  _buildMacroCapsule(
                      'كارب',
                      '${_dietPlan!.targetCarbs.toStringAsFixed(0)}g',
                      const Color(0xFF3B82F6)),
                  _buildMacroCapsule(
                      'دهون',
                      '${_dietPlan!.targetFats.toStringAsFixed(0)}g',
                      const Color(0xFF10B981)),
                ],
              ),
            ),
            SizedBox(height: 12.h),
          ],

          // قائمة الوجبات
          if (_dietPlan != null)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _dietPlan!.meals.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, idx) {
                final meal = _dietPlan!.meals[idx];
                return _buildMealCard(meal);
              },
            ),
        ],
      ],
    );
  }

  Widget _buildMacroCapsule(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.5.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10.5.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(MealModel meal) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.restaurant_rounded,
                        color: Color(0xFF10B981), size: 18),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    _getMealTitle(meal.mealType),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              IconButton(
                tooltip: 'إلغاء هذه الوجبة',
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 20),
                onPressed: () => _deleteMeal(meal),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 4.h,
            children: meal.ingredients
                .map((i) => Chip(
                      label: Text(
                        '${i.name} (${i.quantityUnit})',
                        style:
                            TextStyle(fontFamily: 'Cairo', fontSize: 10.5.sp),
                      ),
                      backgroundColor: const Color(0xFFF1F3F5),
                      padding: EdgeInsets.zero,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  String _getMealTitle(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return 'وجبة الإفطار 🍳';
      case 'lunch':
        return 'وجبة الغداء 🍗';
      case 'dinner':
        return 'وجبة العشاء 🥗';
      case 'snack':
        return 'وجبة خفيفة (سناك) 🍎';
      default:
        return 'وجبة $type';
    }
  }

  // ─── حوار التأكيد العام (Confirmation Dialog) ─────────────
  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmButtonText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(
              isDestructive
                  ? Icons.warning_amber_rounded
                  : Icons.info_outline_rounded,
              color: isDestructive ? Colors.red : AppColors.newPrimaryColor,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13.sp,
            color: Colors.grey[800],
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDestructive ? Colors.red : AppColors.newPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmButtonText,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _showErrorSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }
}
