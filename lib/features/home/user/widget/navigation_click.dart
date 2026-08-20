import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/di/dependency_injection.dart';
import 'package:team_ar/core/network/api_service.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/routing/routes.dart';
import 'package:team_ar/core/utils/app_constants.dart';
import 'package:team_ar/features/admin_panal/widget/admin_manage_card.dart';
import 'package:team_ar/features/chat/model/chat_user_model.dart';
import 'package:team_ar/features/chat/services/supabase_chat_service.dart';
import 'package:team_ar/features/diet/logic/user_diet_cubit.dart';
import 'package:team_ar/features/diet/ui/user_diet_screen.dart';
import 'package:team_ar/features/home/user/logic/user_cubit.dart';
import 'package:team_ar/features/home/user/ui/user_home_screen.dart';
import 'package:team_ar/features/profile_screen/profile_screen.dart';
import 'package:team_ar/features/work_out/ui/work_out_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../logic/navigation/nav_bar_items.dart';
import '../logic/navigation/navigation_cubit.dart';
import '../logic/navigation/navigation_state.dart';

class NavigationClick extends StatelessWidget {
  const NavigationClick({super.key});

  /// Reads the trainer's ChatUserModel from SharedPreferences.
  /// If not cached, tries REST API, then Supabase as a last resort.
  Future<ChatUserModel> _getTrainerModel() async {
    String? id = await SharedPreferencesHelper.getString(AppConstants.trainerId);
    String? name = await SharedPreferencesHelper.getString(AppConstants.trainerName);
    String? email = await SharedPreferencesHelper.getString(AppConstants.trainerEmail);

    // Fallback 1: fetch from REST API (getAllChas)
    if (id == null || id.isEmpty) {
      try {
        final api = getIt<ApiService>();
        final contacts = await api.getAllChas();
        if (contacts.isNotEmpty) {
          final trainer = contacts.first;
          id = trainer.id ?? '';
          name = trainer.userName ?? 'المدرب';
          email = trainer.email ?? '';
          log('Trainer info from REST API: id=$id, name=$name');
        }
      } catch (e) {
        log('REST API fallback failed: $e');
      }
    }

    // Fallback 2: query Supabase for messages received by this trainee
    if (id == null || id.isEmpty) {
      try {
        final currentUserId =
            await SharedPreferencesHelper.getString(AppConstants.userId);
        if (currentUserId != null && currentUserId.isNotEmpty) {
          final supabaseService = SupabaseChatService();
          final trainerId =
              await supabaseService.getTrainerIdForTrainee(currentUserId);
          if (trainerId != null && trainerId.isNotEmpty) {
            id = trainerId;
            name = 'المدرب';
            email = '';
            log('Trainer ID from Supabase fallback: id=$id');
          }
        }
      } catch (e) {
        log('Supabase fallback failed: $e');
      }
    }

    // Save for future use (avoid repeated lookups)
    if (id != null && id.isNotEmpty) {
      await SharedPreferencesHelper.setString(AppConstants.trainerId, id);
      await SharedPreferencesHelper.setString(
          AppConstants.trainerName, name ?? 'المدرب');
      await SharedPreferencesHelper.setString(
          AppConstants.trainerEmail, email ?? '');
    }

    return ChatUserModel(
      id: id ?? '',
      userName: name ?? 'المدرب',
      email: email ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationCubit, NavigationState>(
      listenWhen: (previous, current) => current.navbarItem == NavBarItems.chat,
      listener: (context, state) async {
        final trainer = await _getTrainerModel();
        if (context.mounted) {
          Navigator.pushNamed(context, Routes.chat, arguments: trainer);
        }
      },
      child: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) {
          if (state.navbarItem == NavBarItems.home) {
            return const UserHomeScreen();
          }
          if (state.navbarItem == NavBarItems.workouts) {
            return const WorkOutScreen();
          }
          if (state.navbarItem == NavBarItems.food) {
            return BlocProvider(
              create: (context) => UserDietCubit(),
              child: const UserDietScreen(),
            );
          }
          if (state.navbarItem == NavBarItems.chat) {
            return Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(height: 30.h),
                      AdminManageCard(
                        title: "تواصل معنا",
                        cardColor: AppColors.lightBlue,
                        onTap: () async {
                          final trainer = await _getTrainerModel();
                          if (context.mounted) {
                            Navigator.pushNamed(context, Routes.chat,
                                arguments: trainer);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          if (state.navbarItem == NavBarItems.profile) {
            return BlocProvider(
              create: (context) => UserCubit(),
              child: const ProfileScreen(),
            );
          }
          return const SizedBox(); // Fallback UI
        },
      ),
    );
  }
}
