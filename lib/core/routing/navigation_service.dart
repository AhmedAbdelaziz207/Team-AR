import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:team_ar/core/common/notification_model.dart';
import 'package:team_ar/core/common/notification_type_enum.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/features/chat/model/chat_user_model.dart';
import 'package:team_ar/features/home/user/logic/navigation/nav_bar_items.dart';
import 'package:team_ar/features/home/user/logic/navigation/navigation_cubit.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static Future<T?>? navigateTo<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState
        ?.pushNamed<T>(routeName, arguments: arguments);
  }

  static void goBack() {
    return navigatorKey.currentState?.pop();
  }

  static void _safelyNavigate(void Function() action) {
    if (navigatorKey.currentState != null) {
      action();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        action();
      });
    }
  }

  /// Admin-only follow-up navigation with strict role verification
  static void navigateToFollowUp({String? traineeId}) async {
    final userRole =
        await SharedPreferencesHelper.getString(AppConstants.userRole);
    final role = userRole?.toLowerCase().trim();
    final isAdmin =
        role == 'admin' || role == 'adimn' || role == 'administrator';

    if (!isAdmin) {
      debugPrint(
          "Navigation to follow up blocked: current user is not admin ($userRole)");
      return;
    }

    _safelyNavigate(() {
      navigatorKey.currentState?.pushNamed(
        Routes.followUpTrainees,
        arguments: traineeId,
      );
    });
  }

  /// Direct navigation to chat with either coach or specific user
  static Future<void> navigateToChat({
    ChatUserModel? user,
    String? senderId,
    String? senderName,
  }) async {
    ChatUserModel? chatUser = user;
    if (chatUser == null && senderId != null && senderId.isNotEmpty) {
      chatUser = ChatUserModel(
        id: senderId,
        userName: senderName ?? 'محادثة',
      );
    }
    if (chatUser == null) {
      final trainerId =
          await SharedPreferencesHelper.getString(AppConstants.trainerId);
      final trainerName =
          await SharedPreferencesHelper.getString(AppConstants.trainerName);
      if (trainerId != null && trainerId.isNotEmpty) {
        chatUser = ChatUserModel(
          id: trainerId,
          userName: trainerName ?? 'المدرب',
        );
      }
    }

    if (chatUser != null) {
      _safelyNavigate(() {
        navigatorKey.currentState?.pushNamed(
          Routes.chat,
          arguments: chatUser,
        );
      });
    }
  }

  /// Direct navigation to Diet (switches RootScreen to Food tab)
  static void navigateToDiet() {
    try {
      getIt<NavigationCubit>().getNavBarItem(NavBarItems.food);
    } catch (_) {}

    _safelyNavigate(() {
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    });
  }

  /// Direct navigation to Workouts (switches RootScreen to Workouts tab)
  static void navigateToWorkout() {
    try {
      getIt<NavigationCubit>().getNavBarItem(NavBarItems.workouts);
    } catch (_) {}

    _safelyNavigate(() {
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    });
  }

  /// Navigation to Subscription plans
  static void navigateToSubscription() {
    _safelyNavigate(() {
      navigatorKey.currentState?.pushNamed(Routes.plans);
    });
  }

  /// Unified routing handler for any notification payload (JSON or plain text)
  static void routeFromNotificationPayload(String payload) {
    if (payload.isEmpty) return;
    try {
      Map<String, dynamic>? data;
      try {
        final decoded = jsonDecode(payload);
        if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}

      final type = (data?['type'] ??
              (payload.contains('follow_up') ? 'follow_up' : ''))
          .toString()
          .toLowerCase();

      switch (type) {
        case 'follow_up':
          final traineeId = data?['trainee_id']?.toString();
          navigateToFollowUp(traineeId: traineeId);
          break;

        case 'chat':
        case 'chat_message':
          final senderId = (data?['senderId'] ??
                  data?['sender_id'] ??
                  data?['userId'])
              ?.toString();
          final senderName = (data?['senderName'] ??
                  data?['sender_name'] ??
                  data?['userName'])
              ?.toString();
          navigateToChat(senderId: senderId, senderName: senderName);
          break;

        case 'diet':
        case 'diet_plan':
        case 'food':
        case 'user_diet':
          navigateToDiet();
          break;

        case 'workout':
        case 'workout_plan':
        case 'workout_reminder':
        case 'exercise':
          navigateToWorkout();
          break;

        case 'subscription_expiry':
        case 'subscription_expiring':
        case 'subscription':
          navigateToSubscription();
          break;

        default:
          if (payload.contains('follow_up')) {
            navigateToFollowUp();
          } else if (payload.contains('chat')) {
            navigateToChat();
          } else if (payload.contains('diet') || payload.contains('food')) {
            navigateToDiet();
          } else if (payload.contains('workout') ||
              payload.contains('exercise')) {
            navigateToWorkout();
          }
          break;
      }
    } catch (e) {
      debugPrint("Error routing notification payload: $e");
    }
  }

  /// Unified routing handler for FCM RemoteMessage
  static void routeFromRemoteMessage(RemoteMessage message) {
    if (message.data.isNotEmpty) {
      routeFromNotificationPayload(jsonEncode(message.data));
    }
  }

  /// Unified routing handler for stored NotificationModel
  static void routeFromNotificationModel(NotificationModel notification) {
    if (notification.payload != null && notification.payload!.isNotEmpty) {
      routeFromNotificationPayload(notification.payload!);
      return;
    }

    switch (notification.type) {
      case NotificationType.chatMessage:
        navigateToChat();
        break;
      case NotificationType.workoutReminder:
      case NotificationType.workoutPlan:
        navigateToWorkout();
        break;
      case NotificationType.subscriptionExpiry:
        navigateToSubscription();
        break;
      default:
        break;
    }
  }
}
