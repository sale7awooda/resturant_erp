import 'package:starter_template/core/new_db_helper.dart';
class OrdersDao {
  static const table = 'orders';

  static Future<int> insert(Map<String, dynamic> data) =>
      NewDBHelper.insert(table, data);

  /// Get orders with optional filters
  static Future<List<Map<String, dynamic>>> getAll({
    String? date,
    String? orderType,
    String? paymentStatus,
  }) async {
    final whereClauses = <String>[];
    final args = <dynamic>[];

    if (date != null) {
      whereClauses.add('DATE(createdAt)=?');
      args.add(date);
    }
    if (orderType != null) {
      whereClauses.add('orderType=?');
      args.add(orderType);
    }
    if (paymentStatus != null) {
      whereClauses.add('paymentStatus=?');
      args.add(paymentStatus);
    }

    final where = whereClauses.isEmpty ? null : whereClauses.join(' AND ');

    return NewDBHelper.query(
      table,
      where: where,
      whereArgs: args,
      orderBy: 'createdAt DESC',
    );
  }

  static Future<int> updateOrder(Map<String, dynamic> data, int id) =>
      NewDBHelper.update(table, data, where: 'id=?', whereArgs: [id]);

  static Future<int> cancelOrder(int id) => NewDBHelper.update(
        table,
        {
          'orderStatus': 'cancelled',
          'paymentStatus': 'cancelled',
          'totalAmount': 0,
          'totalItems': 0,
        },
        where: 'id=?',
        whereArgs: [id],
      );
}
