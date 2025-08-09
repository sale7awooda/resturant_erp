import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
            flex: 7,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              // padding: EdgeInsets.all(2.w),
              // physics: NeverScrollableScrollPhysics(),
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 70,
                  color: clrAmber,
                ),
                Container(
                  height: 170,
                  color: clrGrey,
                ),
                Container(
                  height: 80,
                  color: clrBlue,
                ),
                Container(
                  height: 40,
                  color: clrAmber,
                ),
                Container(
                  height: 300,
                  color: clrDarkGreen,
                ),
                Container(
                  height: 70,
                  color: clrAmber,
                ),
                Container(
                  height: 270,
                  color: clrGrey,
                )
              ],
            )),
        Flexible(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    // scrollDirection: Axis.vertical,
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TxtWidget(txt: 'bill detaills:'),
                            TxtWidget(txt: 'bill #19278')
                          ]),
                      gapH16,
                      TxtWidget(txt: 'customer name:'),
                      gapH12,
                      TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.r),
                              borderSide:
                                  BorderSide(width: 1.w, color: clrLightGrey)),
                          labelText: 'Enter customer name',
                        ),
                      ),
                      gapH12,
                      Container(
                        height: 170,
                        color: clrGrey,
                        child: Center(child: TxtWidget(txt: 'list of items')),
                      ),
                      Divider(),
                      Container(
                        height: 100,
                        color: clrGrey,
                        child: Center(
                            child: TxtWidget(txt: 'items discounts and taxes')),
                      ),
                      Divider(),
                      Container(
                        height: 70,
                        color: clrGrey,
                        child:
                            Center(child: TxtWidget(txt: 'items total amount')),
                      ),
                      Divider(),
                      gapH12,
                      TxtWidget(txt: 'select payment method'),
                      gapH12,
                      SizedBox(
                        height: 100.h,
                        child: ListView(shrinkWrap: true,
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          scrollDirection: Axis.horizontal,
                          children: [
                            Container(
                              height: 100.h,
                              width: 100.h,
                              decoration: BoxDecoration(
                                  // color: clrBlue,
                                  border:
                                      Border.all(width: 2.w, color: clrBlue),
                                  borderRadius: BorderRadius.circular(15.r)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.money,
                                    color: clrBlue,
                                  ),
                                  gapH8,
                                  TxtWidget(
                                    txt: 'Pay With Cash',
                                    // fontsize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  )
                                ],
                              ),
                            ),
                            gapW8,
                            Container(
                              height: 100.h,
                              width: 100.h,
                              decoration: BoxDecoration(
                                  // color: clrBlue,
                                  border:
                                      Border.all(width: 2.w, color: clrBlue),
                                  borderRadius: BorderRadius.circular(15.r)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.mobile_screen_share,
                                    color: clrBlue,
                                  ),
                                  gapH8,
                                  TxtWidget(
                                      txt: 'Mobile Banking',
                                      // fontsize: 12.sp,
                                      fontWeight: FontWeight.w500)
                                ],
                              ),
                            ),
                            // gapW8,
                            // Container(
                            //   height: 100.h,
                            //   width: 100.h,
                            //   decoration: BoxDecoration(
                            //       // color: clrBlue,
                            //       border:
                            //           Border.all(width: 2.w, color: clrBlue),
                            //       borderRadius: BorderRadius.circular(15.r)),
                            //   child: Column(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            //       Icon(
                            //         Icons.mobile_screen_share,
                            //         color: clrBlue,
                            //       ),
                            //       gapH8,
                            //       TxtWidget(
                            //         txt: 'FawrySD',
                            //         // fontsize: 12.sp,
                            //         fontWeight: FontWeight.w500,
                            //       )
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      )
                    ],
                  ),
                  gapH20,
                  Container(
                      padding: EdgeInsets.all(20.w),
                      // margin: EdgeInsets.all(10.w),
                      color: Colors.blue,
                      child: Text('I am always at the bottom!',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center)),
                ],
              ),
            ),
          ),
          // Stack(
          //   children: [
          //     // Main content

          //     // Floating at the bottom
          //     Positioned(
          //         left: 0,
          //         right: 0,
          //         bottom: 10,
          //         child: Container(
          //           padding: EdgeInsets.all(16),
          //           color: Colors.blue,
          //           child: Text(
          //             'I am always at the bottom!',
          //             style: TextStyle(color: Colors.white),
          //             textAlign: TextAlign.center,
          //           ),
          //         )),
          //   ],
          // )
        )
      ],
    );
  }
}
