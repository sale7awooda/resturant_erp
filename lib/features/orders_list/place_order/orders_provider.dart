// // lib/features/orders_list/place_order/orders_provider.dart

// import 'dart:math';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:starter_template/core/db_helper.dart';
// import 'package:starter_template/features/logs/log_model.dart';
// import 'package:starter_template/features/menu/payment_method/payment_method_provider.dart';
// import 'package:starter_template/features/menu/tabs_section/delivery_address_provider.dart';
// import 'package:starter_template/features/menu/tabs_section/order_type_provider.dart';
// import 'package:starter_template/features/menu/tabs_section/table_provider.dart';
// import 'package:starter_template/features/orders_list/place_order/order_model.dart';

// // --- Filters ---
// final ordersSelectedDateProvider =
//     StateProvider<DateTime>((_) => DateTime.now());
// final ordersFilterTypeProvider = StateProvider<String?>((_) => null);
// final ordersFilterPayProvider = StateProvider<String?>((_) => null);
// final expandedOrderIdProvider = StateProvider<int?>((_) => null);

// final currentUserIdProvider = Provider<String>((_) => 'user-123');

// // --- Orders Notifier ---
// final ordersAsyncProvider =
//     AsyncNotifierProvider<OrdersNotifier, List<OrderModel>>(
//   () => OrdersNotifier(),
// );

// class OrdersNotifier extends AsyncNotifier<List<OrderModel>> {
//   String _fmtDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

//   @override
//   Future<List<OrderModel>> build() async {
//     final date = ref.watch(ordersSelectedDateProvider);
//     final type = ref.watch(ordersFilterTypeProvider);
//     final pay = ref.watch(ordersFilterPayProvider);

//     return DBHelper.getOrders(
//       date: _fmtDate(date),
//       orderType: type,
//       paymentType: pay,
//     );
//   }

//   Future<void> reload() async {
//     state = const AsyncValue.loading();
//     state = AsyncValue.data(await build());
//   }

//   void setDate(DateTime d) =>
//       ref.read(ordersSelectedDateProvider.notifier).state = d;
//   void setType(String? t) => ref.read(ordersFilterTypeProvider.notifier).state =
//       (t?.isEmpty ?? true) ? null : t;
//   void setPayment(String? p) =>
//       ref.read(ordersFilterPayProvider.notifier).state =
//           (p?.isEmpty ?? true) ? null : p;

//   Future<void> placeOrder() async {
//     final orderType = ref.read(orderTypeProvider).name;
//     final paymentType = ref.read(paymentMethodProvider);
//     final table =
//         orderType == 'dinein' ? ref.read(selectedTableProvider) : null;
//     final deliveryAddress = orderType == 'delivery'
//         ? ref.read(selectedDeliveryAddressProvider)
//         : null;

//     final items =
//         await DBHelper.getCartItems(orderType: orderType, selectedTable: table);
//     if (items.isEmpty) throw Exception('Cart is empty for this order.');

//     final total = items.fold<double>(0, (s, e) => s + e.price * e.quantity);
//     final count = items.fold<int>(0, (s, e) => s + e.quantity);
//     final transactionId = _generateTxnId();

//     final order = OrderModel(
//       items: items,
//       totalAmount: total,
//       totalItems: count,
//       orderType: orderType,
//       paymentType: paymentType.toString(),
//       transactionId: transactionId,
//       tableName: table?.isEmpty == true ? null : table,
//       deliveryAddress:
//           deliveryAddress?.isEmpty == true ? null : deliveryAddress,
//       createdAt: DateTime.now(),
//     );

//     await DBHelper.insertOrder(order);
//     final userId = ref.read(currentUserIdProvider);

//     await DBHelper.insertLog(LogModel(
//       action: 'place_order',
//       details:
//           'Placed order ${order.transactionId} | Type: $orderType | Total: $total | Items: $count',
//       userId: userId,
//       timestamp: DateTime.now(),
//     ));

//     // Clear cart
//     if (orderType == 'dinein') {
//       await DBHelper.clearCart(selectedTable: table, orderType: orderType);
//     } else {
//       await DBHelper.clearCart(orderType: orderType);
//     }

