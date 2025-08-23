import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/tabs_section/delivery_address_provider.dart';

class DeliveryAddressSelector extends ConsumerWidget {
  const DeliveryAddressSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final address = ref.watch(deliveryAddressProvider);
    final selected = ref.watch(selectedDeliveryAddressProvider);

    return SizedBox(
        // color: clrMainAppClrLight,
        // margin: EdgeInsets.symmetric(vertical: 10.h),
        // height: 200.h,
        // width: 290.w,
        // decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(10.r),
        //     border: Border.all(color: clrMainAppClr, width: 2.w)),
        child: Center(
      child: Wrap(
          spacing: 1.w,
          direction: Axis.horizontal,
          // scrollDirection: Axis.horizontal,
          // shrinkWrap: true,
          // physics: AlwaysScrollableScrollPhysics(),
          children: address.map((a) {
            final isSelected = selected == a;
            return Padding(
                // margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(2.w),
                child: ChoiceChip(
                    showCheckmark: false,
                    selectedColor: clrMainAppClr,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        side: BorderSide(
                            color: isSelected ? clrMainAppClr : clrLightGrey,
                            width: 2.w)),
                    labelPadding: EdgeInsets.all(0),
                    label: Container(
                      alignment: Alignment.center,
                      height: 40.h,
                      width: 50.w,
                      child: TxtWidget(
                          txt: a.toUpperCase(),
                          color: isSelected ? clrWhite : clrBlack,
                          fontWeight: FontWeight.w500,
                          textAlign: TextAlign.center,
                          fontsize: 12.sp),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(selectedDeliveryAddressProvider.notifier).state =
                          a;
                      debugPrint(
                          '=================================\n Selected table: $a');
                    }));
          }).toList()),
    ));
  }
}
