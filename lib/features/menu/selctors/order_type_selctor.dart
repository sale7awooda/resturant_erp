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

    // Define the icons for each order type
    final Map<OrderType, IconData> icons = {
      OrderType.takeaway: Icons.shopping_bag_rounded,
      OrderType.dinein: Icons.dinner_dining_outlined,
      OrderType.delivery: Icons.delivery_dining_outlined,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        gapH4,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TxtWidget(
              txt: "Select Order Type",
              fontsize:
                  MediaQuery.sizeOf(context).width >= 1200 ? 12.sp : 14.sp,
              fontWeight: FontWeight.w600,
              color: clrMainAppClr,
            ),Icon(Icons.menu_rounded, color: clrMainAppClr, size: 28.sp)
          ],
        ),gapH8,
        Center(
          child: Wrap(
            spacing: 7.w,
            runSpacing: 7.h,
            children: OrderType.values.map((type) {
              final isSelected = orderType == type;
              return InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () => ref.read(orderTypeProvider.notifier).state = type,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding:
                      EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: isSelected ? clrMainAppClr : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: isSelected ? clrMainAppClr : clrLightGrey,
                        width: 1.5.w),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: clrMainAppClr.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icons[type],
                        size: 28.sp,
                        color: isSelected ? clrWhite : clrBlack,
                      ),
                      SizedBox(height: 5.h),
                      TxtWidget(
                        txt: type.name.toUpperCase(),
                        color: isSelected ? clrWhite : clrBlack,
                        fontsize: MediaQuery.sizeOf(context).width >= 1200
                            ? 10.sp
                            : 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }
}
