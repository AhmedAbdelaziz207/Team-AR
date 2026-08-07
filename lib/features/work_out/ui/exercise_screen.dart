import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/services/pdf_protection_service.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/features/work_out/logic/workout_cubit.dart';
import 'package:team_ar/features/work_out/logic/workout_state.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({
    super.key,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  String? _pdfUrl;
  bool _isPdfError = false;

  @override
  void initState() {
    super.initState();
    PdfProtectionService.enable();
    loadData();
  }

  @override
  void dispose() {
    PdfProtectionService.disable();
    super.dispose();
  }

  void loadData() async {
    setState(() {
      _isPdfError = false;
    });
    final exerciseId = await SharedPreferencesHelper.getInt(AppConstants.exerciseId);
    log("Get Workout with Id $exerciseId");
    if (mounted) {
      context.read<WorkoutCubit>().getWorkout(exerciseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF102E50),
        elevation: 2,
        leading: const AppBarBackButton(
          color: AppColors.white,
        ),
        title: Text(
          AppLocalKeys.workouts.tr(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        actions: const [],
      ),
      body: BlocBuilder<WorkoutCubit, WorkoutState>(
        builder: (context, state) {
          if (state is WorkoutSuccess) {
            final String cleanBaseUrl = ApiEndPoints.baseUrl.endsWith('/')
                ? ApiEndPoints.baseUrl.substring(0, ApiEndPoints.baseUrl.length - 1)
                : ApiEndPoints.baseUrl;
            final url = '$cleanBaseUrl/Exercises/${state.url}';

            if (_pdfUrl != url) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _pdfUrl = url;
                    _isPdfError = false;
                  });
                }
              });
            }

            if (_isPdfError) {
              return _buildErrorStateView();
            }

            return SfPdfViewer.network(
              url,
              canShowScrollHead: false,
              canShowScrollStatus: false,
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                log("PDF Load Failed: ${details.description}");
                if (mounted) {
                  setState(() {
                    _isPdfError = true;
                  });
                }
              },
            );
          }

          if (state is WorkoutFailure) {
            return _buildErrorStateView();
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: Color(0xFF102E50),
                ),
                SizedBox(height: 16.h),
                Text(
                  "جاري تحميل تمارين النظام...",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: "Cairo",
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorStateView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.0.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.sp),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.picture_as_pdf_rounded,
                size: 56.sp,
                color: Colors.red[400],
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              AppLocalKeys.noWorkouts.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18.sp,
                fontFamily: "Cairo",
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "تعذر عرض ملف التمارين حالياً، يرجى التأكد من الاتصال بالشبكة وإعادة المحاولة",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13.sp,
                fontFamily: "Cairo",
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
                  onPressed: loadData,
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: Text(
                    "إعادة المحاولة",
                    style: TextStyle(
                      fontFamily: "Cairo",
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF102E50),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
