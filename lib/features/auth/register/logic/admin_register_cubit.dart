import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/features/auth/register/logic/register_state.dart';
import 'package:team_ar/features/auth/register/model/register_admin_request.dart';
import 'package:team_ar/features/auth/register/repos/register_repository.dart';
import 'package:team_ar/features/trainer_register_success/model/register_success_model.dart';

class AdminRegisterCubit extends Cubit<RegisterState> {
  AdminRegisterCubit(this._repo) : super(const RegisterState.initial());
  final RegisterRepository _repo;

  final formKey = GlobalKey<FormState>();

  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final startPackageController = TextEditingController();
  final endPackageController = TextEditingController();
  final packageIdController = TextEditingController();

  // Cached credentials to pass to success screen after registration
  RegisterSuccessModel? _lastCreatedUser;
  RegisterSuccessModel? get lastCreatedUser => _lastCreatedUser;

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    // Cache credentials BEFORE sending (API doesn't return password)
    final savedEmail = emailController.text.trim();
    final savedPassword = passwordController.text;
    final savedUserName = userNameController.text.trim();

    final req = RegisterAdminRequest(
      userName: savedUserName,
      email: savedEmail,
      password: savedPassword,
      startPackage: DateTime.parse(startPackageController.text.trim()),
      endPackage: DateTime.parse(endPackageController.text.trim()),
      packageId: int.tryParse(packageIdController.text.trim()) ?? 0,
    );

    emit(const RegisterState.loading());
    final result = await _repo.addTrainerByAdmin(req);
    if (isClosed) return;
    result.when(
      success: (data) async {
        // Build success model with cached credentials
        _lastCreatedUser = RegisterSuccessModel(
          userName: data.userName ?? savedUserName,
          email: savedEmail,
          password: savedPassword,
        );
        emit(RegisterState.success(data));
        // Fire-and-forget payment update WITHOUT changing state
        _updateUserPaymentSilently(data.id ?? '');
      },
      failure: (error) => emit(RegisterState.failure(error)),
    );
  }

  /// Updates payment status in the background without affecting UI state
  Future<void> _updateUserPaymentSilently(String userId) async {
    if (userId.isEmpty) return;
    try {
      await _repo.updateUserPayment(userId);
    } catch (_) {
      // Silently ignore — non-critical
    }
  }

  @override
  Future<void> close() {
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    startPackageController.dispose();
    endPackageController.dispose();
    packageIdController.dispose();
    return super.close();
  }
}
