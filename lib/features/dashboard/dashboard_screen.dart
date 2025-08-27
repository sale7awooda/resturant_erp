import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/selctors/order_type_provider.dart';
import 'package:starter_template/features/orders_list/place_order/orders_provider.dart';
import 'package:starter_template/features/orders_list/place_order/order_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersAsyncProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: ordersAsync.when(
        data: (orders) {
          final dineinPending = orders
              .where((o) =>
                  o.orderType.toLowerCase() == OrderType.dinein.name &&
                  o.paymentStatus.toLowerCase() == "pending")
              .toList();

          final deliveryPending = orders
              .where((o) =>
                  o.orderType.toLowerCase() == "delivery" &&
                  o.paymentStatus.toLowerCase() == "pending")
              .toList();

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            child: Column(
              children: [
                _ordersSection(
                  context,
                  "Pending Dine-In Payments",
                  Icons.restaurant,
                  dineinPending,
                ),
                gapH8,
                _ordersSection(
                  context,
                  "Pending Delivery Payments",
                  Icons.delivery_dining,
                  deliveryPending,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _ordersSection(
    BuildContext context,
    String title,
    IconData icon,
    List<OrderModel> orders,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            // --- Title Row ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TxtWidget(
                  txt: title,
                  fontsize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                const Spacer(),
                Icon(
                  icon,
                  color: clrMainAppClr,
                  size: 35.sp,
                ),
              ],
            ),

            // --- Orders Horizontal List ---
            SizedBox(
              height: 120.h,
              child: orders.isEmpty
                  ? const Center(child: Text("No pending payments 🎉"))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _orderCard(context, order
                            // ,order.orderType.toLowerCase() == "dinein"
                            );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderCard(BuildContext context, OrderModel order
      // , bool isDinein
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () {
        // Navigate using GoRouter with the order ID
        GoRouter.of(context).push('/order-details/${order.id}');
      },
      child: Container(
        width: 150.h,
        padding: EdgeInsets.all(12.h),
        decoration: BoxDecoration(
          color: clrWhite,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TxtWidget(
              txt: "Order #${order.id}",
              fontsize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
            gapH4,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TxtWidget(
                    txt: "${order.totalItems} items",
                    fontsize: 14.sp,
                    color: clrLightBlack),
                order.orderType == OrderType.dinein.name
                    ? Row(children: [
                        Icon(Icons.table_restaurant_rounded,
                            color: clrMainAppClr),
                        gapW4,
                        TxtWidget(
                            txt: "${order.tableName}",
                            fontsize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: clrMainAppClr)
                      ])
                    : Row(children: [
                        Icon(Icons.location_pin, color: clrMainAppClr),
                        gapW4,
                        TxtWidget(
                            txt: "${order.deliveryAddress}",
                            fontsize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: clrMainAppClr)
                      ])
              ],
            ),
            Center(
              child: TxtWidget(
                txt: "SDG ${order.totalAmount.toStringAsFixed(0)}",
                fontsize: 15.sp,
                fontWeight: FontWeight.w600,
                color: clrMainAppClr,
              ),
            ),
            gapH4,
            Center(
              child: Text(
                DateFormat("dd MMM, hh:mm a").format(order.createdAt),
                style: const TextStyle(fontSize: 12, color: clrLightBlack),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
