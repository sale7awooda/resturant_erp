import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/payment_method/payment_method_provider.dart';
import 'package:starter_template/features/orders_list/place_order/order_model.dart';

class PaymentMethodSelector extends ConsumerWidget {
  final OrderModel? order;
  const PaymentMethodSelector({super.key, this.order});

  bool get _isLocked =>
      order != null &&
      (order!.orderStatus == OrderStatus.cancelled.name ||
          order!.orderStatus == OrderStatus.completed.name);

  bool get _isPending =>
      order != null && order!.orderStatus == OrderStatus.pending.name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerSelected = ref.watch(paymentMethodProvider);

    // Decide selected method:
    final selected = _isLocked
        ? order?.paymentType // locked → order's payment
        : _isPending
            ? providerSelected!.isNotEmpty
                ? providerSelected
                : order
                    ?.paymentType // pending → allow provider, fallback to order's
            : providerSelected; // no order → provider only

    return SizedBox(
      height: MediaQuery.sizeOf(context).width >= 1200 ? 130.h : 100.h,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TxtWidget(
            txt: "Select Payment Type",
            fontsize: MediaQuery.sizeOf(context).width >= 1200 ? 12.sp : 14.sp,
            fontWeight: FontWeight.w600,
            color: clrMainAppClr,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        m == PaymentMethod.cashPayment
                            ? Icons.attach_money_rounded
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
                            ? 11.sp
                            : 13.sp,
                      )
                    ],
                  ),
                  selected: isSelected,
                  onSelected: _isLocked
                      ? null // 🔹 Disabled if canceled/complete
                      : (_) {
                          debugPrint('Selected payment method: $m');
                          ref.read(paymentMethodProvider.notifier).state =
                              m.name;
                        },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
