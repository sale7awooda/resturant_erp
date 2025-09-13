// lib/core/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_template/features/auth/auth_provider.dart';
import 'package:starter_template/features/auth/login_screen.dart';
import 'package:starter_template/features/dashboard/dashboard_screen.dart';
import 'package:starter_template/features/inventory/inventory_screen.dart';
import 'package:starter_template/features/logs/logs_screen.dart';
import 'package:starter_template/features/menu/menu_screen.dart';
import 'package:starter_template/features/orders/order_details_screen.dart';
import 'package:starter_template/features/orders/orders_screen.dart';
import 'package:starter_template/features/reports/reports_screen.dart';
import 'package:starter_template/features/settings/settings_screen.dart';
import 'package:starter_template/features/sidemenu/sidemenu_widget.dart';
import 'package:starter_template/features/staff/staff_screen.dart';

/// GoRouter provider (Riverpod-aware)
final goRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: auth, // listen to AuthService changes
    redirect: (BuildContext context, GoRouterState state) {
      final loggedIn = auth.loggedIn;
      final loggingIn = state.location == '/login';

      // If not logged in → only allow /login
      if (!loggedIn && !loggingIn) return '/login';

      // If logged in and trying to go to login → go dashboard
      if (loggedIn && loggingIn) return '/dashboard';

      return null;
    },
    routes: [
      // 🔹 LOGIN (outside shell)
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // 🔹 AUTHENTICATED AREA
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) =>
                _fadePage(state, const DashboardScreen()),
          ),
          GoRoute(
            path: '/menu',
            pageBuilder: (context, state) => _fadePage(state, MenuScreen()),
          ),
          GoRoute(
            path: '/orders',
            pageBuilder: (context, state) =>
                _fadePage(state, const OrdersScreen()),
          ),
          GoRoute(
            path: '/order-details/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return _fadePage(
                state,
                OrderDetailsScreen(specialOrderId: id),
              );
            },
          ),
          GoRoute(
            path: '/reports',
            pageBuilder: (context, state) =>
                _fadePage(state, const ReportsScreen()),
          ),
          GoRoute(
            path: '/inventory',
            pageBuilder: (context, state) =>
                _fadePage(state, const InventoryScreen()),
          ),
          GoRoute(
            path: '/staff',
            pageBuilder: (context, state) =>
                _fadePage(state, const StaffScreen()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
                _fadePage(state, const SettingsScreen()),
          ),
          GoRoute(
            path: '/logs',
            pageBuilder: (context, state) =>
                _fadePage(state, const LogsScreen()),
          ),
        ],
      ),
    ],
  );
});

/// Fade transition for all routes
CustomTransitionPage _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

/// Current route as a Riverpod provider
final currentRouteProvider = Provider<String>((ref) {
  final router = ref.watch(goRouterProvider);
  return router.location;
});

/// Enum for screens
enum AppScreen {
  login,
  dashboard,
  menu,
  orders,
  orderDetails,
  reports,
  inventory,
  staff,
  settings,
  logs,
  unknown,
}

/// Map current route → AppScreen enum
final currentScreenProvider = Provider<AppScreen>((ref) {
  final location = ref.watch(currentRouteProvider);

  if (location.startsWith('/dashboard')) return AppScreen.dashboard;
  if (location.startsWith('/menu')) return AppScreen.menu;
  if (location.startsWith('/orders')) return AppScreen.orders;
  if (location.startsWith('/order-details')) return AppScreen.orderDetails;
  if (location.startsWith('/reports')) return AppScreen.reports;
  if (location.startsWith('/inventory')) return AppScreen.inventory;
  if (location.startsWith('/staff')) return AppScreen.staff;
  if (location.startsWith('/settings')) return AppScreen.settings;
  if (location.startsWith('/logs')) return AppScreen.logs;
  if (location.startsWith('/login')) return AppScreen.login;

  return AppScreen.unknown;
});
