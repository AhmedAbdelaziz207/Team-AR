import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Removed heavy in-app PDF renderer for performance
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/features/work_out/logic/workout_cubit.dart';
import 'package:team_ar/features/work_out/logic/workout_state.dart';
import 'package:url_launcher/url_launcher.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({
    super.key,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  String? _pdfUrl;
  WebViewController? _webController;
  bool _isLoading = true;
  @override
  void initState() {
    loadData();
    super.initState();
  }

  void loadData() async {
    log("Get Workout with Id ${await SharedPreferencesHelper.getInt(AppConstants.exerciseId)}");

    await SharedPreferencesHelper.getInt(AppConstants.exerciseId).then(
      (value) {
        context.read<WorkoutCubit>().getWorkout(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const AppBarBackButton(
          color: AppColors.white,
        ),
        title: Text(
          AppLocalKeys.workouts.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Download',
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: _pdfUrl == null
                ? null
                : () async {
                    try {
                      final uri = Uri.parse(_pdfUrl!);
                      final can = await canLaunchUrl(uri);
                      if (can) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalKeys.noWorkouts.tr())),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to open link')),
                        );
                      }
                    }
                  },
          ),
        ],
      ),
      body: BlocBuilder<WorkoutCubit, WorkoutState>(
        builder: (context, state) {
          if (state is WorkoutSuccess) {
            final url = '${ApiEndPoints.baseUrl}/Exercises/${state.url}';
            // Update current URL to enable the download button and (re)configure WebView.
            if (_pdfUrl != url || _webController == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                final viewerUrl =
                    'https://docs.google.com/gview?embedded=1&url=' + Uri.encodeComponent(url);
                final controller = WebViewController()
                  ..setJavaScriptMode(JavaScriptMode.unrestricted)
                  ..setBackgroundColor(Colors.black)
                  ..setNavigationDelegate(
                    NavigationDelegate(
                      onPageStarted: (_) {
                        if (mounted) setState(() => _isLoading = true);
                      },
                      onPageFinished: (_) {
                        if (mounted) setState(() => _isLoading = false);
                      },
                      onWebResourceError: (_) {
                        if (mounted) setState(() => _isLoading = false);
                      },
                    ),
                  );
                await controller.loadRequest(Uri.parse(viewerUrl));
                if (mounted) {
                  setState(() {
                    _pdfUrl = url;
                    _webController = controller;
                  });
                }
              });
            }

            return Stack(
              children: [
                if (_webController != null)
                  WebViewWidget(controller: _webController!),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            );
          }

          if (state is WorkoutFailure) {
            return Center(
              child: Text(
                AppLocalKeys.noWorkouts.tr(),
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20.sp,
                  fontFamily: "Cairo",
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
