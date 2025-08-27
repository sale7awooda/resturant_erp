import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_template/core/db_helper.dart';
import 'package:starter_template/features/logs/log_model.dart';
import 'package:starter_template/features/menu/cart/cart_model.dart';
import 'package:starter_template/features/orders_list/place_order/orders_provider.dart';

final cartAsyncNotifierProvider = AsyncNotifierProvider<CartNotifier, List<CartItemModel>>(
  () => CartNotifier(),
);

class CartNotifier extends AsyncNotifier<List<CartItemModel>> {
  @override
  Future<List<CartItemModel>> build() async {
    return DBHelper.getCartItems();
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await DBHelper.getCartItems());
  }

  Future<void> setCartItems(List<CartItemModel> items) async {
    await DBHelper.clearCart();
    for (final item in items) {
      await DBHelper.insertCartItem(item);
    }
    await reload();
  }

  Future<void> addToCart(CartItemModel item) async {
    final current = state.value ?? [];
    final idx = current.indexWhere((c) =>
        c.itemId == item.itemId &&
        (c.selectedOption ?? '') == (item.selectedOption ?? ''));

    if (idx != -1) {
      final ex = current[idx];
      final updated = ex.copyWith(quantity: ex.quantity + item.quantity);
      await DBHelper.updateCartItem(updated);
      await _log('cart_update', 'cart', updated.dbId?.toString(),
          'Updated ${updated.name} quantity to ${updated.quantity}');
    } else {
      final id = await DBHelper.insertCartItem(item);
      await _log('cart_add', 'cart', id.toString(),
          'Added ${item.name} x${item.quantity}');
    }
    await reload();
  }

  Future<void> updateQuantity(int dbId, int quantity) async {
    final list = state.value ?? [];
    final i = list.indexWhere((e) => e.dbId == dbId);
    if (i == -1) return;

    final updated = list[i].copyWith(quantity: quantity);
    await DBHelper.updateCartItem(updated);
    await _log('cart_update', 'cart', dbId.toString(),
        'Set ${updated.name} quantity to $quantity');
    await reload();
  }

  Future<void> removeItem(int dbId) async {
    final list = state.value ?? [];
    final item = list.firstWhere((e) => e.dbId == dbId);
    await DBHelper.deleteCartItem(dbId);
    await _log('cart_remove', 'cart', dbId.toString(),
        'Removed ${item.name} from cart');
    await reload();
  }

  Future<void> clearCart() async {
    await DBHelper.clearCart();
    await _log('cart_cleared', 'cart', null, 'Cart cleared');
    await reload();
  }

  Future<void> _log(String action, String entity, String? entityId, String details) async {
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

// --- Totals ---
final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartAsyncNotifierProvider).value ?? [];
  return items.fold(0.0, (sum, c) => sum + c.price * c.quantity);
});

final cartCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartAsyncNotifierProvider).value ?? [];
  return items.fold(0, (sum, c) => sum + c.quantity);
});
