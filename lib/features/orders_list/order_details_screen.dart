import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/cart/cart_model.dart';
import 'package:starter_template/features/menu/cart/cart_provider.dart';
import 'package:starter_template/features/menu/categories/category_selector.dart';
import 'package:starter_template/features/menu/menu_items/menu_items_list_widget.dart';
import 'package:starter_template/features/menu/payment_method/payment_method_provider.dart';
import 'package:starter_template/features/menu/payment_method/payment_selection_tiles.dart';
import 'package:starter_template/features/orders_list/place_order/orders_provider.dart';
import 'package:starter_template/features/orders_list/place_order/order_model.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final int orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  OrderModel? order;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    // Fetch orders from provider
    final orders = await ref.read(ordersAsyncProvider.future);
    final found = orders.firstWhere((o) => o.id == widget.orderId,
        orElse: () => throw Exception("Order not found"));
    setState(() => order = found);

    // Prefill cart ONLY for this order
    await ref
        .read(cartAsyncNotifierProvider.notifier)
        .setCartItems(order!.items);
  }

  void _completeOrder() async {
    final selectedPayment = ref.read(paymentMethodProvider);
    if (selectedPayment == null) return;

    if (order == null) return;

    // Update existing order with cart contents
    await ref.read(ordersAsyncProvider.notifier).placeOrUpdateOrder(
          pendingOrder: order,
          orderType: order!.orderType,
          paymentStatus: "paid",
          paymentType: selectedPayment,
        );

    if (mounted) Navigator.pop(context);
  }

  void _cancelOrder() async {
    if (order == null) return;
    await ref.read(ordersAsyncProvider.notifier).cancelOrder(order!.id!);
    if (mounted) Navigator.pop(context);
  }

  Widget _cartItemCard(CartItemModel it) {
    return Card(
      color: clrWhite,
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TxtWidget(
                txt: it.name, fontsize: 16.sp, fontWeight: FontWeight.w600),
            TxtWidget(
                txt: it.price.toString(),
                fontsize: 16.sp,
                fontWeight: FontWeight.w500,
                color: clrGrey),
          ],
        ),
        subtitle: Text('Option: ${it.selectedOption ?? '-'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            it.quantity != 1
                ? IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed:
                        order?.orderStatus == OrderStatus.cancelled.name ||
                                order?.orderStatus == OrderStatus.completed.name
                            ? null
                            : () {
                                final newQty =
                                    it.quantity > 1 ? it.quantity - 1 : 1;
                                ref
                                    .read(cartAsyncNotifierProvider.notifier)
                                    .updateQuantity(it.dbId!, newQty);
                              },
                  )
                : IconButton(
                    icon: Icon(Icons.delete,
                        color: order?.orderStatus ==
                                    OrderStatus.cancelled.name ||
                                order?.orderStatus == OrderStatus.completed.name
                            ? clrGrey
                            : clrRed),
                    onPressed:
                        order?.orderStatus == OrderStatus.cancelled.name ||
                                order?.orderStatus == OrderStatus.completed.name
                            ? null
                            : () => ref
                                .read(cartAsyncNotifierProvider.notifier)
                                .removeItem(it.dbId!),
                  ),
            TxtWidget(
                txt: '${it.quantity}', fontsize: 16.sp, color: clrMainAppClr),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: order?.orderStatus == OrderStatus.cancelled.name ||
                      order?.orderStatus == OrderStatus.completed.name
                  ? null
                  : () => ref
                      .read(cartAsyncNotifierProvider.notifier)
                      .updateQuantity(it.dbId!, it.quantity + 1),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartAsyncNotifierProvider);
    final total = ref.watch(cartTotalProvider);
    final count = ref.watch(cartCountProvider);

    if (order == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
          title: TxtWidget(
              txt: 'Order #${order!.id}',
              fontsize: 18.sp,
              fontWeight: FontWeight.w600)),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Left Menu Column ---
          Flexible(
            flex: MediaQuery.sizeOf(context).width >= 1200 ? 8 : 7,
            child: Container(
              color: clrLightGrey.withValues(alpha: 0.5),
              padding: EdgeInsets.all(2.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TxtWidget(
                      txt: 'Categories',
                      fontsize: 18.sp,
                      fontWeight: FontWeight.w600),
                  CategorySelector(),
                  const SizedBox(height: 8),
                  Expanded(
                      child: ItemsList(
                    order: order,
                  )),
                ],
              ),
            ),
          ),

          const VerticalDivider(width: 3),

          // --- Right Cart Column ---
          Flexible(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(3.w),
              child: cartState.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(child: Text('Cart is empty'));
                  }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Cart Items ---
                        Card(
                          child: Column(
                            children: items.map(_cartItemCard).toList(),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // --- Payment Selector ---
                        Card(
                          child: Column(children: [
                            SizedBox(height: 8),
                            const TxtWidget(
                                txt: 'Payment Method',
                                fontsize: 15,
                                fontWeight: FontWeight.w600),
                            PaymentMethodSelector(
                              order: order,
                            ),
                            gapH8
                          ]),
                        ),

                        const SizedBox(height: 8),

                        // --- Totals ---
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TxtWidget(
                                    txt: '$count item(s)',
                                    fontsize: 15.sp,
                                    fontWeight: FontWeight.w500),
                                TxtWidget(
                                    txt: '$total SDG',
                                    fontsize: 15.sp,
                                    fontWeight: FontWeight.w600),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // --- Action Buttons ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    minimumSize: Size(140.h, 80.h),
                                    foregroundColor: clrRed,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.w)),
                                onPressed: _cancelOrder,
                                child: (order?.orderStatus ==
                                            OrderStatus.cancelled.name ||
                                        order?.orderStatus ==
                                            OrderStatus.completed.name)
                                    ? const Text('Back')
                                    : const Text('Cancel Order')),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: Size(140.h, 80.h),
                                  foregroundColor: clrGreen,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.w)),
                              onPressed: (order?.orderStatus ==
                                          OrderStatus.cancelled.name ||
                                      order?.orderStatus ==
                                          OrderStatus.completed.name)
                                  ? null
                                  : _completeOrder,
                              child: const Text('Complete Order'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error loading cart: $e')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
