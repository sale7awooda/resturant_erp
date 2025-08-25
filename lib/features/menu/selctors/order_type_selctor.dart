import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/selctors/order_type_provider.dart';

class OrderTypeSelector extends ConsumerWidget {
  const OrderTypeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderType = ref.watch(orderTypeProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      // mainAxisAlignment: MainAxisAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --- Choice Chips --- //
        Wrap(
            spacing: 5.w,
            // shrinkWrap: true,
            // scrollDirection: Axis.horizontal,
            direction: Axis.horizontal,
            children: [
              ChoiceChip(
                showCheckmark: false,
                selectedColor: clrMainAppClr,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 3.h),
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_bag_rounded,
                        color: orderType.name == OrderType.takeaway.name
                            ? clrWhite
                            : clrBlack, size: 30.h),
                    TxtWidget(
                        txt: OrderType.takeaway.name.toUpperCase(),
                        color: orderType.name == OrderType.takeaway.name
                            ? clrWhite
                            : clrBlack,
                        fontsize: MediaQuery.sizeOf(context).width >=1200? 11.sp:13.sp,
                        fontWeight: FontWeight.w500)
                  ],
                ),
                selected: orderType.name == OrderType.takeaway.name,
                onSelected: (_) => ref.read(orderTypeProvider.notifier).state =
                    OrderType.takeaway,
              ),
              ChoiceChip(
                showCheckmark: false,
                selectedColor: clrMainAppClr,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 0),
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.dinner_dining_outlined,
                        color: orderType.name == OrderType.dinein.name
                            ? clrWhite
                            : clrBlack,
                        size: 30.h),
                    TxtWidget(
                        txt: OrderType.dinein.name
                            .toUpperCase()
                            .split('DINE')
                            .join('DINE '),
                        color: orderType.name == OrderType.dinein.name
                            ? clrWhite
                            : clrBlack,
                        fontsize: MediaQuery.sizeOf(context).width >=1200? 11.sp:13.sp,
                        fontWeight: FontWeight.w500)
                  ],
                ),
                selected: orderType.name == OrderType.dinein.name,
                onSelected: (_) => ref.read(orderTypeProvider.notifier).state =
                    OrderType.dinein,
              ),
              ChoiceChip(
                  showCheckmark: false,
                  selectedColor: clrMainAppClr,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 0),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.dinner_dining_outlined,
                          color: orderType.name == OrderType.delivery.name
                              ? clrWhite
                              : clrBlack,
                          size: 30.h),
                      TxtWidget(
                          txt: OrderType.delivery.name.toUpperCase(),
                          color: orderType.name == OrderType.delivery.name
                              ? clrWhite
                              : clrBlack,
                          fontsize:MediaQuery.sizeOf(context).width >=1200? 11.sp:13.sp,
                          fontWeight: FontWeight.w500)
                    ],
                  ),
                  selected: orderType.name == OrderType.delivery.name,
                  onSelected: (_) => ref
                      .read(orderTypeProvider.notifier)
                      .state = OrderType.delivery)
            ]),
        gapH12,
      ],
    );
  }
}
