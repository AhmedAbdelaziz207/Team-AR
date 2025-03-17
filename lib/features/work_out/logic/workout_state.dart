import 'package:equatable/equatable.dart';
import 'package:team_ar/features/work_out/model/workout_model.dart';

class WorkoutState extends Equatable {
final int selectedDay;
final List<WorkoutModel> exercises;

WorkoutState({required this.selectedDay, required this.exercises});

@override
List<Object?> get props => [selectedDay, exercises];

WorkoutState copyWith({int? selectedDay, List<WorkoutModel>? exercises}) {
 return WorkoutState(
  selectedDay: selectedDay ?? this.selectedDay,
  exercises: exercises ?? this.exercises,
 );
}
}