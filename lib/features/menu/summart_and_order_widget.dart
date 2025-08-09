import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/payment_method/payment_selection_tiles.dart';

class SummaryAndOrder extends ConsumerWidget {
  const SummaryAndOrder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final total = ref.watch(cartTotalProvider);
    // final count = ref.watch(cartCountProvider);
    return Container(
        // height: 10.h,
        padding: EdgeInsets.only(bottom: 5.w),
        // margin: EdgeInsets.all(10.w),
        // color: Colors.blue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              TxtWidget(
                txt:'test',// '$count item(s)',
                textAlign: TextAlign.center,
                fontsize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              TxtWidget(
                  txt: "test",//'Total: \$${total.toStringAsFixed(2)} SDG',
                  textAlign: TextAlign.center,
                  fontsize: 14.sp,
                  fontWeight: FontWeight.w500)
            ]),
            TxtWidget(
              txt: 'select payment method :',
              textAlign: TextAlign.center,
              fontsize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            gapH12,
            Center(
              child: SizedBox(
                  height: 80.h, width: 280.w, child: PaymentMethodSelector()),
            )
          ],
        ));
  }
}

// class SummayAndOrder extends StatelessWidget {
//   const SummayAndOrder({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         // height: 10.h,
//         padding: EdgeInsets.only(bottom: 5.w),
//         // margin: EdgeInsets.all(10.w),
//         // color: Colors.blue,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//               TxtWidget(
//                 txt: 'items total amount',
//                 textAlign: TextAlign.center,
//                 fontsize: 14.sp,
//                 fontWeight: FontWeight.w500,
//               ),
//               TxtWidget(
//                   txt: '20 SDG',
//                   textAlign: TextAlign.center,
//                   fontsize: 14.sp,
//                   fontWeight: FontWeight.w500)
//             ]),
//             TxtWidget(
//               txt: 'select payment method :',
//               textAlign: TextAlign.center,
//               fontsize: 14.sp,
//               fontWeight: FontWeight.w500,
//             ),
//             gapH12,
//             Center(
//               child: SizedBox(
//                   height: 80.h, width: 280.w, child: PaymentMethodSelector()),
//             )
//           ],
//         ));
//   }
// }
