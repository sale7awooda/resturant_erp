import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/orders/order_model.dart';
import 'package:starter_template/features/orders/order_details_screen.dart';
import 'package:starter_template/features/orders/orders_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(allOrdersProvider);

    return Scaffold(
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (orders) => _buildDashboard(context, ref, orders),
      ),
    );
  }

  Widget _buildDashboard(
      BuildContext context, WidgetRef ref, List<OrderModel> orders) {
    final now = DateTime.now();

    // --- Filtered ---
    final todayOrders =
        orders.where((o) => _isSameDay(o.createdAt, now)).toList();
    final weekOrders = orders
        .where(
            (o) => o.createdAt.isAfter(now.subtract(const Duration(days: 7))))
        .toList();
    final monthOrders = orders
        .where((o) =>
            o.createdAt.month == now.month && o.createdAt.year == now.year)
        .toList();

    final dineinPending = orders
        .where((o) =>
            o.orderType.toLowerCase() == "dinein" &&
            o.paymentStatus.toLowerCase() == "pending")
        .toList();
    final deliveryPending = orders
        .where((o) =>
            o.orderType.toLowerCase() == "delivery" &&
            o.paymentStatus.toLowerCase() == "pending")
        .toList();

    // --- Revenue ---
    double revenueToday = todayOrders.fold(0, (s, o) => s + o.totalAmount);
    double revenueWeek = weekOrders.fold(0, (s, o) => s + o.totalAmount);
    double revenueMonth = monthOrders.fold(0, (s, o) => s + o.totalAmount);
    // double revenueTotal = orders.fold(0, (s, o) => s + o.totalAmount);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TxtWidget(
              txt: "Dashboard",
              fontsize:
                  MediaQuery.sizeOf(context).width >= 1200 ? 16.sp : 18.sp,
              fontWeight: FontWeight.w700),
          gapH4,
          TxtWidget(
              txt: "📊 Summary",
              fontsize:
                  MediaQuery.sizeOf(context).width >= 1200 ? 14.sp : 16.sp,
              fontWeight: FontWeight.w600,
              color: clrMainAppClr),
          gapH4,

          // --- Summary Cards ---
          Center(
              child: Wrap(spacing: 6.w, runSpacing: 8.h, children: [
            _summaryCard("Today's Orders", todayOrders.length.toString(),
                Icons.today, clrMainAppClr, context),
            _summaryCard("This Week", weekOrders.length.toString(),
                Icons.calendar_view_week, clrOrange, context),
            _summaryCard("This Month", monthOrders.length.toString(),
                Icons.calendar_month, clrGrey, context),
            _summaryCard(
                "Revenue Today",
                "${revenueToday.toStringAsFixed(0)} SDG",
                Icons.attach_money,
                clrGreen,
                context),
            _summaryCard(
                "Revenue Week",
                "${revenueWeek.toStringAsFixed(0)} SDG",
                Icons.trending_up,
                Colors.blue,
                context),
            _summaryCard(
                "Revenue Month",
                "${revenueMonth.toStringAsFixed(0)} SDG",
                Icons.stacked_bar_chart,
                clrpurble,
                context),
            // _summaryCard(
            //     "Total Revenue",
            //     "${revenueTotal.toStringAsFixed(0)} SDG",
            //     Icons.savings,
            //     Colors.teal,
            //     context,
            //     highlight: true),
            _summaryCard(
                "Pending Payments",
                (dineinPending.length + deliveryPending.length).toString(),
                Icons.pending_actions,
                clrRed,
                context)
          ])),
          gapH4,
          TxtWidget(
            txt: "⚠ Pending Payments",
            fontsize: MediaQuery.sizeOf(context).width >= 1200 ? 14.sp : 16.sp,
            fontWeight: FontWeight.w600,
            color: clrRed,
          ),
          gapH4,

          _ordersSection(
              context, "Dine-In", Icons.restaurant, dineinPending, ref),
          gapH4,
          _ordersSection(
              context, "Delivery", Icons.delivery_dining, deliveryPending, ref),
        ],
      ),
    );
  }

  // ✅ Summary Card
  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    BuildContext ctx,
    // {bool highlight = false}
  ) {
    return SizedBox(
      width: 130.w,
      height: MediaQuery.sizeOf(ctx).width >= 1200 ? 100.h : 95.h,
      child: Card(
        elevation: 5, //highlight ? 5 : 2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        child: Padding(
          padding: EdgeInsets.all(5.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 25.sp),
              TxtWidget(
                txt: value,
                fontsize: MediaQuery.sizeOf(ctx).width >= 1200 ? 14.sp : 16.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              TxtWidget(
                txt: title,
                fontsize: MediaQuery.sizeOf(ctx).width >= 1200 ? 11.sp : 12.sp,
                fontWeight: FontWeight.w600,
                color: clrLightBlack,
              )
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Orders Section (only shows when there are orders, otherwise collapsed with a message)
  Widget _ordersSection(
    BuildContext context,
    String title,
    IconData icon,
    List<OrderModel> orders,
    WidgetRef ref,
  ) {
    if (orders.isEmpty) {
      // 🔹 Return a collapsed info row instead of ExpansionTile
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
            gapW8,
            TxtWidget(
              txt: "No pending $title orders 🎉",
              fontsize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.green,
            ),
          ],
        ),
      );
    }

    // 🔹 If there ARE pending orders, show the ExpansionTile
    return Card(
      child: ExpansionTile(
        initiallyExpanded: true, // expand automatically since there are items
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        tilePadding: EdgeInsets.symmetric(horizontal: 10.w),
        childrenPadding: EdgeInsets.all(8.w),
        leading: Icon(icon, color: clrMainAppClr, size: 26.sp),
        title: TxtWidget(
          txt: title,
          fontsize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        children: [
          SizedBox(
            height: 130.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) =>
                  _orderCard(context, orders[index], ref),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Single Order Card
  Widget _orderCard(BuildContext context, OrderModel order, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () {
        if (order.specialOrderId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => OrderDetailsScreen(
                    specialOrderId: order.specialOrderId.toString())),
          );
        }
      },
      child: Container(
        width: 170.w,
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: clrWhite,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TxtWidget(
              txt: "Order# ${order.specialOrderId}",
              fontsize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  order.orderType == "dinein"
                      ? Icons.table_restaurant_rounded
                      : Icons.location_pin,
                  size: 16.sp,
                  color: clrMainAppClr,
                ),
                gapW4,
                Flexible(
                  child: TxtWidget(
                    txt: order.orderType == "dinein"
                        ? "${order.tableName}"
                        : "${order.deliveryAddress}",
                    fontsize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: clrMainAppClr,
                  ),
                )
              ],
            ),
            TxtWidget(
              txt: "${order.totalItems} items",
              fontsize: 13.sp,
              color: clrLightBlack,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              TxtWidget(
                  txt: "SDG ${order.totalAmount.toStringAsFixed(0)}",
                  fontsize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: clrGreen),
              gapW4,
              (order.deliveryFee != null && order.deliveryFee! > 0)
                  ? TxtWidget(
                      txt: "(+${order.deliveryFee})",
                      fontsize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: clrLightBlack)
                  : SizedBox.shrink()
            ]),
            Text(
              DateFormat("dd MMM, hh:mm a").format(order.createdAt),
              style: const TextStyle(fontSize: 12, color: clrLightBlack),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) =>
      d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}
