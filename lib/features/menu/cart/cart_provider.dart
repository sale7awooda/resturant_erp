import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_template/core/new_db_helper.dart';
import 'package:starter_template/features/menu/cart/cart_model.dart';
import 'cart_dao.dart';
import 'package:starter_template/features/orders/orders_provider.dart';
import 'package:starter_template/features/logs/log_model.dart';

/// ------------------ NORMAL CART ------------------
final cartAsyncNotifierProvider =
    AsyncNotifierProvider<CartNotifier, List<CartItemModel>>(
  () => CartNotifier(),
);

class CartNotifier extends AsyncNotifier<List<CartItemModel>> {
  @override
  Future<List<CartItemModel>> build() async => _loadCart();

  Future<List<CartItemModel>> _loadCart() async {
    final rows = await CartDao.getAll(source: 'normal');
    return rows.map((row) => CartItemModel.fromMap(row)).toList(growable: true);
  }

  Future<void> reload() async {
    final newItems = await _loadCart();
    state = AsyncValue.data(newItems);
  }

  Future<void> setCartItems(List<CartItemModel> items) async {
    final prev = state.value ?? [];
    state = AsyncValue.data(items);
    try {
      await CartDao.clear(source: 'normal');
      for (final item in items) {
        await CartDao.insert(item.copyWith(source: 'normal').toMap());
      }
    } catch (e) {
      state = AsyncValue.data(prev); // rollback
      rethrow;
    }
  }

  Future<void> addToCart(CartItemModel item) async {
    final prev = state.value ?? [];
    final current = [...prev];
    final idx = current.indexWhere((c) =>
        c.itemId == item.itemId &&
        (c.selectedOption ?? '') == (item.selectedOption ?? ''));

    if (idx != -1) {
      final existing = current[idx];
      final updated =
          existing.copyWith(quantity: existing.quantity + item.quantity);
      current[idx] = updated;
      state = AsyncValue.data(current);

      try {
        if (updated.id != null) {
          await CartDao.updateItem(updated.toMap(), updated.id!);
          await _log('cartUpdate', 'cart', updated.id.toString(),
              'Updated ${updated.name} quantity to ${updated.quantity}');
        }
      } catch (e) {
        state = AsyncValue.data(prev); // rollback
        rethrow;
      }
    } else {
      state = AsyncValue.data([...current, item]); // optimistic add
      try {
        final id = await CartDao.insert(item.copyWith(source: 'normal').toMap());
        final added = item.copyWith(id: id, source: 'normal');
        state = AsyncValue.data([...current, added]);

        await _log('cartAdd', 'cart', id.toString(),
            'Added ${item.name} x${item.quantity} (source=normal)');
      } catch (e) {
        state = AsyncValue.data(prev); // rollback
        rethrow;
      }
    }
  }

  Future<void> updateQuantity(int id, int quantity) async {
    final prev = state.value ?? [];
    final list = [...prev];
    final idx = list.indexWhere((e) => e.id == id);
    if (idx == -1) return;

    final updated = list[idx].copyWith(quantity: quantity);
    list[idx] = updated;
    state = AsyncValue.data(list);

    try {
      await CartDao.updateItem(updated.toMap(), id);
      await _log('cartUpdate', 'cart', id.toString(),
          'Set ${updated.name} quantity to $quantity');
    } catch (e) {
      state = AsyncValue.data(prev);
      rethrow;
    }
  }

  Future<void> removeItem(int id) async {
    final prev = state.value ?? [];
    final list = [...prev];
    final item = list.firstWhere((e) => e.id == id);
    list.removeWhere((e) => e.id == id);
    state = AsyncValue.data(list);

    try {
      await CartDao.deleteItem(id);
      await _log('cartRemove', 'cart', id.toString(),
          'Removed ${item.name} (source=normal)');
    } catch (e) {
      state = AsyncValue.data(prev);
      rethrow;
    }
  }

  Future<void> clearCart() async {
    final prev = state.value ?? [];
    state = const AsyncValue.data([]);

    try {
      await CartDao.clear(source: 'normal');
      await _log('cartCleared', 'cart', null, 'Normal cart cleared');
    } catch (e) {
      state = AsyncValue.data(prev);
      rethrow;
    }
  }

  Future<void> _log(String action, String entity, String? entityId, String details) async {
    await NewDBHelper.insert(
        'logs',
        LogModel(
          action: action,
          entity: entity,
          entityId: entityId,
          details: details,
          userId: ref.read(currentUserIdProvider),
          timestamp: DateTime.now(),
        ).toMap());
  }
}

/// ------------------ PREFILLED CART ------------------
final prefilledCartNotifierProvider =
    AsyncNotifierProvider<PrefilledCartNotifier, List<CartItemModel>>(
  () => PrefilledCartNotifier(),
);

