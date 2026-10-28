import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/features/home/admin/data/trainee_model.dart';
import 'package:team_ar/features/home/admin/repos/trainees_repository.dart';
import 'package:team_ar/features/workout_systems/model/workout_system_model.dart';
import 'package:team_ar/features/workout_systems/repo/workout_system_repository.dart';
import '../../workout_v2/models/exercise_model.dart';
import '../../workout_v2/models/workout_model.dart';
import '../../workout_v2/repos/workout_repository_v2.dart';
import '../services/workout_template_service.dart';

class WorkoutBuilderScreen extends StatefulWidget {
  final String? targetTraineeId;
  final int? initialMode;

  const WorkoutBuilderScreen({
    super.key,
    this.targetTraineeId,
    this.initialMode,
  });

  @override
  State<WorkoutBuilderScreen> createState() => _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends State<WorkoutBuilderScreen> {
  // 0: إسناد لمتدرب محدد | 1: مكتبة القوالب (للاستخدام لاحقاً)
  int _activeMode = 0;

  // في وضع القوالب: 0: استعراض القوالب المحفوظة | 1: صياغة قالب جديد
  int _templateSubTab = 0;

  // نوع الخطة: 0: تفاعلي ذكي 🏋️ | 1: خطة ملف PDF فقط 📄 | 2: نظام هجين متكامل 🌟
  int _planType = 0;

  TraineeModel? _selectedTrainee;
  List<TraineeModel> _allTrainees = [];
  bool _isLoadingTrainees = false;

  List<WorkoutTemplateModel> _allTemplates = [];
  bool _isLoadingTemplates = false;

  // إدارة ملفات الـ PDF المركزية (Zero Storage Overhead)
  WorkoutSystemModel? _selectedPdfSystem;
  List<WorkoutSystemModel> _availablePdfSystems = [];
  bool _isLoadingPdfSystems = false;
  bool _isUploadingPdf = false;

  // حقول الخطة التدريبية
  final _titleCtrl = TextEditingController(text: 'Push Day');
  final _introVideoCtrl = TextEditingController();
  final _pdfUrlCtrl = TextEditingController();
  final List<String> _selectedMuscles = ['الصدر', 'الترايسبس'];
  final List<_ExerciseDraft> _exercises = [];

  bool _isSaving = false;
  String? _appliedTemplateId;
  String? _appliedTemplateTitle;
  String? _editingTemplateId;
  String _selectedDayLabel = 'اليوم الأول';
  final List<String> _daysList = [
    'اليوم الأول',
    'اليوم الثاني',
    'اليوم الثالث',
    'اليوم الرابع',
    'اليوم الخامس',
    'اليوم السادس',
  ];

  // التحقق مما إذا كان التمرين الحالي موجوداً بالفعل في مكتبة التمارين
  bool get _isAlreadyInTemplates {
    final currentTitle = _titleCtrl.text.trim();
    if (currentTitle.isEmpty) return false;
    if (_appliedTemplateId != null &&
        _appliedTemplateTitle != null &&
        _appliedTemplateTitle!.trim().toLowerCase() ==
            currentTitle.toLowerCase()) {
      return true;
    }
    return _allTemplates.any((t) =>
        (_appliedTemplateId != null && t.id == _appliedTemplateId) ||
        t.title.trim().toLowerCase() == currentTitle.toLowerCase());
  }

  // مزود آمن لصور المتدربين لتجنب أخطاء الـ URI المنسوبة لـ file:/// أو المسارات النسبية
  ImageProvider? _getTraineeImageProvider(String? image) {
    if (image == null || image.trim().isEmpty) return null;
    final clean = image.trim();
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return NetworkImage(clean);
    }
    final relative = clean.replaceFirst('file:///', '');
    return NetworkImage('${ApiEndPoints.usersImagesBaseUrl}$relative');
  }

