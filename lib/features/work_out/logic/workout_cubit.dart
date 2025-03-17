import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:team_ar/features/work_out/logic/workout_state.dart';

import '../model/workout_model.dart';


class WorkoutCubit extends Cubit<WorkoutState> {
  WorkoutCubit() : super(WorkoutState(selectedDay: 1,exercises:[]));
  void selectDay(int day) {
    List<WorkoutModel> exercise = [];

    if(day==1){
      exercise= [
        WorkoutModel(title: "كيفية التسخين قبل التمرين",
            image1: "assets/images/workout1.png", image2: "assets/images/workout1.png"),
        WorkoutModel(title: "تمرين الصدر بالدامبل", image1: "assets/images/workout1.png",
            image2: "assets/images/workout1.png"),
      ];

    }
    if(day==2){
      exercise= [
        WorkoutModel(title: "تمرين الأرجل بالبار", image1: "assets/images/workout1.png", image2: "assets/images/workout1.png"),
        WorkoutModel(title: "تمرين القرفصاء", image1: "assets/images/workout1.png", image2: "assets/images/workout1.png"),
      ];
    }

    emit(state.copyWith(selectedDay: day, exercises: exercise));

  }

}
