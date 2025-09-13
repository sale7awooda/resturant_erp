// lib/layout/main_layout.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/auth/auth_provider.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  final SideMenuController _sideMenu = SideMenuController();

  final List<Map<String, dynamic>> menuItems = [
    {
      'icon': Icons.dashboard_rounded,
      'title': 'Dashboard',
      'route': '/dashboard',
      'perm': 'dashboard.view'
    },
    {
      'icon': Icons.restaurant_menu_rounded,
      'title': 'Menu',
      'route': '/menu',
      'perm': 'menu.view'
    },
    {
      'icon': Icons.list_alt_rounded,
      'title': 'Orders',
      'route': '/orders',
      'perm': 'orders.view'
    },
    {
      'icon': Icons.kitchen_outlined,
      'title': 'Inventory',
      'route': '/inventory',
      'perm': 'inventory.view'
    },
    {
      'icon': Icons.people_alt_rounded,
      'title': 'Staff',
      'route': '/staff',
      'perm': 'staff.view'
    },
    {
      'icon': Icons.bar_chart_rounded,
      'title': 'Reports',
      'route': '/reports',
      'perm': 'reports.view'
    },
    {
      'icon': Icons.history_rounded,
      'title': 'Logs',
      'route': '/logs',
      'perm': 'logs.view'
    },
    {
      'icon': Icons.settings_rounded,
      'title': 'Settings',
      'route': '/settings',
      'perm': 'settings.view'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouter.of(context).location;
    final selectedIndex =
        menuItems.indexWhere((m) => m['route'] == currentLocation);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedIndex != -1) _sideMenu.changePage(selectedIndex);
    });

    // ✅ Get current user permissions from provider
    final auth = ref.watch(authProvider);
    final permissions = auth.permissions;

    return Scaffold(
      body: Row(
        children: [
          SideMenu(
              controller: _sideMenu,
              style: SideMenuStyle(
                backgroundColor: clrWhite,
                openSideMenuWidth: 180.w,
                displayMode: SideMenuDisplayMode.auto,
                hoverColor: clrLightGrey,
                selectedColor: clrMainAppClr,
                selectedIconColor: Colors.white,
                selectedTitleTextStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
                unselectedTitleTextStyle: const TextStyle(color: clrMainAppClr),
                unselectedIconColor: clrMainAppClr,
              ),
              title: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: clrMainAppClrLight,
                    radius: 40.w,
                    child: TxtWidget(txt: 'LOGO'),
                  ),
                  SizedBox(height: 8.h),
                  Text('My App Name'.tr(),
                      style: TextStyle(color: clrBlack, fontSize: 16.sp)),
                  const Divider(),
                ],
              ),
              footer: Padding(
                padding: EdgeInsets.all(8.h),
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(authProvider).logout();
                    GoRouter.of(context).go('/login');
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                ),
              ),
              items: [
                for (var i = 0; i < menuItems.length; i++)
                  SideMenuItem(
                    title: menuItems[i]['title'].toString(),
                    icon: Icon(
                      menuItems[i]['icon'] as IconData,
                      color: permissions.contains(menuItems[i]['perm'])
                          ? clrMainAppClr
                          : clrLightGrey, // greyed-out icon
                    ),
                    onTap: permissions.contains(menuItems[i]['perm'])
                        ? (index, _) {
                            final route = menuItems[index]['route'] as String;
                            GoRouter.of(context).go(route);
                          }
                        : null, // disables tap
                    badgeColor: Colors.transparent,
                    badgeContent: !permissions.contains(menuItems[i]['perm'])
                        ? const Icon(Icons.lock, size: 18, color: clrRed)
                        : null,
                    // enabled: permissions.contains(
                    //     menuItems[i]['perm']), // keeps easy_sidemenu happy
                    // titleTextStyle: TextStyle(
                    //     color: permissions.contains(menuItems[i]['perm'])
                    //         ? clrMainAppClr
                    //         : clrLightGrey, // greyed-out text
                    //     fontWeight: FontWeight.w600),
                  )
              ]),
          const VerticalDivider(width: 1),
          Expanded(
              child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: widget.child))
        ],
      ),
    );
  }
}