  final List<String> _availableMuscles = [
    'الصدر',
    'الظهر',
    'الأكتاف',
    'البايسبس',
    'الترايسبس',
    'الأرجل',
    'البطن',
    'السمانة',
  ];

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(_onTitleChanged);
    _loadTrainees();
    if (widget.initialMode != null) {
      _activeMode = widget.initialMode!;
    }
    _loadTemplates();
    _loadPdfSystems();
  }

  void _onTitleChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _titleCtrl.removeListener(_onTitleChanged);
    _titleCtrl.dispose();
    _introVideoCtrl.dispose();
    _pdfUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTrainees() async {
    setState(() => _isLoadingTrainees = true);
    try {
      final res = await getIt<TraineesRepository>().getAllTrainees();
      res.when(
        success: (list) {
          if (mounted) {
            final valid =
                list.where((u) => u.role?.toLowerCase() != 'admin').toList();
            setState(() {
              _allTrainees = valid;
              _isLoadingTrainees = false;

              // إذا تم فتح الشاشة بمعرّف متدرب محدد، نختاره تلقائياً
              if (widget.targetTraineeId != null &&
                  widget.targetTraineeId!.isNotEmpty) {
                final match = _allTrainees
                    .where((t) => t.id == widget.targetTraineeId)
                    .firstOrNull;
                final chosen = match ??
                    TraineeModel.fromJson({
                      'id': widget.targetTraineeId,
                      'userName': 'المتدرب المحدد',
                    });
                _selectTrainee(chosen);
                _activeMode = 0;
              }
            });
          }
        },
        failure: (_) {
          if (mounted) setState(() => _isLoadingTrainees = false);
        },
      );
    } catch (_) {
      if (mounted) setState(() => _isLoadingTrainees = false);
    }
  }

  void _selectTrainee(TraineeModel trainee) {
    setState(() {
      _selectedTrainee = trainee;
      _exercises.clear();
      _titleCtrl.text = 'Push Day';
      _selectedMuscles.clear();
      _selectedMuscles.addAll(['الصدر', 'الترايسبس']);
      _introVideoCtrl.clear();
      _pdfUrlCtrl.clear();
      _selectedPdfSystem = null;
      _planType = 0;
    });
    if (trainee.id != null && trainee.id!.isNotEmpty) {
      _loadTraineeExistingWorkout(trainee.id!);
    }
  }

  Future<void> _loadTraineeExistingWorkout(String traineeId) async {
    try {
      final repo = getIt<WorkoutRepositoryV2>();
      final existing = await repo.getWorkoutForTrainee(traineeId);
      if (mounted && existing != null) {
        setState(() {
          _titleCtrl.text = existing.title;
          _selectedMuscles.clear();
          _selectedMuscles.addAll(existing.targetMuscles);
          if (existing.introVideoUrl != null &&
              existing.introVideoUrl!.isNotEmpty) {
            _introVideoCtrl.text = existing.introVideoUrl!;
          }
          if (existing.pdfAttachmentUrl != null &&
              existing.pdfAttachmentUrl!.isNotEmpty) {
            _pdfUrlCtrl.text = existing.pdfAttachmentUrl!;
            final match = _availablePdfSystems.firstWhere(
              (s) => s.url == existing.pdfAttachmentUrl,
              orElse: () => WorkoutSystemModel(
                name: 'مرفق المتدرب (PDF)',
                url: existing.pdfAttachmentUrl,
              ),
            );
            _selectedPdfSystem = match;
            _planType = existing.exercises.isEmpty ? 1 : 2;
          } else {
            _planType = 0;
            _selectedPdfSystem = null;
          }

          _exercises.clear();
          for (final ex in existing.exercises) {
            _exercises.add(_ExerciseDraft(
              name: ex.name,
              technicalTip: ex.technicalTip ?? '',
              videoUrl: ex.videoGuideUrl,
              targetSets: ex.targetSets,
              targetRepsRange: ex.targetRepsRange,
              restSeconds: ex.restSeconds,
              rir: ex.rir,
              tempo: ex.tempo,
            ));
          }
        });
      }
    } catch (e) {
      log('Error loading existing trainee workout: $e');
    }
  }

  Future<void> _loadTemplates({bool forceRefresh = false}) async {
    setState(() => _isLoadingTemplates = true);
    try {
      final templates = await WorkoutTemplateService.getAllTemplates(
          forceRefresh: forceRefresh);
      if (mounted) {
        setState(() {
          _allTemplates = templates;
          _isLoadingTemplates = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingTemplates = false);
    }
  }

  Future<void> _loadPdfSystems() async {
    setState(() => _isLoadingPdfSystems = true);
    try {
      final res = await getIt<WorkoutSystemRepository>().getWorkoutSystems();
      res.when(
        success: (list) {
          if (mounted) {
            setState(() {
              _availablePdfSystems = list;
              _isLoadingPdfSystems = false;
            });
          }
        },
        failure: (_) {
          if (mounted) setState(() => _isLoadingPdfSystems = false);
        },
      );
    } catch (_) {
      if (mounted) setState(() => _isLoadingPdfSystems = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const AppBarBackButton(color: AppColors.black),
        title: Text(
          _activeMode == 0 ? 'إسناد جدول تمرين لمتدرب' : 'مكتبة التمارين 📚',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16.5.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. شريط التبديل العلوي الصريح والواضح (Tabs Switcher)
          _buildModeSelector(),

          // 2. المحتوى التفاعلي حسب الوضع المختار مع دعم السحب للتحديث الذكي
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (_activeMode == 1) {
                  await _loadTemplates(forceRefresh: true);
                } else {
                  await _loadTrainees();
                  if (_selectedTrainee?.id != null) {
                    await _loadTraineeExistingWorkout(_selectedTrainee!.id!);
                  }
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: _activeMode == 0
                    ? _buildTraineeAssignmentContent()
                    : _buildTemplatesLibraryContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 1. شريط التبديل العلوي الصريح ──────────────────────────
  Widget _buildModeSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // خيار 1: إسناد لمتدرب
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _activeMode = 0),
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: _activeMode == 0
                      ? AppColors.newPrimaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_pin_rounded,
                      size: 18.sp,
                      color: _activeMode == 0 ? Colors.white : Colors.grey[700],
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'إسناد لمتدرب',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color:
                            _activeMode == 0 ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          // خيار 2: مكتبة القوالب
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _activeMode = 1),
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: _activeMode == 1
                      ? AppColors.newPrimaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.library_books_rounded,
                      size: 18.sp,
                      color: _activeMode == 1 ? Colors.white : Colors.grey[700],
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'مكتبة التمارين',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color:
                            _activeMode == 1 ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. محتوى وضع الإسناد لمتدرب (Trainee Assignment Mode) ───────
  Widget _buildTraineeAssignmentContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // كارت اختيار المتدرب الذكي (بدون كتابة ID نهائياً)
        _buildSmartTraineePickerCard(),

        SizedBox(height: 14.h),

        // شريط اختيار نوع الخطة التدريبية (تفاعلي ذكي | خطة PDF فقط | هجين متكامل)
        _buildPlanTypeSelector(),

        SizedBox(height: 14.h),

        // شريط تسريع العمل (قوالب سريعة + نسخ من متدرب آخر) - فقط لو تفاعلي أو هجين
        if (_planType != 1) ...[
          _buildQuickAssistToolbar(),
          SizedBox(height: 14.h),
        ],

        // بيانات الخطة (العنوان، الفيديو العام)
        _buildWorkoutMetadataSection(),

        // قسم إدارة ملف الـ PDF المرفق (مكتبة مركزية + رفع بدون روابط نصية)
        if (_planType == 1 || _planType == 2) ...[
          SizedBox(height: 14.h),
          _buildPdfAttachmentSection(),
        ],

        // العضلات والتمارين (إذا كان تفاعلي أو هجين)
        if (_planType != 1) ...[
          SizedBox(height: 16.h),
          _buildMusclesSelectorSection(),
          SizedBox(height: 16.h),
          _buildExercisesListSection(),
          SizedBox(height: 20.h),
        ] else ...[
          SizedBox(height: 16.h),
          _buildPdfOnlyPlanSummaryCard(),
          SizedBox(height: 20.h),
        ],

        // زر الحفظ الرئيسي للمتدرب
        SizedBox(
          height: 52.h,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveAndPublishWorkoutToTrainee,
            icon: _isSaving
                ? const SizedBox.shrink()
                : const Icon(Icons.rocket_launch_rounded, color: Colors.white),
            label: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    _selectedTrainee != null
                        ? (_planType == 1
                            ? 'حفظ وتفعيل خطة الـ PDF لـ (${_selectedTrainee!.userName ?? _selectedTrainee!.name ?? "المتدرب"}) 🚀'
                            : 'حفظ وتفعيل الجدول لـ (${_selectedTrainee!.userName ?? _selectedTrainee!.name ?? "المتدرب"}) 🚀')
                        : 'اختر متدرباً لتفعيل الخطة له 🚀',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedTrainee != null
                  ? AppColors.newPrimaryColor
                  : Colors.grey[400],
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 2,
            ),
          ),
        ),

        if (!_isAlreadyInTemplates) ...[
          SizedBox(height: 10.h),

          // خيار إضافي: حفظ نسخة من هذا التمرين في مكتبة التمارين
          OutlinedButton.icon(
            onPressed: _showSaveAsTemplateDialog,
            icon: Icon(Icons.bookmark_add_rounded,
                size: 18.sp, color: AppColors.newPrimaryColor),
            label: Text(
              'حفظ نسخة من هذه الخطة في مكتبة التمارين 💾',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.5.sp,
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
        ],

        SizedBox(height: 24.h),
      ],
    );
  }

  // كارت اختيار المتدرب التفاعلي (وداعاً لكتابة الـ ID يدوياً!)
  Widget _buildSmartTraineePickerCard() {
    if (_selectedTrainee != null) {
      final t = _selectedTrainee!;
      return Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.newPrimaryColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.newPrimaryColor.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // صورة المتدرب
            CircleAvatar(
              radius: 24.r,
              backgroundColor:
                  AppColors.newPrimaryColor.withValues(alpha: 0.12),
              backgroundImage: _getTraineeImageProvider(t.image),
              onBackgroundImageError: _getTraineeImageProvider(t.image) != null
                  ? (exception, stackTrace) {}
                  : null,
              child: _getTraineeImageProvider(t.image) == null
                  ? Icon(Icons.person,
                      color: AppColors.newPrimaryColor, size: 26.sp)
                  : null,
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
                          t.userName ?? t.name ?? 'متدرب',
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
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'المتدرب المستهدف',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    t.email ?? t.phone ?? t.phoneNumber ?? 'مسجل في المنصة',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _openTraineePickerSheet(
                title: 'تغيير المتدرب',
                onSelected: (trainee) {
                  _selectTrainee(trainee);
                },
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.newPrimaryColor,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
              ),
              child: const Text('تغيير',
                  style: TextStyle(
                      fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    // إذا لم يتم اختيار متدرب بعد:
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openTraineePickerSheet(
          title: 'اختر المتدرب لتخصيص الخطة له',
          onSelected: (trainee) {
            _selectTrainee(trainee);
          },
        ),
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: AppColors.newPrimaryColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
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
                  color: AppColors.newPrimaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_search_rounded,
                    color: AppColors.newPrimaryColor, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اضغط لاختيار المتدرب من القائمة 👥',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'اختر المتدرب بنقرة واحدة من قائمة المشتركين لتفعيل الجدول له مباشرة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14.sp, color: AppColors.newPrimaryColor),
            ],
          ),
        ),
      ),
    );
  }

  // شريط تسريع إعداد الخطة (مكتبة القوالب + نسخ من متدرب آخر)
  Widget _buildQuickAssistToolbar() {
    return Container(
      padding: EdgeInsets.all(12.w),
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
              Icon(Icons.auto_awesome_rounded,
                  color: const Color(0xFFD97706), size: 17.sp),
              SizedBox(width: 6.w),
              Text(
                'تسريع إعداد الخطة (عدم تكرار البيانات)',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              // اختيار من مكتبة القوالب
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showApplyTemplateSheet,
                  icon: Icon(Icons.library_books_rounded, size: 16.sp),
                  label: Text(
                    'مكتبة التمارين 📚',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.newPrimaryColor.withValues(alpha: 0.1),
                    foregroundColor: AppColors.newPrimaryColor,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      side: BorderSide(
                        color:
                            AppColors.newPrimaryColor.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // نسخ من متدرب آخر
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openCloneFromAnotherTraineeFlow,
                  icon: Icon(Icons.copy_all_rounded, size: 16.sp),
                  label: Text(
                    'نسخ متدرب آخر 👥',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF0284C7).withValues(alpha: 0.1),
                    foregroundColor: const Color(0xFF0284C7),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      side: BorderSide(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                      ),
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

  // ─── 3. محتوى وضع مكتبة القوالب (Templates Library Mode) ────────
  Widget _buildTemplatesLibraryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // شريط التنقل العلوي بين استعراض القوالب وصياغة قالب جديد بدون التمرير الطويل
        Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _templateSubTab = 0),
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: _templateSubTab == 0
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: _templateSubTab == 0
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_special_rounded,
                          size: 18.sp,
                          color: _templateSubTab == 0
                              ? AppColors.newPrimaryColor
                              : Colors.grey[600],
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'التمارين المحفوظة (${_allTemplates.length})',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.bold,
                            color: _templateSubTab == 0
                                ? AppColors.newPrimaryColor
                                : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _templateSubTab = 1),
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: _templateSubTab == 1
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: _templateSubTab == 1
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          size: 18.sp,
                          color: _templateSubTab == 1
                              ? const Color(0xFF10B981)
                              : Colors.grey[600],
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'إضافة جدول جديد ➕',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.bold,
                            color: _templateSubTab == 1
                                ? const Color(0xFF10B981)
                                : Colors.grey[700],
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

        SizedBox(height: 14.h),

        if (_templateSubTab == 0) ...[
          // ─── وضع استعراض القوالب المحفوظة ───
          // بطاقة سريعة للبدء بصياغة قالب جديد
          InkWell(
            onTap: () => setState(() => _templateSubTab = 1),
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.newPrimaryColor.withValues(alpha: 0.08),
                    const Color(0xFF10B981).withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: AppColors.newPrimaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: const BoxDecoration(
                      color: AppColors.newPrimaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 20),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'صياغة وتصميم جدول تدريبي جديد 🏋️‍♂️',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'اضغط هنا لصياغة جدول عام وحفظه للرجوع إليه وتطبيقه لاحقاً',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 16.sp, color: AppColors.newPrimaryColor),
                ],
              ),
            ),
          ),

          SizedBox(height: 14.h),

          // قائمة التمارين المحفوظة بالمكتبة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'التمارين المتوفرة بالمكتبة (${_allTemplates.length})',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                onPressed: () => _loadTemplates(forceRefresh: true),
                tooltip: 'تحديث المكتبة',
              ),
            ],
          ),

          SizedBox(height: 8.h),

          if (_isLoadingTemplates)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child:
                    CircularProgressIndicator(color: AppColors.newPrimaryColor),
              ),
            )
          else if (_allTemplates.isEmpty)
            Container(
              padding: EdgeInsets.all(28.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 40.sp, color: Colors.grey[400]),
                  SizedBox(height: 8.h),
                  Text(
                    'لا توجد جداول تمارين حالياً بالمكتبة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'اضغط على زر "إضافة جدول جديد" بالأعلى لإنشاء أول جدول جاهز.',
                    style:
                        TextStyle(fontFamily: 'Cairo', color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _allTemplates.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, idx) {
                final tmpl = _allTemplates[idx];
                return _buildTemplateLibraryItemCard(tmpl);
              },
            ),
        ] else ...[
          // ─── وضع صياغة قالب جديد (Form مباشرة في الأعلى دون سكرول) ───
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mode_edit_rounded,
                      color: Color(0xFF10B981), size: 18),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _editingTemplateId != null
                            ? 'تعديل الجدول التدريبي بالمكتبة ✏️'
                            : 'صياغة وتصميم جدول تدريبي جديد 🏋️‍♂️',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        _editingTemplateId != null
                            ? 'قم بتعديل بيانات الجدول أو التمارين والعدات ثم احفظ التغييرات.'
                            : 'حدد التمارين والعدات والزوايا لحفظها كجدول جاهز للاستخدام الدائم.',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_editingTemplateId != null)
                  IconButton(
                    tooltip: 'إلغاء التعديل',
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _editingTemplateId = null;
                        _templateSubTab = 0;
                      });
                    },
                  ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // بيانات القالب
          _buildWorkoutMetadataSection(),

          SizedBox(height: 14.h),

          // عضلات القالب مع زر الإضافة المخصصة
          _buildMusclesSelectorSection(),

          SizedBox(height: 14.h),

          // تمارين القالب
          _buildExercisesListSection(),

          SizedBox(height: 20.h),

          // زر الحفظ في المكتبة
          SizedBox(
            height: 52.h,
            child: ElevatedButton.icon(
              onPressed: _saveCurrentPlanAsTemplate,
              icon: Icon(
                  _editingTemplateId != null
                      ? Icons.check_circle_rounded
                      : Icons.bookmark_add_rounded,
                  color: Colors.white),
              label: Text(
                _editingTemplateId != null
                    ? 'حفظ التعديلات في مكتبة التمارين 💾✅'
                    : 'حفظ في مكتبة التمارين للاستخدام لاحقاً 💾',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _editingTemplateId != null
                    ? AppColors.newPrimaryColor
                    : const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          TextButton.icon(
            onPressed: () => setState(() => _templateSubTab = 0),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text(
              'إلغاء والعودة لمكتبة التمارين',
              style:
                  TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTemplateLibraryItemCard(WorkoutTemplateModel tmpl) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: tmpl.isCustom
                  ? AppColors.newPrimaryColor.withValues(alpha: 0.1)
                  : const Color(0xFF3B82F6).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              tmpl.isCustom ? Icons.star_rounded : Icons.fitness_center_rounded,
              color: tmpl.isCustom
                  ? AppColors.newPrimaryColor
                  : const Color(0xFF3B82F6),
              size: 20.sp,
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
                        tmpl.title,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        tmpl.isCustom ? 'مخصص للمدرب' : 'معتمد Team AR',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 8.5.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  '${tmpl.exercises.length} تمارين • ${tmpl.targetMuscles.join("، ")}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // أزرار الإجراءات للقالب
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // زر تطبيق
              IconButton(
                tooltip: 'تطبيق للمتدرب 🚀',
                icon: const Icon(Icons.play_circle_fill_rounded,
                    color: Color(0xFF10B981), size: 24),
                onPressed: () {
                  _applyTemplate(tmpl);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('تم تحميل جدول "${tmpl.title}" في المحرر 🚀'),
                      backgroundColor: const Color(0xFF10B981),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              // زر تعديل القالب بالمكتبة
              IconButton(
                tooltip: 'تعديل القالب ✏️',
                icon: const Icon(Icons.edit_note_rounded,
                    color: AppColors.newPrimaryColor, size: 24),
                onPressed: () => _startEditingTemplate(tmpl),
              ),
              // زر حذف القالب مع تأكيد
              IconButton(
                tooltip: 'حذف القالب 🗑️',
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 22),
                onPressed: () => _confirmDeleteTemplate(tmpl),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startEditingTemplate(WorkoutTemplateModel tmpl) {
    setState(() {
      _editingTemplateId = tmpl.id;
      _titleCtrl.text = tmpl.title;
      _introVideoCtrl.text = tmpl.introVideoUrl ?? '';
      _pdfUrlCtrl.text = tmpl.pdfAttachmentUrl ?? '';
      _selectedMuscles.clear();
      _selectedMuscles.addAll(tmpl.targetMuscles);
      _exercises.clear();
      _exercises.addAll(tmpl.exercises.map((e) => _ExerciseDraft(
            name: e.name,
            technicalTip: e.technicalTip,
            targetSets: e.targetSets,
            targetRepsRange: e.targetRepsRange,
            restSeconds: e.restSeconds,
            rir: e.rir,
            tempo: e.tempo,
            videoUrl: e.videoUrl,
          )));
      _activeMode = 1;
      _templateSubTab = 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم فتح قالب "${tmpl.title}" للتعديل ✏️'),
        backgroundColor: AppColors.newPrimaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmDeleteTemplate(WorkoutTemplateModel tmpl) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            const Icon(Icons.delete_forever_rounded,
                color: Colors.red, size: 26),
            SizedBox(width: 8.w),
            Text(
              'تأكيد حذف القالب',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف قالب "${tmpl.title}" نهائياً من مكتبة التمارين؟\n\nلن تتمكن من التراجع عن هذه الخطوة.',
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
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'حذف القالب',
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

    if (confirmed == true) {
      await WorkoutTemplateService.deleteCustomTemplate(tmpl.id);
      await _loadTemplates(forceRefresh: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف قالب "${tmpl.title}" بنجاح 🗑️'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  // ─── اختيار نوع الخطة التدريبية ──────────────────────────
  Widget _buildPlanTypeSelector() {
    return Container(
      padding: EdgeInsets.all(12.w),
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
            children: [
              Icon(Icons.tune_rounded,
                  color: AppColors.newPrimaryColor, size: 18.sp),
              SizedBox(width: 6.w),
              Text(
                'نوع الخطة التدريبية للمتدرب',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _buildPlanTypeOption(
                type: 0,
                title: 'تفاعلي ذكي',
                icon: Icons.fitness_center_rounded,
                subtitle: 'تمارين وعدات',
              ),
              SizedBox(width: 8.w),
              _buildPlanTypeOption(
                type: 1,
                title: 'خطة PDF فقط',
                icon: Icons.picture_as_pdf_rounded,
                subtitle: 'ملف معتمد بنقرة',
              ),
              SizedBox(width: 8.w),
              _buildPlanTypeOption(
                type: 2,
                title: 'نظام هجين',
                icon: Icons.auto_awesome_rounded,
                subtitle: 'تفاعلي + ملف',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanTypeOption({
    required int type,
    required String title,
    required IconData icon,
    required String subtitle,
  }) {
    final isSelected = _planType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _planType = type),
        borderRadius: BorderRadius.circular(10.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.newPrimaryColor.withValues(alpha: 0.1)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.newPrimaryColor
                  : Colors.grey.withValues(alpha: 0.2),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22.sp,
                color:
                    isSelected ? AppColors.newPrimaryColor : Colors.grey[600],
              ),
              SizedBox(height: 6.h),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color:
                      isSelected ? AppColors.newPrimaryColor : AppColors.black,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 9.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── إدارة ملف الـ PDF المرفق (Zero Redundancy) ───────────────
  Widget _buildPdfAttachmentSection() {
    final hasSelectedPdf = _selectedPdfSystem != null ||
        (_pdfUrlCtrl.text.isNotEmpty && _pdfUrlCtrl.text.startsWith('http'));

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: hasSelectedPdf
              ? AppColors.newPrimaryColor.withValues(alpha: 0.4)
              : Colors.grey.withValues(alpha: 0.15),
          width: hasSelectedPdf ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.picture_as_pdf_rounded,
                    color: Colors.red, size: 18),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ملف الخطة التدريبية (PDF)',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      'اختر ملفاً معتمداً من مكتبتك دون استهلاك مساحة، أو ارفع ملفاً جديداً',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10.5.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (hasSelectedPdf)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: const Text(
                    'مربوط بنجاح ✅',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 14.h),
          if (_selectedPdfSystem != null)
            _buildActivePdfCard(_selectedPdfSystem!)
          else
            _buildEmptyPdfActions(),
        ],
      ),
    );
  }

  Widget _buildActivePdfCard(WorkoutSystemModel system) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Colors.red,
                  size: 26,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      system.name ?? 'ملف خطة التدريب المعتمد',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'مخزن في المكتبة المركزية (ID: ${system.id ?? "-"}) • صفر استهلاك مساحة إضافية',
                      maxLines: 1,
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
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openPdfSystemsPickerSheet(),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                  label: const Text('تغيير الملف',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.newPrimaryColor,
                    side: BorderSide(
                        color:
                            AppColors.newPrimaryColor.withValues(alpha: 0.3)),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedPdfSystem = null;
                    _pdfUrlCtrl.clear();
                  });
                },
                tooltip: 'إلغاء الإرفاق',
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPdfActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _openPdfSystemsPickerSheet,
                icon: const Icon(Icons.folder_shared_rounded, size: 18),
                label: const Text(
                  'اختيار من مكتبة الـ PDF 📂',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.newPrimaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUploadingPdf ? null : _pickAndUploadNewPdfFile,
                icon: _isUploadingPdf
                    ? SizedBox(
                        width: 16.r,
                        height: 16.r,
                        child: const CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.newPrimaryColor),
                      )
                    : const Icon(Icons.upload_file_rounded, size: 18),
                label: Text(
                  _isUploadingPdf ? 'جاري الرفع...' : 'رفع من الهاتف 📤',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.newPrimaryColor,
                  side: BorderSide(
                      color: AppColors.newPrimaryColor.withValues(alpha: 0.4)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPdfOnlyPlanSummaryCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.check_rounded, color: Colors.white, size: 18),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خطة سريعة ومعتمدة عبر ملف الـ PDF 📄',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'لا داعي لإدخال التمارين والعدات يدوياً. بمجرد الضغط على زر الحفظ بالأسفل، سيتم ربط ملف الخطة المختار بحساب المتدرب فوراً، وسيتمكن من فتحه وتصفحه بحماية كاملة من شاشة التمارين بتطبيقه.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5.sp,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 4. أقسام الخطة المشتركة (Metadata, Muscles, Exercises) ───
  Widget _buildWorkoutMetadataSection() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'بيانات الخطة التدريبية',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ترتيب اليوم في الجدول الأسبوعي للمتدرب:',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.5.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 6.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _daysList.map((day) {
                final isSelected = _selectedDayLabel == day;
                return Padding(
                  padding: EdgeInsets.only(left: 6.w),
                  child: ChoiceChip(
                    label: Text(
                      day,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey[800],
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.newPrimaryColor,
                    backgroundColor: const Color(0xFFF1F3F5),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedDayLabel = day);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 10.h),
          _inputField(
            controller: _titleCtrl,
            label: _planType == 1
                ? 'عنوان الخطة التدريبية (مثال: خطة تضخيم 4 أيام للمبتدئين)'
                : 'عنوان الخطة / اليوم (مثال: Push Day - صدر وتراي)',
            icon: Icons.title_rounded,
          ),
          SizedBox(height: 10.h),
          _inputField(
            controller: _introVideoCtrl,
            label: 'رابط فيديو التوجيه العام باليوتيوب (اختياري)',
            icon: Icons.video_library_rounded,
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              '💡 يظهر كفيديو توجيهي عام للمتدرب في أعلى شاشة اليوم التدريبي لشرح الفلسفة العامة والتكنيك.',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10.5.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusclesSelectorSection() {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.fitness_center_rounded,
                        size: 18.sp, color: AppColors.newPrimaryColor),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        'العضلات المستهدفة (${_selectedMuscles.length})',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              InkWell(
                onTap: _showAddCustomMuscleDialog,
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.newPrimaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded,
                          size: 16.sp, color: AppColors.newPrimaryColor),
                      SizedBox(width: 4.w),
                      Text(
                        'إضافة عضلة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.newPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              ..._availableMuscles.map((muscle) {
                final isSelected = _selectedMuscles.contains(muscle);
                return FilterChip(
                  label: Text(muscle,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5.sp,
                        color: isSelected ? Colors.white : AppColors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      )),
                  selected: isSelected,
                  selectedColor: AppColors.newPrimaryColor,
                  backgroundColor: const Color(0xFFF4F6F8),
                  checkmarkColor: Colors.white,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedMuscles.add(muscle);
                      } else {
                        _selectedMuscles.remove(muscle);
                      }
                    });
                  },
                );
              }),
              ActionChip(
                avatar:
                    const Icon(Icons.add, size: 16, color: Color(0xFF10B981)),
                label: Text(
                  'عضلة أخرى ➕',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981),
                  ),
                ),
                backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                side: BorderSide(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                onPressed: _showAddCustomMuscleDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddCustomMuscleDialog() {
    final muscleCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: AppColors.newPrimaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fitness_center_rounded,
                  color: AppColors.newPrimaryColor, size: 20),
            ),
            SizedBox(width: 8.w),
            const Text(
              'إضافة عضلة مخصصة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أدخل اسم العضلة المستهدفة التي تريد إضافتها للخطة (مثال: السواعد، المجنص، الترابيس، الترابس)',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: muscleCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'اسم العضلة...',
                hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide:
                      BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide:
                      BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.newPrimaryColor),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = muscleCtrl.text.trim();
              if (val.isNotEmpty) {
                setState(() {
                  if (!_availableMuscles.contains(val)) {
                    _availableMuscles.add(val);
                  }
                  if (!_selectedMuscles.contains(val)) {
                    _selectedMuscles.add(val);
                  }
                });
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.newPrimaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
            child: const Text('إضافة وتحديد',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'قائمة التمارين (${_exercises.length})',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton.icon(
              onPressed: _addNewExerciseDialog,
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: Color(0xFF10B981)),
              label: Text(
                'إضافة تمرين جديد',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (_exercises.isEmpty)
          Container(
            padding: EdgeInsets.all(24.w),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                Icon(Icons.fitness_center_rounded,
                    color: Colors.grey[400], size: 36.sp),
                SizedBox(height: 6.h),
                Text(
                  'لا توجد تمارين مضافة بعد',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _exercises.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, i) {
              final ex = _exercises[i];
              return Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border:
                      Border.all(color: Colors.grey.withValues(alpha: 0.15)),
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
                                width: 26.w,
                                height: 26.w,
                                decoration: BoxDecoration(
                                  color: AppColors.newPrimaryColor
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.newPrimaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  ex.name,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.red, size: 20),
                          onPressed: () {
                            setState(() {
                              _exercises.removeAt(i);
                            });
                          },
                        ),
                      ],
                    ),
                    if (ex.technicalTip.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          '💡 ${ex.technicalTip}',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            color: const Color(0xFF92400E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 6.w,
                      children: [
                        _pill('${ex.targetSets} مجموعات'),
                        _pill('${ex.targetRepsRange} تكرار'),
                        _pill('راحة ${ex.restSeconds}s'),
                        _pill('RIR ${ex.rir}'),
                        _pill('Tempo ${ex.tempo}'),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            fontFamily: 'Cairo', fontSize: 12.sp, color: Colors.grey[600]),
        prefixIcon: Icon(icon, size: 18.sp, color: AppColors.newPrimaryColor),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
    );
  }

  // ─── 5. نافذة اختيار المتدربين التفاعلية (بدون كتابة أي ID) ───────
  void _openTraineePickerSheet({
    required String title,
    required ValueChanged<TraineeModel> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = _allTrainees.where((t) {
              final name = (t.userName ?? t.name ?? '').toLowerCase();
              final email = (t.email ?? '').toLowerCase();
              final q = searchQuery.toLowerCase();
              return name.contains(q) || email.contains(q);
            }).toList();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // حقل البحث الفوري
                  TextField(
                    onChanged: (val) {
                      setSheetState(() => searchQuery = val);
                    },
                    decoration: InputDecoration(
                      hintText: 'ابحث بالاسم أو البريد الإلكتروني...',
                      hintStyle: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          color: Colors.grey[500]),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.newPrimaryColor),
                      filled: true,
                      fillColor: const Color(0xFFF4F6F8),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Expanded(
                    child: _isLoadingTrainees
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.newPrimaryColor))
                        : filtered.isEmpty
                            ? Center(
                                child: Text('لا يوجد متدرب مطابق للبحث',
                                    style: TextStyle(
                                        fontFamily: 'Cairo',
                                        color: Colors.grey[600])),
                              )
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 8.h),
                                itemBuilder: (context, idx) {
                                  final t = filtered[idx];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      onSelected(t);
                                    },
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Container(
                                      padding: EdgeInsets.all(10.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        border: Border.all(
                                            color: Colors.grey
                                                .withValues(alpha: 0.15)),
                                      ),
                                      child: Row(
                                        children: [
                                          Builder(
                                            builder: (context) {
                                              final imageProvider =
                                                  _getTraineeImageProvider(
                                                      t.image);
                                              return CircleAvatar(
                                                radius: 20.r,
                                                backgroundColor: AppColors
                                                    .newPrimaryColor
                                                    .withValues(alpha: 0.1),
                                                backgroundImage: imageProvider,
                                                onBackgroundImageError:
                                                    imageProvider != null
                                                        ? (exception,
                                                            stackTrace) {}
                                                        : null,
                                                child: imageProvider == null
                                                    ? Icon(Icons.person,
                                                        color: AppColors
                                                            .newPrimaryColor,
                                                        size: 20.sp)
                                                    : null,
                                              );
                                            },
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  t.userName ??
                                                      t.name ??
                                                      'متدرب',
                                                  style: TextStyle(
                                                    fontFamily: 'Cairo',
                                                    fontSize: 13.5.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.black,
                                                  ),
                                                ),
                                                Text(
                                                  t.email ??
                                                      t.phone ??
                                                      'مسجل في التطبيق',
                                                  style: TextStyle(
                                                    fontFamily: 'Cairo',
                                                    fontSize: 11.sp,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 14,
                                              color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── 6. تدفق النسخ الفوري من متدرب آخر (1-Tap Clone) ───────────────
  void _openCloneFromAnotherTraineeFlow() {
    _openTraineePickerSheet(
      title: 'اختر المتدرب المراد نسخ خطته',
      onSelected: (sourceTrainee) async {
        if (sourceTrainee.id == null || sourceTrainee.id!.isEmpty) return;

        setState(() => _isSaving = true);
        final repo = getIt<WorkoutRepositoryV2>();
        final existing = await repo.getWorkoutForTrainee(sourceTrainee.id!);

        if (mounted) {
          setState(() => _isSaving = false);
          if (existing != null && existing.exercises.isNotEmpty) {
            setState(() {
              _titleCtrl.text = existing.title;
              _selectedMuscles.clear();
              _selectedMuscles.addAll(existing.targetMuscles);
              if (existing.introVideoUrl != null) {
                _introVideoCtrl.text = existing.introVideoUrl!;
              }
              if (existing.pdfAttachmentUrl != null) {
                _pdfUrlCtrl.text = existing.pdfAttachmentUrl!;
                final match = _availablePdfSystems.firstWhere(
                  (s) => s.url == existing.pdfAttachmentUrl,
                  orElse: () => WorkoutSystemModel(
                      name: 'مرفق المتدرب (PDF)',
                      url: existing.pdfAttachmentUrl),
                );
                _selectedPdfSystem = match;
                _planType = 2;
              }
              _exercises.clear();
              for (final ex in existing.exercises) {
                _exercises.add(_ExerciseDraft(
                  name: ex.name,
                  technicalTip: ex.technicalTip ?? '',
                  videoUrl: ex.videoGuideUrl,
                  targetSets: ex.targetSets,
                  targetRepsRange: ex.targetRepsRange,
                  restSeconds: ex.restSeconds,
                  rir: ex.rir,
                  tempo: ex.tempo,
                ));
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'تم نسخ ${existing.exercises.length} تمارين من المتدرب (${sourceTrainee.userName ?? sourceTrainee.name}) بنجاح! 📋'),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'لم يتم العثور على تمارين مسجلة للمتدرب (${sourceTrainee.userName ?? sourceTrainee.name})'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      },
    );
  }

  // ─── 7. نافذة اختيار وتطبيق قالب من المكتبة ───────────────────────
  void _showApplyTemplateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      'اختر جدولاً من مكتبة التمارين 📚',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    tooltip: 'تحديث المكتبة',
                    onPressed: () async {
                      await _loadTemplates(forceRefresh: true);
                      (ctx as Element).markNeedsBuild();
                    },
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: _allTemplates.isEmpty
                    ? Center(
                        child: Text('لا توجد جداول في مكتبة التمارين حالياً',
                            style: TextStyle(
                                fontFamily: 'Cairo', color: Colors.grey[600])),
                      )
                    : ListView.separated(
                        itemCount: _allTemplates.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (context, idx) {
                          final tmpl = _allTemplates[idx];
                          return InkWell(
                            onTap: () {
                              Navigator.pop(ctx);
                              _applyTemplate(tmpl);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'تم تطبيق جدول "${tmpl.title}" بنجاح! 📋'),
                                  backgroundColor: const Color(0xFF10B981),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                    color: Colors.grey.withValues(alpha: 0.15)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.r),
                                    decoration: BoxDecoration(
                                      color: tmpl.isCustom
                                          ? AppColors.newPrimaryColor
                                              .withValues(alpha: 0.1)
                                          : const Color(0xFF3B82F6)
                                              .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      tmpl.isCustom
                                          ? Icons.star_rounded
                                          : Icons.fitness_center_rounded,
                                      color: tmpl.isCustom
                                          ? AppColors.newPrimaryColor
                                          : const Color(0xFF3B82F6),
                                      size: 20.sp,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tmpl.title,
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          '${tmpl.exercises.length} تمارين • ${tmpl.targetMuscles.join("، ")}',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 11.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.newPrimaryColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      'اختيار',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.newPrimaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _applyTemplate(WorkoutTemplateModel tmpl) {
    setState(() {
      _appliedTemplateId = tmpl.id;
      _appliedTemplateTitle = tmpl.title;
      _activeMode = 0; // التحويل لشاشة إعداد وإسناد التمرين للمتدرب
      _titleCtrl.text = tmpl.title;
      _selectedMuscles.clear();
      _selectedMuscles.addAll(tmpl.targetMuscles);
      if (tmpl.introVideoUrl != null) {
        _introVideoCtrl.text = tmpl.introVideoUrl!;
      }
      if (tmpl.pdfAttachmentUrl != null) {
        _pdfUrlCtrl.text = tmpl.pdfAttachmentUrl!;
        final match = _availablePdfSystems.firstWhere(
          (s) => s.url == tmpl.pdfAttachmentUrl,
          orElse: () => WorkoutSystemModel(
              name: 'مرفق التمرين (PDF)', url: tmpl.pdfAttachmentUrl),
        );
        _selectedPdfSystem = match;
        if (_planType == 0) _planType = 2;
      }
      _exercises.clear();
      for (final ex in tmpl.exercises) {
        _exercises.add(_ExerciseDraft(
          name: ex.name,
          technicalTip: ex.technicalTip,
          videoUrl: ex.videoUrl,
          targetSets: ex.targetSets,
          targetRepsRange: ex.targetRepsRange,
          restSeconds: ex.restSeconds,
          rir: ex.rir,
          tempo: ex.tempo,
        ));
      }
    });
  }

  // ─── نافذة اختيار ملف PDF من المكتبة المركزية (Zero Storage) ───
  void _openPdfSystemsPickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = _availablePdfSystems.where((s) {
              final name = s.name?.toLowerCase() ?? '';
              return name.contains(searchQuery.toLowerCase());
            }).toList();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'مكتبة ملفات الـ PDF المعتمدة 📚',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        onPressed: () async {
                          await _loadPdfSystems();
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                  Text(
                    'اختر ملفاً لربطه بالمتدرب دون تكرار التخزين (Zero Storage Overhead)',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.5.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // خانة البحث السريع
                  TextField(
                    onChanged: (val) => setSheetState(() => searchQuery = val),
                    decoration: InputDecoration(
                      hintText:
                          'ابحث عن اسم الخطة (مثال: تضخيم، فتنس، تنشيف)...',
                      hintStyle: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.h, horizontal: 12.w),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Expanded(
                    child: _isLoadingPdfSystems
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.newPrimaryColor),
                          )
                        : filtered.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.folder_off_outlined,
                                        size: 40.sp, color: Colors.grey[400]),
                                    SizedBox(height: 8.h),
                                    Text(
                                      searchQuery.isNotEmpty
                                          ? 'لا توجد نتائج مطابقة'
                                          : 'لا توجد ملفات في المكتبة بعد',
                                      style: TextStyle(
                                          fontFamily: 'Cairo',
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 8.h),
                                itemBuilder: (context, idx) {
                                  final sys = filtered[idx];
                                  final isSelected =
                                      _selectedPdfSystem?.id == sys.id;
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedPdfSystem = sys;
                                        if (sys.url != null) {
                                          _pdfUrlCtrl.text = sys.url!;
                                        }
                                        if (_titleCtrl.text.isEmpty ||
                                            _titleCtrl.text == 'Push Day') {
                                          _titleCtrl.text =
                                              sys.name ?? 'خطة تدريبية PDF';
                                        }
                                      });
                                      Navigator.pop(ctx);
                                    },
                                    borderRadius: BorderRadius.circular(10.r),
                                    child: Container(
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.newPrimaryColor
                                                .withValues(alpha: 0.08)
                                            : const Color(0xFFF9FAFB),
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.newPrimaryColor
                                              : Colors.grey
                                                  .withValues(alpha: 0.15),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8.r),
                                            decoration: BoxDecoration(
                                              color: Colors.red
                                                  .withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                                Icons.picture_as_pdf_rounded,
                                                color: Colors.red,
                                                size: 20),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  sys.name ?? 'نظام تدريبي',
                                                  style: TextStyle(
                                                    fontFamily: 'Cairo',
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.black,
                                                  ),
                                                ),
                                                Text(
                                                  'ID: ${sys.id ?? "-"} • ملف سحابي معتمد',
                                                  style: TextStyle(
                                                    fontFamily: 'Cairo',
                                                    fontSize: 10.5.sp,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isSelected)
                                            const Icon(
                                                Icons.check_circle_rounded,
                                                color:
                                                    AppColors.newPrimaryColor)
                                          else
                                            const Icon(
                                                Icons
                                                    .radio_button_unchecked_rounded,
                                                color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),

                  SizedBox(height: 10.h),

                  // زر إضافة ملف جديد للمكتبة من داخل الشيت
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _pickAndUploadNewPdfFile();
                    },
                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                    label: const Text('رفع ملف PDF جديد من الهاتف للمكتبة 📤',
                        style: TextStyle(
                            fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.newPrimaryColor,
                      side: BorderSide(
                          color:
                              AppColors.newPrimaryColor.withValues(alpha: 0.3)),
                      padding: EdgeInsets.symmetric(vertical: 11.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── رفع ملف PDF جديد من الهاتف وحفظه بالمكتبة المركزية ───────────
  Future<void> _pickAndUploadNewPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name.replaceAll('.pdf', '');

      // نافذة تأكيد الاسم
      final nameCtrl = TextEditingController(text: fileName);
      if (!mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dlgCtx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            'تسمية الخطة التدريبية 📝',
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر اسماً واضحاً للخطة ليتم حفظها في مكتبتك المركزية للاستخدام الدائم.',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    color: Colors.grey[600]),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'اسم الخطة (مثال: تضخيم 4 أيام للمبتدئين)',
                  labelStyle: const TextStyle(fontFamily: 'Cairo'),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgCtx, false),
              child: const Text('إلغاء',
                  style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dlgCtx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.newPrimaryColor),
              child: const Text('تأكيد ورفع 🚀',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      final finalName =
          nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : fileName;

      setState(() => _isUploadingPdf = true);

      final repo = getIt<WorkoutSystemRepository>();
      final uploadRes = await repo.uploadWorkoutSystemFile(
        WorkoutSystemModel(name: finalName),
        file,
      );

      uploadRes.when(
        success: (_) async {
          // تحديث قائمة المكتبة
          final refreshRes = await repo.getWorkoutSystems();
          refreshRes.when(
            success: (list) {
              if (mounted) {
                final latest = list.isNotEmpty ? list.last : null;
                setState(() {
                  _availablePdfSystems = list;
                  _isUploadingPdf = false;
                  if (latest != null) {
                    _selectedPdfSystem = latest;
                    if (latest.url != null) _pdfUrlCtrl.text = latest.url!;
                    _titleCtrl.text = latest.name ?? finalName;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'تم رفع وحفظ "$finalName" في مكتبة الـ PDF بنجاح! 🚀'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              }
            },
            failure: (_) {
              if (mounted) setState(() => _isUploadingPdf = false);
            },
          );
        },
        failure: (err) {
          if (mounted) {
            setState(() => _isUploadingPdf = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(err.getErrorsMessage() ??
                    'فشل رفع ملف الـ PDF، يرجى المحاولة ثانية'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPdf = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء اختيار الملف: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─── 8. عمليات الحفظ والنشر ──────────────────────────────────────
  // حفظ وتفعيل للمتدرب المختار
  void _saveAndPublishWorkoutToTrainee() async {
    if (_selectedTrainee == null ||
        _selectedTrainee!.id == null ||
        _selectedTrainee!.id!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار المتدرب أولاً من القائمة أعلاه 👥'),
          backgroundColor: Colors.orange,
        ),
      );
      _openTraineePickerSheet(
        title: 'اختر المتدرب لتخصيص الخطة له',
        onSelected: (t) => setState(() => _selectedTrainee = t),
      );
      return;
    }

    // التحقق بناءً على نوع الخطة
    if (_planType == 1) {
      // وضع خطة PDF فقط
      if (_selectedPdfSystem == null && _pdfUrlCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى اختيار ملف PDF من المكتبة أو رفعه أولاً 📄'),
            backgroundColor: Colors.orange,
          ),
        );
        _openPdfSystemsPickerSheet();
        return;
      }
    } else {
      // تفاعلي ذكي أو هجين
      if (_exercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى إضافة تمرين واحد على الأقل للخطة'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      if (_planType == 2 &&
          _selectedPdfSystem == null &&
          _pdfUrlCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'يرجى إرفاق ملف الـ PDF المرجعي أو تحويل الخطة لتفاعلي فقط'),
            backgroundColor: Colors.orange,
          ),
        );
        _openPdfSystemsPickerSheet();
        return;
      }
    }

    setState(() => _isSaving = true);
    final repo = getIt<WorkoutRepositoryV2>();
    final coachId =
        await SharedPreferencesHelper.getString(AppConstants.userId) ?? 'coach';

    final pdfUrl = _selectedPdfSystem?.url ??
        (_pdfUrlCtrl.text.isNotEmpty ? _pdfUrlCtrl.text.trim() : null);

    final workoutTitle = _titleCtrl.text.trim().isNotEmpty
        ? _titleCtrl.text.trim()
        : (_selectedPdfSystem?.name ?? 'خطة تدريبية');

    log('================================================================');
    log('🚀 [WorkoutBuilder] بدء حفظ وتفعيل الخطة للمتدرب:');
    log('   • Trainee ID: ${_selectedTrainee!.id}');
    log('   • Trainee Name: ${_selectedTrainee!.userName ?? _selectedTrainee!.name}');
    log('   • Trainee Email: ${_selectedTrainee!.email}');
    log('   • Coach ID: $coachId');
    log('   • Plan Title: "$workoutTitle"');
    log('   • Plan Mode: $_planType (0: تفاعلي ذكي, 1: ملف PDF فقط, 2: هجين)');
    log('   • Muscles Targeted: $_selectedMuscles');
    log('   • Exercises Count: ${_exercises.length}');
    log('   • PDF Attachment: ${pdfUrl ?? "None"}');
    log('================================================================');

    // 1. المزامنة الثنائية مع السيرفر القديم في حال وجود ملف PDF
    if (_selectedPdfSystem?.id != null && _selectedTrainee!.id != null) {
      try {
        final legacyRepo = getIt<WorkoutSystemRepository>();
        await legacyRepo.addWorkoutForUser(
          workoutId: _selectedPdfSystem!.id!,
          userId: _selectedTrainee!.id!,
        );
        log('✅ [WorkoutBuilder] Legacy PDF System assigned successfully to trainee.');
      } catch (e) {
        log('⚠️ [WorkoutBuilder] Legacy PDF assignment failed: $e (متابعة الحفظ على السيرفر الجديد)');
      }
    }

    final workout = WorkoutModel(
      id: '',
      coachId: coachId,
      traineeId: _selectedTrainee!.id!,
      title: workoutTitle,
      dayOfWeek: _selectedDayLabel,
      targetMuscles: _selectedMuscles,
      introVideoUrl:
          _introVideoCtrl.text.isNotEmpty ? _introVideoCtrl.text.trim() : null,
      pdfAttachmentUrl: pdfUrl,
      createdAt: DateTime.now(),
    );

    log('⏳ [WorkoutBuilder] إرسال طلب إنشاء الـ Workout إلى Supabase...');
    final workoutId = await repo.createWorkout(workout);

    if (workoutId != null) {
      log('🎉 [WorkoutBuilder] تم إنشاء الخطة بنجاح في Supabase! المعرّف: $workoutId');
      int successfulExercises = 0;

      // إذا كان هناك تمارين تفاعلية (في الوضع التفاعلي أو الهجين فقط):
      if (_planType != 1) {
        for (int i = 0; i < _exercises.length; i++) {
          final d = _exercises[i];
          final ex = ExerciseModel(
            id: '',
            workoutId: workoutId,
            name: d.name,
            videoGuideUrl: d.videoUrl,
            technicalTip: d.technicalTip.isNotEmpty ? d.technicalTip : null,
            targetSets: d.targetSets,
            targetRepsRange: d.targetRepsRange,
            restSeconds: d.restSeconds,
            rir: d.rir,
            tempo: d.tempo,
            orderIndex: i,
          );
          final ok = await repo.addExercise(ex);
          if (ok) {
            successfulExercises++;
          } else {
            log('⚠️ [WorkoutBuilder] فشل إدخال التمرين #${i + 1}: ${d.name}');
          }
        }
      }

      log('📊 [WorkoutBuilder] اكتمل حفظ التمارين: $successfulExercises من أصل ${_exercises.length}');

      setState(() => _isSaving = false);
      if (mounted) {
        final planTypeName = _planType == 1
            ? 'خطة الـ PDF'
            : (_planType == 2 ? 'النظام الهجين المتكامل' : 'الجدول التفاعلي');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'تم تفعيل $planTypeName بنجاح للمتدرب (${_selectedTrainee!.userName ?? _selectedTrainee!.name})! 🚀'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      log('❌ [WorkoutBuilder] فشل إنشاء الخطة في السيرفر (workoutId returned null)');
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'حدث خطأ أثناء حفظ الخطة في السيرفر، يرجى مراجعة تفاصيل السجل'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // حفظ الخطة الحالية مباشرة في مكتبة التمارين
  Future<void> _saveCurrentPlanAsTemplate() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى كتابة عنوان للجدول'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إضافة تمرين واحد على الأقل'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final templateId =
        _editingTemplateId ?? 'custom_${DateTime.now().millisecondsSinceEpoch}';

    final newTemplate = WorkoutTemplateModel(
      id: templateId,
      title: title,
      targetMuscles: List.from(_selectedMuscles),
      introVideoUrl: _introVideoCtrl.text.trim().isNotEmpty
          ? _introVideoCtrl.text.trim()
          : null,
      pdfAttachmentUrl: _selectedPdfSystem?.url ??
          (_pdfUrlCtrl.text.trim().isNotEmpty ? _pdfUrlCtrl.text.trim() : null),
      exercises: _exercises
          .map((e) => ExerciseTemplateItem(
                name: e.name,
                technicalTip: e.technicalTip,
                targetSets: e.targetSets,
                targetRepsRange: e.targetRepsRange,
                restSeconds: e.restSeconds,
                rir: e.rir,
                tempo: e.tempo,
                videoUrl: e.videoUrl,
              ))
          .toList(),
      isCustom: true,
    );

    await WorkoutTemplateService.saveCustomTemplate(newTemplate);
    await _loadTemplates(forceRefresh: true);
    final wasEditing = _editingTemplateId != null;
    setState(() {
      _appliedTemplateId = newTemplate.id;
      _appliedTemplateTitle = newTemplate.title;
      _editingTemplateId = null;
      _templateSubTab = 0;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(wasEditing
              ? 'تم تحديث وحفظ تعديلات قالب "$title" بنجاح! 💾✅'
              : 'تم حفظ جدول "$title" في مكتبة التمارين بنجاح! 💾'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  void _showSaveAsTemplateDialog() {
    final templateNameCtrl =
        TextEditingController(text: _titleCtrl.text.trim());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('حفظ في مكتبة التمارين 💾',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'أدخل اسم الجدول لحفظه في مكتبتك الخاصة واستخدامه لأي متدرب لاحقاً:',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: templateNameCtrl,
              decoration: const InputDecoration(
                labelText: 'اسم الجدول',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = templateNameCtrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);

              final newTemplate = WorkoutTemplateModel(
                id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                title: name,
                targetMuscles: List.from(_selectedMuscles),
                introVideoUrl: _introVideoCtrl.text.trim().isNotEmpty
                    ? _introVideoCtrl.text.trim()
                    : null,
                pdfAttachmentUrl: _selectedPdfSystem?.url ??
                    (_pdfUrlCtrl.text.trim().isNotEmpty
                        ? _pdfUrlCtrl.text.trim()
                        : null),
                exercises: _exercises
                    .map((e) => ExerciseTemplateItem(
                          name: e.name,
                          technicalTip: e.technicalTip,
                          targetSets: e.targetSets,
                          targetRepsRange: e.targetRepsRange,
                          restSeconds: e.restSeconds,
                          rir: e.rir,
                          tempo: e.tempo,
                          videoUrl: e.videoUrl,
                        ))
                    .toList(),
                isCustom: true,
              );

              await WorkoutTemplateService.saveCustomTemplate(newTemplate);
              await _loadTemplates();

              if (mounted) {
                setState(() {
                  _appliedTemplateId = newTemplate.id;
                  _appliedTemplateTitle = newTemplate.title;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('تم حفظ جدول "$name" في مكتبة التمارين بنجاح! 💾'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.newPrimaryColor,
            ),
            child: const Text('حفظ في المكتبة',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _addNewExerciseDialog() {
    final nameCtrl = TextEditingController();
    final tipCtrl = TextEditingController();
    final videoCtrl = TextEditingController();
    int sets = 3;
    final repsCtrl = TextEditingController(text: '8-10');
    final restCtrl = TextEditingController(text: '120');
    int rir = 2;
    final tempoCtrl = TextEditingController(text: '3-2-2');

    final commonReps = ['6-8', '8-10', '10-12', '12-15', 'فشل عضلي'];
    final commonRests = ['60', '90', '120', '180'];
    final commonTempos = ['3-1-1', '3-2-2', '2-0-1', '4-1-2'];

    final rirLabels = [
      'فشل عضلي تام (0 عدات متبقية)',
      'أقصى مجهود (باقي عدة واحدة فقط)',
      'المدى المثالي للبناء العضلي (باقي عدتين)',
      'شدة متوسطة ومتحكم بها (باقي 3 عدات)',
      'إحماء أو تمرين خفيف (باقي 4 عدات)',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.90,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              children: [
                // رأس النافذة
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color:
                              AppColors.newPrimaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          color: AppColors.newPrimaryColor,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إعداد وتخصيص التمرين 🏋️‍♂️',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 15.5.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                            Text(
                              'حدد المتغيرات التدريبية بدقة واحترافية',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11.5.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),

                // محتوى الإدخال
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ─── 1. بيانات التمرين والفيديو ───
                        _buildSectionHeader('1. بيانات التمرين والفيديو 🎥'),
                        SizedBox(height: 8.h),
                        _inputField(
                          controller: nameCtrl,
                          label: 'اسم التمرين (مثال: Flat Dumbbell Press)',
                          icon: Icons.fitness_center,
                        ),
                        SizedBox(height: 10.h),
                        _inputField(
                          controller: videoCtrl,
                          label: 'رابط فيديو يوتيوب للتكنيك (اختياري)',
                          icon: Icons.video_collection_rounded,
                        ),
                        SizedBox(height: 4.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            '💡 اختياري: في حال تركه فارغاً، سيوفر التطبيق للمتدرب تلقائياً زراً ذكياً للبحث ومشاهدة التكنيك على YouTube.',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10.5.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // ─── 2. الحجم التدريبي والراحة ───
                        _buildSectionHeader('2. الحجم التدريبي والراحة 🎯'),
                        SizedBox(height: 10.h),

                        // المجموعات بتصميم Stepper
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.repeat_rounded,
                                      color: AppColors.newPrimaryColor,
                                      size: 20.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'عدد المجموعات (Sets):',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                        Icons.remove_circle_outline_rounded),
                                    color: sets > 1
                                        ? AppColors.newPrimaryColor
                                        : Colors.grey,
                                    onPressed: sets > 1
                                        ? () => setModalState(() => sets--)
                                        : null,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 14.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                          color: Colors.grey
                                              .withValues(alpha: 0.2)),
                                    ),
                                    child: Text(
                                      '$sets',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.newPrimaryColor,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.add_circle_outline_rounded),
                                    color: AppColors.newPrimaryColor,
                                    onPressed: () =>
                                        setModalState(() => sets++),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // مدى التكرارات مع خيارات سريعة
                        _inputField(
                          controller: repsCtrl,
                          label: 'مدى التكرارات (مثال: 8-10 أو 12-15)',
                          icon: Icons.bolt_rounded,
                        ),
                        SizedBox(height: 6.h),
                        Wrap(
                          spacing: 6.w,
                          children: commonReps.map((r) {
                            return InkWell(
                              onTap: () {
                                repsCtrl.text = r;
                                setModalState(() {});
                              },
                              child: Chip(
                                label: Text(r,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11.sp,
                                      color: repsCtrl.text == r
                                          ? Colors.white
                                          : AppColors.black,
                                      fontWeight: FontWeight.bold,
                                    )),
                                backgroundColor: repsCtrl.text == r
                                    ? AppColors.newPrimaryColor
                                    : const Color(0xFFF1F3F5),
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                              ),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 12.h),

                        // فترة الراحة بالثواني مع خيارات سريعة
                        _inputField(
                          controller: restCtrl,
                          label: 'الراحة بين المجموعات (بالثواني)',
                          icon: Icons.timer_rounded,
                        ),
                        SizedBox(height: 6.h),
                        Wrap(
                          spacing: 6.w,
                          children: commonRests.map((rst) {
                            return InkWell(
                              onTap: () {
                                restCtrl.text = rst;
                                setModalState(() {});
                              },
                              child: Chip(
                                label: Text('$rst ثانية',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11.sp,
                                      color: restCtrl.text == rst
                                          ? Colors.white
                                          : AppColors.black,
                                      fontWeight: FontWeight.bold,
                                    )),
                                backgroundColor: restCtrl.text == rst
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFF1F3F5),
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                              ),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 16.h),

                        // ─── 3. الشدة والتكنيك الحركي ───
                        _buildSectionHeader('3. الشدة والتوجيه الفني ⚡'),
                        SizedBox(height: 10.h),

                        // محدد RIR مع النص التوضيحي
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'معدل الاحتياط للفشل (RIR):',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 3.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.newPrimaryColor
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      'RIR $rir',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.newPrimaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(5, (val) {
                                  final isSel = rir == val;
                                  return InkWell(
                                    onTap: () => setModalState(() => rir = val),
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Container(
                                      width: 48.w,
                                      height: 38.h,
                                      decoration: BoxDecoration(
                                        color: isSel
                                            ? AppColors.newPrimaryColor
                                            : Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        border: Border.all(
                                          color: isSel
                                              ? AppColors.newPrimaryColor
                                              : Colors.grey
                                                  .withValues(alpha: 0.25),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$val',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: isSel
                                              ? Colors.white
                                              : AppColors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                '💡 ${rirLabels[rir.clamp(0, 4)]}',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11.5.sp,
                                  color: const Color(0xFFB45309),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // Tempo مع خيارات سريعة
                        _inputField(
                          controller: tempoCtrl,
                          label: 'إيقاع الحركة (Tempo) مثل: 3-2-2',
                          icon: Icons.speed_rounded,
                        ),
                        SizedBox(height: 6.h),
                        Wrap(
                          spacing: 6.w,
                          children: commonTempos.map((tmp) {
                            return InkWell(
                              onTap: () {
                                tempoCtrl.text = tmp;
                                setModalState(() {});
                              },
                              child: Chip(
                                label: Text(tmp,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11.sp,
                                      color: tempoCtrl.text == tmp
                                          ? Colors.white
                                          : AppColors.black,
                                      fontWeight: FontWeight.bold,
                                    )),
                                backgroundColor: tempoCtrl.text == tmp
                                    ? AppColors.newPrimaryColor
                                    : const Color(0xFFF1F3F5),
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                              ),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 12.h),

                        // التوجيه الفني
                        _inputField(
                          controller: tipCtrl,
                          label:
                              'التوجيه الفني والملحوظة الذهبية (Technical Tip)',
                          icon: Icons.lightbulb_outline_rounded,
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),

                // زر الإضافة النهائي بالأسفل
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: AppColors.newPrimaryColor,
                    borderRadius: BorderRadius.circular(12.r),
                    elevation: 2,
                    child: InkWell(
                      onTap: () {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('يرجى إدخال اسم التمرين أولاً'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _exercises.add(_ExerciseDraft(
                            name: name,
                            technicalTip: tipCtrl.text.trim(),
                            videoUrl: videoCtrl.text.trim().isNotEmpty
                                ? videoCtrl.text.trim()
                                : null,
                            targetSets: sets,
                            targetRepsRange: repsCtrl.text.trim(),
                            restSeconds: int.tryParse(restCtrl.text) ?? 120,
                            rir: rir,
                            tempo: tempoCtrl.text.trim(),
                          ));
                        });
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        width: double.infinity,
                        height: 50.h,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_circle_outline_rounded,
                                color: Colors.white, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'تأكيد وإضافة التمرين للجدول',
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 13.5.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    );
  }
}

class _ExerciseDraft {
  final String name;
  final String technicalTip;
  final int targetSets;
  final String targetRepsRange;
  final int restSeconds;
  final int rir;
  final String tempo;
  final String? videoUrl;

  _ExerciseDraft({
    required this.name,
    required this.technicalTip,
    required this.targetSets,
    required this.targetRepsRange,
    required this.restSeconds,
    required this.rir,
    required this.tempo,
    this.videoUrl,
  });
}
