import 'package:easy_localization/easy_localization.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/features/menu/payment_method/payment_method_provider.dart';
import 'package:starter_template/features/orders_list/orders_dropdown_filter.dart';
import 'package:starter_template/features/orders_list/place_order/order_model.dart';
import 'package:starter_template/features/orders_list/place_order/orders_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersAsyncProvider);
    final selectedDate = ref.watch(ordersSelectedDateProvider);
    final typeFilter = ref.watch(ordersFilterTypeProvider);
    final payFilter = ref.watch(ordersFilterPayProvider);

    final totalAmount = ref.watch(ordersDayTotalAmountProvider);
    final totalItems = ref.watch(ordersDayTotalCountProvider);
    final ordersCount = ref.watch(ordersDayOrdersCountProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Orders'),
        // actions: [
        //   IconButton(
        //     tooltip: 'Today',
        //     onPressed: () =>
        //         ref.read(ordersAsyncProvider.notifier).setDate(DateTime.now()),
        //     icon: const Icon(Icons.event_available),
        //   )
        // ],
      ),
      body: Column(
        children: [
          // --- Filters ---
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 20.h,
              // runSpacing: 8,
              children: [
                ElevatedButton(
                    onPressed: () => ref
                        .read(ordersAsyncProvider.notifier)
                        .setDate(DateTime.now()),
                    child: TxtWidget(txt: 'Today')),
                _DateChip(
                  label: DateFormat('EEE, MMM d, yyyy').format(selectedDate),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020, 1, 1),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      ref.read(ordersAsyncProvider.notifier).setDate(picked);
                    }
                  },
                ),
                FiltersSection(payFilter: payFilter, typeFilter: payFilter),
                ElevatedButton(
                    onPressed: () =>
                        ref.read(ordersAsyncProvider.notifier).reload(),
                    child: TxtWidget(txt: 'Refresh Orders')),
              ],
            ),
          ),

          // const Divider(height: 1),

          // --- Orders list ---
          Expanded(
              child: ordersState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (orders) {
                    if (orders.isEmpty) {
                      return const Center(
                          child: Text('No orders for this filter.'));
                    }

                    return SingleChildScrollView(
                        child: ExpansionTileGroup(
                            toggleType: ToggleType.expandOnlyCurrent,
                            children: orders
                                .map((o) => _buildOrderTile(o, ref))
                                .toList()));
                  })),

          // --- Summary footer ---
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: const Border(top: BorderSide(width: .5)),
            ),
            child: Row(
              children: [
                Expanded(child: Text('Orders: $ordersCount')),
                Expanded(child: Text('Items: $totalItems')),
                Expanded(
                  child: Text(
                    'Revenue: ${totalAmount.toStringAsFixed(2)}',
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  ExpansionTileItem _buildOrderTile(OrderModel order, WidgetRef ref) {
    return ExpansionTileItem(
      key: ValueKey(order.id),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              '#${order.id} • ${order.orderType.toUpperCase()} • ${order.paymentType}'),
          Text(order.totalAmount.toStringAsFixed(2)),
        ],
      ),
      subtitle: Text(
          '${DateFormat('HH:mm').format(order.createdAt)} • ${order.status}'),
      children: [_OrderDetails(order: order, ref: ref)],
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DateChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      avatar: const Icon(Icons.calendar_today, size: 18),
      onPressed: onTap,
    );
  }
}

class _OrderDetails extends ConsumerStatefulWidget {
  final OrderModel order;
  const _OrderDetails({required this.order, required this.ref});

  final WidgetRef ref;

  @override
  ConsumerState<_OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends ConsumerState<_OrderDetails> {
  late String _payment;
  late String? _table;
  late String? _addr;

  @override
  void initState() {
    super.initState();
    _payment = widget.order.paymentType!;
    _table = widget.order.tableName;
    _addr = widget.order.deliveryAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Items list
      SizedBox(
        height: 80.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: widget.order.items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) {
            final it = widget.order.items[i];
            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              child: Container(
                width: 220,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    it.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(it.imageUrl!,
                                width: 40, height: 40, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.fastfood, size: 40),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(it.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Option: ${it.selectedOption ?? '-'}'),
                          Text(
                              'x${it.quantity} • ${(it.price * it.quantity).toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(child: Text('Total items: ${widget.order.totalItems}')),
          Expanded(
            child: Text(
              'Total: ${widget.order.totalAmount.toStringAsFixed(2)}',
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      // Edit fields
      Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          DropdownButton<String>(
            value: _payment,
            items: PaymentMethod.values
                .map((e) => DropdownMenuItem(
                    value: e.name, child: TxtWidget(txt: e.name)))
                .toList(),
            onChanged: (v) => setState(() => _payment = v ?? _payment),
          ),
          if (widget.order.orderType == 'dinein')
            SizedBox(
              width: 180,
              child: TextField(
                decoration: const InputDecoration(labelText: 'Table'),
                controller: TextEditingController(text: _table ?? '')
                  ..selection =
                      TextSelection.collapsed(offset: (_table ?? '').length),
                onChanged: (v) => _table = v,
              ),
            ),
          if (widget.order.orderType == 'delivery')
            SizedBox(
              width: 260,
              child: TextField(
                decoration:
                    const InputDecoration(labelText: 'Delivery address'),
                controller: TextEditingController(text: _addr ?? '')
                  ..selection =
                      TextSelection.collapsed(offset: (_addr ?? '').length),
                onChanged: (v) => _addr = v,
              ),
            ),
        ],
      ),
      const SizedBox(height: 12),
      // Row(
      //   children: [
      //     // ElevatedButton.icon(
      //     //   icon: const Icon(Icons.save),
      //     //   label: const Text('Update'),
      //     //   onPressed: () async {
      //     //     final updated = widget.order.copyWith(
      //     //       paymentType: _payment,
      //     //       tableName: _table,
      //     //       deliveryAddress: _addr,
      //     //       status: 'updated',
      //     //     );
      //     //     await widget.ref
      //     //         .read(ordersAsyncProvider.notifier)
      //     //         .updateOrder(updated);
      //     //     if (context.mounted) {
      //     //       ScaffoldMessenger.of(context).showSnackBar(
      //     //           const SnackBar(content: Text('Order updated')));
      //     //     }
      //     //   },
      //     // ),
      //     // const SizedBox(width: 12),
      //     // OutlinedButton.icon(
      //     //   icon: const Icon(Icons.cancel),
      //     //   label: const Text('Cancel order'),
      //     //   onPressed: widget.order.status == 'canceled'
      //     //       ? null
      //     //       : () async {
      //     //           await widget.ref
      //     //               .read(ordersAsyncProvider.notifier)
      //     //               .cancelOrder(
      //     //                   orderId: widget.order.id!,
      //     //                   reason: 'Canceled from UI');
      //     //           if (context.mounted) {
      //     //             ScaffoldMessenger.of(context).showSnackBar(
      //     //                 const SnackBar(content: Text('Order canceled')));
      //     //           }
      //     //         },
      //     // ),

      //   ],
      // ),
    ]);
  }
}
