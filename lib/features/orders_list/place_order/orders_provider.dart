// lib/features/orders_list/place_order/orders_provider.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_template/core/db_helper.dart';
import 'package:starter_template/features/logs/log_model.dart';
import 'package:starter_template/features/menu/selctors/order_type_provider.dart';
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

  Future<void> placeOrder({
    required String orderType,
    required String orderStatus,
    required String paymentStatus,
    String? paymentType,
    String? transactionId,
    String? tableName,
    String? deliveryAddress,
    String? deliveryOwner,
    String? deliveryPhone,
  }) async {
    final items = await DBHelper.getCartItems();
    if (items.isEmpty) throw Exception("Cart is empty");

    final total = items.fold<double>(0, (s, e) => s + e.price * e.quantity);
    final count = items.fold<int>(0, (s, e) => s + e.quantity);

    final order = OrderModel(
      orderType: orderType,
      orderStatus: orderStatus,
      paymentStatus: paymentStatus,
      paymentType:orderType==OrderType.dinein.name?paymentStatus: paymentType,
      totalAmount: total,
      totalItems: count,
      transactionId: transactionId ?? _generateTxnId(),
      tableName: tableName,
      deliveryAddress: deliveryAddress,
      deliveryOwner: deliveryOwner,
      deliveryPhone: deliveryPhone,
      createdAt: DateTime.now(),
      items: items,
    );

    final id = await DBHelper.insertOrder(order);
    debugPrint('Order placed details are: ${order.toMap()}');
    await DBHelper.clearCart();

    await _log('order_placed', 'order', id.toString(),
        'Placed $orderType order ($count items, $total total)');
    await reload();
  }

  Future<void> cancelOrder(int orderId) async {
    await DBHelper.cancelOrder(orderId);
    await _log('order_canceled', 'order', orderId.toString(),
        'Order $orderId canceled');
    await reload();
  }

  String _generateTxnId() {
    // final r = Random();
    // return 'TXN-${DateTime.now().millisecondsSinceEpoch}-${r.nextInt(99999)}';
    return 'will be updated later'; // 6-digit code
  }

  Future<void> _log(
      String action, String entity, String? entityId, String details) async {
    await DBHelper.insertLog(LogModel(
      action: action,
      entity: entity,
      entityId: entityId,
      details: details,
      userId: ref.read(currentUserIdProvider),
      timestamp: DateTime.now(),
    ));
  }
}
