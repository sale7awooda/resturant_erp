import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/core/db_helper.dart';
import 'package:window_manager/window_manager.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await windowManager.ensureInitialized();

  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // 🔹 Initialize DB here before providers run
  await DBHelper.init();

  WindowOptions options = WindowOptions(
      minimumSize: Size(800, 800),
      size: Size(1200, 800),
      center: true,
      title: tr(AppConstants().appName));
  windowManager.waitUntilReadyToShow(options, () {
    windowManager.show();
    windowManager.focus();
  });

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: [Locale('en'), Locale('ar')],
        path: 'assets/translation',
        fallbackLocale: Locale('ar'),
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1200, 800),
      splitScreenMode: false,
      minTextAdapt: true,
      builder: (_, __) => MaterialApp.router(
        // title: tr(AppConstants().appName),
        routerConfig: goRouter,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        builder: EasyLoading.init(),
        theme: ThemeData(
          scaffoldBackgroundColor: clrWhite,
          // primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: clrMainAppClr,
            primary: clrMainAppClr,
            surface: clrWhite,
            secondary: clrGrey, // Colors.blueGrey,
          ),
        ),
      ),
    );
  }
}
