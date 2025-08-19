import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/features/auth/register/logic/register_state.dart';
import 'package:team_ar/features/auth/register/model/register_admin_request.dart';
import 'package:team_ar/features/auth/register/repos/register_repository.dart';

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

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final req = RegisterAdminRequest(
      userName: userNameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      startPackage: DateTime.parse(startPackageController.text.trim()),
      endPackage: DateTime.parse(endPackageController.text.trim()),
      packageId: int.tryParse(packageIdController.text.trim()) ?? 0,
    );

    emit(const RegisterState.loading());
    final result = await _repo.addTrainerByAdmin(req);
    if (isClosed) return;
    result.when(
      success: (data) => emit(RegisterState.success(data)),
      failure: (error) => emit(RegisterState.failure(error)),
    );
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
