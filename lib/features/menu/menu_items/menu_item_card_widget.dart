import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/cart/cart_model.dart';
import 'package:starter_template/features/menu/cart/cart_provider.dart';
import 'package:starter_template/features/menu/menu_items/menu_items_models.dart';
import 'package:starter_template/features/menu/menu_items/menu_items_providers.dart';
import 'package:starter_template/features/menu/selctors/order_type_provider.dart';
import 'package:starter_template/features/orders_list/place_order/order_model.dart';

class ItemCard extends ConsumerWidget {
  final MenuItemModel item;
  final OrderModel? order;
  const ItemCard({super.key, required this.item, this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedOptions = ref.watch(selectedOptionsProvider);
    // final selectedTable = ref.read(selectedTableProvider);
    final orderType = ref.read(orderTypeProvider).name;
    final quantity = ref.watch(itemQuantityProvider(item.id));

    final selectedOption = selectedOptions[item.id];

    return Card(
      color: clrWhite,
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width >= 1200
                          ? 100.w
                          : 125.w,
                      child: TxtWidget(
                          txt: item.name,
                          fontsize: MediaQuery.sizeOf(context).width >= 1200
                              ? 12.sp
                              : 15.sp,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w700),
                    ),
                    // gapH4,
                    SizedBox(
                      width: 70.w,
                      child: TxtWidget(
                        txt: '${item.price} SDG',
                        fontWeight: FontWeight.w700,
                        color: clrMainAppClr,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 85.h,
                  width: 85.h,
                  decoration: BoxDecoration(
                    color: clrWhite,
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(color: clrLightGrey),
                  ),
                  child: Image.asset(item.img),
                ),
              ],
            ),
            Center(
              child: Wrap(
                spacing: 5.h,
                children: item.options.map((opt) {
                  final isSel = selectedOption == opt;
                  return ChoiceChip(
                    showCheckmark: false,
                    labelPadding: EdgeInsets.all(0),
                    label: TxtWidget(
                      txt: opt,
                      fontsize: MediaQuery.sizeOf(context).width >= 1200
                          ? 10.sp
                          : 13.sp,
                    ),
                    selected: isSel,
                    onSelected: (_) {
                      final map = Map<String, String?>.from(
                        ref.read(selectedOptionsProvider),
                      );
                      map[item.id] = opt;
                      ref.read(selectedOptionsProvider.notifier).state = map;
                      debugPrint('Selected option for ${item.name}: $opt');
                    },
                  );
                }).toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (quantity > 1) {
                      ref.read(itemQuantityProvider(item.id).notifier).state--;
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$quantity'),
                IconButton(
                  onPressed: () {
                    ref.read(itemQuantityProvider(item.id).notifier).state++;
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            Center(
              child: ElevatedButton.icon(
                onPressed: (selectedOption == null ||
                        ((order?.orderStatus == OrderStatus.cancelled.name ||
                            order?.orderStatus == OrderStatus.completed.name)))
                    ? null
                    : () async {
                        ref
                            .read(cartAsyncNotifierProvider.notifier)
                            .addToCart(CartItemModel(
                              itemId: item.id,
                              name: item.name,
                              price: item.price,
                              imageUrl: item.img,
                              selectedOption: selectedOption,
                              // selectedTable: orderType == OrderType.dinein.name
                              //     ? ref.read(selectedTableProvider)
                              //     : null,
                              orderType: orderType,
                              quantity: quantity,
                            ));
                      },
                icon: const Icon(Icons.add_shopping_cart),
                label: ((order?.orderStatus == OrderStatus.cancelled.name ||
                        order?.orderStatus == OrderStatus.completed.name))
                    ? const Text('Canceled/Completed')
                    : const Text('Add to Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
