// // payment_method_selector.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:starter_template/common/widgets/txt_widget.dart';
// import 'package:starter_template/core/constants.dart';
// import 'payment_method_provider.dart';

// class PaymentMethodSelector extends ConsumerWidget {
//   const PaymentMethodSelector({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final selectedMethod = ref.watch(paymentMethodProvider);

//     Widget buildButton(String method, IconData icon) {
//       final isSelected = selectedMethod == method;

//       return Expanded(
//         child: GestureDetector(
//           onTap: () {
//             ref.read(paymentMethodProvider.notifier).state = method;
//             debugPrint('Selected payment method: $method');
//           },
//           child:
// Container(
//             height: 90.h,
//             alignment: Alignment.center,
//             padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 2.h),
//             decoration: BoxDecoration(
//                 color: isSelected ? clrMainAppClr : clrWhite,
//                 borderRadius: BorderRadius.circular(10.w),
//                 border: Border.all(
//                     color: isSelected ? clrMainAppClr : clrLightGrey,
//                     width: 2.w)),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(icon, color: isSelected ? clrWhite : clrBlack),
//                 TxtWidget(
//                     txt: method,
//                     color: isSelected ? clrWhite : clrBlack,
//                     textAlign: TextAlign.center,
//                     fontsize: 14.sp),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     return Row(
//       children: [
//         buildButton("Cash Payment", Icons.attach_money),
//         const SizedBox(width: 12),
//         buildButton("Mobile Banking", Icons.mobile_screen_share_outlined),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/payment_method/payment_method_provider.dart';

class PaymentMethodSelector extends ConsumerWidget {
  const PaymentMethodSelector({super.key});
  // final methods = const ['Cash Payment', 'Mobile Banking'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(paymentMethodProvider);

    return Center(
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        // spacing: 8,
        children: PaymentMethod.values.map((m) {
          final isSelected = selected == m.name;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: ChoiceChip(
                showCheckmark: false,
                selectedColor: clrMainAppClr,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    side: BorderSide(
                        color: isSelected ? clrMainAppClr : clrLightGrey,
                        width: 2.w)),
                labelPadding: EdgeInsets.all(0),
                label: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(
                        m == PaymentMethod.cashPayment //'Cash Payment'
                            ? Icons.attach_money_rounded
                            : Icons.mobile_screen_share_rounded,
                        color: isSelected ? clrWhite : clrBlack,
                        size: 30.sp,
                      ),
                      TxtWidget(
                          txt: m == PaymentMethod.cashPayment
                              ? m.name.toUpperCase().split('CASH').join('CASH ')
                              : m.name
                                  .toUpperCase()
                                  .split('MOBILE')
                                  .join('MOBILE '),
                          color: isSelected ? clrWhite : clrBlack,
                          textAlign: TextAlign.center,
                          fontsize: 13.sp)
                    ]),
                selected: isSelected,
                onSelected: (_) {
                  debugPrint('Selected payment method: $m');
                  ref.read(paymentMethodProvider.notifier).state = m.name;
                }),
          );
        }).toList(),
      ),
    );
  }
}
