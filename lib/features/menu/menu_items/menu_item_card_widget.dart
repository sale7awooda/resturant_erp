import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/cart/cart_model.dart';
import 'package:starter_template/features/menu/cart/cart_provider.dart';
import 'package:starter_template/features/menu/menu_items/menu_items_models.dart';
import 'package:starter_template/features/menu/menu_items/menu_items_providers.dart';

class ItemCard extends ConsumerStatefulWidget {
  final MenuItemModel item;
  const ItemCard({super.key, required this.item});

  @override
  ConsumerState<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends ConsumerState<ItemCard> {
  String? selectedOption;
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final selectedOptions = ref.watch(selectedOptionsProvider);

    // initialize from provider if exists
    selectedOption = selectedOptions[widget.item.id] ?? selectedOption;

    return Card(
      // margin:  EdgeInsets.symmetric(vertical: 5.w, horizontal: 5.w),
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                TxtWidget(
                    txt: widget.item.name,
                    fontsize: 18.sp,
                    fontWeight: FontWeight.bold),
                TxtWidget(txt: 'SDG ${widget.item.price.toString()}')
              ]),
              Container(
                height: 70.h,
                width: 70.h,
                decoration: BoxDecoration(
                    color: clrMainAppClrLight,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: clrLightGrey)),
              )
            ],
          ),
          gapH8,
          Center(
            child: Wrap(
              spacing: 5.h,
              children: widget.item.options.map((opt) {
                final isSel = selectedOption == opt;
                return ChoiceChip(
                  showCheckmark: false,
                  labelPadding: EdgeInsets.all(0),
                  label: TxtWidget(txt: opt),
                  selected: isSel,
                  onSelected: (_) {
                    // setState(() {
                    //   selectedOption = opt;
                    // });
                    // persist into selectedOptionsProvider (ui state)
                    final map = Map<String, String?>.from(
                        ref.read(selectedOptionsProvider));
                    map[widget.item.id] = opt;
                    ref.read(selectedOptionsProvider.notifier).state = map;
                    debugPrint('Selected option for ${widget.item.name}: $opt');
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => setState(
                    () => quantity = (quantity > 1) ? quantity - 1 : 1),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('$quantity'),
              IconButton(
                onPressed: () => setState(() => quantity++),
                icon: const Icon(Icons.add_circle_outline),
              )
            ],
          ),
          Center(
            child: ElevatedButton.icon(
              onPressed: selectedOption == null
                  ? null
                  : () async {
                      final cartItem = CartItemModel(
                        itemId: widget.item.id,
                        name: widget.item.name,
                        price: widget.item.price,
                        selectedOption: selectedOption,
                        quantity: quantity,
                      );
                      await ref
                          .read(cartAsyncNotifierProvider.notifier)
                          .addToCart(cartItem);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('${widget.item.name} added to cart')),
                      );
                    },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add to Order'),
            ),
          )
        ]),
      ),
    );
  }
}
