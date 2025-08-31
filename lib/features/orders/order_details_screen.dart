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
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  /// Load the order from provider and prefill cart
  Future<void> _loadOrder() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final orders = await ref.read(allOrdersProvider.future);
      final found = orders.firstWhere(
        (o) => o.specialOrderId == widget.specialOrderId,
        orElse: () => throw Exception("Order not found"),
      );

      // Prefill cart
      final cart = ref.read(prefilledCartNotifierProvider.notifier);
      await cart.clearCart();

      for (final it in found.orderItems) {
        await cart.addToCart(CartItemModel.fromOrderItem(it, found.orderType
            // , source: 'prefilled'
            ));
      }

      if (mounted) {
        setState(() {
          order = found;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading order: $e");
      if (mounted) {
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    }
  }

  /// Complete the order
  Future<void> _completeOrder() async {
    if (order == null) return;
    final selectedPayment = ref.read(paymentMethodProvider);
    if (selectedPayment == null) return;

    await ref.read(ordersAsyncProvider.notifier).placeOrUpdateOrder(
          pendingOrder: order,
          orderType: order!.orderType,
          paymentStatus: "paid",
          paymentMethod: selectedPayment,
        );

    ref.invalidate(allOrdersProvider);

    if (mounted) Navigator.pop(context);
  }

  /// Cancel the order
  Future<void> _cancelOrder() async {
    if (order == null) return;

    await ref.read(ordersAsyncProvider.notifier).cancelOrder(order!.id!);
    ref.invalidate(allOrdersProvider);

    if (mounted) Navigator.pop(context);
  }

  /// Single cart item card
  Widget _cartItemCard(CartItemModel it) {
    final cart = ref.read(prefilledCartNotifierProvider.notifier);
    final disabled = order?.orderStatus == OrderStatus.completed.name ||
        order?.orderStatus == OrderStatus.cancelled.name;

    return Card(
      color: clrWhite,
      margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 5.w),
      elevation: 2,
      child: ListTile(
        title: Text(it.name,
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14.sp, color: clrBlack)),
        subtitle: (it.selectedOption != null && it.selectedOption!.isNotEmpty)
            ? TxtWidget(txt: 'Option: ${it.selectedOption}', color: clrGrey)
            : SizedBox.shrink( ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (it.quantity > 1)
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
                txt: '${it.quantity}', fontsize: 15.sp, color: clrMainAppClr),
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

  /// Reusable row for totals
  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TxtWidget(txt: label, fontsize: 14.sp, fontWeight: FontWeight.w500),
          TxtWidget(
              txt: value,
              fontsize: 14.sp,
              fontWeight: FontWeight.w600,
              color: clrMainAppClr),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(prefilledCartNotifierProvider).value ?? [];
    final total = ref.watch(prefilledCartTotalProvider);
    final count = ref.watch(prefilledCartCountProvider);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error || order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Order not found")),
        body: const Center(
            child: Text("⚠ This order could not be loaded.",
                style: TextStyle(color: Colors.red))),
      );
    }

    final isDisabled = order?.orderStatus == OrderStatus.completed.name ||
        order?.orderStatus == OrderStatus.cancelled.name;

    return Scaffold(
      appBar: AppBar(
        title: TxtWidget(
          txt: 'Order #${order!.specialOrderId}',
          fontsize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Menu
          Flexible(
            flex: MediaQuery.sizeOf(context).width >= 1200 ? 8 : 7,
            child: Container(
              color: clrLightGrey.withValues(alpha: 0.5),
              padding: EdgeInsets.all(6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TxtWidget(
                    txt: 'Categories',
                    fontsize: MediaQuery.sizeOf(context).width >= 1200
                        ? 14.sp
                        : 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  const CategorySelector(),
                  gapH8,
                  Expanded(child: ItemsList(order: order)),
                ],
              ),
            ),
          ),

          const VerticalDivider(width: 2),

          // Right Cart
          Flexible(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(6.w),
              child: cartItems.isEmpty
                  ? const Center(child: Text('🛒 Cart is empty'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            child: Column(
                                children:
                                    cartItems.map(_cartItemCard).toList()),
                          ),
                          gapH8,
                          Card(
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                const TxtWidget(
                                    txt: 'Payment Method',
                                    fontsize: 15,
                                    fontWeight: FontWeight.w600),
                                PaymentMethodSelector(order: order),
                                gapH8,
                              ],
                            ),
                          ),
                          gapH8,
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  _buildRow('$count item(s)',
                                      '${total.toStringAsFixed(0)} SDG'),
                                  if (order?.orderType ==
                                      OrderType.delivery.name)
                                    _buildRow('Delivery Fee',
                                        '${order!.deliveryFee} SDG'),
                                  const Divider(),
                                  _buildRow(
                                    'Total Cost',
                                    '${(order!.totalAmount + (order!.deliveryFee ?? 0)).toStringAsFixed(0)} SDG',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          gapH12,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.all(15.h),
                                  minimumSize: Size(130.h, 55.h),
                                  backgroundColor:
                                      isDisabled ? clrMainAppClr : clrRed,
                                  foregroundColor: clrWhite,
                                ),
                                onPressed: isDisabled
                                    ? () => Navigator.pop(context)
                                    : _cancelOrder,
                                child:
                                    Text(isDisabled ? 'Back' : 'Cancel Order'),
                              ),
                              gapW4,
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.all(15.h),
                                  minimumSize: Size(130.h, 55.h),
                                  backgroundColor:
                                      isDisabled ? clrGrey : clrGreen,
                                  foregroundColor: clrWhite
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
    );
  }
}