//     await reload();
//   }

//   String _generateTxnId() {
//     final r = Random();
//     return 'TXN-${DateTime.now().millisecondsSinceEpoch}-${r.nextInt(99999).toString().padLeft(5, '0')}';
//   }

//   Future<void> updateOrder(OrderModel updated) async {
//     final userId = ref.read(currentUserIdProvider);
//     await DBHelper.updateOrder(updated);
//     await DBHelper.insertLog(LogModel(
//       action: 'update_order',
//       details: 'Updated order ${updated.id}',
//       userId: userId,
//       timestamp: DateTime.now(),
//     ));
//     await reload();
//   }

//   Future<void> cancelOrder({required int orderId, String reason = ''}) async {
//     final userId = ref.read(currentUserIdProvider);
//     await DBHelper.updateOrderStatus(id: orderId, status: 'canceled');
//     await DBHelper.insertLog(LogModel(
//       action: 'cancel_order',
//       details:
//           'Canceled order $orderId${reason.isNotEmpty ? " | $reason" : ""}',
//       userId: userId,
//       timestamp: DateTime.now(),
//     ));
//     await reload();
//   }
// }

// // --- Day Summary ---
// final ordersDayTotalAmountProvider = Provider<double>((ref) {
//   final list = ref.watch(ordersAsyncProvider).value ?? [];
//   return list.fold(0.0, (sum, o) => sum + o.totalAmount);
// });

// final ordersDayTotalCountProvider = Provider<int>((ref) {
//   final list = ref.watch(ordersAsyncProvider).value ?? [];
//   return list.fold(0, (sum, o) => sum + o.totalItems);
// });

// final ordersDayOrdersCountProvider = Provider<int>((ref) {
//   return ref.watch(ordersAsyncProvider).value?.length ?? 0;
// });

// lib/features/orders_list/place_order/orders_provider.dart

// ... unchanged imports

import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_template/core/db_helper.dart';
import 'package:starter_template/features/logs/log_model.dart';
import 'package:starter_template/features/menu/payment_method/payment_method_provider.dart';
import 'package:starter_template/features/menu/tabs_section/delivery_address_provider.dart';
import 'package:starter_template/features/menu/tabs_section/order_type_provider.dart';
import 'package:starter_template/features/menu/tabs_section/table_provider.dart';
import 'package:starter_template/features/orders_list/place_order/order_model.dart';

final ordersSelectedDateProvider =
    StateProvider<DateTime>((_) => DateTime.now());
final ordersFilterTypeProvider = StateProvider<String?>((_) => null);
final ordersFilterPayProvider = StateProvider<String?>((_) => null);
final expandedOrderIdProvider = StateProvider<int?>((_) => null);

final currentUserIdProvider = Provider<String>((_) => 'user-123');

final ordersAsyncProvider =
    AsyncNotifierProvider<OrdersNotifier, List<OrderModel>>(
  () => OrdersNotifier(),
);

