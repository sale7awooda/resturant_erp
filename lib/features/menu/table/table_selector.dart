import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/table/table_provider.dart';

class TableSelector extends ConsumerWidget {
  const TableSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tables = ref.watch(tablesProvider);
    final selected = ref.watch(selectedTableProvider);

    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TxtWidget(
                  txt: "Select Table",
                  fontsize:
                      MediaQuery.sizeOf(context).width >= 1200 ? 12.sp : 14.sp,
                  fontWeight: FontWeight.w600,
                  color: clrMainAppClr,
                ),
                Icon(Icons.table_bar, color: clrMainAppClr, size: 28.sp)
              ],
            ),gapH8,
            Center(
              child: Wrap(
                spacing: 5.w,
                runSpacing: 5.h,
                children: tables.map((t) {
                  final isSelected = selected == t;

                  return InkWell(
                    borderRadius: BorderRadius.circular(16.r),
                    onTap: () {
                      ref.read(selectedTableProvider.notifier).state = t;
                      debugPrint("✅ Selected table: $t");
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      height: 50.h,
                      width: 65.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? clrMainAppClr : Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isSelected ? clrMainAppClr : clrLightGrey,
                          width: 1.5.w,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: clrMainAppClr.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : [],
                      ),
                      child: TxtWidget(
                        txt: t.toUpperCase(),
                        textAlign: TextAlign.center,
                        color: isSelected ? clrWhite : clrBlack,
                        fontWeight: FontWeight.w600,
                        fontsize: MediaQuery.sizeOf(context).width >= 1200 ? 10.sp : 12.sp,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
