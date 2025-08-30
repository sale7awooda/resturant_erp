import 'package:starter_template/core/new_db_helper.dart';

class OrdersDao {
  static const table = 'orders';

  static Future<int> insert(Map<String, dynamic> data) =>
      NewDBHelper.insert(table, data);

  static Future<List<Map<String, dynamic>>> getAll({
    String? date,
    String? orderType,
    String? paymentType,
  }) async {
    String where = '1=1';
    final args = <dynamic>[];

    if (date != null) {
      where += ' AND DATE(createdAt)=?';
      args.add(date);
    }
    if (orderType != null) {
      where += ' AND orderType=?';
      args.add(orderType);
    }
    if (paymentType != null) {
      where += ' AND paymentType=?';
      args.add(paymentType);
    }

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
