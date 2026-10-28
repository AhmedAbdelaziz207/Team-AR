import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/features/coach_v2/services/workout_template_service.dart';
import 'package:team_ar/features/workout_systems/logic/workout_system_cubit.dart';
import 'package:team_ar/features/workout_systems/logic/workout_system_state.dart';
import 'package:team_ar/features/workout_systems/widget/workout_system_card.dart';
import 'create_workout_system.dart';

class WorkoutSystemsScreen extends StatefulWidget {
  const WorkoutSystemsScreen({super.key});

  @override
  State<WorkoutSystemsScreen> createState() => _WorkoutSystemsScreenState();
}

class _WorkoutSystemsScreenState extends State<WorkoutSystemsScreen> {
  // 0: الجداول التفاعلية والقوالب الذكية ⚡ | 1: مكتبة ملفات الـ PDF المعتمدة 📄
  int _selectedTab = 0;

  List<WorkoutTemplateModel> _hubTemplates = [];
  bool _isLoadingHubTemplates = false;

  @override
  void initState() {
    super.initState();
    context.read<WorkoutSystemCubit>().getWorkoutSystems();
    _loadHubTemplates();
  }

  Future<void> _loadHubTemplates({bool force = false}) async {
    setState(() => _isLoadingHubTemplates = true);
    try {
      final templates =
          await WorkoutTemplateService.getAllTemplates(forceRefresh: force);
      if (mounted) {
        setState(() {
          _hubTemplates = templates;
          _isLoadingHubTemplates = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingHubTemplates = false);
    }
  }

  Future<void> _refreshAll() async {
    context.read<WorkoutSystemCubit>().refreshWorkoutSystems();
    await _loadHubTemplates(force: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: const SizedBox.shrink(),
        title: Text(
          'مركز إدارة التمارين والخطط 🏋️‍♂️',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            color: AppColors.black,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث كافة البيانات',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.black),
            onPressed: _refreshAll,
          ),
          IconButton(
            tooltip: 'فتح مصمم التمارين الذكي',
            icon: const Icon(Icons.tune_rounded,
                color: AppColors.newPrimaryColor),
            onPressed: () => Navigator.pushNamed(context, Routes.workoutBuilder)
                .then((_) => _refreshAll()),
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط التبديل العلوي بين الجداول التفاعلية ومكتبة الـ PDF
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
                      onTap: () => setState(() => _selectedTab = 0),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: _selectedTab == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.fitness_center_rounded,
                                  size: 16.sp,
                                  color: _selectedTab == 0
                                      ? AppColors.newPrimaryColor
                                      : Colors.grey[600],
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  'جداول التمارين الذكية ⚡',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedTab == 0
                                        ? AppColors.newPrimaryColor
                                        : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTab = 1),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: _selectedTab == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.picture_as_pdf_rounded,
                                  size: 16.sp,
                                  color: _selectedTab == 1
                                      ? const Color(0xFFE11D48)
                                      : Colors.grey[600],
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  'مكتبة ملفات الـ PDF 📄',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedTab == 1
                                        ? const Color(0xFFE11D48)
                                        : Colors.grey[700],
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
              ),
            ),
          ),

          // المحتوى
          Expanded(
            child: _selectedTab == 0
                ? _buildInteractiveHubTab()
                : _buildPdfLibraryTab(),
          ),
        ],
      ),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton.extended(
              heroTag: 'fab_smart_builder',
              onPressed: () =>
                  Navigator.pushNamed(context, Routes.workoutBuilder)
                      .then((_) => _refreshAll()),
              elevation: 4,
              backgroundColor: AppColors.newPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'بناء جدول ذكي',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            )
          : FloatingActionButton.extended(
              heroTag: 'fab_pdf_upload',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => WorkoutSystemCubit(),
                      child: const CreateWorkoutScreen(),
                    ),
                  ),
                ).then((value) {
                  if (context.mounted) {
                    _refreshAll();
                  }
                  log('refreshed pdf library');
                });
              },
              elevation: 4,
              backgroundColor: const Color(0xFFE11D48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
              label: Text(
                'رفع ملف PDF',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
    );
  }

  // ─── تبويب الجداول التفاعلية والقوالب الذكية ───
  Widget _buildInteractiveHubTab() {
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        children: [
          // بطاقة بصرية رئيسية لمصمم التمارين
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1E293B),
                  Color(0xFF0F172A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
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
                        color: AppColors.newPrimaryColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: AppColors.newPrimaryColor,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'مصمم الجداول التفاعلية ⚡',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15.5.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  'أنشئ جداول تمارين احترافية للمتدربين بدقة وتفصيل (مجموعات، تكرارات، زوايا، فيديوهات يوتيوب، و RIR)، أو اختر من مكتبة التمارين بنقرة واحدة.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    color: const Color(0xFFCBD5E1),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16.h),
                Material(
                  color: AppColors.newPrimaryColor,
                  borderRadius: BorderRadius.circular(12.r),
                  elevation: 0,
                  child: InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, Routes.workoutBuilder)
                            .then((_) => _refreshAll()),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      width: double.infinity,
                      height: 48.h,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_circle_outline_rounded,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'فتح مصمم التمارين الذكي',
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
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // بطاقات الإجراءات السريعة
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.person_add_alt_1_rounded,
                  iconColor: AppColors.newPrimaryColor,
                  title: 'إسناد لمتدرب 👤',
                  subtitle: 'اختر متدرباً وصمم له جدولاً مخصصاً',
                  onTap: () => Navigator.pushNamed(
                          context, Routes.workoutBuilder,
                          arguments: 0)
                      .then((_) => _refreshAll()),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.bookmark_added_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: 'مكتبة التمارين 📚',
                  subtitle: 'جداول Push/Pull/Legs الجاهزة',
                  onTap: () => Navigator.pushNamed(
                          context, Routes.workoutBuilder,
                          arguments: 1)
                      .then((_) => _refreshAll()),
                ),
              ),
            ],
          ),

          // استعراض حي لقوالب مكتبة التمارين المحدثة
          if (_isLoadingHubTemplates)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child:
                    CircularProgressIndicator(color: AppColors.newPrimaryColor),
              ),
            )
          else if (_hubTemplates.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'قوالب التمارين في المكتبة (${_hubTemplates.length}) 📚',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(
                          context, Routes.workoutBuilder,
                          arguments: 1)
                      .then((_) => _refreshAll()),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                  label: const Text('عرض الكل',
                      style: TextStyle(
                          fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ..._hubTemplates.take(4).map((tmpl) {
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border:
                      Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                ),
                child: ListTile(
                  onTap: () => Navigator.pushNamed(
                          context, Routes.workoutBuilder,
                          arguments: 1)
                      .then((_) => _refreshAll()),
                  leading: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.newPrimaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.fitness_center_rounded,
                        color: AppColors.newPrimaryColor, size: 18),
                  ),
                  title: Text(
                    tmpl.title,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${tmpl.exercises.length} تمارين • ${tmpl.targetMuscles.join("، ")}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: Colors.grey),
                ),
              );
            }),
          ],

          SizedBox(height: 16.h),

          // بطاقة التوافق والتكامل الذكي
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.sync_alt_rounded,
                        color: const Color(0xFF3B82F6), size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'نظام متكامل ومرونة مطلقة (Hybrid)',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  'يمكنك في أي وقت الاختيار بين:\n'
                  '• جدول تفاعلي ذكي 🏋️ (يدعم تسجيل الأوزان والعدادات بالتطبيق)\n'
                  '• خطة PDF سريعة 📄 (ربط مباشر بملفات مكتبتك المركزية)\n'
                  '• نظام هجين 🌟 (جدول تفاعلي مع ملف الـ PDF كمرجع معتمد)',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5.sp,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(height: 10.h),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10.5.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── تبويب مكتبة ملفات الـ PDF المعتمدة ───
  Widget _buildPdfLibraryTab() {
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<WorkoutSystemCubit>().refreshWorkoutSystems(),
      child: BlocBuilder<WorkoutSystemCubit, WorkoutSystemState>(
        builder: (context, state) {
          if (state is WorkoutSystemLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WorkoutSystemFailure) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                SizedBox(height: 80.h),
                Center(
                  child: Text(
                    state.errorModel.getErrorsMessage() ?? "Unknown Error",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is WorkoutSystemLoadSuccess) {
            if (state.data.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  SizedBox(height: 80.h),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 70.sp,
                          color: AppColors.grey.withValues(alpha: 0.4),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          "لا توجد ملفات PDF مسجلة حالياً بالمكتبة",
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "اضغط على زر 'رفع ملف PDF' أدناه لإضافة خطة معتمدة للمكتبة",
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.grey[500],
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: state.data.length + 1,
              padding: EdgeInsets.only(
                  left: 14.w, right: 14.w, top: 10.h, bottom: 90.h),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFFE11D48).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: Color(0xFFE11D48), size: 20),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'المكتبة المركزية (${state.data.length} خطط PDF): يتم ربط هذه الملفات بالمتدربين بنقرة واحدة من مصمم التمارين دون أي تكرار في التخزين.',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11.sp,
                              color: const Color(0xFF9F1239),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final item = state.data[index - 1];
                return WorkoutSystemCard(
                  name: item.name,
                  workout: item,
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
