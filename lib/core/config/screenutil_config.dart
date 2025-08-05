
import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenUtilInit extends StatelessWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const ScreenUtilInit({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // designSize: Size(375, 812),
      builder: builder,
    );
  }
}
