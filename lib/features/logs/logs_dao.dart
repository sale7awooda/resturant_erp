import 'package:starter_template/core/new_db_helper.dart';

class LogsDao {
  static const table = 'logs';

  /// Insert a new log
  static Future<int> insert(Map<String, dynamic> data) =>
      NewDBHelper.insert(table, data);

  /// Fetch logs with optional filtering and pagination
  static Future<List<Map<String, dynamic>>> getAll({
    String? action,
    String? entity,
    String? entityId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final whereClauses = <String>[];
    final args = <dynamic>[];

    if (action != null) {
      whereClauses.add('action=?');
      args.add(action);
    }
    if (entity != null) {
      whereClauses.add('entity=?');
      args.add(entity);
    }
    if (entityId != null) {
      whereClauses.add('entityId=?');
      args.add(entityId);
    }
    if (userId != null) {
      whereClauses.add('userId=?');
      args.add(userId);
    }
    if (startDate != null) {
      whereClauses.add('DATE(timestamp) >= ?');
      args.add(startDate.toIso8601String().split('T')[0]);
    }
    if (endDate != null) {
      whereClauses.add('DATE(timestamp) <= ?');
      args.add(endDate.toIso8601String().split('T')[0]);
    }

    final where = whereClauses.isEmpty ? null : whereClauses.join(' AND ');

    final orderBy = 'timestamp DESC';
    final limitOffset =
        (limit != null ? ' LIMIT $limit' : '') + (offset != null ? ' OFFSET $offset' : '');

    final queryResult = await NewDBHelper.query(
      table,
      where: where,
      whereArgs: args,
      orderBy: '$orderBy$limitOffset',
    );

    return queryResult;
  }
}
