import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_template/core/db_helper.dart';
import 'package:starter_template/features/logs/log_model.dart';
import 'package:starter_template/features/menu/cart/cart_model.dart';
import 'package:starter_template/features/menu/cart/cart_provider.dart';
import 'package:starter_template/features/menu/selctors/order_type_provider.dart';
import 'package:starter_template/features/orders_list/place_order/order_model.dart';

final ordersSelectedDateProvider =
    StateProvider<DateTime>((_) => DateTime.now());
final ordersFilterTypeProvider = StateProvider<String?>((_) => null);
final ordersFilterPayProvider = StateProvider<String?>((_) => null);
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
        date: _fmtDate(date), orderType: type, paymentType: pay);
  }

  // ✅ safer: just update the provider date
  void setDate(DateTime d) {
    ref.read(ordersSelectedDateProvider.notifier).state = d;
    ref.invalidateSelf(); // triggers build() again with new date
  }

  // ✅ manual reload (e.g. refresh button)
  Future<void> reload() async {
    state = const AsyncValue.loading();
    try {
      // explicitly read without watch
      final date = ref.read(ordersSelectedDateProvider);
      final type = ref.read(ordersFilterTypeProvider);
      final pay = ref.read(ordersFilterPayProvider);

      final result = await DBHelper.getOrders(
        date: _fmtDate(date),
        orderType: type,
        paymentType: pay,
      );
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> placeOrUpdateOrder(
      {OrderModel? pendingOrder,
      required String orderType,
      required String paymentStatus,
      String? tableName,
      String? deliveryAddress,
      String? deliveryOwner,
      String? deliveryPhone,
      String? deliveryInstructions,
      String? paymentType,
      String? transactionId}) async {
    final items = await DBHelper.getCartItems();
    if (items.isEmpty) throw Exception("Cart is empty");

    final total = items.fold<double>(0, (s, e) => s + e.price * e.quantity);
    final count = items.fold<int>(0, (s, e) => s + e.quantity);

    if (pendingOrder != null) {
      final updated = pendingOrder.copyWith(
          totalAmount: total,
          totalItems: count,
          items: items,
          tableName: tableName,
          deliveryAddress: deliveryAddress ?? pendingOrder.deliveryAddress,
          deliveryOwner: deliveryOwner ?? pendingOrder.deliveryOwner,
          deliveryPhone: deliveryPhone ?? pendingOrder.deliveryPhone,
          deliveryInstructions:
              deliveryInstructions ?? pendingOrder.deliveryInstructions,
          orderStatus: OrderStatus.completed.name,
          paymentStatus: paymentStatus,
          paymentType: paymentType ?? pendingOrder.paymentType);
      await DBHelper.updateOrder(updated);
      debugPrint(
          '++++++++++++++++ the updated order is : \n ${updated.toMap()}');
      await _log('order_updated', 'order', pendingOrder.id.toString(),
          'Updated order ${pendingOrder.id} with $count items, $total total');
    } else {
      final newOrder = OrderModel(
        orderType: orderType,
        orderStatus: orderType == OrderType.takeaway.name
            ? OrderStatus.completed.name
            : OrderStatus.pending.name,
        paymentStatus: paymentStatus,
        paymentType: paymentType,
        tableName: tableName,
        deliveryAddress: deliveryAddress,
        deliveryOwner: deliveryOwner,
        deliveryPhone: deliveryPhone,
        totalAmount: total,
        totalItems: count,
        transactionId: transactionId ?? _generateTxnId(),
        createdAt: DateTime.now(),
        items: items,
      );
      final id = await DBHelper.insertOrder(newOrder);
      debugPrint('++++++++++++++++ the new order is : \n ${newOrder.toMap()}');
      await _log('order_placed', 'order', id.toString(),
          'Placed $orderType order ($count items, $total total)');
    }

    await DBHelper.clearCart();
    ref.invalidate(cartAsyncNotifierProvider);
    await reload();
  }

  Future<void> loadOrderIntoCart(OrderModel order) async {
    await DBHelper.clearCart();
    for (final item in order.items) {
      await DBHelper.insertCartItem(
          CartItemModel.fromOrderItem(item, order.orderType));
    }
    ref.invalidate(cartAsyncNotifierProvider);
  }

  Future<void> cancelOrder(int orderId) async {
    await DBHelper.cancelOrder(orderId);
    await _log('order_canceled', 'order', orderId.toString(),
        'Order $orderId canceled');
    await reload();
  }

  String _generateTxnId() => 'TXN-${DateTime.now().millisecondsSinceEpoch}';

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
