import 'package:starter_template/core/new_db_helper.dart';

class OrderItemsDao {
  static const table = 'orderItems';

  static Future<int> insert(Map<String, dynamic> data) =>
      NewDBHelper.insert(table, data);

  static Future<List<Map<String, dynamic>>> getByOrder(int orderId) =>
      NewDBHelper.query(table, where: 'orderId=?', whereArgs: [orderId]);

  static Future<int> deleteByOrder(int orderId) =>
      NewDBHelper.delete(table, where: 'orderId=?', whereArgs: [orderId]);

  static Future<List<Map<String, dynamic>>> bestSellingItems() async {
    final db = await NewDBHelper.db;
    return db.rawQuery('''
      SELECT m.name, SUM(oi.quantity) as qty
      FROM orderItems oi
      JOIN menuItems m ON oi.menuItemId = m.id
      GROUP BY m.id
      ORDER BY qty DESC
      LIMIT 5
    ''');
  }
}
