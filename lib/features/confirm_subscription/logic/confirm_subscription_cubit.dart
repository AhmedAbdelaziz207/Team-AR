import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/features/plans_screen/model/user_plan.dart';

part 'confirm_subscription_state.dart';

class ConfirmSubscriptionCubit extends Cubit<ConfirmSubscriptionState> {
  ConfirmSubscriptionCubit() : super(ConfirmSubscriptionInitial());

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isSendImages = false;
  late final UserPlan userPlan ;
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final trainingDaysController = TextEditingController();
  final smokingController = TextEditingController();
  final lastTrainedController = TextEditingController();
  final painController = TextEditingController();
  final allergyController = TextEditingController();
  final infectionController = TextEditingController();
  final  genderController = TextEditingController();

  @override
  Future<void> close() {
    // Dispose controllers when Cubit is closed
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    addressController.dispose();
    heightController.dispose();
    weightController.dispose();
    trainingDaysController.dispose();
    smokingController.dispose();
    lastTrainedController.dispose();
    painController.dispose();
    allergyController.dispose();
    infectionController.dispose();
    genderController.dispose();
    return super.close();
  }
}
