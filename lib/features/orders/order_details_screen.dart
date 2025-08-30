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
import 'package:starter_template/features/menu/selctors/order_type_provider.dart';
import 'package:starter_template/features/orders/order_model.dart';
import 'package:starter_template/features/orders/orders_provider.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final String specialOrderId;

  const OrderDetailsScreen({super.key, required this.specialOrderId});

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
    try {
      final orders = await ref.read(ordersAsyncProvider.future);
      final found = orders.firstWhere(
        (o) => o.specialOrderId == widget.specialOrderId,
        orElse: () => throw Exception("Order not found"),
      );

      setState(() => order = found);

      // Prefill cart with conversion from OrderItemModel → CartItemModel
      final cart = ref.read(prefilledCartNotifierProvider.notifier);
      await cart.clearCart();

      for (final it in order!.orderItems) {
        final cartItem = CartItemModel(
          itemId: it.menuItemId,
          name: it.itemName,
          price: it.price,
          imageUrl: it.menuItemId,
          // hasOption: it.hasOption,
          selectedOption: it.selectedOption,
          orderType: order!.orderType,
          quantity: it.quantity,
          source: 'prefilled',
        );
        await cart.addToCart(cartItem);
      }
    } catch (e) {
      debugPrint("Error loading order: $e");
    }
  }

  void _completeOrder() async {
    final selectedPayment = ref.read(paymentMethodProvider);
    if (selectedPayment == null || order == null) return;

    await ref.read(ordersAsyncProvider.notifier).placeOrUpdateOrder(
          pendingOrder: order,
          orderType: order!.orderType,
          paymentStatus: "paid",
          paymentMethod: selectedPayment,
        );

    if (mounted) Navigator.pop(context);
  }

  void _cancelOrder() async {
    if (order == null) return;
    await ref.read(ordersAsyncProvider.notifier).cancelOrder(order!.id!);
    if (mounted) Navigator.pop(context);
  }

  Widget _cartItemCard(CartItemModel it) {
    final cart = ref.read(prefilledCartNotifierProvider.notifier);
    final disabled = order?.orderStatus == OrderStatus.completed.name ||
        order?.orderStatus == OrderStatus.cancelled.name;

    return Card(
      color: clrWhite,
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TxtWidget(
                txt: it.name,
                fontsize:
                    MediaQuery.sizeOf(context).width >= 1200 ? 12.sp : 14.sp,
                fontWeight: FontWeight.w600),
            TxtWidget(
                txt: it.price.toString(),
                fontsize:
                    MediaQuery.sizeOf(context).width >= 1200 ? 13.sp : 15.sp,
                fontWeight: FontWeight.w500,
                color: clrGrey),
          ],
        ),
        subtitle: Text('Option: ${it.selectedOption ?? '-'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (it.quantity != 1)
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: disabled
                    ? null
                    : () => cart.updateQuantity(it.id!, it.quantity - 1),
              ),
            if (it.quantity == 1)
              IconButton(
                icon: Icon(Icons.delete, color: disabled ? clrGrey : clrRed),
                onPressed: disabled ? null : () => cart.removeItem(it.id!),
              ),
            TxtWidget(
                txt: '${it.quantity}', fontsize: 16.sp, color: clrMainAppClr),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: disabled
                  ? null
                  : () => cart.updateQuantity(it.id!, it.quantity + 1),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(prefilledCartNotifierProvider).value ?? [];
    final total = ref.watch(prefilledCartTotalProvider);
    final count = ref.watch(prefilledCartCountProvider);

    if (order == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDisabled = order?.orderStatus == OrderStatus.completed.name ||
        order?.orderStatus == OrderStatus.cancelled.name;

    return Scaffold(
      appBar: AppBar(
        title: TxtWidget(
            txt: 'Order #${order!.specialOrderId}',
            fontsize: 18.sp,
            fontWeight: FontWeight.w600),
      ),
      body: Card(
        child: Row(
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
                        fontsize: MediaQuery.sizeOf(context).width>=1200?14.sp: 16.sp, 
                        fontWeight: FontWeight.w600),
                    const CategorySelector(),
                    const SizedBox(height: 8),
                    Expanded(child: ItemsList(order: order)),
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
                child: cartItems.isEmpty
                    ? const Center(child: Text('Cart is empty'))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // --- Cart Items ---
                            Card(
                              child: Column(
                                children: cartItems.map(_cartItemCard).toList(),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // --- Payment Selector ---
                            Card(
                              child: Column(
                                children: [
                                  SizedBox(height: 8),
                                  const TxtWidget(
                                      txt: 'Payment Method',
                                      fontsize: 15,
                                      fontWeight: FontWeight.w600),
                                  PaymentMethodSelector(order: order),
                                  gapH8,
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            // --- Totals ---
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TxtWidget(
                                              txt: '$count item(s)',
                                              fontsize: 15.sp,
                                              fontWeight: FontWeight.w500),
                                          TxtWidget(
                                              txt: '$total SDG',
                                              fontsize: 15.sp,
                                              fontWeight: FontWeight.w600)
                                        ]),
                                    if (order?.orderType ==
                                        OrderType.delivery.name)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TxtWidget(
                                              txt: 'Delivery',
                                              fontsize:
                                                  MediaQuery.sizeOf(context)
                                                              .width >=
                                                          1200
                                                      ? 12.sp
                                                      : 14.sp,
                                              fontWeight: FontWeight.w500),
                                          TxtWidget(
                                              txt:
                                                  '${order!.totalAmount - total} SDG',
                                              fontsize:
                                                  MediaQuery.sizeOf(context)
                                                              .width >=
                                                          1200
                                                      ? 12.sp
                                                      : 14.sp,
                                              fontWeight: FontWeight.w600),
                                        ],
                                      ),
                                    const Divider(),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TxtWidget(
                                              txt: 'Total Cost',
                                              fontsize:
                                                  MediaQuery.sizeOf(context)
                                                              .width >=
                                                          1200
                                                      ? 12.sp
                                                      : 14.sp,
                                              fontWeight: FontWeight.w500),
                                          TxtWidget(
                                              txt: '${order?.totalAmount} SDG',
                                              fontsize:
                                                  MediaQuery.sizeOf(context)
                                                              .width >=
                                                          1200
                                                      ? 12.sp
                                                      : 14.sp,
                                              fontWeight: FontWeight.w600)
                                        ])
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
                                    minimumSize: Size(135.h, 60.h),
                                    backgroundColor: clrRed,
                                    foregroundColor: clrWhite,
                                  ),
                                  onPressed: isDisabled
                                      ? () => Navigator.pop(context)
                                      : _cancelOrder,
                                  child: Text(
                                      isDisabled ? 'Back' : 'Cancel Order'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(135.h, 60.h),
                                    backgroundColor: clrGreen,
                                    foregroundColor: clrWhite,
                                  ),
                                  onPressed: isDisabled ? null : _completeOrder,
                                  child: const Text('Complete Order'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
