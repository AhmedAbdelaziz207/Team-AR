import 'package:team_ar/core/network/api_result.dart';
import 'package:team_ar/features/auth/login/model/login_request_body.dart';
import 'package:team_ar/features/auth/login/repos/login_repository.dart';

import 'login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._loginRepo) : super(const LoginState.initial());
  final LoginRepository _loginRepo;

  emitLoginStates(LoginRequestBody loginRequestBody) async {
    emit(const LoginState.loading());

    final ApiResult result = await _loginRepo.login(loginRequestBody);
    result.when(
      success: (data) => emit(LoginState.success(data)),
      failure: (apiErrorModel) => emit(LoginState.failure(apiErrorModel)),
    );
  }
}
