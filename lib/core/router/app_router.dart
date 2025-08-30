import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import '../../features/auth/splash_screen.dart';

final goRouter = GoRouter(initialLocation: '/dashboard', routes: [
  ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(
            path: '/dashboard', builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/menu', builder: (_, __) => MenuScreen()),
        GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),

        // New dynamic route for OrderDetailsScreen
        GoRoute(
          path: '/order-details/:id',
          builder: (context, state) {
            // final id = int.tryParse(state.pathParameters['id'] ?? '');
            final id = state.pathParameters['id'] ?? ''; // fallback
            return OrderDetailsScreen(specialOrderId: id);
          },
        ),

        GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
        GoRoute(
            path: '/inventory', builder: (_, __) => const InventoryScreen()),
        GoRoute(path: '/staff', builder: (_, __) => const StaffScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(path: '/logs', builder: (_, __) => const LogsScreen())
      ])
]); // Provide the current route location (String, not GoRouter)
final currentRouteProvider = Provider<String>((ref) {
  return goRouter.location; // <-- String like "/dashboard"
});

enum AppScreen {
  splash,
  dashboard,
  menu,
  orders,
  orderDetails,
  reports,
  inventory,
  staff,
  settings,
  logs,
  unknown
}

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
  if (location.startsWith('/splash')) return AppScreen.splash;

  return AppScreen.unknown;
});
