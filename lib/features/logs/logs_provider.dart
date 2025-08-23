// lib/features/logs/logs_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_template/core/db_helper.dart';
import 'package:starter_template/features/logs/log_model.dart';

// --- Filters ---
final logsFilterActionProvider = StateProvider<String?>((_) => null);
final logsFilterUserProvider = StateProvider<String?>((_) => null);

// --- Logs AsyncNotifier ---
final logsAsyncProvider = AsyncNotifierProvider<LogsNotifier, List<LogModel>>(
  () => LogsNotifier(),
);

class LogsNotifier extends AsyncNotifier<List<LogModel>> {
  @override
  Future<List<LogModel>> build() async {
    final action = ref.watch(logsFilterActionProvider);
    final userId = ref.watch(logsFilterUserProvider);

    return DBHelper.getLogs(action: action, userId: userId);
  }

  /// Refresh logs manually
  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await build());
  }

  /// Set filter by action
  void setActionFilter(String? action) {
    ref.read(logsFilterActionProvider.notifier).state =
        (action?.isEmpty ?? true) ? null : action;
  }

  /// Set filter by userId
  void setUserFilter(String? userId) {
    ref.read(logsFilterUserProvider.notifier).state =
        (userId?.isEmpty ?? true) ? null : userId;
  }

  /// Clear all filters
  void clearFilters() {
    ref.read(logsFilterActionProvider.notifier).state = null;
    ref.read(logsFilterUserProvider.notifier).state = null;
  }
}

// --- Logs Summary Providers ---
final logsCountProvider = Provider<int>((ref) {
  final logs = ref.watch(logsAsyncProvider).value ?? [];
  return logs.length;
});
