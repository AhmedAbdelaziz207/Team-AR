import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team_ar/features/workout_log/model/set_log.dart';

part 'workout_log_state.freezed.dart';

// نموذج إدخال مجموعة واحدة (في الـ UI)
class SetInput {
  final double? weightKg;
  final int? reps;

  const SetInput({this.weightKg, this.reps});

  bool get isValid => (weightKg ?? 0) > 0 && (reps ?? 0) > 0;

  SetInput copyWith({double? weightKg, int? reps}) => SetInput(
        weightKg: weightKg ?? this.weightKg,
        reps: reps ?? this.reps,
      );
}

@freezed
class WorkoutLogState with _$WorkoutLogState {
  /// الحالة الأولية — جاهز للتسجيل
  const factory WorkoutLogState.initial() = WorkoutLogInitial;

  /// جلب آخر جلسة
  const factory WorkoutLogState.loadingPrevious() = WorkoutLogLoadingPrevious;

  /// آخر جلسة جاهزة
  const factory WorkoutLogState.ready({
    required List<SetLog> previousSets,
    @Default(0.0) double previousPR,
  }) = WorkoutLogReady;

  /// جاري الحفظ
  const factory WorkoutLogState.saving() = WorkoutLogSaving;

  /// تم الحفظ بنجاح
  const factory WorkoutLogState.saved({
    required List<SetLog> savedSets,
    required bool isNewPR,
    required double bestWeightKg,
  }) = WorkoutLogSaved;

  /// حُفظ محليًا (offline)
  const factory WorkoutLogState.savedOffline() = WorkoutLogSavedOffline;

  /// خطأ
  const factory WorkoutLogState.error(String message) = WorkoutLogError;
}
