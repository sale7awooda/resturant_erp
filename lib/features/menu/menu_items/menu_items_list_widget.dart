// // menu_list.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:starter_template/common/widgets/txt_widget.dart';
// import 'package:starter_template/core/constants.dart';
// import 'package:starter_template/features/menu/menu_items/menu_items_models.dart';
// import 'package:starter_template/features/menu/menu_items/menu_items_providers.dart';

// class MenuList extends ConsumerWidget {
//   const MenuList({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final menuItems = ref.watch(menuProvider);
//     final selectedOptions = ref.watch(selectedOptionsProvider);

//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         mainAxisSpacing: 1.w,
//         // crossAxisSpacing: 1.w,
//         childAspectRatio: 1.15, // Adjust as needed for card aspect ratio
//       ),
//       shrinkWrap: true,
//       scrollDirection: Axis.vertical,
//       itemCount: menuItems.length,
//       itemBuilder: (context, index) {
//         final item = menuItems[index];
//         final selectedOption = selectedOptions[item.id];

//         return Card(
//           margin: EdgeInsets.symmetric(vertical: 5.w, horizontal: 5.w),
//           child: Padding(
//             padding: EdgeInsets.all(10.h),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(children: [
//                       TxtWidget(
//                           txt: item.name,
//                           fontsize: 18.sp,
//                           fontWeight: FontWeight.w600),
//                       TxtWidget(
//                           txt: "\$${item.price.toStringAsFixed(2)}",
//                           color: clrMainAppClr,
//                           fontsize: 15.sp,
//                           fontWeight: FontWeight.w600)
//                     ]),
//                     Container(
//                       height: 85.h,
//                       width: 85.h,
//                       decoration: BoxDecoration(
//                           // image: DecorationImage(
//                           //     image: AssetImage(
//                           //         item.imagePath ?? 'assets/placeholder.png'),
//                           //     fit: BoxFit.cover),
//                           borderRadius: BorderRadius.circular(15.r),
//                           border: Border.all(color: clrMainAppClrLight)),
//                       child: Center(child: Icon(Icons.soup_kitchen)),
//                     ),
//                   ],
//                 ),
//                 gapH8,
//                 // Options
//                 Center(
//                   child: Wrap(
//                     spacing: 5.w,
//                     children: item.options.map((option) {
//                       final isSelected = selectedOption == option;
//                       return ChoiceChip(
//                         checkmarkColor: clrMainAppClr,
//                         labelPadding: EdgeInsets.all(0.w),
//                         selectedColor: clrMainAppClrLight,
//                         showCheckmark: false,
//                         label: TxtWidget(txt: option, fontsize: 12.sp),
//                         selected: isSelected,
//                         onSelected: (_) {
//                           ref.read(selectedOptionsProvider.notifier).state = {
//                             ...selectedOptions,
//                             item.id: option
//                           };
//                           debugPrint(
//                               'Selected option for ${item.name}: $option');
//                         },
//                       );
//                     }).toList(),
//                   ),
//                 ),
//                 gapH16,
//                 // Add to Order button
//                 Center(
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       ref.read(cartProvider.notifier).addToCart(
//                             CartItem(
//                               id: item.id,
//                               name: item.name,
//                               price: item.price,
//                               selectedOption: selectedOption,
//                             ),
//                           );
//                       // EasyLoading.showToast("${item.name} added to cart",
//                       //     toastPosition: EasyLoadingToastPosition.bottom);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text("${item.name} added to cart")),
//                       );
//                     },
//                     icon: const Icon(Icons.add_shopping_cart),
//                     label: const Text("Add to Order"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:starter_template/features/menu/menu_items/menu_items_models.dart';

// class ItemsList extends ConsumerWidget {
//   final List<MenuItemModel> items;

//   const ItemsList({super.key, required this.items});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       itemCount: items.length,
//       itemBuilder: (context, index) {
//         return ItemCard(item: items[index]);
//       },
//     );
//   }
// }

// class ItemCard extends ConsumerStatefulWidget {
//   final MenuItemModel item;

//   const ItemCard({super.key, required this.item});

//   @override
//   ConsumerState<ItemCard> createState() => _ItemCardState();
// }

// class _ItemCardState extends ConsumerState<ItemCard> {
//   String? selectedOption;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 8),
//       child: Padding(
//         padding: EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(widget.item.name, style: TextStyle(fontSize: 18)),
//             SizedBox(height: 4),
//             Text("\$${widget.item.price.toStringAsFixed(2)}"),
//             SizedBox(height: 8),
//             Wrap(
//               spacing: 6,
//               children: widget.item.options.map((opt) {
//                 return ChoiceChip(
//                   label: Text(opt),
//                   selected: selectedOption == opt,
//                   onSelected: (_) {
//                     setState(() => selectedOption = opt);
//                   },
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: selectedOption == null
//                   ? null
//                   : () {
//                       // ref
//                       //     .read(cartProvider.notifier)
//                       //     .addToCart(widget.item, selectedOption!);
//                     },
//               child: Text("Add to Order"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
      height: 300.h, width: double.infinity, // Adjust as needed
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 1.w,
          crossAxisSpacing: 1.w,
          childAspectRatio: 1.05, // Adjust as needed for card aspect ratio
        ),
        itemCount: items.length,
        itemBuilder: (context, i) => ItemCard(item: items[i]),
      ),
    );
  }
}
