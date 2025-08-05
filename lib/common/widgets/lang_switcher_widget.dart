// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class LanguageSwitcher extends ConsumerWidget {
//   const LanguageSwitcher({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final currentLocale = context.locale;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: SizedBox(
//         width: MediaQuery.sizeOf(context).width * .9,
//         height: 70.h,
//         child: Center(
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               InkWell(
//                 onTap: () async {
//                   final newLocale = const Locale('en');
//                   if (currentLocale != newLocale) {
//                     await context.setLocale(newLocale);
//                     // persist choice manually if needed
//                     ref
//                         .read(prefStringProvider.notifier)
//                         .saveString('language', 'en');
//                   }
//                 },
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     color: currentLocale.languageCode == 'en'
//                         ? AppConstants().appMainClr
//                         : clrLightGrey,
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Image.asset('images/ukFlag.png',
//                           height: 30.h, width: 30.h),
//                       TxtWidget(txt: 'English'.tr(), fontsize: 16.sp),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               InkWell(
//                 onTap: () async {
//                   final newLocale = const Locale('ar');
//                   if (currentLocale != newLocale) {
//                     await context.setLocale(newLocale);
//                     ref
//                         .read(prefStringProvider.notifier)
//                         .saveString('language', 'ar');
//                   }
//                 },
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     color: currentLocale.languageCode == 'ar'
//                         ? AppConstants().appMainClr
//                         : clrLightGrey,
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Image.asset('images/kuFlag.png',
//                           height: 30.h, width: 30.h),
//                       TxtWidget(txt: 'Arabic'.tr(), fontsize: 16.sp),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