class PrefilledCartNotifier extends AsyncNotifier<List<CartItemModel>> {
  @override
  Future<List<CartItemModel>> build() async => _loadCart();

  Future<List<CartItemModel>> _loadCart() async {
    final rows = await CartDao.getAll(source: 'prefilled');
    return rows.map((row) => CartItemModel.fromMap(row)).toList(growable: true);
  }

  Future<void> reload() async {
    final newItems = await _loadCart();
    state = AsyncValue.data(newItems);
  }

  Future<void> setCartItems(List<CartItemModel> items) async {
    final prev = state.value ?? [];
    state = AsyncValue.data(items);
    try {
      await CartDao.clear(source: 'prefilled');
      for (final item in items) {
        await CartDao.insert(item.copyWith(source: 'prefilled').toMap());
      }
    } catch (e) {
      state = AsyncValue.data(prev);
      rethrow;
    }
  }

  Future<void> addToCart(CartItemModel item) async {
    final prev = state.value ?? [];
    final current = [...prev];
    final idx = current.indexWhere((c) =>
        c.itemId == item.itemId &&
        (c.selectedOption ?? '') == (item.selectedOption ?? ''));

    if (idx != -1) {
      final existing = current[idx];
      final updated =
          existing.copyWith(quantity: existing.quantity + item.quantity);
      current[idx] = updated;
      state = AsyncValue.data(current);

      try {
        if (updated.id != null) {
          await CartDao.updateItem(updated.toMap(), updated.id!);
          await _log('cartUpdate', 'prefilled_cart', updated.id.toString(),
              'Updated ${updated.name} quantity to ${updated.quantity}');
        }
      } catch (e) {
        state = AsyncValue.data(prev);
        rethrow;
      }
    } else {
      state = AsyncValue.data([...current, item]);
      try {
        final id = await CartDao.insert(item.copyWith(source: 'prefilled').toMap());
        final added = item.copyWith(id: id, source: 'prefilled');
        state = AsyncValue.data([...current, added]);

        await _log('cartAdd', 'prefilled_cart', id.toString(),
            'Added ${item.name} x${item.quantity} (source=prefilled)');
      } catch (e) {
        state = AsyncValue.data(prev);
        rethrow;
      }
    }
  }

  Future<void> updateQuantity(int id, int quantity) async {
    final prev = state.value ?? [];
    final list = [...prev];
    final idx = list.indexWhere((e) => e.id == id);
    if (idx == -1) return;

    final updated = list[idx].copyWith(quantity: quantity);
    list[idx] = updated;
    state = AsyncValue.data(list);

    try {
      await CartDao.updateItem(updated.toMap(), id);
      await _log('cartUpdate', 'prefilled_cart', id.toString(),
          'Set ${updated.name} quantity to $quantity');
    } catch (e) {
      state = AsyncValue.data(prev);
      rethrow;
    }
  }

  Future<void> removeItem(int id) async {
    final prev = state.value ?? [];
    final list = [...prev];
    final item = list.firstWhere((e) => e.id == id);
    list.removeWhere((e) => e.id == id);
    state = AsyncValue.data(list);

    try {
      await CartDao.deleteItem(id);
      await _log('cartRemove', 'prefilled_cart', id.toString(),
          'Removed ${item.name} (source=prefilled)');
    } catch (e) {
      state = AsyncValue.data(prev);
      rethrow;
    }
  }

  Future<void> clearCart() async {
    final prev = state.value ?? [];
    state = const AsyncValue.data([]);

    try {
      await CartDao.clear(source: 'prefilled');
      await _log('cartCleared', 'prefilled_cart', null, 'Prefilled cart cleared');
    } catch (e) {
      state = AsyncValue.data(prev);
      rethrow;
    }
  }

  Future<void> _log(String action, String entity, String? entityId, String details) async {
    await NewDBHelper.insert(
        'logs',
        LogModel(
          action: action,
          entity: entity,
          entityId: entityId,
          details: details,
          userId: ref.read(currentUserIdProvider),
          timestamp: DateTime.now(),
        ).toMap());
  }
}

/// ------------------ DERIVED PROVIDERS ------------------
final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartAsyncNotifierProvider).value ?? [];
  return items.fold(0.0, (sum, c) => sum + c.price * c.quantity);
});

final prefilledCartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(prefilledCartNotifierProvider).value ?? [];
  return items.fold(0.0, (sum, c) => sum + c.price * c.quantity);
});

final cartCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartAsyncNotifierProvider).value ?? [];
  return items.fold(0, (sum, c) => sum + c.quantity);
});

final prefilledCartCountProvider = Provider<int>((ref) {
  final items = ref.watch(prefilledCartNotifierProvider).value ?? [];
  return items.fold(0, (sum, c) => sum + c.quantity);
});
