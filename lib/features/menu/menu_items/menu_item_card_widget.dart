import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/cart/cart_model.dart';
import 'package:starter_template/features/menu/cart/cart_provider.dart';
import 'package:starter_template/features/menu/menu_items/menu_items_models.dart';
import 'package:starter_template/features/menu/menu_items/menu_items_providers.dart';
import 'package:starter_template/features/menu/tabs_section/order_type_provider.dart';

class ItemCard extends ConsumerWidget {
  final MenuItemModel item;
  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedOptions = ref.watch(selectedOptionsProvider);
    final orderType = ref.read(orderTypeProvider).name;
    final quantity = ref.watch(itemQuantityProvider(item.id));

    final selectedOption = selectedOptions[item.id];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 115.w,
                      child: TxtWidget(
                        txt: item.name,
                        fontsize: 18.sp,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 70.w,
                      child: TxtWidget(
                        txt: '${item.price} SDG',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 90.h,
                  width: 90.h,
                  decoration: BoxDecoration(
                    color: clrWhite,
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(color: clrLightGrey),
                  ),
                  child: Image.asset(item.img),
                ),
              ],
            ),
            gapH4,
            Center(
              child: Wrap(
                spacing: 5.h,
                children: item.options.map((opt) {
                  final isSel = selectedOption == opt;
                  return ChoiceChip(
                    showCheckmark: false,
                    labelPadding: EdgeInsets.all(0),
                    label: TxtWidget(txt: opt),
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
                onPressed: selectedOption == null
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
                              selectedTable: null,
                              orderType: orderType,
                              quantity: quantity,
                            ));
                      },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
