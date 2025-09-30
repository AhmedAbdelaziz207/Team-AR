import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/custom_text_form_field.dart';
import 'package:team_ar/features/workout_systems/logic/workout_system_cubit.dart';
import 'package:team_ar/features/workout_systems/logic/workout_system_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_bar_back_button.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  File? selectedPdf;

  void _pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);

      setState(() => selectedPdf = file);

      final cubit = context.read<WorkoutSystemCubit>();
      cubit.workoutPdf = file; // only select; do not upload yet
    }
  }

  String? name = '';

  @override
  Widget build(BuildContext context) {
    // final cubit = context.read<WorkoutSystemCubit>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: const AppBarBackButton(),
        centerTitle: true,
        title: Text(
          AppLocalKeys.createWorkoutSystem.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                fontSize: 21.sp,
              ),
        ),
      ),
      body: Padding(
          padding: EdgeInsets.all(16.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Workout Name Label

                SizedBox(height: 24.h),

                /// Select PDF + Save Buttons with BLoC state
                BlocConsumer<WorkoutSystemCubit, WorkoutSystemState>(
                  listener: (context, state) {
                    if (state is WorkoutSystemFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(state.errorModel.getErrorsMessage() ?? ''),
                          backgroundColor: AppColors.red,
                        ),
                      );
                    }
                    if (state is WorkoutSystemUploadSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalKeys.success.tr()),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Clear selected file to allow choosing another
                      setState(() {
                        selectedPdf = null;
                      });
                      final cubit = context.read<WorkoutSystemCubit>();
                      cubit.workoutPdf = null;
                    }
                  },
                  builder: (context, state) {
                    final cubit = context.watch<WorkoutSystemCubit>();
                    final isLoading = state is WorkoutSystemLoading;
                    final progress = cubit.uploadProgress; // 0.0 - 1.0

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Select PDF button (enabled even if name is empty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalKeys.workoutSystemName.tr(),
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                  SizedBox(height: 8.h),

                                  /// Workout Name Input
                                  CustomTextFormField(
                                    controller: context
                                        .read<WorkoutSystemCubit>()
                                        .nameController,
                                    hintText: AppLocalKeys.name.tr(),
                                    suffixIcon: Icons.drive_file_rename_outline,
                                    onChanged: (value) {
                                      setState(() {
                                        name = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: ElevatedButton.icon(
                                onPressed: isLoading ? null : _pickPdfFile,
                                icon: const Icon(Icons.attach_file),
                                label: Text(
                                  selectedPdf == null
                                      ? AppLocalKeys.selectPdf.tr()
                                      : AppLocalKeys.replace.tr(),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  minimumSize: Size(double.infinity, 48.h),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5),

                        ElevatedButton(
                          onPressed: isLoading ||
                                  selectedPdf == null ||
                                  (name?.isEmpty ?? true)
                              ? null
                              : () => cubit.uploadWorkoutSystem(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            minimumSize: Size(double.infinity, 48.h),
                          ),
                          child: isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Text(
                                        "${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%"),
                                  ],
                                )
                              : Text(AppLocalKeys.save.tr()),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 12.h),

                /// Selected PDF Name
                if (selectedPdf != null)
                  Text(
                    "${AppLocalKeys.files.tr()}: ${selectedPdf!.path.split('/').last}",
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                  ),
              ],
            ),
          ),
        ),
    );
  }
}
