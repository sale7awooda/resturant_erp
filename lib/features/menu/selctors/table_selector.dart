import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/selctors/table_provider.dart';

class TableSelector extends ConsumerWidget {
  const TableSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tables = ref.watch(tablesProvider);
    final selected = ref.watch(selectedTableProvider);

    return SizedBox(
        // color: clrMainAppClrLight,
        // margin: EdgeInsets.symmetric(vertical: 10.h),
        // height: 200.h,
        // width: 290.w,
        // decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(10.r),
        //     border: Border.all(color: clrMainAppClr, width: 2.w)),
        child:Center(
            child: Wrap(
                spacing: 1.w,
                direction: Axis.horizontal,
                // scrollDirection: Axis.horizontal,
                // shrinkWrap: true,
                // physics: AlwaysScrollableScrollPhysics(),
                children: tables.map((t) {
                  final isSelected = selected == t;
                  return Padding(
                      // margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(2.w),
                      child: ChoiceChip(
                          showCheckmark: false,
                          selectedColor: clrMainAppClr,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                              side: BorderSide(
                                  color:
                                      isSelected ? clrMainAppClr : clrLightGrey,
                                  width: 2.w)),
                          labelPadding: EdgeInsets.all(0),
                          label: Container(
                            alignment: Alignment.center,
                            height: 40.h,
                            width: 40.w,
                            child: TxtWidget(
                                txt: t.toUpperCase(),
                                color: isSelected ? clrWhite : clrBlack,
                                fontWeight: FontWeight.w500,
                                textAlign: TextAlign.center,
                                fontsize: 12.sp),
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            ref.read(selectedTableProvider.notifier).state = t;
                            debugPrint(
                                '=================================\n Selected table: $t}');
                          }));
                }).toList()),
          ) 
        // ExpansionTileItem.card(
        //     initiallyExpanded: true,
        //     childrenPadding: EdgeInsets.only(bottom: 5.h),
        //     title: TxtWidget(
        //         txt: 'Select Table:',
        //         color: clrMainAppClr,
        //         textAlign: TextAlign.center,
        //         fontsize: 16.sp,
        //         fontWeight: FontWeight.w600),
        //     children: [
        //   Center(
        //     child: Wrap(
        //         spacing: 1.w,
        //         direction: Axis.horizontal,
        //         // scrollDirection: Axis.horizontal,
        //         // shrinkWrap: true,
        //         // physics: AlwaysScrollableScrollPhysics(),
        //         children: tables.map((t) {
        //           final isSelected = selected == t;
        //           return Padding(
        //               // margin: EdgeInsets.all(10),
        //               padding: EdgeInsets.all(2.w),
        //               child: ChoiceChip(
        //                   showCheckmark: false,
        //                   selectedColor: clrMainAppClr,
        //                   shape: RoundedRectangleBorder(
        //                       borderRadius: BorderRadius.circular(15.r),
        //                       side: BorderSide(
        //                           color:
        //                               isSelected ? clrMainAppClr : clrLightGrey,
        //                           width: 2.w)),
        //                   labelPadding: EdgeInsets.all(0),
        //                   label: Container(
        //                     alignment: Alignment.center,
        //                     height: 40.h,
        //                     width: 40.w,
        //                     child: TxtWidget(
        //                         txt: t.toUpperCase(),
        //                         color: isSelected ? clrWhite : clrBlack,
        //                         fontWeight: FontWeight.w500,
        //                         textAlign: TextAlign.center,
        //                         fontsize: 12.sp),
        //                   ),
        //                   selected: isSelected,
        //                   onSelected: (_) {
        //                     ref.read(selectedTableProvider.notifier).state = t;
        //                     debugPrint(
        //                         '=================================\n Selected table: $t}');
        //                   }));
        //         }).toList()),
        //   ),
        // ])
        );
  }
}
