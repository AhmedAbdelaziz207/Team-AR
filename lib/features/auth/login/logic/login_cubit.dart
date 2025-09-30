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
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_service.dart';

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
        DioFactory.setTokenIntoHeaderAfterLogin(loginResponse.token!);
          await  SharedPreferencesHelper.setString(
            AppConstants.userId,
            loginResponse.id!,
          );

        log("User token: ${loginResponse.token}");
        // Flags (we do NOT save yet)
        final bool isUnpaid = (loginResponse.isPaid == false);
        final bool isTrainer =
            loginResponse.role?.toLowerCase() == 'trainer'.toLowerCase();
        final bool isIncomplete = isTrainer &&
            ((loginResponse.isDataCompleted == null) ||
                (loginResponse.isDataCompleted == false));

        if (loginResponse.role?.toLowerCase() == 'admin'.toLowerCase()) {
          emit(LoginState.loginSuccess(loginResponse));
          saveUserData(loginResponse);
          return;
        }

        // If user hasn't paid: let UI redirect to plans/payment (do NOT save)
        if (isUnpaid) {
          log("User is not paid -> UI will navigate to plans");
          emit(LoginState.loginSuccess(loginResponse));
          return;
        }

        // If paid, check package expiry BEFORE saving (endPackage <= today)
        try {
          final userId = loginResponse.id;
          if (userId != null && userId.isNotEmpty) {
     
            DioFactory.setTokenIntoHeaderAfterLogin(loginResponse.token!);
            final api = getIt<ApiService>();

            final user = await api.getLoggedUserData(userId);
            final end = user.endPackage; // DateTime?
            final expired =
                (end == null) || end.difference(DateTime.now()).inDays < 1;
            if (expired) {
              log("User package expired -> navigate to subscription expired (no save)");
              emit(LoginState.navigateToSubscriptionExpired(loginResponse));
              return;
            }
          }
        } catch (e) {
          // If we fail to verify, be conservative and do not save; sen log("Failed to verify subscription expiry: $e");d to expired screen
          emit(LoginState.navigateToSubscriptionExpired(loginResponse));
          return;
        }

        // Handle incomplete data for trainers
        if (isIncomplete) {
          // Save now (valid paid user) so complete-data flow has token and info
          await saveUserData(loginResponse);
          emit(LoginState.navigateToCompleteData(loginResponse));
          return;
        }

        // Otherwise success
        await saveUserData(loginResponse);
        emit(LoginState.loginSuccess(loginResponse));
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
    await SharedPreferencesHelper.setData(
      AppConstants.dataCompleted,
      loginResponse.isDataCompleted!,
    );

    DioFactory.setTokenIntoHeaderAfterLogin(loginResponse.token!);
  }

  /// Check data completion status on app startup
  void checkDataCompletionOnStartup() async {
    final token = await SharedPreferencesHelper.getString(AppConstants.token);
    final userRole =
        await SharedPreferencesHelper.getString(AppConstants.userRole);
    final dataCompleted =
        await SharedPreferencesHelper.getBool(AppConstants.dataCompleted);
    final userId = await SharedPreferencesHelper.getString(AppConstants.userId);

    if (token != null &&
        userRole?.toLowerCase() == 'trainer'.toLowerCase() &&
        !dataCompleted) {
      // Create a mock LoginResponse for navigation
      final mockLoginResponse = LoginResponse(
        token: token,
        role: userRole,
        id: userId,
        isDataCompleted: dataCompleted,
      );
      emit(LoginState.navigateToCompleteData(mockLoginResponse));
    }
  }
}
