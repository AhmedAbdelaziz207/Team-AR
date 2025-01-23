import 'package:easy_localization/easy_localization.dart';
import 'package:team_ar/app/app.dart';
import 'package:flutter/material.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  // Easy Localization init
  await EasyLocalization.ensureInitialized();

  runApp(const App());
}