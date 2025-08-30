import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_template/features/logs/log_model.dart';
import 'logs_dao.dart';

class LogsNotifier extends StateNotifier<AsyncValue<List<LogModel>>> {
  LogsNotifier() : super(const AsyncValue.loading()) {
    loadLogs();
  }

  Future<void> loadLogs({
    String? action,
    String? entity,
    String? entityId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      state = const AsyncValue.loading();

      final logsData = await LogsDao.getAll(
        action: action,
        entity: entity,
        entityId: entityId,
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      );

      final logs = logsData.map((map) => LogModel.fromMap(map)).toList();
      state = AsyncValue.data(logs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addLog(LogModel log) async {
    try {
      await LogsDao.insert(log.toMap());
      await loadLogs();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final logsProvider =
    StateNotifierProvider<LogsNotifier, AsyncValue<List<LogModel>>>(
  (ref) => LogsNotifier(),
);
