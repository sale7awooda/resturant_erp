import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';

class DineInTab extends StatelessWidget {
  const DineInTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TxtWidget(
                        txt: 'bill detaills:',
                        color: clrMainAppClr,
                        textAlign: TextAlign.center,
                        fontsize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      TxtWidget(
                        txt: '#19278',
                        color: clrMainAppClr,
                        textAlign: TextAlign.center,
                        fontsize: 14.sp,
                        fontWeight: FontWeight.w500,
                      )
                    ]),
                gapH12,
                TxtWidget(
                  txt: 'customer name:',
                  color: clrMainAppClr,
                  textAlign: TextAlign.center,
                  fontsize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                gapH12,
                SizedBox(
                  height: 40.h,
                  width: 280.w,
                  child: TextFormField(
                    decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.person_3_rounded, color: clrMainAppClr),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                                style: BorderStyle.solid,
                                width: 1.w,
                                color: clrMainAppClr)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(
                                style: BorderStyle.solid,
                                width: 1.w,
                                color: clrMainAppClr)),
                        label: TxtWidget(
                          txt: 'Enter customer name',
                          // color: clrMainAppClr,
                          textAlign: TextAlign.center,
                          fontsize: 13.sp,
                          fontWeight: FontWeight.w400,
                        )),
                  ),
                ),
                gapH12,
                Container(
                  height: 170.h,
                  color: clrLightGrey,
                  child: Center(child: TxtWidget(txt: 'list of items')),
                ),
                Divider(),
                Container(
                  height: 100.h,
                  color: clrLightGrey,
                  child: Center(
                      child: TxtWidget(txt: 'items discounts and taxes')),
                ),
                // Divider(),
                // Padding(
                //   padding: EdgeInsets.symmetric(vertical: 10.h),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       TxtWidget(
                //         txt: 'items total amount',
                //         textAlign: TextAlign.center,
                //         fontsize: 14.sp,
                //         fontWeight: FontWeight.w500,
                //       ),
                //       TxtWidget(
                //         txt: '20 SDG',
                //         textAlign: TextAlign.center,
                //         fontsize: 14.sp,
                //         fontWeight: FontWeight.w500,
                //       )
                //     ],
                //   ),
                // ),
                // Divider(),
                // gapH12,
                // TxtWidget(
                //   txt: 'select payment method :',
                //   textAlign: TextAlign.center,
                //   fontsize: 14.sp,
                //   fontWeight: FontWeight.w500,
                // ),
                // gapH12,
                // Center(
                //   child: SizedBox(
                //       height: 100.h,
                //       width: 280.w,
                //       child:PaymentMethodSelector()
                //       ),
                // )
              ],
            ),
            // gapH20,
            // Container(
            //     padding: EdgeInsets.all(20.w),
            //     // margin: EdgeInsets.all(10.w),
            //     color: Colors.blue,
            //     child: Text('I am always at the bottom!',
            //         style: TextStyle(color: Colors.white),
            //         textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}
