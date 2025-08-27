import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/selctors/delivery_address_provider.dart';

class DeliveryAddressSelector extends ConsumerWidget {
  const DeliveryAddressSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(deliveryAddressProvider);
    final selected = ref.watch(selectedDeliveryAddressProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TxtWidget(
                  txt: "Delivery Address",
                  fontsize:
                      MediaQuery.sizeOf(context).width >= 1200 ? 12.sp : 14.sp,
                  fontWeight: FontWeight.w600,
                  color: clrMainAppClr,
                ),
                Icon(Icons.location_on, color: clrMainAppClr, size: 28.sp),
              ],
            ),
            gapH8,
            Center(
              child: Wrap(
                spacing: 5.w,
                runSpacing: 5.h,
                children: addresses.map((addr) {
                  final isSelected = selected == addr;
                  return InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () {
                      ref.read(selectedDeliveryAddressProvider.notifier).state =
                          addr;
                      debugPrint("✅ Selected address: $addr");
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      height: 50.h,
                      width: 80.w,
                      alignment: Alignment.center,
                      // padding: EdgeInsets.symmetric(horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: isSelected ? clrMainAppClr : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected ? clrMainAppClr : clrLightGrey,
                          width: 1.5.w,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: clrMainAppClr.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : [],
                      ),
                      child: TxtWidget(
                        txt: addr.toUpperCase(),
                        textAlign: TextAlign.center,
                        color: isSelected ? clrWhite : clrBlack,
                        fontWeight: FontWeight.w500,
                        fontsize: MediaQuery.sizeOf(context).width >= 1200
                            ? 9.sp
                            : 11.sp,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
