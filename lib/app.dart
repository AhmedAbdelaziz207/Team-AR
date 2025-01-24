import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:team_ar/core/routing/app_router.dart';
import 'package:team_ar/core/routing/routes.dart';
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          initialRoute: Routes.splash,
          theme: ThemeData(
            fontFamily: context.locale.languageCode == 'ar' ? 'Cairo' : 'Roboto',
          ),
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    );
  }
}
