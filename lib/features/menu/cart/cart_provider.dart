// lib/features/menu/cart/cart_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_template/core/db_helper.dart';
import 'package:starter_template/features/menu/cart/cart_model.dart';
import 'package:starter_template/features/menu/tabs_section/order_type_provider.dart';
import 'package:starter_template/features/menu/tabs_section/table_provider.dart';

final cartAsyncNotifierProvider =
    AsyncNotifierProvider<CartNotifier, List<CartItemModel>>(
  () => CartNotifier(),
);

class CartNotifier extends AsyncNotifier<List<CartItemModel>> {
  @override
  Future<List<CartItemModel>> build() async {
    final orderType = ref.watch(orderTypeProvider).name;
    final table = ref.watch(selectedTableProvider);

    return DBHelper.getCartItems(
      orderType: orderType,
      selectedTable: orderType == 'dinein' ? table : null,
    );
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    final orderType = ref.read(orderTypeProvider).name;
    final table = ref.read(selectedTableProvider);

    final list = await DBHelper.getCartItems(
      orderType: orderType,
      selectedTable: orderType == 'dinein' ? table : null,
    );
    state = AsyncValue.data(list);
  }

  Future<void> addToCart(CartItemModel raw) async {
    final orderType = ref.read(orderTypeProvider).name;
    String? table;
    if (orderType == 'dinein') {
      table = ref.read(selectedTableProvider);
      if (table == null || table.isEmpty) {
        throw Exception('Please select a table before adding items.');
      }
    }

    final item = raw.copyWith(selectedTable: table);

    final current = state.value ?? [];
    final idx = current.indexWhere((c) =>
        c.itemId == item.itemId &&
        (c.selectedOption ?? '') == (item.selectedOption ?? '') &&
        (c.selectedTable ?? '') == (item.selectedTable ?? '') &&
        c.orderType == item.orderType);

    if (idx != -1) {
      final ex = current[idx];
      final updated = ex.copyWith(quantity: ex.quantity + item.quantity);
      await DBHelper.updateCartItem(updated);
    } else {
      await DBHelper.insertCartItem(item);
    }

    await reload();
  }

  Future<void> updateQuantity(int dbId, int quantity) async {
    final list = state.value ?? [];
    final i = list.indexWhere((e) => e.dbId == dbId);
    if (i == -1) return;

    await DBHelper.updateCartItem(list[i].copyWith(quantity: quantity));
    await reload();
  }

  Future<void> removeItem(int dbId) async {
    await DBHelper.deleteCartItem(dbId);
    await reload();
  }

  Future<void> clearCart() async {
    final orderType = ref.read(orderTypeProvider).name;
    final table = ref.read(selectedTableProvider);

    if (orderType == 'dinein') {
      if (table == null || table.isEmpty) {
        throw Exception("Select a table before clearing cart.");
      }
      await DBHelper.clearCart(orderType: orderType, selectedTable: table);
    } else {
      await DBHelper.clearCart(orderType: orderType);
    }
    await reload();
  }
}

// --- Totals ---
final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartAsyncNotifierProvider).value ?? [];
  return items.fold(0.0, (sum, c) => sum + c.price * c.quantity);
});

final cartCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartAsyncNotifierProvider).value ?? [];
  return items.fold(0, (sum, c) => sum + c.quantity);
});