class OrdersNotifier extends AsyncNotifier<List<OrderModel>> {
  String _fmtDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  @override
  Future<List<OrderModel>> build() async {
    final date = ref.watch(ordersSelectedDateProvider);
    final type = ref.watch(ordersFilterTypeProvider);
    final pay = ref.watch(ordersFilterPayProvider);

    return DBHelper.getOrders(
      date: _fmtDate(date),
      orderType: type,
      paymentType: pay,
    );
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await build());
  }

  void setDate(DateTime d) =>
      ref.read(ordersSelectedDateProvider.notifier).state = d;
  void setType(String? t) => ref.read(ordersFilterTypeProvider.notifier).state =
      (t?.isEmpty ?? true) ? null : t;
  void setPayment(String? p) =>
      ref.read(ordersFilterPayProvider.notifier).state =
          (p?.isEmpty ?? true) ? null : p;

  // --- Dine-in step 1: send to kitchen ---
  Future<void> sendToKitchen() async {
    final table = ref.read(selectedTableProvider);
    if (table == null || table.isEmpty) {
      throw Exception("Select a table first.");
    }

    final items =
        await DBHelper.getCartItems(orderType: 'dinein', selectedTable: table);
    if (items.isEmpty) throw Exception("Cart empty for this table.");

    final total = items.fold<double>(0, (s, e) => s + e.price * e.quantity);
    final count = items.fold<int>(0, (s, e) => s + e.quantity);

    final order = OrderModel(
      items: items,
      totalAmount: total,
      totalItems: count,
      orderType: 'dinein',
      paymentType: null, // no payment yet
      transactionId: _generateTxnId(),
      tableName: table,
      createdAt: DateTime.now(),
      status: 'sent_to_kitchen',
    );

    await DBHelper.insertOrder(order);
    await DBHelper.insertLog(LogModel(
      action: 'send_to_kitchen',
      details: 'Sent table $table order to kitchen',
      userId: ref.read(currentUserIdProvider),
      timestamp: DateTime.now(),
    ));

    await reload(); // NOTE: cart remains intact
  }

  // --- Place order (finalize) ---
  Future<void> placeOrder() async {
    final orderType = ref.read(orderTypeProvider).name;
    final paymentType = ref.read(paymentMethodProvider);
    final table =
        orderType == 'dinein' ? ref.read(selectedTableProvider) : null;
    final deliveryAddress = orderType == 'delivery'
        ? ref.read(selectedDeliveryAddressProvider)
        : null;

    final items =
        await DBHelper.getCartItems(orderType: orderType, selectedTable: table);
    if (items.isEmpty) throw Exception('Cart is empty for this order.');

    final total = items.fold<double>(0, (s, e) => s + e.price * e.quantity);
    final count = items.fold<int>(0, (s, e) => s + e.quantity);

    // Special case: dine-in may already have a "sent_to_kitchen" order → update instead of insert
    if (orderType == 'dinein') {
      final existing = (await DBHelper.getOrders(orderType: 'dinein'))
          .where((o) => o.tableName == table && o.status == 'sent_to_kitchen')
          .toList();

      if (existing.isNotEmpty) {
        final current = existing.first;
        final updated = current.copyWith(
          items: items,
          totalAmount: total,
          totalItems: count,
          paymentType: paymentType.toString(),
          status: 'placed',
        );
        await DBHelper.updateOrder(updated);
      } else {
        final newOrder = OrderModel(
          items: items,
          totalAmount: total,
          totalItems: count,
          orderType: 'dinein',
          paymentType: paymentType.toString(),
          transactionId: _generateTxnId(),
          tableName: table,
          createdAt: DateTime.now(),
          status: 'placed',
        );
        await DBHelper.insertOrder(newOrder);
      }
      await DBHelper.clearCart(orderType: 'dinein', selectedTable: table);
    } else {
      // takeaway & delivery always create a fresh order
      final order = OrderModel(
        items: items,
        totalAmount: total,
        totalItems: count,
        orderType: orderType,
        paymentType: paymentType.toString(),
        transactionId: _generateTxnId(),
        tableName: table,
        deliveryAddress: deliveryAddress,
        createdAt: DateTime.now(),
        status: 'placed',
      );
      await DBHelper.insertOrder(order);
      await DBHelper.clearCart(orderType: orderType);
    }

    await DBHelper.insertLog(LogModel(
      action: 'place_order',
      details: 'Placed $orderType order | Total: $total | Items: $count',
      userId: ref.read(currentUserIdProvider),
      timestamp: DateTime.now(),
    ));

    await reload();
  }

  // helpers
  String _generateTxnId() {
    final r = Random();
    return 'TXN-${DateTime.now().millisecondsSinceEpoch}-${r.nextInt(99999).toString().padLeft(5, '0')}';
  }
}

// --- Day Summary ---
final ordersDayTotalAmountProvider = Provider<double>((ref) {
  final list = ref.watch(ordersAsyncProvider).value ?? [];
  return list.fold(0.0, (sum, o) => sum + o.totalAmount);
});

final ordersDayTotalCountProvider = Provider<int>((ref) {
  final list = ref.watch(ordersAsyncProvider).value ?? [];
  return list.fold(0, (sum, o) => sum + o.totalItems);
});

final ordersDayOrdersCountProvider = Provider<int>((ref) {
  return ref.watch(ordersAsyncProvider).value?.length ?? 0;
});
