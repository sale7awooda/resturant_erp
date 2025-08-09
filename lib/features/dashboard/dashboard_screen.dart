// dashboard_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text('Dashboard'.tr(), style: TextStyle(fontSize: 24)));
  }
}
