import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final SideMenuController _sideMenu = SideMenuController();

  // use a map list so we can access route/title/icon cleanly
  final List<Map<String, dynamic>> menuItems = [
    {'icon': Icons.dashboard, 'title': 'Dashboard', 'route': '/dashboard'},
    {'icon': Icons.restaurant_menu, 'title': 'Menu', 'route': '/menu'},
    {'icon': Icons.list_alt, 'title': 'Orders List', 'route': '/orders'},
    // {'icon': Icons.receipt_long, 'title': 'Bills', 'route': '/bills'},
    {'icon': Icons.inventory_2, 'title': 'Inventory', 'route': '/inventory'},
    // {'icon': Icons.history, 'title': 'History', 'route': '/history'},
    {'icon': Icons.people, 'title': 'Staff', 'route': '/staff'},
    {'icon': Icons.bar_chart, 'title': 'Reports', 'route': '/reports'},
    {'icon': Icons.history, 'title': 'Logs', 'route': '/logs'},
    {'icon': Icons.settings, 'title': 'Settings', 'route': '/settings'},
  ];

  @override
  void initState() {
    super.initState();
    // Optional: if you want to react when the user clicks the menu (sideMenu listeners)
    // _sideMenu.addListener((index) { print('menu changed to $index'); });
  }

  @override
  Widget build(BuildContext context) {
    // get current route location (works for go_router)
    final currentLocation = GoRouter.of(context).location;
    final selectedIndex =
        menuItems.indexWhere((m) => m['route'] == currentLocation);

    // Sync side menu selection with the current route AFTER build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedIndex != -1) {
        // safe call; the controller belongs to this widget
        _sideMenu.changePage(selectedIndex);
      }
    });
    // ignore: unused_local_variable
    final locale = context.locale;
    return Scaffold(
      body: Row(
        children: [
          SideMenu(
            controller: _sideMenu,
            // style is supported by easy_sidemenu
            style: SideMenuStyle(
              backgroundColor: clrWhite,
              openSideMenuWidth: 170.w,
              // compactSideMenuWidth: 100.w,
              displayMode: SideMenuDisplayMode.auto,
              showHamburger: true,
              hoverColor: clrLightGrey, // Colors.blue.shade500,
              selectedHoverColor: clrGrey, //Colors.blue.shade600,
              selectedColor: clrMainAppClr,
              selectedTitleTextStyle:
                  const TextStyle(color: clrWhite, fontWeight: FontWeight.w600),
              selectedIconColor: Colors.white,
              unselectedTitleTextStyle: const TextStyle(
                  color: clrMainAppClr, fontWeight: FontWeight.w400),
              unselectedIconColor: clrMainAppClr,
            ),
            title: Column(
              children: [
                // gapH10,
                CircleAvatar(
                  backgroundColor: clrMainAppClrLight,
                  minRadius: 40.w,
                  child: TxtWidget(txt: 'LOGO'),
                ),
                Text('My App Name'.tr(),
                    style: TextStyle(color: clrBlack, fontSize: 18.sp)),
                const Divider(color: clrLightBlack, indent: 8, endIndent: 8),
              ],
            ),
            footer: Padding(
              padding: EdgeInsets.all(8.h),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(50.h)),
                onPressed: () {
                  // implement sign-out logic here
                  // e.g. clear auth and go to login or dashboard
                  // GoRouter.of(context).go('/dashboard');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
              ),
            ),
            items: [
              // create SideMenuItem entries from menuItems
              for (var i = 0; i < menuItems.length; i++)
                SideMenuItem(
                  title: menuItems[i]['title'].toString().tr(),
                  icon: Icon(menuItems[i]['icon'] as IconData),
                  onTap: (index, _) {
                    // navigate with go_router (index corresponds to the i)
                    final route = menuItems[index]['route'] as String;
                    GoRouter.of(context).go(route);
                  },
                ),
            ],
          ),

          // divider + content
          const VerticalDivider(width: 1),
          Expanded(
            child: Container(
              // color: Colors.grey[50],
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sideMenu.dispose();
    super.dispose();
  }
}
