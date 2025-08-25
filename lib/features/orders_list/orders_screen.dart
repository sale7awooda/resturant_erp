// import 'package:easy_localization/easy_localization.dart';
// import 'package:expansion_tile_group/expansion_tile_group.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:starter_template/common/widgets/txt_widget.dart';
// import 'package:starter_template/features/menu/payment_method/payment_method_provider.dart';
// import 'package:starter_template/features/menu/selctors/order_type_provider.dart';
// import 'package:starter_template/features/orders_list/place_order/order_model.dart';
// import 'package:starter_template/features/orders_list/place_order/orders_provider.dart';

// class OrdersScreen extends ConsumerWidget {
//   const OrdersScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final ordersState = ref.watch(ordersAsyncProvider);
//     final selectedDate = ref.watch(ordersSelectedDateProvider);
//     final typeFilter = ref.watch(ordersFilterTypeProvider);
//     final payFilter = ref.watch(ordersFilterPayProvider);

//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text('Orders'),
//       ),
//       body: Column(
//         children: [
//           _FiltersSection(
//             ref: ref,
//             selectedDate: selectedDate,
//             typeFilter: typeFilter,
//             payFilter: payFilter,
//           ),
//           const SizedBox(height: 8),
//           Expanded(
//             child: ordersState.when(
//               loading: () => const Center(child: CircularProgressIndicator()),
//               error: (e, _) => Center(child: Text('Error: $e')),
//               data: (orders) {
//                 if (orders.isEmpty) {
//                   return const Center(child: Text('No orders available.'));
//                 }

//                 // Calculate totals for footer
//                 final totalItems =
//                     orders.fold<int>(0, (sum, o) => sum + o.totalItems);
//                 final totalAmount =
//                     orders.fold<double>(0, (sum, o) => sum + o.totalAmount);
//                 final ordersCount = orders.length;

