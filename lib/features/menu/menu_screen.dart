import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_template/features/menu/cart/cart_provider.dart';
import 'package:starter_template/features/menu/tabs_section/delivery_tab.dart';
import 'package:starter_template/features/menu/tabs_section/dine_in_tab.dart';
import 'package:starter_template/features/menu/tabs_section/order_type_provider.dart';
import 'package:starter_template/features/menu/tabs_section/takeaway_tab.dart';

class MenuScreen extends ConsumerWidget {
  MenuScreen({super.key});

  final tabs = [
    Tab(icon: Icon(Icons.shopping_bag, color: Colors.orange), text: "takeaway"),
    Tab(icon: Icon(Icons.restaurant,color: Colors.blue), text: "dine-in"),
    Tab(icon: Icon(Icons.delivery_dining,color: Colors.green), text: "delivery")
  ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Builder(builder: (context) {
        final tabCtrl = DefaultTabController.of(context);
        tabCtrl.addListener(() {
          if (!tabCtrl.indexIsChanging) {
            ref.read(orderTypeProvider.notifier).state =
                OrderType.values[tabCtrl.index];
            ref.read(cartAsyncNotifierProvider.notifier).reload();
          }
        });
        // Provider -> tab (optional: if you change provider elsewhere)
        // ref.listen<OrderType>(orderTypeProvider, (prev, next) {
        //   if (tabCtrl.index != next.index) {
        //     tabCtrl.animateTo(next.index);
        //   }
        // });

        return Scaffold(
          appBar: AppBar(
              title: TabBar(
                  // indicator: BoxDecoration(color: clrLightGrey),
                  tabs: tabs
                      .map((tab) => Tab(
                          text: tab.text,
                          icon: tab.icon,
                          iconMargin: EdgeInsets.all(0)))
                      .toList())),
          body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [TakeAwayTab(), DineInTab(), DeliveryTab()]),
        );
      }),
    );
  }
}
