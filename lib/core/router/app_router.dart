import 'package:go_router/go_router.dart';
import 'package:starter_template/features/bills/bills_screen.dart';
import 'package:starter_template/features/dashboard/dashboard_screen.dart';
// import 'package:starter_template/features/home/home_screen.dart';
import 'package:starter_template/features/inventory/inventory_screen.dart';
import 'package:starter_template/features/logs/history_screen.dart';
import 'package:starter_template/features/logs/logs_screen.dart';
import 'package:starter_template/features/menu/menu_screen.dart';
import 'package:starter_template/features/orders_list/orders_screen.dart';
import 'package:starter_template/features/reports/reports_screen.dart';
import 'package:starter_template/features/settings/settings_screen.dart';
import 'package:starter_template/features/sidemenu/sidemenu_widget.dart';
import 'package:starter_template/features/staff/staff_screen.dart';
import '../../features/splash/splash_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        // GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(
            path: '/dashboard', builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/menu', builder: (_, __) => const MenuScreen()),
        GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
        GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
        GoRoute(path: '/bills', builder: (_, __) => const BillsScreen()),
        GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
        GoRoute(
            path: '/inventory', builder: (_, __) => const InventoryScreen()),
        GoRoute(path: '/staff', builder: (_, __) => const StaffScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(path: '/logs', builder: (_, __) => const LogsScreen()),
      ],
    ),
  ],
);
