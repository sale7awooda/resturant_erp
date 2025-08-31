import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/address/delivery_address_provider.dart';
import 'package:starter_template/features/menu/address/delivery_address_selector.dart';
import 'package:starter_template/features/menu/cart/cart_model.dart';
import 'package:starter_template/features/menu/cart/cart_provider.dart';
import 'package:starter_template/features/menu/categories/category_selector.dart';
import 'package:starter_template/features/menu/menu_items/menu_items_list_widget.dart';
import 'package:starter_template/features/menu/menu_items/menu_items_providers.dart';
import 'package:starter_template/features/menu/payment_method/payment_method_provider.dart';
import 'package:starter_template/features/menu/payment_method/payment_selection_tiles.dart';
import 'package:starter_template/features/menu/selctors/order_type_provider.dart';
import 'package:starter_template/features/menu/selctors/order_type_selctor.dart';
import 'package:starter_template/features/menu/table/table_provider.dart';
import 'package:starter_template/features/menu/table/table_selector.dart';
import 'package:starter_template/features/orders/orders_provider.dart';

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
    final selectedArea = ref.watch(selectedDeliveryAddressProvider)?.name;
    final selectedAreaCost = ref.watch(selectedDeliveryAddressProvider)?.cost;

    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isLargeScreen = screenWidth >= 1200;

    void placeOrder() async {
      await ref.read(ordersAsyncProvider.notifier).placeOrUpdateOrder(
            orderType: orderType.name,
            paymentStatus: orderType == OrderType.takeaway ? "paid" : "pending",
            paymentMethod:
                orderType == OrderType.takeaway ? selectedPayment : "pending",
            tableName: orderType == OrderType.dinein ? selectedTable : null,
            deliveryAddress:
                orderType == OrderType.delivery ? selectedArea : null,
            deliveryFee: orderType == OrderType.delivery ? selectedAreaCost : 0,
          );
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

    Widget cartItemCard(CartItemModel it) {
      return Card(
        color: clrWhite,
        elevation: 2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TxtWidget(
                      txt: it.name,
                      fontsize: isLargeScreen ? 12.sp : 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    gapH4,
                    (it.selectedOption != null && it.selectedOption!.isNotEmpty)
                        ? TxtWidget(
                            txt: 'Option: ${it.selectedOption}',
                            fontsize: isLargeScreen ? 10.sp : 12.sp,
                            fontWeight: FontWeight.w400,
                            color: clrGrey,
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      it.quantity != 1
                          ? IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                final newQty =
                                    it.quantity > 1 ? it.quantity - 1 : 1;
                                ref
                                    .read(cartAsyncNotifierProvider.notifier)
                                    .updateQuantity(it.id!, newQty);
                              },
                            )
                          : IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => ref
                                  .read(cartAsyncNotifierProvider.notifier)
                                  .removeItem(it.id!),
                            ),
                      TxtWidget(
                        txt: '${it.quantity}',
                        fontsize: isLargeScreen ? 14.sp : 16.sp,
                        color: clrMainAppClr,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => ref
                            .read(cartAsyncNotifierProvider.notifier)
                            .updateQuantity(it.id!, it.quantity + 1),
                      ),
                    ],
                  ),
                  TxtWidget(
                    txt: '${it.price} SDG',
                    fontsize: isLargeScreen ? 12.sp : 14.sp,
                    fontWeight: FontWeight.w500,
                    color: clrGrey,
                  ),
                  gapH8
                ],
              )
            ],
          ),
        ),
      );
    }

    Widget conditionalSelector() {
      switch (orderType) {
        case OrderType.takeaway:
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            child: const PaymentMethodSelector(),
          );
        case OrderType.dinein:
          return const TableSelector();
        case OrderType.delivery:
          return const DeliveryAddressSelector();
      }
    }

    return Scaffold(
      backgroundColor: clrLightGrey.withValues(alpha: 0.3),
      body: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TxtWidget(
              txt: 'Menu',
              fontsize: isLargeScreen ? 18.sp : 20.sp,
              fontWeight: FontWeight.w600,
              color: clrBlack,
            ),
            gapH12,
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Left Menu Column --- //
                  Flexible(
                    flex: isLargeScreen ? 8 : 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TxtWidget(
                          txt: 'Categories',
                          fontsize: isLargeScreen ? 13.sp : 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        gapH8,
                        const CategorySelector(),
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 5.h, horizontal: 5.w),
                          height: 30.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TxtWidget(
                                txt: 'Select Menu',
                                fontsize: isLargeScreen ? 13.sp : 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              TxtWidget(
                                txt: 'showing ${menuItems.length} items',
                                fontsize: isLargeScreen ? 12.sp : 14.sp,
                                color: clrGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ),
                        const Expanded(child: ItemsList()),
                      ],
                    ),
                  ),

                  const VerticalDivider(width: 3),

                  // --- Right Cart Column --- //
                  Flexible(
                    flex: 3,
                    child: cartState.when(
                      data: (items) {
                        if (items.isEmpty) {
                          return const Center(child: Text('Cart is empty'));
                        }

                        return Column(
                          children: [
                            // --- Scrollable Cart --- //
                            Expanded(
                              child: ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r)),
                                    child: Padding(
                                      padding: EdgeInsets.all(8.w),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TxtWidget(
                                            txt: 'Order Details:',
                                            fontsize:
                                                isLargeScreen ? 14.sp : 15.sp,
                                            fontWeight: FontWeight.w600,
                                            color: clrMainAppClr,
                                          ),
                                          gapH8,
                                          ...items.map(cartItemCard),
                                        ],
                                      ),
                                    ),
                                  ),
                                  gapH8,
                                  Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r)),
                                    child: Padding(
                                      padding: EdgeInsets.all(8.w),
                                      child: const OrderTypeSelector(),
                                    ),
                                  ),
                                  gapH8,
                                  conditionalSelector(),
                                ],
                              ),
                            ),

                            // --- Sticky Totals & Buttons --- //
                            Container(
                              decoration: BoxDecoration(
                                color: clrWhite,
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: const Offset(0, -2),
                                  )
                                ],
                              ),
                              padding: EdgeInsets.all(8.w),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TxtWidget(txt: '$count item(s)'),
                                      TxtWidget(txt: '$total SDG'),
                                    ],
                                  ),
                                  if (orderType == OrderType.delivery)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const TxtWidget(txt: 'Delivery'),
                                        TxtWidget(
                                          txt: selectedAreaCost == null
                                              ? '----'
                                              : '$selectedAreaCost SDG',
                                        ),
                                      ],
                                    ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const TxtWidget(txt: 'Total Cost'),
                                      TxtWidget(
                                        txt:
                                            '${total + (selectedAreaCost ?? 0)} SDG',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                  gapH12,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(135.h, 60.h),
                                          backgroundColor: clrRed,
                                        ),
                                        onPressed: () => ref
                                            .read(cartAsyncNotifierProvider
                                                .notifier)
                                            .clearCart(),
                                        child: const TxtWidget(
                                            txt: 'Clear Cart', color: clrWhite),
                                      ),
                                      gapW8,
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(135.h, 60.h),
                                          backgroundColor: clrGreen,
                                        ),
                                        onPressed: ((selectedPayment == null &&
                                                    orderType ==
                                                        OrderType.takeaway) ||
                                                (orderType ==
                                                        OrderType.dinein &&
                                                    selectedTable == null) ||
                                                (orderType ==
                                                        OrderType.delivery &&
                                                    selectedArea == null))
                                            ? null
                                            : placeOrder,
                                        child: TxtWidget(
                                          txt: (selectedPayment == null &&
                                                  orderType ==
                                                      OrderType.takeaway)
                                              ? 'Select Payment'
                                              : (orderType ==
                                                          OrderType.dinein &&
                                                      selectedTable == null)
                                                  ? 'Select Table'
                                                  : (orderType ==
                                                              OrderType
                                                                  .delivery &&
                                                          selectedArea == null)
                                                      ? 'Select Address'
                                                      : 'Complete Order',
                                          color: clrWhite,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, st) =>
                          Center(child: Text('Error loading cart: $e')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
