import 'package:flutter/cupertino.dart';
import 'package:team_ar/core/network/api_result.dart';
import 'package:team_ar/features/auth/login/model/login_request_body.dart';
import 'package:team_ar/features/auth/login/repos/login_repository.dart';

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
      success: (data) => emit(LoginState.loginSuccess(data)),
      failure: (apiErrorModel) => emit(LoginState.loginFailure(apiErrorModel)),
    );
  }
}
