import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/payment_method/payment_method_provider.dart';
import 'package:starter_template/features/orders/order_model.dart';

class PaymentMethodSelector extends ConsumerWidget {
  final OrderModel? order;
  const PaymentMethodSelector({super.key, this.order});

  bool _isLocked() =>
      order != null &&
      (order!.orderStatus == OrderStatus.cancelled.name ||
          order!.orderStatus == OrderStatus.completed.name);

  bool _isPending() =>
      order != null && order!.orderStatus == OrderStatus.pending.name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerSelected = ref.watch(paymentMethodProvider);

    // Determine selected method
    final selected = _isLocked()
        ? order?.paymentMethod // Locked → order's payment
        : _isPending()
            ? (providerSelected?.isNotEmpty ?? false)
                ? providerSelected
                : order?.paymentMethod
            : providerSelected; // Default → provider only

    final chipHeight = MediaQuery.sizeOf(context).width >= 1200 ? 140.h : 120.h;

    return SizedBox(
      height: chipHeight,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TxtWidget(
                txt: "Select Payment Type",
                fontsize:
                    MediaQuery.sizeOf(context).width >= 1200 ? 12.sp : 14.sp,
                fontWeight: FontWeight.w600,
                color: clrMainAppClr,
              ),
              Icon(Icons.attach_money_rounded,
                  color: clrMainAppClr, size: 28.sp),
            ],
          ),
          gapH8,
          Center(
            child: Wrap(
              spacing: 12.w,
              children: PaymentMethod.values.map((m) {
                final isSelected = (selected == m.name);

                return ChoiceChip(
                  showCheckmark: false,
                  elevation: isSelected ? 4 : 0,
                  pressElevation: 2,
                  selectedColor: clrMainAppClr,
                  backgroundColor: clrWhite,
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    side: BorderSide(
                      color: isSelected ? clrMainAppClr : clrLightGrey,
                      width: 1.5.w,
                    ),
                  ),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        m == PaymentMethod.cashPayment
                            ? Icons.money_rounded
                            : Icons.mobile_screen_share_rounded,
                        color: isSelected ? clrWhite : clrBlack,
                        size: 26.sp,
                      ),
                      gapH4,
                      TxtWidget(
                        txt: m == PaymentMethod.cashPayment ? "CASH" : "MOBILE",
                        color: isSelected ? clrWhite : clrBlack,
                        textAlign: TextAlign.center,
                        fontsize: MediaQuery.sizeOf(context).width >= 1200
                            ? 10.sp
                            : 12.sp,
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: _isLocked()
                      ? null
                      : (_) => ref.read(paymentMethodProvider.notifier).state =
                          m.name,
                );
              }).toList(),
            ),
          ),
          gapH8,
        ],
      ),
    );
  }
}
