import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_endpoints.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/services/pdf_protection_service.dart';
import 'package:team_ar/core/theme/app_colors.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/core/utils/app_local_keys.dart';
import 'package:team_ar/core/widgets/app_bar_back_button.dart';
import 'package:team_ar/features/work_out/logic/workout_cubit.dart';
import 'package:team_ar/features/work_out/logic/workout_state.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  bool _isPdfError = false;
  String? _localPdfPath;
  bool _isDownloading = false;
  double? _downloadProgress;
  int _receivedBytes = 0;
  int? _totalBytes;
  HttpClient? _activeClient;
  String? _currentLoadedUrl;

  @override
  void initState() {
    super.initState();
    PdfProtectionService.enable();
    loadData();
  }

  @override
  void dispose() {
    _activeClient?.close(force: true);
    PdfProtectionService.disable();
    super.dispose();
  }

  void loadData() async {
    _activeClient?.close(force: true);
    _activeClient = null;

    if (_localPdfPath != null) {
      try {
        final f = File(_localPdfPath!);
        if (await f.exists()) {
          await f.delete();
        }
      } catch (_) {}
    }

    _currentLoadedUrl = null;
    if (mounted) {
      setState(() {
        _isPdfError = false;
        _localPdfPath = null;
        _isDownloading = false;
        _downloadProgress = null;
        _receivedBytes = 0;
        _totalBytes = null;
      });
    }

    int? cachedExerciseId =
        await SharedPreferencesHelper.getInt(AppConstants.exerciseId);
    log("Get Workout with Id $cachedExerciseId from SharedPreferences");

    // Load from cache first
    if (cachedExerciseId != null && cachedExerciseId != 0 && mounted) {
      context.read<WorkoutCubit>().getWorkout(cachedExerciseId);
    } else if (mounted) {
      setState(() => _isPdfError = true);
    }

    // Fetch fresh user data in background to update exerciseId if changed
    final userId = await SharedPreferencesHelper.getString(AppConstants.userId);
    if (userId != null && userId.isNotEmpty) {
      try {
        final api = getIt<ApiService>();
        final user = await api.getLoggedUserData(userId);
        if (user.exerciseId != null) {
          await SharedPreferencesHelper.setData(
              AppConstants.exerciseId, user.exerciseId!);
          if (cachedExerciseId != user.exerciseId && mounted) {
            setState(() {
              _isPdfError = false;
              _localPdfPath = null;
            });
            context.read<WorkoutCubit>().getWorkout(user.exerciseId!);
          }
        } else if ((cachedExerciseId == null || cachedExerciseId == 0) &&
            mounted) {
          setState(() => _isPdfError = true);
        }
      } catch (e) {
        log("Failed to fetch fresh user data: $e");
      }
    }
  }

  Future<bool> _isValidPdf(File file) async {
    if (!await file.exists()) return false;
    final length = await file.length();
    if (length < 1024) return false;

    RandomAccessFile? raf;
    try {
      raf = await file.open(mode: FileMode.read);
      final headerBytes = await raf.read(5);
      final header = String.fromCharCodes(headerBytes);
      return header == '%PDF-';
    } catch (e) {
      log("Validation error: $e");
      return false;
    } finally {
      await raf?.close();
    }
  }

  Future<void> _checkAndDownloadPdf(String relativeUrl) async {
    if (_currentLoadedUrl == relativeUrl && _localPdfPath != null) {
      return;
    }
    _currentLoadedUrl = relativeUrl;

    try {
      final cleanBaseUrl = ApiEndPoints.baseUrl.endsWith('/')
          ? ApiEndPoints.baseUrl.substring(0, ApiEndPoints.baseUrl.length - 1)
          : ApiEndPoints.baseUrl;
      final fullUrl = Uri.encodeFull('$cleanBaseUrl/Exercises/$relativeUrl');

      final tempDir = await getTemporaryDirectory();
      final safeName = relativeUrl.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final targetFile = File('${tempDir.path}/workout_$safeName');

      // 1. Check if cached and valid
      if (await targetFile.exists()) {
        final isValid = await _isValidPdf(targetFile);
        if (isValid) {
          log("Valid cached workout PDF found: ${targetFile.path}");
          if (mounted) {
            setState(() {
              _localPdfPath = targetFile.path;
              _isDownloading = false;
              _isPdfError = false;
            });
          }
          return;
        } else {
          try {
            await targetFile.delete();
          } catch (_) {}
        }
      }

      // 2. Stream download chunk-by-chunk to disk without blocking UI isolate
      if (mounted) {
        setState(() {
          _isDownloading = true;
          _downloadProgress = null;
          _receivedBytes = 0;
          _totalBytes = null;
          _isPdfError = false;
        });
      }

      final tempFile = File('${targetFile.path}.tmp');
      if (await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }

      final client = HttpClient();
      _activeClient = client;
      client.connectionTimeout = const Duration(seconds: 30);
      client.autoUncompress = true;

      final req = await client.getUrl(Uri.parse(fullUrl));
      final res = await req.close();

      if (res.statusCode != 200) {
        throw Exception("Server response error: ${res.statusCode}");
      }

      final contentLength =
          res.headers.contentLength > 0 ? res.headers.contentLength : null;
      if (mounted) {
        setState(() {
          _totalBytes = contentLength;
        });
      }

      final tempSink = tempFile.openWrite();
      int received = 0;

      await for (final chunk in res) {
        tempSink.add(chunk);
        received += chunk.length;
        if (mounted) {
          setState(() {
            _receivedBytes = received;
            if (contentLength != null && contentLength > 0) {
              _downloadProgress = received / contentLength;
            }
          });
        }
      }

      await tempSink.flush();
      await tempSink.close();

      // Check validity
      final isValid = await _isValidPdf(tempFile);
      if (!isValid) {
        if (await tempFile.exists()) {
          try {
            await tempFile.delete();
          } catch (_) {}
        }
        throw Exception("Downloaded PDF file is invalid or corrupted");
      }

      if (await targetFile.exists()) {
        try {
          await targetFile.delete();
        } catch (_) {}
      }
      await tempFile.rename(targetFile.path);

      if (mounted) {
        setState(() {
          _localPdfPath = targetFile.path;
          _isDownloading = false;
          _isPdfError = false;
        });
      }
    } catch (e) {
      log("Error downloading workout PDF: $e");
      if (mounted) {
        setState(() {
          _isPdfError = true;
          _isDownloading = false;
        });
      }
    } finally {
      _activeClient?.close();
      _activeClient = null;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(1)} KB";
    }
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
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
      body: BlocConsumer<WorkoutCubit, WorkoutState>(
        listener: (context, state) {
          if (state is WorkoutSuccess) {
            if (state.url != null && state.url!.isNotEmpty) {
              _checkAndDownloadPdf(state.url!);
            } else {
              setState(() {
                _isPdfError = true;
              });
            }
          }
        },
        builder: (context, state) {
          if (state is WorkoutSuccess) {
            if (state.url == null || state.url!.isEmpty) {
              return _buildErrorStateView();
            }
            if (_currentLoadedUrl != state.url &&
                !_isDownloading &&
                _localPdfPath == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && state.url != null && state.url!.isNotEmpty) {
                  _checkAndDownloadPdf(state.url!);
                }
              });
            }
          }

          if (_isPdfError) {
            return _buildErrorStateView();
          }

          if (state is WorkoutFailure) {
            return _buildErrorStateView();
          }

          if (_localPdfPath != null &&
              File(_localPdfPath!).existsSync() &&
              !_isDownloading) {
            return SfPdfViewer.file(
              File(_localPdfPath!),
              canShowScrollHead: false,
              canShowScrollStatus: false,
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                log("ExerciseScreen - Local PDF Load Failed: ${details.description}");
                if (mounted) {
                  try {
                    File(_localPdfPath!).deleteSync();
                  } catch (_) {}
                  setState(() {
                    _isPdfError = true;
                    _localPdfPath = null;
                  });
                }
              },
            );
          }

          return _buildLoadingView();
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_downloadProgress != null) ...[
              SizedBox(
                width: 70.w,
                height: 70.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _downloadProgress,
                      strokeWidth: 5,
                      color: const Color(0xFF102E50),
                      backgroundColor: Colors.grey[200],
                    ),
                    Text(
                      "${(_downloadProgress! * 100).toInt()}%",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Cairo",
                        color: const Color(0xFF102E50),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "جاري تحميل جدول التمرين...",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Cairo",
                  color: const Color(0xFF102E50),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "${_formatBytes(_receivedBytes)}${_totalBytes != null ? ' / ${_formatBytes(_totalBytes!)}' : ''}",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: "Cairo",
                  color: Colors.grey[600],
                ),
              ),
            ] else ...[
              const CircularProgressIndicator(
                color: Color(0xFF102E50),
              ),
              SizedBox(height: 16.h),
              Text(
                "جاري تحميل جدول التمرين...",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Cairo",
                  color: Colors.grey[700],
                ),
              ),
            ],
          ],
        ),
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
              "تعذر عرض جدول التمرين حالياً، يرجى التأكد من الاتصال بالشبكة وإعادة المحاولة",
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
