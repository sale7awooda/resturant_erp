import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/features/menu/menu_items/menu_item_card_widget.dart';
import 'package:starter_template/features/menu/menu_items/menu_items_providers.dart';

class ItemsList extends ConsumerWidget {
  const ItemsList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(filteredMenuProvider);
    return SizedBox(
      height: 575.h, // width: double.infinity, // Adjust as needed
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.sizeOf(context).width >= 1200 ? 4 : 3,
            mainAxisSpacing: 1.w,
            crossAxisSpacing: 1.w,
            // mainAxisExtent: 260,
            childAspectRatio: .90),
        itemCount: items.length,
        itemBuilder: (context, i) => ItemCard(item: items[i]),
      ),
    );
  }
}
