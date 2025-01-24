import 'package:easy_localization/easy_localization.dart';
import 'package:team_ar/app.dart';
import 'package:flutter/material.dart';
import 'package:team_ar/core/utils/app_assets.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  // Easy Localization init
  await EasyLocalization.ensureInitialized();

  runApp( EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: AppAssets.translationsPath,
      fallbackLocale: const Locale('en'),
      child: const App()
  ),
  );
}