import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:team_ar/core/network/api_result.dart';
import 'package:team_ar/core/network/dio_factory.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/features/auth/login/model/login_request_body.dart';
import 'package:team_ar/features/auth/login/repos/login_repository.dart';
import '../../../../core/prefs/shared_pref_manager.dart';
import '../model/login_response.dart';
import 'login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._loginRepo) : super(const LoginState.loginInitial());
  final LoginRepository _loginRepo;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void emitLoginStates(LoginRequestBody loginRequestBody) async {
    emit(const LoginState.loginLoading());

    final ApiResult result = await _loginRepo.login(loginRequestBody);
    result.when(
      success: (data) async {
        final loginResponse = data as LoginResponse;
        log("User token: ${loginResponse.token}");

        await saveUserData(loginResponse);

        emit(LoginState.loginSuccess(data));
      },
      failure: (apiErrorModel) => emit(LoginState.loginFailure(apiErrorModel)),
    );
  }

  Future<void> saveUserData(LoginResponse loginResponse) async {
    await SharedPreferencesHelper.setData(
      AppConstants.token,
      loginResponse.token,
    );
    await SharedPreferencesHelper.setData(
      AppConstants.userId,
      loginResponse.id,
    );
    await SharedPreferencesHelper.setData(
      AppConstants.userRole,
      loginResponse.role,
    );
    // persist dataCompleted flag
    if (loginResponse.isDataCompleted != null) {
      await SharedPreferencesHelper.setData(
        AppConstants.dataCompleted,
        loginResponse.isDataCompleted!,
      );
    }

    DioFactory.setTokenIntoHeaderAfterLogin(loginResponse.token!);
  }
}