//                 return Column(
//                   children: [
//                     Expanded(
//                       child: SingleChildScrollView(
//                         padding: EdgeInsets.symmetric(horizontal: 8.w),
//                         child: ExpansionTileGroup(
//                           toggleType: ToggleType.expandOnlyCurrent,
//                           children: orders
//                               .map((o) => _buildOrderTile(o, ref))
//                               .toList(),
//                         ),
//                       ),
//                     ),
//                     _SummaryFooter(
//                       totalOrders: ordersCount,
//                       totalItems: totalItems,
//                       totalRevenue: totalAmount,
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   ExpansionTileItem _buildOrderTile(OrderModel order, WidgetRef ref) {
//     // Collapsed view card
//     return ExpansionTileItem(
//       key: ValueKey(order.id),
//       title: Card(
//         margin: EdgeInsets.symmetric(vertical: 4.h),
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//         elevation: 2,
//         child: Padding(
//           padding: EdgeInsets.all(12.w),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // First row: ID, type, status
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   TxtWidget(
//                       txt: '#${order.id}',
//                       fontWeight: FontWeight.w600,
//                       fontsize: 16.sp),
//                   TxtWidget(
//                     txt: order.orderStatus.toUpperCase(),
//                     color: order.orderStatus.toLowerCase() == 'canceled'
//                         ? Colors.red
//                         : order.orderStatus.toLowerCase() == 'completed'
//                             ? Colors.green
//                             : Colors.orange,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   TxtWidget(
//                       txt: order.orderType.toUpperCase(),
//                       fontWeight: FontWeight.w500),
//                 ],
//               ),
//               const SizedBox(height: 6),
//               // Second row: payment, table/address, totals
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   TxtWidget(txt: '${order.paymentType}', fontsize: 14.sp),
//                   order.orderType == OrderType.takeaway.name
//                       ? SizedBox.shrink()
//                       : TxtWidget(
//                           txt: order.orderType == 'dinein'
//                               ? 'Table: ${order.tableName ?? "-"}'
//                               : 'Address: ${order.deliveryAddress ?? "-"}',
//                           fontsize: 14.sp,
//                         ),
//                   TxtWidget(
//                     txt:
//                         'Items: ${order.totalItems} • ${order.totalAmount.toStringAsFixed(2)} SDG',
//                     fontsize: 14.sp,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//       children: [_OrderDetails(order: order, ref: ref)],
//     );
//   }
// }

// class _OrderDetails extends ConsumerWidget {
//   final OrderModel order;
//   final WidgetRef ref;

//   const _OrderDetails({required this.order, required this.ref});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       elevation: 2,
//       child: Padding(
//         padding: EdgeInsets.all(12.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Order info
//             Wrap(
//               spacing: 12.w,
//               runSpacing: 8.h,
//               children: [
//                 Chip(
//                   label: TxtWidget(txt: 'Payment: ${order.paymentType}'),
//                   backgroundColor: Colors.blue.shade50,
//                 ),
//                 if (order.orderType == 'dinein')
//                   Chip(
//                     label: TxtWidget(txt: 'Table: ${order.tableName ?? "-"}'),
//                     backgroundColor: Colors.green.shade50,
//                   ),
//                 if (order.orderType == 'delivery')
//                   Chip(
//                     label: TxtWidget(
//                         txt: 'Address: ${order.deliveryAddress ?? "-"}'),
//                     backgroundColor: Colors.orange.shade50,
//                   ),
//                 Chip(
//                   label: TxtWidget(txt: 'Status: ${order.orderStatus}'),
//                   backgroundColor: Colors.grey.shade200,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             // Items list
//             SizedBox(
//               height: 100.h,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: order.items.length,
//                 separatorBuilder: (_, __) => const SizedBox(width: 8),
//                 itemBuilder: (_, i) {
//                   final it = order.items[i];
//                   return Card(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8.r)),
//                     child: Container(
//                       width: 200.w,
//                       padding: const EdgeInsets.all(8),
//                       child: Row(
//                         children: [
//                           it.imageUrl != null
//                               ? ClipRRect(
//                                   borderRadius: BorderRadius.circular(6),
//                                   child: Image.asset(it.imageUrl!,
//                                       width: 40, height: 40, fit: BoxFit.cover),
//                                 )
//                               : const Icon(Icons.fastfood, size: 40),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 TxtWidget(
//                                     txt: it.name, fontWeight: FontWeight.w600),
//                                 TxtWidget(
//                                     txt: 'Option: ${it.selectedOption ?? "-"}',
//                                     fontsize: 12.sp,
//                                     color: Colors.grey[700]),
//                                 TxtWidget(
//                                   txt:
//                                       'x${it.quantity} • ${(it.price * it.quantity).toStringAsFixed(2)}',
//                                   fontsize: 12.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 12),
//             // Total
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 TxtWidget(
//                     txt: 'Total items: ${order.totalItems}', fontsize: 14.sp),
//                 TxtWidget(
//                     txt: 'Total: ${order.totalAmount.toStringAsFixed(2)} SDG',
//                     fontsize: 14.sp,
//                     fontWeight: FontWeight.w600),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _FiltersSection extends ConsumerWidget {
//   final WidgetRef ref;
//   final DateTime selectedDate;
//   final String? typeFilter;
//   final String? payFilter;

//   const _FiltersSection({
//     required this.ref,
//     required this.selectedDate,
//     required this.typeFilter,
//     required this.payFilter,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: [
//             // Today button
//             ElevatedButton(
//               onPressed: () {
//                 ref.read(ordersSelectedDateProvider.notifier).state =
//                     DateTime.now();
//                 ref.read(ordersAsyncProvider.notifier).reload();
//               },
//               child: const Text('Today'),
//             ),
//             const SizedBox(width: 8),
//             // Date picker chip
//             GestureDetector(
//               onTap: () async {
//                 final picked = await showDatePicker(
//                   context: context,
//                   initialDate: selectedDate,
//                   firstDate: DateTime(2020, 1, 1),
//                   lastDate: DateTime.now().add(const Duration(days: 365)),
//                 );
//                 if (picked != null) {
//                   ref.read(ordersSelectedDateProvider.notifier).state = picked;
//                   ref.read(ordersAsyncProvider.notifier).reload();
//                 }
//               },
//               child: Card(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.r)),
//                 color: Colors.blue.shade50,
//                 child: Padding(
//                   padding:
//                       EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//                   child: TxtWidget(
//                       txt: DateFormat('EEE, MMM d, yyyy').format(selectedDate)),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             // Order Type Dropdown
//             _DropdownCard<String>(
//               value: typeFilter,
//               hint: 'Order Type',
//               items: ['all', 'dinein', 'delivery', 'takeaway'],
//               onChanged: (v) =>
//                   ref.read(ordersFilterTypeProvider.notifier).state = v,
//             ),
//             const SizedBox(width: 8),
//             // Payment Type Dropdown
//             _DropdownCard<String>(
//               value: payFilter,
//               hint: 'Payment',
//               items: PaymentMethod.values.map((e) => e.name).toList(),
//               onChanged: (v) =>
//                   ref.read(ordersFilterPayProvider.notifier).state = v,
//             ),
//             const SizedBox(width: 8),
//             // Refresh button
//             ElevatedButton.icon(
//               icon: const Icon(Icons.refresh),
//               label: const Text('Refresh'),
//               onPressed: () => ref.read(ordersAsyncProvider.notifier).reload(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DropdownCard<T> extends StatelessWidget {
//   final T? value;
//   final List<T> items;
//   final String hint;
//   final ValueChanged<T?> onChanged;

//   const _DropdownCard({
//     required this.value,
//     required this.items,
//     required this.hint,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       color: Colors.grey.shade100,
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
//         child: DropdownButton<T>(
//           value: value,
//           hint: Text(hint),
//           items: items
//               .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
//               .toList(),
//           onChanged: onChanged,
//           underline: const SizedBox.shrink(),
//           isDense: true,
//         ),
//       ),
//     );
//   }
// }

// class _SummaryFooter extends StatelessWidget {
//   final int totalOrders;
//   final int totalItems;
//   final double totalRevenue;

//   const _SummaryFooter({
//     required this.totalOrders,
//     required this.totalItems,
//     required this.totalRevenue,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.all(8.w),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       color: Colors.grey.shade200,
//       child: Padding(
//         padding: EdgeInsets.all(12.w),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             TxtWidget(txt: 'Orders: $totalOrders', fontWeight: FontWeight.w600),
//             TxtWidget(txt: 'Items: $totalItems', fontWeight: FontWeight.w600),
//             TxtWidget(
//                 txt: 'Revenue: ${totalRevenue.toStringAsFixed(2)} SDG',
//                 fontWeight: FontWeight.w600),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/features/orders_list/place_order/order_model.dart';
import 'package:starter_template/features/orders_list/place_order/orders_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersAsyncProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Orders'),
      ),
      body: ordersState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No orders available.'));
          }

          // PlutoGrid columns
          final columns = <PlutoColumn>[
            PlutoColumn(
              title: 'ID',
              field: 'id',
              type: PlutoColumnType.number(),
              width: 80,
            ),
            PlutoColumn(
              title: 'Date',
              field: 'date',
              type: PlutoColumnType.text(),
              width: 150,
            ),
            PlutoColumn(
              title: 'Type',
              field: 'orderType',
              type: PlutoColumnType.text(),
              width: 120,
            ),
            PlutoColumn(
              title: 'Status',
              field: 'status',
              type: PlutoColumnType.text(),
              width: 120,
            ),
            PlutoColumn(
              title: 'Payment',
              field: 'payment',
              type: PlutoColumnType.text(),
              width: 120,
            ),
            PlutoColumn(
              title: 'Items',
              field: 'items',
              type: PlutoColumnType.number(),
              width: 80,
            ),
            PlutoColumn(
              title: 'Amount (SDG)',
              field: 'amount',
              type: PlutoColumnType.number(format: '#,###.00'),
              width: 140,
            ),
          ];

          // PlutoGrid rows
          final rows = orders.map((order) {
            return PlutoRow(cells: {
              'id': PlutoCell(value: order.id ?? 0),
              'date': PlutoCell(
                value: DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt),
              ),
              'orderType': PlutoCell(value: order.orderType),
              'status': PlutoCell(value: order.orderStatus),
              'payment': PlutoCell(value: order.paymentType ?? "-"),
              'items': PlutoCell(value: order.totalItems),
              'amount': PlutoCell(value: order.totalAmount),
            });
          }).toList();

          // Totals for footer
          final totalItems =
              orders.fold<int>(0, (sum, o) => sum + o.totalItems);
          final totalAmount =
              orders.fold<double>(0, (sum, o) => sum + o.totalAmount);
          final ordersCount = orders.length;

          return Column(
            children: [
              Expanded(
                child: PlutoGrid(
                  columns: columns,
                  rows: rows,
                  configuration: PlutoGridConfiguration(
                    style: PlutoGridStyleConfig(
                      borderColor: Colors.grey.shade300,
                      gridBorderRadius: BorderRadius.circular(12.r),
                      rowHeight: 48.h,
                      columnHeight: 48.h,
                      activatedBorderColor: Colors.blue,
                      activatedColor: Colors.blue.shade50,
                      gridBorderColor: Colors.grey.shade200,
                    ),
                  ),
                  onRowDoubleTap: (event) {
                    final orderId = event.row.cells['id']!.value;
                    final order =
                        orders.firstWhere((o) => o.id == orderId as int);
                    _showOrderDetails(context, order);
                  },
                ),
              ),
              _SummaryFooter(
                totalOrders: ordersCount,
                totalItems: totalItems,
                totalRevenue: totalAmount,
              ),
            ],
          );
        },
      ),
    );
  }

  void _showOrderDetails(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      // isScrollControlled: true,
      barrierDismissible: true, useSafeArea: true,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      // ),
      builder: (_) {
        return Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 400.w, vertical: 50.h),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TxtWidget(
                      txt: "Order #${order.id}",
                      fontWeight: FontWeight.w700,
                      fontsize: 18.sp,
                    ),
                    const Divider(),
                    Center(
                      child: Wrap(
                        spacing: 12.w,
                        runSpacing: 8.h,
                        children: [
                          Chip(label: Text("Type: ${order.orderType}")),
                          Chip(label: Text("Status: ${order.orderStatus}")),
                          Chip(label: Text("Payment: ${order.paymentType ?? "-"}")),
                          if (order.tableName != null)
                            Chip(label: Text("Table: ${order.tableName}")),
                          if (order.deliveryAddress != null)
                            Chip(label: Text("Address: ${order.deliveryAddress}")),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TxtWidget(
                      txt: "Items",
                      fontWeight: FontWeight.w600,
                      fontsize: 16.sp,
                    ),
                    SizedBox(
                      height: 200.h,
                      child: ListView.separated(
                        itemCount: order.items.length,
                        separatorBuilder: (_, __) => Divider(),
                        itemBuilder: (_, i) {
                          final it = order.items[i];
                          return ListTile(
                            leading: const Icon(Icons.fastfood),
                            title: Text(it.name),
                            subtitle: Text("x${it.quantity} • ${it.price}"),
                            trailing: Text(
                              (it.price * it.quantity).toStringAsFixed(2),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TxtWidget(txt: "Total items: ${order.totalItems}"),
                        TxtWidget(
                          txt:
                              "Total: ${order.totalAmount.toStringAsFixed(2)} SDG",
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SummaryFooter extends StatelessWidget {
  final int totalOrders;
  final int totalItems;
  final double totalRevenue;

  const _SummaryFooter({
    required this.totalOrders,
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
        padding: EdgeInsets.all(12.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TxtWidget(txt: 'Orders: $totalOrders', fontWeight: FontWeight.w600),
            TxtWidget(txt: 'Items: $totalItems', fontWeight: FontWeight.w600),
            TxtWidget(
              txt: 'Revenue: ${totalRevenue.toStringAsFixed(2)} SDG',
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
      ),
    );
  }
}
