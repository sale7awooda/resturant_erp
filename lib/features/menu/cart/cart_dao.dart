import 'package:starter_template/core/new_db_helper.dart';

class CartDao {
  static const table = 'cart';

  static Future<int> insert(Map<String, dynamic> data) =>
      NewDBHelper.insert(table, data);

  static Future<List<Map<String, dynamic>>> getAll({String? source}) async {
    return NewDBHelper.query(
      table,
      where: source != null ? 'source=?' : null,
      whereArgs: source != null ? [source] : null,
    );
  }

  static Future<int> updateItem(Map<String, dynamic> data, int id) =>
      NewDBHelper.update(table, data, where: 'id=?', whereArgs: [id]);

  static Future<int> deleteItem(int id) =>
      NewDBHelper.delete(table, where: 'id=?', whereArgs: [id]);

  static Future<int> clear({String? source}) => NewDBHelper.delete(
        table,
        where: source != null ? 'source=?' : '1=1',
        whereArgs: source != null ? [source] : [],
      );
}
