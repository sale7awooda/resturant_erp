// // category_selector.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:starter_template/common/widgets/txt_widget.dart';
// import 'package:starter_template/core/constants.dart';
// import 'package:starter_template/features/menu/categories/categories_provider.dart';

// class CategorySelector extends ConsumerWidget {
//   const CategorySelector({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final categories = ref.watch(categoriesProvider);
//     final selectedCategory = ref.watch(selectedCategoryProvider);

// return Container(
//   margin: EdgeInsets.symmetric(vertical: 10.h),
//   height: 100.h,
//       child: ListView(
// scrollDirection: Axis.horizontal, shrinkWrap: true,
// physics: AlwaysScrollableScrollPhysics(),
// children: categories.map((category) {
//           final isSelected = selectedCategory == category;

//           return GestureDetector(
//             onTap: () {
//               ref.read(selectedCategoryProvider.notifier).state = category;
//               debugPrint(
//                   '=================================\n Selected category: $category');
//             },
//             child: Container(
//                 margin: EdgeInsets.all(5.w),
//                 height: 90.h,
//                 width: 90.h,
//                 alignment: Alignment.center,
//                 // padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 2.h),
//                 decoration: BoxDecoration(
//                   color: isSelected ? clrMainAppClr : clrWhite,
//                   borderRadius: BorderRadius.circular(10.r),
//                   border: Border.all(
//                       color: isSelected ? clrMainAppClr : clrLightGrey,
//                       width: 2.w),
//                 ),
//                 child: TxtWidget(
//                     txt: category,
//                     color: isSelected ? Colors.white : Colors.black,
//                     fontWeight: FontWeight.bold,
//                     textAlign: TextAlign.center,
//                     fontsize: 14.sp)),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/categories/categories_provider.dart';

class CategorySelector extends ConsumerWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selected = ref.watch(selectedCategoryProvider);

    return Container(
      // color: clrMainAppClrLight,
      margin: EdgeInsets.symmetric(horizontal: 5.h),
      // decoration: BoxDecoration(
      //     borderRadius: BorderRadius.circular(10.r),
      //     border: Border.all(color: clrMainAppClr, width: 2.w)),
      height: 70.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        children: categories.map((c) {
          final isSelected = selected == c;
          return Padding(
            // margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(3.h),
            child: ChoiceChip(
              showCheckmark: false,
              selectedColor: clrMainAppClr,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                  side: BorderSide(
                      color: isSelected ? clrMainAppClr : clrLightGrey,
                      width: 2.w)),
              label: Container(
                alignment: Alignment.center,
                height: 50.h,
                child: TxtWidget(
                    txt: c.toUpperCase().split('ALL').join('ALL '),
                    color: isSelected ? clrWhite : clrBlack,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.center,
                    fontsize: 12.sp),
              ),
              selected: isSelected,
              onSelected: (_) {
                ref.read(selectedCategoryProvider.notifier).state = c;
                debugPrint(
                    '=================================\n Selected category: $c');
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
