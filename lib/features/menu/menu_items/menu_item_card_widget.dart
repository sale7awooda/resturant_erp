import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/core/router/app_router.dart';
import 'package:starter_template/features/menu/cart/cart_model.dart';
import 'package:starter_template/features/menu/cart/cart_provider.dart';
import 'package:starter_template/features/menu/menu_items/menu_items_models.dart';
import 'package:starter_template/features/menu/menu_items/menu_items_providers.dart';
import 'package:starter_template/features/menu/selctors/order_type_provider.dart';
import 'package:starter_template/features/orders/order_model.dart';

class ItemCard extends ConsumerWidget {
  final MenuItemModel item;
  final OrderModel? order;

  const ItemCard({super.key, required this.item, this.order});

  bool _isLocked() =>
      order != null &&
      (order!.orderStatus == OrderStatus.cancelled.name ||
          order!.orderStatus == OrderStatus.completed.name);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedOptions = ref.watch(selectedOptionsProvider);
    final orderType = ref.read(orderTypeProvider).name;
    final quantity = ref.watch(itemQuantityProvider(item.id));
    final selectedOption = selectedOptions[item.id];
    final cart = ref.read(cartAsyncNotifierProvider.notifier);
    final cartPrefilled = ref.read(prefilledCartNotifierProvider.notifier);
    final currentScreen = ref.watch(currentScreenProvider);

    return Card(
      color: clrWhite,
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // --- Item Info & Image ---
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      width: 80.w,
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
                  child: Image.asset(item.img, fit: BoxFit.cover),
                ),
              ],
            ),

            // --- Options Selector ---
            item.options != null
                ? Center(
                    child: Wrap(
                        spacing: 5.h,
                        children: item.options!.map((opt) {
                          final isSelected = selectedOption == opt;
                          return ChoiceChip(
                              showCheckmark: false,
                              labelPadding: EdgeInsets.all(0),
                              label: TxtWidget(
                                txt: opt,
                                fontsize:
                                    MediaQuery.sizeOf(context).width >= 1200
                                        ? 10.sp
                                        : 13.sp,
                              ),
                              selected: isSelected,
                              onSelected: _isLocked()
                                  ? null
                                  : (_) {
                                      final updatedMap =
                                          Map<String, String?>.from(
                                              selectedOptions);
                                      updatedMap[item.id] = opt;
                                      ref
                                          .read(
                                              selectedOptionsProvider.notifier)
                                          .state = updatedMap;
                                      debugPrint(
                                          'Selected option for ${item.name}: $opt');
                                    });
                        }).toList()))
                : SizedBox.shrink(),
            // --- Quantity Selector ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _isLocked() || quantity <= 1
                      ? null
                      : () => ref
                          .read(itemQuantityProvider(item.id).notifier)
                          .state--,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                TxtWidget(
                    txt: '$quantity',
                    fontsize: 15.sp,
                    fontWeight: FontWeight.w600),
                IconButton(
                  onPressed: _isLocked()
                      ? null
                      : () => ref
                          .read(itemQuantityProvider(item.id).notifier)
                          .state++,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),

            // --- Add to Cart Button ---
            Center(
              child: ElevatedButton.icon(
                onPressed: item.options != null
                    ? ((selectedOption == null || _isLocked())
                        ? null
                        : () {
                            currentScreen == AppScreen.orderDetails
                                ? cartPrefilled.addToCart(CartItemModel(
                                    itemId: item.id,
                                    name: item.name,
                                    price: item.price,
                                    imageUrl: item.img,
                                    selectedOption: selectedOption,
                                    orderType: orderType,
                                    quantity: quantity,
                                  ))
                                : cart.addToCart(CartItemModel(
                                    itemId: item.id,
                                    name: item.name,
                                    price: item.price,
                                    imageUrl: item.img,
                                    selectedOption: selectedOption,
                                    orderType: orderType,
                                    quantity: quantity,
                                  ));
                          })
                    : (_isLocked())
                        ? null
                        : () {
                            currentScreen == AppScreen.orderDetails
                                ? cartPrefilled.addToCart(CartItemModel(
                                    itemId: item.id,
                                    name: item.name,
                                    price: item.price,
                                    imageUrl: item.img,
                                    selectedOption: selectedOption,
                                    orderType: orderType,
                                    quantity: quantity,
                                  ))
                                : cart.addToCart(CartItemModel(
                                    itemId: item.id,
                                    name: item.name,
                                    price: item.price,
                                    imageUrl: item.img,
                                    selectedOption: selectedOption,
                                    orderType: orderType,
                                    quantity: quantity,
                                  ));
                          },
                icon: const Icon(Icons.add_shopping_cart),
                label: TxtWidget(
                  txt: _isLocked() ? 'Canceled/Completed' : 'Add to Order',
                  fontsize:
                      MediaQuery.sizeOf(context).width >= 1200 ? 11.sp : 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
