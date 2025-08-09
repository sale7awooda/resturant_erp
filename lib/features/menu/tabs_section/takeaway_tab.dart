import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/cart/cart_provider.dart';

class TakeAwayTab extends ConsumerWidget {
  const TakeAwayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartAsyncNotifierProvider);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TxtWidget(
                        txt: 'bill detaills:',
                        color: clrMainAppClr,
                        textAlign: TextAlign.center,
                        fontsize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      TxtWidget(
                        txt: '#19278',
                        color: clrMainAppClr,
                        textAlign: TextAlign.center,
                        fontsize: 14.sp,
                        fontWeight: FontWeight.w500,
                      )
                    ]),
                gapH12,
                TxtWidget(
                  txt: 'customer name:',
                  color: clrMainAppClr,
                  textAlign: TextAlign.center,
                  fontsize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                gapH12,
                SizedBox(
                  height: 40.h,
                  width: 280.w,
                  child: TextFormField(
                    decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.person_3_rounded, color: clrMainAppClr),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                                style: BorderStyle.solid,
                                width: 1.w,
                                color: clrMainAppClr)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                                style: BorderStyle.solid,
                                width: 1.w,
                                color: clrMainAppClr)),
                        label: TxtWidget(
                          txt: 'Enter customer name',
                          // color: clrMainAppClr,
                          textAlign: TextAlign.center,
                          fontsize: 13.sp,
                          fontWeight: FontWeight.w400,
                        )),
                  ),
                ),
                gapH12,
                cartState.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return const Center(child: Text('Cart is empty'));
                    }
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, i) {
                              final it = items[i];
                              return ListTile(
                                title: Text(it.name),
                                subtitle:
                                    Text('Option: ${it.selectedOption ?? '-'}'),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          final newQty = (it.quantity > 1)
                                              ? it.quantity - 1
                                              : 1;
                                          ref
                                              .read(cartAsyncNotifierProvider
                                                  .notifier)
                                              .updateQuantity(it.dbId!, newQty);
                                        },
                                      ),
                                      Text('${it.quantity}'),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () => ref
                                            .read(cartAsyncNotifierProvider
                                                .notifier)
                                            .updateQuantity(
                                                it.dbId!, it.quantity + 1),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => ref
                                            .read(cartAsyncNotifierProvider
                                                .notifier)
                                            .removeItem(it.dbId!),
                                      ),
                                    ]),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: () {
                                  ref
                                      .read(cartAsyncNotifierProvider.notifier)
                                      .clearCart();
                                },
                                child: const Text('Clear Cart'),
                              ),
                              const Spacer(),
                              Text(
                                  'Total: \$${ref.watch(cartTotalProvider).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                  onPressed: () {
                                    // checkout flow (not implemented)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Checkout not implemented')));
                                  },
                                  child: const Text('Checkout')),
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
                )
                // Divider(),
                // Padding(
                //   padding: EdgeInsets.symmetric(vertical: 10.h),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       TxtWidget(
                //         txt: 'items total amount',
                //         textAlign: TextAlign.center,
                //         fontsize: 14.sp,
                //         fontWeight: FontWeight.w500,
                //       ),
                //       TxtWidget(
                //         txt: '20 SDG',
                //         textAlign: TextAlign.center,
                //         fontsize: 14.sp,
                //         fontWeight: FontWeight.w500,
                //       )
                //     ],
                //   ),
                // ),
                // Divider(),
                // gapH12,
                // TxtWidget(
                //   txt: 'select payment method :',
                //   textAlign: TextAlign.center,
                //   fontsize: 14.sp,
                //   fontWeight: FontWeight.w500,
                // ),
                // gapH12,
                // Center(
                //   child: SizedBox(
                //       height: 100.h,
                //       width: 280.w,
                //       child:PaymentMethodSelector()
                //       ),
                // )
              ],
            ),
            // gapH20,
            // Container(
            //     padding: EdgeInsets.all(20.w),
            //     // margin: EdgeInsets.all(10.w),
            //     color: Colors.blue,
            //     child: Text('I am always at the bottom!',
            //         style: TextStyle(color: Colors.white),
            //         textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}
