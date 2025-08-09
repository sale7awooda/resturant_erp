// --- Cart StateNotifier which persists to SQLite ---
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_template/core/db_helper.dart';
import 'package:starter_template/features/menu/cart/cart_model.dart';

final cartAsyncNotifierProvider =
    AsyncNotifierProvider<CartNotifier, List<CartItemModel>>(
  () => CartNotifier(),
);

class CartNotifier extends AsyncNotifier<List<CartItemModel>> {
  @override
  Future<List<CartItemModel>> build() async {
    // load from db on startup
    final list = await DBHelper.getCartItems();
    return list;
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    final list = await DBHelper.getCartItems();
    state = AsyncValue.data(list);
  }

  Future<void> addToCart(CartItemModel item) async {
    // If an identical item (itemId + selectedOption) exists, increase quantity
    final current = state.value ?? [];
    final index = current.indexWhere((c) =>
        c.itemId == item.itemId &&
        (c.selectedOption ?? '') == (item.selectedOption ?? ''));

    if (index != -1) {
      // update quantity
      final existing = current[index];
      final updated =
          existing.copyWith(quantity: existing.quantity + item.quantity);
      await DBHelper.updateCartItem(updated.copyWith(dbId: existing.dbId));
    } else {
      final newId = await DBHelper.insertCartItem(item);
      // set the dbId on item when reading back
      // (we will just reload from DB)
    }
    await reload();
  }

  Future<void> updateQuantity(int dbId, int quantity) async {
    final current = state.value ?? [];
    final index = current.indexWhere((c) => c.dbId == dbId);
    if (index == -1) return;
    final updated = current[index].copyWith(quantity: quantity);
    await DBHelper.updateCartItem(updated.copyWith(dbId: dbId));
    await reload();
  }

  Future<void> removeItem(int dbId) async {
    await DBHelper.deleteCartItem(dbId);
    await reload();
  }

  Future<void> clearCart() async {
    await DBHelper.clearCart();
    await reload();
  }
}

// Derived provider to compute totals
final cartTotalProvider = Provider<double>((ref) {
  final cartState = ref.watch(cartAsyncNotifierProvider);
  final list = cartState.value ?? [];
  return list.fold(0.0, (sum, c) => sum + c.price * c.quantity);
});

final cartCountProvider = Provider<int>((ref) {
  final cartState = ref.watch(cartAsyncNotifierProvider);
  final list = cartState.value ?? [];
  return list.fold(0, (sum, c) => sum + c.quantity);
});
