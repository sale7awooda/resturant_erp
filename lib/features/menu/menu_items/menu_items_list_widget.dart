import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/features/menu/menu_items/menu_item_card_widget.dart';
import 'package:starter_template/features/menu/menu_items/menu_items_providers.dart';
import 'package:starter_template/features/orders/order_model.dart';

class ItemsList extends ConsumerWidget {
  final OrderModel? order;
  const ItemsList({super.key, this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(filteredMenuProvider);

    final crossCount = MediaQuery.sizeOf(context).width >= 1200 ? 4 : 3;

    return SizedBox(
      height: 575.h,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossCount,
          mainAxisSpacing: 2.h,
          crossAxisSpacing: 2.h,
          childAspectRatio: .95,
        ),
        itemCount: items.length,
        itemBuilder: (_, index) => ItemCard(
          item: items[index],
          order: order, // allows prefill/edit mode
        ),
      ),
    );
  }
}
