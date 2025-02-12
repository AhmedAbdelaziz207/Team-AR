import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:team_ar/core/prefs/shared_pref_manager.dart';
import 'package:team_ar/core/routing/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_local_keys.dart';

class LogoutButton extends StatefulWidget {
  const LogoutButton({super.key});

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
      ),
      onPressed: isPressed
          ? null
          : () {
              setState(() {
                isPressed = true;
              });
              logout(context);
            },
      child: isPressed
          ? const CircularProgressIndicator(
              color: AppColors.primaryColor,
            )
          : Text(
              AppLocalKeys.logout.tr(),
              style: const TextStyle(
                  color: AppColors.white, fontWeight: FontWeight.bold),
            ),
    );
  }

  void logout(BuildContext context) {
    SharedPreferencesHelper.removeAll().then((value) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.login,
            (route) => false,
      );
    });
  }

}
