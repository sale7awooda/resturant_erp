import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/menu/menu_items/menu_items_list_widget.dart';
import 'package:starter_template/features/menu/tabs_section/delivery_tab.dart';
import 'package:starter_template/features/menu/tabs_section/dine_in_tab.dart';
import 'package:starter_template/features/menu/tabs_section/takeaway_tab.dart';
import 'package:starter_template/features/menu/categories/category_selector.dart';
import 'package:starter_template/features/menu/summart_and_order_widget.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
            flex: 7,
            child: Padding(
              padding: EdgeInsets.all(5.w),
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: [
                  //? header center bar
                  SizedBox(
                    height: 80.h,
                    // color: clrAmber,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //? SEARCH BAR
                        SizedBox(
                          width: 350.w,
                          height: 50.h,
                          child: SearchBar(
                              backgroundColor:
                                  WidgetStateProperty.all(clrLightGrey),
                              hintText: 'what are you looking for?',
                              leading: Icon(Icons.search_outlined)),
                        ),
                        //? USER INFO
                        SizedBox(
                            width: 250.w,
                            height: 80.h,
                            child: ListTile(
                              leading: Icon(
                                Icons.person,
                                color: clrMainAppClr,
                              ),
                              title: TxtWidget(
                                txt: 'welcome,${'user roll'}',
                                fontsize: 14.sp,
                                color: clrBlack,
                                fontWeight: FontWeight.w600,
                              ),
                              subtitle: TxtWidget(
                                txt: 'user name',
                                fontsize: 18.sp,
                                color: clrMainAppClr,
                                fontWeight: FontWeight.w400,
                              ),
                            )),
                        //? NOTIFICATION ICON
                        IconButton(
                          icon: Icon(Icons.notifications, color: clrMainAppClr),
                          onPressed: () {},
                        )
                      ],
                    ),
                  ),
                  TxtWidget(
                      txt: 'Categories',
                      fontsize: 18.sp,
                      fontWeight: FontWeight.w600),
                  gapH8,
                  CategorySelector(),
                  Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                      height: 40.h,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TxtWidget(
                                txt: 'Select Menu',
                                fontsize: 14.sp,
                                // color: clrMainAppClr,
                                fontWeight: FontWeight.w600),
                            TxtWidget(
                                txt: 'showing 10 items',
                                fontsize: 13.sp,
                                color: clrGrey,
                                fontWeight: FontWeight.w500)
                          ])),
                  gapH12,
                  // MenuList(),
                  ItemsList(),
                  // Container(
                  //   height: 270,
                  //   color: clrGrey,
                  // )
                ],
              ),
            )),
        Flexible(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(5.w),
              child: Column(
                children: [
                  Expanded(
                    child: DefaultTabController(
                      length: 3,
                      child: Scaffold(
                        appBar: AppBar(
                          title: const TabBar(
                              labelPadding: EdgeInsets.all(0),
                              labelColor: clrMainAppClr,
                              // indicatorColor: clrMainAppClr,
                              tabs: [
                                Tab(
                                    icon: Icon(Icons.flight_takeoff),
                                    text: "takeaway"),
                                Tab(
                                    icon: Icon(Icons.dinner_dining_outlined),
                                    text: "dine-in"),
                                Tab(
                                    icon: Icon(Icons.delivery_dining_rounded),
                                    text: "delivery")
                              ]),
                          // backgroundColor: Colors.blue,
                        ),
                        body: const TabBarView(
                          children: [TakeAwayTab(), DineInTab(), DeliveryTab()],
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  const SummaryAndOrder(),
                ],
              ),
            ))
      ],
    );
  }
}
