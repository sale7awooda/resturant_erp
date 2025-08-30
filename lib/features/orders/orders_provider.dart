import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:starter_template/core/new_db_helper.dart';
import 'package:starter_template/features/menu/cart/cart_model.dart';
import 'package:starter_template/features/menu/cart/cart_provider.dart';
import 'package:starter_template/features/orders/order_model.dart';
import 'package:starter_template/features/orders/orders_dao.dart';
import 'package:starter_template/features/orders/order_items_dao.dart';
import 'package:starter_template/features/logs/log_model.dart';

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
  String _fmtDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  @override
  Future<List<OrderModel>> build() async => _loadOrders();

  Future<List<OrderModel>> _loadOrders() async {
    final date = ref.watch(ordersSelectedDateProvider);
    final type = ref.watch(ordersFilterTypeProvider);
    final pay = ref.watch(ordersFilterPayProvider);

    final rows = await OrdersDao.getAll(
      date: _fmtDate(date),
      orderType: type,
      paymentType: pay,
    );

    final orders = <OrderModel>[];
    for (final row in rows) {
      final orderId = row['id'] as int;
      final itemsRows = await OrderItemsDao.getByOrder(orderId);
      final items = itemsRows.map((e) => OrderItemModel.fromMap(e)).toList();
      orders.add(OrderModel.fromMap(row, orderItems: items));
    }
    return orders;
  }

  void setDate(DateTime date) {
    ref.read(ordersSelectedDateProvider.notifier).state = date;
    ref.invalidateSelf();
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    try {
      final orders = await _loadOrders();
      state = AsyncValue.data(orders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> placeOrUpdateOrder({
    OrderModel? pendingOrder,
    required String orderType,
    required String paymentStatus,
    String? tableName,
    String? deliveryAddress,
    int? deliveryFee,
    String? deliveryOwner,
    String? deliveryPhone,
    String? deliveryInstructions,
    String? paymentMethod,
    String? transactionId,
  }) async {
    final cartRows = await NewDBHelper.query('cart');
    final cartItems = cartRows.map((e) => CartItemModel.fromMap(e)).toList();
    if (cartItems.isEmpty) throw Exception("Cart is empty");

    // final deliveryFee = ref.watch(selectedDeliveryAddressProvider)?.cost;
    final totalAmount =
        (cartItems.fold<double>(0, (sum, c) => sum + c.price * c.quantity));

    // final totalAmountDelivery =
    //     (cartItems.fold<double>(0, (sum, c) => sum + c.price * c.quantity) +
    //         (deliveryFee ?? 0));
    final totalItems = cartItems.fold<int>(0, (sum, c) => sum + c.quantity);

    if (pendingOrder != null) {
      // --- UPDATE EXISTING ORDER ---
      final updatedOrder = pendingOrder.copyWith(
        totalAmount: totalAmount,
        totalItems: totalItems,
        orderItems: cartItems.map((c) => c.toOrderItem(pendingOrder.id!)).toList(),
        tableName: tableName ?? pendingOrder.tableName,
        paymentStatus: paymentStatus,
        paymentMethod: paymentMethod ?? pendingOrder.paymentMethod,
        orderStatus: "completed",
      );

      await OrdersDao.updateOrder(updatedOrder.toMap(), pendingOrder.id!);
      debugPrint("New order map: ${updatedOrder.toMap()}");

      await OrderItemsDao.deleteByOrder(pendingOrder.id!);

      for (final item in updatedOrder.orderItems) {
        await OrderItemsDao.insert(item.toMap());
      }

      await _log('orderUpdated', 'order', pendingOrder.id.toString(),
          'Updated order ${pendingOrder.id}');
    } else {
      // --- CREATE NEW ORDER ---
      final today = DateFormat('yyMMdd').format(DateTime.now());
      final ordersToday =
          await OrdersDao.getAll(date: _fmtDate(DateTime.now()));
      final dailyIndex = ordersToday.length + 1;
      final specialOrderId = "$today-${dailyIndex.toString().padLeft(3, '0')}";

      final newOrder = OrderModel(
        orderType: orderType,
        orderStatus: orderType == 'takeaway' ? 'completed' : 'pending',
        paymentStatus: paymentStatus,
        paymentMethod: paymentMethod ?? 'cash',
        tableName: tableName,
        totalAmount: totalAmount,
        totalItems: totalItems,
        deliveryFee: deliveryFee ?? 0,
        deliveryAddress: deliveryAddress,
        createdAt: DateTime.now(),
        orderItems: [], // temporarily empty
        specialOrderId: specialOrderId,
      );

      final newId = await OrdersDao.insert(newOrder.toMap());
      final inserted = await OrdersDao.getAll();
      debugPrint("Inserted DB row: $inserted");

      for (final item in cartItems) {
        await OrderItemsDao.insert(item.toOrderItem(newId).toMap());
      }

      debugPrint("Inserted DB row: $inserted");
      debugPrint("New order map: ${newOrder.toMap()}");

      await _log('orderPlaced', 'order', newId.toString(),
          'Placed order $specialOrderId');
    }

    await NewDBHelper.delete('cart', where: '1=1', whereArgs: []);
    ref.invalidate(cartAsyncNotifierProvider);
    await reload();
  }

  Future<void> loadOrderIntoCart(OrderModel order) async {
    await NewDBHelper.delete('cart', where: '1=1', whereArgs: []);
    for (final item in order.orderItems) {
      await NewDBHelper.insert(
        'cart',
        CartItemModel.fromOrderItem(item, order.orderType).toMap(),
      );
    }
    ref.invalidate(cartAsyncNotifierProvider);
  }

  Future<void> cancelOrder(int orderId) async {
    await OrdersDao.cancelOrder(orderId);
    await _log('orderCanceled', 'order', orderId.toString(),
        'Order $orderId canceled');
    await reload();
  }

  Future<void> _log(
      String action, String entity, String? entityId, String details) async {
    await NewDBHelper.insert(
      'logs',
      LogModel(
        action: action,
        entity: entity,
        entityId: entityId,
        details: details,
        userId: ref.read(currentUserIdProvider),
        timestamp: DateTime.now(),
      ).toMap(),
    );
  }
}
