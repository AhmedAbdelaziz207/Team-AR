import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/features/follow_up/logic/follow_up_state.dart';
import 'package:team_ar/features/follow_up/services/follow_up_service.dart';
import 'package:team_ar/features/home/admin/repos/trainees_repository.dart';

class FollowUpCubit extends Cubit<FollowUpState> {
  final FollowUpService followUpService;
  final TraineesRepository traineesRepository;

  FollowUpCubit({
    required this.followUpService,
    required this.traineesRepository,
  }) : super(const FollowUpInitial());

  Future<void> loadFollowUpTrainees() async {
    emit(const FollowUpLoading());
    try {
      final trainees = await followUpService
          .getFollowUpTraineesWithDetails(traineesRepository);
      if (isClosed) return;
      emit(FollowUpSuccess(trainees));
    } catch (e) {
      if (isClosed) return;
      emit(FollowUpFailure(e.toString()));
    }
  }
}
