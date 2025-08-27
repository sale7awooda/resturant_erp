import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/payment_method/payment_method_provider.dart';
import 'package:starter_template/features/menu/selctors/order_type_provider.dart';
import 'package:starter_template/features/orders_list/place_order/order_model.dart';
import 'package:starter_template/features/orders_list/place_order/orders_provider.dart';
import 'order_details_screen.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  Future<void> _pickDate(BuildContext context, WidgetRef ref, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      // Drive the provider date so the query rebuilds with the chosen day
      ref.read(ordersAsyncProvider.notifier).setDate(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(ordersSelectedDateProvider); // single source of truth
    final ordersState = ref.watch(ordersAsyncProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Orders'),
        actions: [
          Card(
            child: TextButton.icon(
              style: TextButton.styleFrom(minimumSize: Size(200.w, 50.h)),
              onPressed: () => _pickDate(context, ref, selectedDate),
              icon: const Icon(Icons.calendar_today, color: clrMainAppClr),
              label: TxtWidget(
                txt: DateFormat('yyyy-MM-dd').format(selectedDate),
                fontsize: 16.sp,
                color: clrMainAppClr,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.read(ordersAsyncProvider.notifier).reload(),
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ordersState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (ordersForSelectedDate) {
          // Provider already filtered by selectedDate in DB query.
          if (ordersForSelectedDate.isEmpty) {
            return Center(
              child: TxtWidget(
                txt: "No orders for ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                fontWeight: FontWeight.w500,
                fontsize: 20.sp,
                color: clrLightBlack,
              ),
            );
          }

          final nonCancelled = ordersForSelectedDate
              .where((o) => o.orderStatus.toLowerCase() != OrderStatus.cancelled.name)
              .toList();

          final cancelled = ordersForSelectedDate
              .where((o) => o.orderStatus.toLowerCase() == OrderStatus.cancelled.name)
              .toList();

          // Columns
          final columns = <PlutoColumn>[
            PlutoColumn(
              title: 'ID',
              field: 'id',
              type: PlutoColumnType.number(),
              readOnly: true,
              width: 100.w,
              minWidth: 100.w,
              enableHideColumnMenuItem: false,
              textAlign: PlutoColumnTextAlign.center,
              titleTextAlign: PlutoColumnTextAlign.center,
              enableColumnDrag: false,
              enableContextMenu: false,
              enableRowDrag: false,
              enableRowChecked: true,
            ),
            PlutoColumn(
              title: 'Order Type',
              field: 'orderType',
              readOnly: true,
              type: PlutoColumnType.text(),
              width: 130.w,
              minWidth: 130.w,
              enableHideColumnMenuItem: false,
              textAlign: PlutoColumnTextAlign.center,
              titleTextAlign: PlutoColumnTextAlign.center,
              enableColumnDrag: true,
              enableContextMenu: false,
              enableRowDrag: false,
            ),
            PlutoColumn(
              title: 'Status',
              field: 'status',
              readOnly: true,
              type: PlutoColumnType.text(),
              width: 120.w,
              minWidth: 120.w,
              enableHideColumnMenuItem: false,
              textAlign: PlutoColumnTextAlign.center,
              titleTextAlign: PlutoColumnTextAlign.center,
              enableColumnDrag: true,
              enableContextMenu: false,
              enableRowDrag: false,
            ),
            PlutoColumn(
              title: 'Payment Status',
              field: 'paymentStatus',
              type: PlutoColumnType.text(),
              width: 160.w,
              minWidth: 160.w,
              readOnly: true,
              enableHideColumnMenuItem: false,
              textAlign: PlutoColumnTextAlign.center,
              titleTextAlign: PlutoColumnTextAlign.center,
              enableColumnDrag: true,
              enableContextMenu: false,
              enableRowDrag: false,
            ),
            PlutoColumn(
              title: 'Payment Type',
              field: 'paymentType',
              type: PlutoColumnType.text(),
              width: 160.w,
              minWidth: 160.w,
              readOnly: true,
              enableHideColumnMenuItem: false,
              textAlign: PlutoColumnTextAlign.center,
              titleTextAlign: PlutoColumnTextAlign.center,
              enableColumnDrag: true,
              enableContextMenu: false,
              enableRowDrag: false,
            ),
            PlutoColumn(
              title: 'Items',
              field: 'items',
              readOnly: true,
              type: PlutoColumnType.text(),
              width: 90.w,
              minWidth: 90.w,
              enableHideColumnMenuItem: false,
              textAlign: PlutoColumnTextAlign.center,
              titleTextAlign: PlutoColumnTextAlign.center,
              enableColumnDrag: true,
              enableContextMenu: false,
              enableRowDrag: false,
            ),
            PlutoColumn(
              title: 'Amount (SDG)',
              field: 'amount',
              readOnly: true,
              type: PlutoColumnType.text(),
              width: 150.w,
              minWidth: 150.w,
              enableHideColumnMenuItem: false,
              textAlign: PlutoColumnTextAlign.center,
              titleTextAlign: PlutoColumnTextAlign.center,
              enableColumnDrag: false,
              enableContextMenu: false,
              enableRowDrag: false,
            ),
            PlutoColumn(
              title: 'Actions',
              field: 'actions',
              readOnly: true,
              type: PlutoColumnType.text(),
              width: 120.w,
              minWidth: 120.w,
              enableHideColumnMenuItem: false,
              textAlign: PlutoColumnTextAlign.center,
              titleTextAlign: PlutoColumnTextAlign.center,
              enableColumnDrag: true,
              enableContextMenu: false,
              enableRowDrag: false,
              renderer: (rendererContext) {
                final status = rendererContext.row.cells['status']!.value
                    .toString()
                    .toLowerCase();

                if (status != "pending") {
                  return Container(
                    color: clrGrey,
                    height: 2.h,
                    width: 30.h,
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: "Edit",
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        final orderId =
                            rendererContext.row.cells['id']!.value as int;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailsScreen(orderId: orderId),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      tooltip: "Cancel",
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () async {
                        final orderId =
                            rendererContext.row.cells['id']!.value as int;
                        await ref.read(ordersAsyncProvider.notifier).cancelOrder(orderId);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Order cancelled")),
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            ),
            PlutoColumn(
              title: 'Created At',
              field: 'date',
              type: PlutoColumnType.text(),
              width: 160.w,
              minWidth: 150.w,
              readOnly: true,
              enableHideColumnMenuItem: false,
              textAlign: PlutoColumnTextAlign.center,
              titleTextAlign: PlutoColumnTextAlign.center,
              enableColumnDrag: true,
              enableContextMenu: false,
              enableRowDrag: false,
            ),
          ];

          // Rows (no extra date filtering here)
          final rows = ordersForSelectedDate.map((order) {
            return PlutoRow(cells: {
              'id': PlutoCell(value: order.id ?? 0),
              'date': PlutoCell(
                value: DateFormat('yyyy/MM/dd HH:mm').format(order.createdAt),
              ),
              'orderType': PlutoCell(
                value: order.orderType == OrderType.dinein.name
                    ? 'DINE-IN'
                    : order.orderType == OrderType.takeaway.name
                        ? 'TAKE AWAY'
                        : order.orderType.toUpperCase(),
              ),
              'status': PlutoCell(value: order.orderStatus.toUpperCase()),
              'paymentType': PlutoCell(
                value: order.paymentType == PaymentMethod.cashPayment.name
                    ? 'CASH PAYMENT'
                    : order.paymentType == PaymentMethod.mobileBanking.name
                        ? 'MOBILE BANKING'
                        : (order.paymentType ?? '-').toUpperCase(),
              ),
              'paymentStatus': PlutoCell(value: order.paymentStatus.toUpperCase()),
              'items': PlutoCell(
                value: order.orderStatus.toLowerCase() == OrderStatus.cancelled.name
                    ? '-'
                    : order.totalItems.toString(),
              ),
              'amount': PlutoCell(
                value: order.orderStatus.toLowerCase() == OrderStatus.cancelled.name
                    ? '-'
                    : order.totalAmount.toStringAsFixed(0),
              ),
              'actions': PlutoCell(value: ''),
            });
          }).toList();

          final totalItems = nonCancelled.fold<int>(0, (sum, o) => sum + o.totalItems);
          final totalAmount =
              nonCancelled.fold<double>(0, (sum, o) => sum + o.totalAmount);

          return Column(
            children: [
              Expanded(
                child: PlutoGrid(
                  columns: columns,
                  rows: rows,
                  configuration: PlutoGridConfiguration(
                    style: PlutoGridStyleConfig(
                      rowColor: Colors.white,
                      oddRowColor: Colors.blue.shade50,
                      activatedColor: clrMainAppClrLight,
                      gridBorderColor: Colors.grey.shade200,
                      gridBorderRadius: BorderRadius.circular(12.r),
                      rowHeight: 40.h,
                      columnHeight: 60.h,
                    ),
                  ),
                  onRowDoubleTap: (event) {
                    final orderId = event.row.cells['id']!.value as int;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailsScreen(orderId: orderId),
                      ),
                    );
                  },
                ),
              ),
              _SummaryFooter(
                totalOrders: nonCancelled.length,
                cancelledOrders: cancelled.length,
                totalItems: totalItems,
                totalRevenue: totalAmount,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryFooter extends StatelessWidget {
  final int totalOrders;
  final int cancelledOrders;
  final int totalItems;
  final double totalRevenue;

  const _SummaryFooter({
    required this.totalOrders,
    required this.cancelledOrders,
    required this.totalItems,
    required this.totalRevenue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.all(15.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TxtWidget(
              txt: 'Total Orders: ${totalOrders + cancelledOrders}',
              fontWeight: FontWeight.w700,
            ),
            TxtWidget(
              txt: 'Active Orders: $totalOrders',
              fontWeight: FontWeight.w700,
              color: clrGreen,
            ),
            TxtWidget(
              txt: 'Cancelled: $cancelledOrders',
              fontWeight: FontWeight.w700,
              color: clrRed,
            ),
            TxtWidget(txt: 'Items: $totalItems', fontWeight: FontWeight.w700),
            TxtWidget(
              txt: 'Revenue: ${totalRevenue.toStringAsFixed(0)} SDG',
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
      ),
    );
  }
}
