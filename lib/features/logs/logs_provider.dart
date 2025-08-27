import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_template/core/db_helper.dart';
import 'log_model.dart';

class LogsNotifier extends StateNotifier<AsyncValue<List<LogModel>>> {
  LogsNotifier() : super(const AsyncValue.loading()) {
    loadLogs();
  }

  Future<void> loadLogs({
    String? action,
    String? entity,
    String? entityId,
    String? userId,
    String? date, // YYYY-MM-DD format
  }) async {
    try {
      final logs = await DBHelper.getLogs(
        action: action,
        entity: entity,
        entityId: entityId,
        userId: userId,
        date: date,
      );
      state = AsyncValue.data(logs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addLog(LogModel log) async {
    await DBHelper.insertLog(log);
    await loadLogs();
  }
}

final logsProvider =
    StateNotifierProvider<LogsNotifier, AsyncValue<List<LogModel>>>(
  (ref) => LogsNotifier(),
);
