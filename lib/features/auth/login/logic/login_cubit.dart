import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:team_ar/core/network/api_result.dart';
import 'package:team_ar/core/network/dio_factory.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/features/auth/login/model/login_request_body.dart';
import 'package:team_ar/features/auth/login/repos/login_repository.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import '../model/login_response.dart';
import 'login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/core/services/background_task_service.dart';
import 'package:team_ar/features/notification/services/push_notifications_services.dart';

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
        if (loginResponse.token != null) {
          DioFactory.setTokenIntoHeaderAfterLogin(loginResponse.token!);
        }

        log("User token: ${loginResponse.token}, Role: ${loginResponse.role}");

        final roleStr = loginResponse.role?.toLowerCase().trim() ?? '';
        final bool isTrainerRole = roleStr == 'trainer';
        final bool isAdminRole =
            roleStr == 'admin' || roleStr == 'adimn' || roleStr == 'administrator';

        // -------------------------------------------------------------
        // CASE 1: TRAINER
        // Trainers are staff/coaches. They have NO package subscriptions.
        // They NEVER expire.
        // -------------------------------------------------------------
        if (isTrainerRole) {
          final bool isIncomplete = (loginResponse.isDataCompleted == false);
          await saveUserData(loginResponse, isRealAdmin: false);
          if (isIncomplete) {
            emit(LoginState.navigateToCompleteData(loginResponse));
          } else {
            emit(LoginState.loginSuccess(loginResponse));
          }
          return;
        }

        // -------------------------------------------------------------
        // CASE 2: ADMIN
        // Admins are system administrators. They NEVER expire and never pay for trainee packages.
        // Always save session immediately with isRealAdmin: true.
        // -------------------------------------------------------------
        if (isAdminRole) {
          await saveUserData(loginResponse, isRealAdmin: true);
          emit(LoginState.loginSuccess(loginResponse));
          return;
        }

        // -------------------------------------------------------------
        // CASE 3: TRAINEE (either role="Trainee" or self-registered admin role)
        // -------------------------------------------------------------
        bool isUnpaid = (loginResponse.isPaid == false);

        if (loginResponse.id != null) {
          try {
            final api = getIt<ApiService>();
            final user = await api.getLoggedUserData(loginResponse.id!);

            if (loginResponse.isPaid == false ||
                user.endPackage == null ||
                user.remindDays == null ||
                user.remindDays! <= 0) {
              isUnpaid = true;
            }
          } catch (e) {
            log("Failed to verify user payment status: $e");
          }
        }

        // If user hasn't paid: let UI redirect to plans/payment (do NOT save session yet)
        if (isUnpaid) {
          log("User is not paid -> UI will navigate to plans");
          emit(LoginState.loginSuccess(loginResponse));
          return;
        }

        // If paid, check package expiry BEFORE saving (endPackage <= today)
        try {
          final userId = loginResponse.id;
          if (userId != null && userId.isNotEmpty) {
            final api = getIt<ApiService>();
            final user = await api.getLoggedUserData(userId);
            final end = user.endPackage;
            final expired =
                (end == null) || end.difference(DateTime.now()).inDays < 1;
            if (expired) {
              log("User package expired -> navigate to subscription expired (no save)");
              emit(LoginState.navigateToSubscriptionExpired(loginResponse));
              return;
            }
          }
        } catch (e) {
          log("Failed to verify subscription expiry: $e");
          emit(LoginState.navigateToSubscriptionExpired(loginResponse));
          return;
        }

        // Valid paid trainee: Save session and navigate to home
        await saveUserData(loginResponse, isRealAdmin: false);
        emit(LoginState.loginSuccess(loginResponse));
      },
      failure: (apiErrorModel) => emit(LoginState.loginFailure(apiErrorModel)),
    );
  }

  Future<void> saveUserData(LoginResponse loginResponse,
      {bool isRealAdmin = false}) async {
    if (loginResponse.token != null && loginResponse.token!.isNotEmpty) {
      await SharedPreferencesHelper.setString(
        AppConstants.token,
        loginResponse.token!,
      );
      DioFactory.setTokenIntoHeaderAfterLogin(loginResponse.token!);
    }
    String? idToSave = loginResponse.id;
    if ((idToSave == null || idToSave.isEmpty) && loginResponse.token != null) {
      try {
        final parts = loginResponse.token!.split('.');
        if (parts.length == 3) {
          final payload = base64Url.normalize(parts[1]);
          final decoded = utf8.decode(base64Url.decode(payload));
          final Map<String, dynamic> data = jsonDecode(decoded);
          idToSave = (data['nameid'] ??
              data['sub'] ??
              data['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
              data['UserId'] ??
              data['id'])?.toString();
        }
      } catch (e) {
        log("JWT userId extract error in LoginCubit: $e");
      }
    }

    if (idToSave != null && idToSave.isNotEmpty) {
      await SharedPreferencesHelper.setString(
        AppConstants.userId,
        idToSave,
      );
    }
    await SharedPreferencesHelper.setData(
      'is_real_admin',
      isRealAdmin,
    );

    // Save normalized role string
    String roleToSave;
    if (isRealAdmin) {
      roleToSave = 'Admin';
    } else if (loginResponse.role?.toLowerCase().trim() == 'trainer') {
      roleToSave = 'Trainer';
    } else {
      roleToSave = 'Trainee';
    }

    await SharedPreferencesHelper.setString(
      AppConstants.userRole,
      roleToSave,
    );

    // persist dataCompleted flag safely without crashing on null
    final bool dataCompleted =
        isRealAdmin ? true : (loginResponse.isDataCompleted ?? false);
    await SharedPreferencesHelper.setData(
      AppConstants.dataCompleted,
      dataCompleted,
    );

    // If the logged-in user is a Trainee, fetch and save the trainer's info
    // so navigation_click.dart can open the correct chat without hardcoding.
    final isTrainee =
        !isRealAdmin && loginResponse.role?.toLowerCase() != 'trainer';
    if (isTrainee && loginResponse.id != null) {
      try {
        final api = getIt<ApiService>();
        // getAllChas returns the trainer as a contact — pick the first one
        final contacts = await api.getAllChas();
        if (contacts.isNotEmpty) {
          final trainer = contacts.first;
          if (trainer.id != null) {
            await SharedPreferencesHelper.setString(
                AppConstants.trainerId, trainer.id!);
            await SharedPreferencesHelper.setString(
                AppConstants.trainerName, trainer.userName ?? 'المدرب');
            await SharedPreferencesHelper.setString(
                AppConstants.trainerEmail, trainer.email ?? '');
            log('Trainer info saved: id=${trainer.id}, name=${trainer.userName}');
          }
        }
      } catch (e) {
        log('Could not fetch trainer info during login: $e');
      }
    }

    if (isRealAdmin) {
      BackgroundTaskService.initialize(
        'https://exiovcdrkakpwpvuplzb.supabase.co',
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV4aW92Y2Rya2FrcHdwdnVwbHpiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODcwNzY4NjMsImV4cCI6MjEwMjY1Mjg2M30.faEeC_8uh4CaxFJ50Ua8Et9OJtqcR57RB9Z6WZAxb3g',
      );
    } else {
      BackgroundTaskService.cancel();
    }

    // Register FCM device token and subscribe to user topics on login
    FirebaseNotificationsServices.sendFcmTokenToServer();
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
