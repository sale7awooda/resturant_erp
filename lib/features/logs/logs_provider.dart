
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_template/core/db_helper.dart';
import 'log_model.dart';

// --- State Notifier --- //
class LogsNotifier extends StateNotifier<AsyncValue<List<LogModel>>> {
  LogsNotifier() : super(const AsyncValue.loading()) {
    loadLogs();
  }

  Future<void> loadLogs() async {
    try {
      final logs = await DBHelper.getLogs();
      state = AsyncValue.data(logs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addLog(LogModel log) async {
    await DBHelper.insertLog(log);
    await loadLogs();
  }

  // Future<void> deleteLog(int id) async {
  //   await DBHelper.deleteLog(id);
  //   await loadLogs();
  // }

  // Future<void> clearLogs() async {
  //   await DBHelper.clearLogs();
  //   await loadLogs();
  // }

  // For filtering (e.g. by type: "order", "error")
  Future<void> filterLogs(String type) async {
    try {
      final logs = await DBHelper.getLogs();
      state = AsyncValue.data(logs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// --- Provider --- //
final logsProvider =
    StateNotifierProvider<LogsNotifier, AsyncValue<List<LogModel>>>(
  (ref) => LogsNotifier(),
);
