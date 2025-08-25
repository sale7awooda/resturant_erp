import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/cart/cart_provider.dart';
import 'package:starter_template/features/menu/categories/category_selector.dart';
import 'package:starter_template/features/menu/menu_items/menu_items_list_widget.dart';
import 'package:starter_template/features/menu/menu_items/menu_items_providers.dart';
import 'package:starter_template/features/menu/payment_method/payment_method_provider.dart';
import 'package:starter_template/features/menu/payment_method/payment_selection_tiles.dart';
import 'package:starter_template/features/menu/selctors/delivery_address_provider.dart';
import 'package:starter_template/features/menu/selctors/delivery_address_selector.dart';
import 'package:starter_template/features/menu/selctors/order_type_provider.dart';
import 'package:starter_template/features/menu/selctors/order_type_selctor.dart';
import 'package:starter_template/features/menu/selctors/table_provider.dart';
import 'package:starter_template/features/menu/selctors/table_selector.dart';
import 'package:starter_template/features/orders_list/place_order/orders_provider.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = ref.watch(filteredMenuProvider);
    final cartState = ref.watch(cartAsyncNotifierProvider);
    final total = ref.watch(cartTotalProvider);
    final count = ref.watch(cartCountProvider);
    final orderType = ref.watch(orderTypeProvider);
    final selectedPayment = ref.watch(paymentMethodProvider);
    final selectedTable = ref.watch(selectedTableProvider);
    final selectedArea = ref.watch(selectedDeliveryAddressProvider);

    void placeOrder() async {
      await ref.read(ordersAsyncProvider.notifier).placeOrder(
          orderType: orderType.name,
          orderStatus: "placed",
          paymentStatus: orderType == OrderType.takeaway ? "paid" : "pending",
          paymentType:orderType == OrderType.takeaway ? selectedPayment : 'pending', 
          tableName: orderType == OrderType.dinein ? selectedTable : null,
          deliveryAddress:
              orderType == OrderType.delivery ? selectedArea : null);
      ref.read(cartAsyncNotifierProvider.notifier).clearCart();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: clrMainAppClr,
            content: Center(child: Text('Order placed')),
          ),
        );
      }
    }

    Widget cartItemCard(it) {
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
                      onPressed: () {
                        final newQty = it.quantity > 1 ? it.quantity - 1 : 1;
                        ref
                            .read(cartAsyncNotifierProvider.notifier)
                            .updateQuantity(it.dbId!, newQty);
                      },
                    )
                  : IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => ref
                          .read(cartAsyncNotifierProvider.notifier)
                          .removeItem(it.dbId!),
                    ),
              TxtWidget(
                  txt: '${it.quantity}', fontsize: 16.sp, color: clrMainAppClr),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => ref
                    .read(cartAsyncNotifierProvider.notifier)
                    .updateQuantity(it.dbId!, it.quantity + 1),
              ),
            ],
          ),
        ),
      );
    }

    Widget conditionalSelector() {
      if (orderType == OrderType.takeaway) {
        return Card(
          child: Column(
            children: const [
              SizedBox(height: 8),
              TxtWidget(
                  txt: 'Payment Method',
                  fontsize: 15,
                  fontWeight: FontWeight.w600),
              Center(child: PaymentMethodSelector()),
              SizedBox(height: 8),
            ],
          ),
        );
      } else if (orderType == OrderType.dinein) {
        return Card(
          child: Column(
            children: const [
              SizedBox(height: 8),
              TxtWidget(
                  txt: 'Select Table',
                  fontsize: 15,
                  fontWeight: FontWeight.w600),
              gapH4,
              TableSelector(),
              SizedBox(height: 8),
            ],
          ),
        );
      } else if (orderType == OrderType.delivery) {
        return Card(
          child: Column(
            children: const [
              SizedBox(height: 8),
              TxtWidget(
                  txt: 'Delivery Address',
                  fontsize: 15,
                  fontWeight: FontWeight.w600),
              DeliveryAddressSelector(),
              SizedBox(height: 8),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return Row(
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
                gapH8,
                const CategorySelector(),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.w),
                  height: 30.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TxtWidget(
                          txt: 'Select Menu',
                          fontsize: 18.sp,
                          fontWeight: FontWeight.w600),
                      TxtWidget(
                          txt: 'showing ${menuItems.length} items',
                          fontsize: 15.sp,
                          color: clrGrey,
                          fontWeight: FontWeight.w500),
                    ],
                  ),
                ),
                Expanded(child: const ItemsList()),
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
                      Card(
                        child: Column(
                          children: [
                            gapH12,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TxtWidget(
                                    txt: 'Order Details:',
                                    color: clrMainAppClr,
                                    fontsize: 16.sp,
                                    fontWeight: FontWeight.w600),
                                // TxtWidget(
                                //     txt: 'Order No: 19278',
                                //     color: clrMainAppClr,
                                //     fontsize: 14.sp,
                                //     fontWeight: FontWeight.w500),
                              ],
                            ),
                            Column(children: items.map(cartItemCard).toList()),
                            gapH8,
                          ],
                        ),
                      ),

                      gapH8,
                      Card(
                        child: Column(
                          children: [
                            SizedBox(height: 4),
                            TxtWidget(
                                txt: 'Order Type',
                                fontsize: 15.sp,
                                fontWeight: FontWeight.w600),
                            SizedBox(height: 8),
                            OrderTypeSelector(),
                          ],
                        ),
                      ),
                      gapH8,
                      conditionalSelector(),
                      gapH8,

                      // Totals Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              TxtWidget(
                                  txt: 'Order Cost',
                                  fontsize: 15.sp,
                                  fontWeight: FontWeight.w600),
                              gapH8,
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
                                        fontWeight: FontWeight.w600),
                                  ]),
                              if (orderType == OrderType.delivery)
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TxtWidget(
                                          txt: 'Delivery',
                                          fontsize: 15.sp,
                                          fontWeight: FontWeight.w500),
                                      TxtWidget(
                                          txt: '0 SDG',
                                          fontsize: 15.sp,
                                          fontWeight: FontWeight.w600),
                                    ]),
                              const Divider(),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TxtWidget(
                                        txt: 'Total Cost',
                                        fontsize: 15.sp,
                                        fontWeight: FontWeight.w500),
                                    TxtWidget(
                                        txt: '$total SDG',
                                        fontsize: 15.sp,
                                        fontWeight: FontWeight.w600),
                                  ]),
                            ],
                          ),
                        ),
                      ),
                      gapH12,

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                minimumSize: Size(140.h, 80.h),
                                foregroundColor: clrRed,
                                padding:
                                    EdgeInsets.symmetric(horizontal: 10.w)),
                            onPressed: () => ref
                                .read(cartAsyncNotifierProvider.notifier)
                                .clearCart(),
                            child: const Text('Clear Cart'),
                          ),
                          gapW8,
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                minimumSize: Size(140.h, 80.h),
                                foregroundColor: clrGreen,
                                padding:
                                    EdgeInsets.symmetric(horizontal: 10.w)),
                            onPressed: (selectedPayment == null &&
                                    orderType == OrderType.takeaway)
                                ? null
                                : placeOrder,
                            child: const Text('Complete Order'),
                          ),
                        ],
                      ),
                      gapH8,
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
    );
  }
}
