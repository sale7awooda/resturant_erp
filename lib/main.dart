import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/core/new_db_helper.dart';
import 'package:starter_template/features/auth/auth_dao.dart';
import 'package:starter_template/features/auth/auth_models.dart';
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
  await NewDBHelper.init();
  await seed();

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

Future<void> seed() async {
  // --- Create Admin Role ---
  final existingAdminRole = await AuthDao.getRoleByName('admin');
  if (existingAdminRole == null) {
    await AuthDao.createRole(RoleModel(
      roleName: 'admin',
      permissions: json.encode([
        'orders.view',
        'orders.edit',
        'menu.view',
        'menu.edit',
        'staff.view',
        'staff.edit',
        'reports.view',
        'settings.edit',
        'settings.view',
        'settings.delete',
        'logs.view',
        'inventory.view',
        'inventory.edit',
        'categories.view',
        'categories.edit',
        'tables.view',
        'tables.edit',
        'auth.view',
        'auth.edit',
        'dashboard.view'
      ]),
    ));
  }

  final adminRole = await AuthDao.getRoleByName('admin');

  // --- Create Default Admin User ---
  final existingAdminUser = await AuthDao.getUserByUsername('admin');
  if (existingAdminUser == null) {
    await AuthDao.registerUser(
      username: 'admin',
      email: 'admin@gmail.com',
      password: 'Admin123',
      roleId: adminRole?.id,
    );
  }
  // --- Create cashier Role ---
  final existingCashierRole = await AuthDao.getRoleByName('cashier');
  if (existingCashierRole == null) {
    await AuthDao.createRole(RoleModel(
      roleName: 'cashier',
      permissions: json.encode([
        'orders.view',
        'orders.edit',
        'menu.view',
        'menu.edit',
        'staff.view',
        'staff.edit',
        'reports.view',
        // 'settings.edit',
        'settings.view',
        // 'settings.delete',
        'logs.view',
        'inventory.view',
        // 'inventory.edit',
        'categories.view',
        // 'categories.edit',
        'tables.view',
        // 'tables.edit',
        'auth.view',
        // 'auth.edit',
        'dashboard.view'
      ]),
    ));
  }

  final cashierRole = await AuthDao.getRoleByName('cashier');

  // --- Create Default Admin User ---
  final existingCashierUser = await AuthDao.getUserByUsername('cashier');
  if (existingCashierUser == null) {
    await AuthDao.registerUser(
      username: 'cashier',
      email: 'cashier@gmail.com',
      password: 'Cashier123',
      roleId: cashierRole?.id,
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(1200, 800),
      splitScreenMode: false,
      minTextAdapt: true,
      builder: (_, __) => MaterialApp.router(
        // title: tr(AppConstants().appName),
        routerConfig: ref.watch(goRouterProvider),
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
