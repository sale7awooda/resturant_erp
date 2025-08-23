import 'package:expansion_tile_group/expansion_tile_group.dart';
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
import 'package:starter_template/features/menu/tabs_section/delivery_address_selector.dart';
import 'package:starter_template/features/orders_list/place_order/orders_provider.dart';

class DeliveryTab extends ConsumerWidget {
  const DeliveryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(filteredMenuProvider);
    final cartState = ref.watch(cartAsyncNotifierProvider);
    final total = ref.watch(cartTotalProvider);
    final count = ref.watch(cartCountProvider);

    final paymenyIsSelected = ref.watch(paymentMethodProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
            flex: 7,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                // shrinkWrap: true,
                // scrollDirection: Axis.vertical,
                children: [
                  //? header center bar
                  // SizedBox(
                  //   height: 70.h,
                  //   // color: clrAmber,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //     children: [
                  //       //? SEARCH BAR
                  //       // SizedBox(
                  //       //   width: 350.w,
                  //       //   height: 50.h,
                  //       //   child: SearchBar(
                  //       //       backgroundColor:
                  //       //           WidgetStateProperty.all(clrLightGrey),
                  //       //       hintText: 'what are you looking for?',
                  //       //       leading: Icon(Icons.search_outlined)),
                  //       // ),
                  //       //? USER INFO
                  //       // SizedBox(
                  //       //     width: 250.w,
                  //       //     // height: 80.h,
                  //       //     child: ListTile(
                  //       //       leading: Icon(
                  //       //         Icons.person,
                  //       //         color: clrMainAppClr,
                  //       //       ),
                  //       //       title: TxtWidget(
                  //       //         txt: 'welcome,${'user roll'}',
                  //       //         fontsize: 14.sp,
                  //       //         color: clrBlack,
                  //       //         fontWeight: FontWeight.w600,
                  //       //       ),
                  //       //       subtitle: TxtWidget(
                  //       //         txt: 'user name',
                  //       //         fontsize: 18.sp,
                  //       //         color: clrMainAppClr,
                  //       //         fontWeight: FontWeight.w400,
                  //       //       ),
                  //       //     )),
                  //       //? NOTIFICATION ICON
                  //       // IconButton(
                  //       //   icon:
                  //       //       Icon(Icons.notifications, color: clrMainAppClr),
                  //       //   onPressed: () {},
                  //       // )
                  //     ],
                  //   ),
                  // ),

                  TxtWidget(
                      txt: 'Categories',
                      fontsize: 18.sp,
                      fontWeight: FontWeight.w600),
                  gapH8,
                  CategorySelector(),
                  Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.w),
                      height: 30.h,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TxtWidget(
                                txt: 'Select Menu',
                                fontsize: 18.sp,
                                // color: clrMainAppClr,
                                fontWeight: FontWeight.w600),
                            Spacer(),
                            TxtWidget(
                                txt: 'showing ${items.length} items',
                                fontsize: 15.sp,
                                color: clrGrey,
                                fontWeight: FontWeight.w500)
                          ])),
                  Expanded(
                    child: ItemsList(),
                  )
                ])),
        VerticalDivider(),
        Flexible(
            flex: 3,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Column(
                children: [
                  ExpansionTileOutlined(
                    title: TxtWidget(
                        txt: 'Select Area of Delivery:',
                        color: clrMainAppClr,
                        textAlign: TextAlign.center,
                        fontsize: 16.sp,
                        fontWeight: FontWeight.w600),
                    expendedBorderColor: Colors.blue,
                    children: [
                      DeliveryAddressSelector(),
                    ],
                  ),
                  cartState.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return Expanded(
                          child: Center(child: Text('Cart is empty')),
                        );
                      }
                      return Expanded(
                        child: Column(
                          children: [
                            // gapH4,
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TxtWidget(
                                    txt: 'Order Details:',
                                    color: clrMainAppClr,
                                    textAlign: TextAlign.center,
                                    fontsize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  TxtWidget(
                                    txt: 'Order No: 19278',
                                    color: clrMainAppClr,
                                    textAlign: TextAlign.center,
                                    fontsize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  )
                                ]),
                            Expanded(
                              child: ListView.builder(
                                itemCount: items.length,
                                itemBuilder: (context, i) {
                                  final it = items[i];
                                  return Card(
                                    child: ListTile(
                                      title: Text(it.name),
                                      subtitle: Text(
                                          'Option: ${it.selectedOption ?? '-'}'),
                                      trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            it.quantity != 1
                                                ? IconButton(
                                                    icon: Icon(Icons.remove),
                                                    onPressed: () {
                                                      final newQty =
                                                          (it.quantity > 1)
                                                              ? it.quantity - 1
                                                              : 1;
                                                      ref
                                                          .read(
                                                              cartAsyncNotifierProvider
                                                                  .notifier)
                                                          .updateQuantity(
                                                              it.dbId!, newQty);
                                                    },
                                                  )
                                                : IconButton(
                                                    icon: Icon(Icons.delete,
                                                        color: Colors.red),
                                                    onPressed: () {
                                                      ref
                                                          .read(
                                                              cartAsyncNotifierProvider
                                                                  .notifier)
                                                          .removeItem(it.dbId!);
                                                    },
                                                  ),
                                            TxtWidget(
                                                txt: '${it.quantity}',
                                                fontsize: 16.sp,
                                                color: clrMainAppClr),
                                            IconButton(
                                                icon: const Icon(Icons.add),
                                                onPressed: () => ref
                                                    .read(
                                                        cartAsyncNotifierProvider
                                                            .notifier)
                                                    .updateQuantity(it.dbId!,
                                                        it.quantity + 1))
                                          ]),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const Divider(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              // mainAxisAlignment: MainAxisAlignment.spaceAround,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TxtWidget(
                                        txt: '$count item(s)',
                                        textAlign: TextAlign.center,
                                        fontsize: 15.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      TxtWidget(
                                          txt: 'Total: $total SDG',
                                          textAlign: TextAlign.center,
                                          fontsize: 15.sp,
                                          fontWeight: FontWeight.w600)
                                    ]),
                                TxtWidget(
                                  txt: 'select payment method :',
                                  textAlign: TextAlign.center,
                                  fontsize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                gapH12,
                                Center(
                                  child: SizedBox(
                                      height: 80.h,
                                      width: 280.w,
                                      child: PaymentMethodSelector()),
                                ),
                                gapH20,
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            minimumSize: Size(140.h, 80.h),
                                            foregroundColor: clrRed,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.w)),
                                        onPressed: () {
                                          ref
                                              .read(cartAsyncNotifierProvider
                                                  .notifier)
                                              .clearCart();
                                        },
                                        child: const Text('Clear Cart')),
                                    gapW8,
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          minimumSize: Size(140.h, 80.h),
                                          foregroundColor: clrGreen,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w)),
                                      onPressed: paymenyIsSelected == null
                                          ? null
                                          : () async {
                                              await ref
                                                  .read(ordersAsyncProvider
                                                      .notifier)
                                                  .placeOrder();
                                              // ref
                                              //     .read(
                                              //         cartAsyncNotifierProvider
                                              //             .notifier)
                                              //     .placeOrder();
                                              debugPrint(
                                                  'Order placed with payment: $paymenyIsSelected');
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                        backgroundColor:
                                                            clrMainAppClr,
                                                        content: Center(
                                                            child: Text(
                                                                'Order placed'))));
                                              }
                                            },
                                      child: const Text('Complete Order'),
                                    )
                                  ],
                                ),
                                gapH8
                              ],
                            )
                          ],
                        ),
                      );

                      // Column(
                      //   mainAxisSize: MainAxisSize.min,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     DeliveryAddressSelector(),
                      //     // Divider(),
                      //     gapH4,
                      //     Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: [
                      //           TxtWidget(
                      //             txt: 'Order Details:',
                      //             color: clrMainAppClr,
                      //             textAlign: TextAlign.center,
                      //             fontsize: 16.sp,
                      //             fontWeight: FontWeight.w600,
                      //           ),
                      //           TxtWidget(
                      //             txt: 'Order No: 19278',
                      //             color: clrMainAppClr,
                      //             textAlign: TextAlign.center,
                      //             fontsize: 14.sp,
                      //             fontWeight: FontWeight.w500,
                      //           )
                      //         ]),
                      //     Expanded(
                      //       child: ListView.builder(
                      //         itemCount: items.length,
                      //         itemBuilder: (context, i) {
                      //           final it = items[i];
                      //           return Card(
                      //             child: ListTile(
                      //               title: Text(it.name),
                      //               subtitle:
                      //                   Text('Option: ${it.selectedOption ?? '-'}'),
                      //               trailing: Row(
                      //                   mainAxisSize: MainAxisSize.min,
                      //                   children: [
                      //                     it.quantity != 1
                      //                         ? IconButton(
                      //                             icon: Icon(Icons.remove),
                      //                             onPressed: () {
                      //                               final newQty = (it.quantity > 1)
                      //                                   ? it.quantity - 1
                      //                                   : 1;
                      //                               ref
                      //                                   .read(
                      //                                       cartAsyncNotifierProvider
                      //                                           .notifier)
                      //                                   .updateQuantity(
                      //                                       it.dbId!, newQty);
                      //                             },
                      //                           )
                      //                         : IconButton(
                      //                             icon: Icon(Icons.delete,
                      //                                 color: Colors.red),
                      //                             onPressed: () {
                      //                               ref
                      //                                   .read(
                      //                                       cartAsyncNotifierProvider
                      //                                           .notifier)
                      //                                   .removeItem(it.dbId!);
                      //                             },
                      //                           ),
                      //                     TxtWidget(
                      //                         txt: '${it.quantity}',
                      //                         fontsize: 16.sp,
                      //                         color: clrMainAppClr),
                      //                     IconButton(
                      //                         icon: const Icon(Icons.add),
                      //                         onPressed: () => ref
                      //                             .read(cartAsyncNotifierProvider
                      //                                 .notifier)
                      //                             .updateQuantity(
                      //                                 it.dbId!, it.quantity + 1))
                      //                   ]),
                      //             ),
                      //           );
                      //         },
                      //       ),
                      //     ),
                      // const Divider(),
                      // Column(
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [
                      //     Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: [
                      //           TxtWidget(
                      //             txt: '$count item(s)',
                      //             textAlign: TextAlign.center,
                      //             fontsize: 15.sp,
                      //             fontWeight: FontWeight.w500,
                      //           ),
                      //           TxtWidget(
                      //               txt: 'Total: $total SDG',
                      //               textAlign: TextAlign.center,
                      //               fontsize: 15.sp,
                      //               fontWeight: FontWeight.w600)
                      //         ]),
                      //     TxtWidget(
                      //       txt: 'select payment method :',
                      //       textAlign: TextAlign.center,
                      //       fontsize: 15.sp,
                      //       fontWeight: FontWeight.w600,
                      //     ),
                      //     gapH12,
                      //     Center(
                      //       child: SizedBox(
                      //           height: 80.h,
                      //           width: 280.w,
                      //           child: PaymentMethodSelector()),
                      //     ),
                      //     gapH20,
                      //     Row(
                      //       mainAxisSize: MainAxisSize.min,
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         ElevatedButton(
                      //             style: ElevatedButton.styleFrom(
                      //                 minimumSize: Size(140.h, 80.h),
                      //                 foregroundColor: clrRed,
                      //                 padding: EdgeInsets.symmetric(
                      //                     horizontal: 10.w)),
                      //             onPressed: () {
                      //               ref
                      //                   .read(
                      //                       cartAsyncNotifierProvider.notifier)
                      //                   .clearCart();
                      //             },
                      //             child: const Text('Clear Cart')),
                      //         gapW8,
                      //         ElevatedButton(
                      //           style: ElevatedButton.styleFrom(
                      //               minimumSize: Size(140.h, 80.h),
                      //               foregroundColor: clrGreen,
                      //               padding:
                      //                   EdgeInsets.symmetric(horizontal: 10.w)),
                      //           onPressed: paymenyIsSelected != null
                      //               ? null
                      //               : () {
                      //                   ref
                      //                       .read(cartAsyncNotifierProvider
                      //                           .notifier)
                      //                       .clearCart();
                      //                 },
                      //           child: const Text('Complete Order'),
                      //         )
                      //       ],
                      //     ),
                      //     gapH8
                      //   ],
                      // )
                      //   ],
                      // );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) =>
                        Center(child: Text('Error loading cart: $e')),
                  ),
                ],
              ),
            ))
      ],
    );
  }
}
