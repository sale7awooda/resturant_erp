import 'package:starter_template/core/new_db_helper.dart';

class MenuItemsDao {
  static const table = 'menu_items';

  static Future<int> insert(Map<String, dynamic> data) =>
      NewDBHelper.insert(table, data);

  static Future<List<Map<String, dynamic>>> getAll() => NewDBHelper.query(table);

  static Future<int> updateItem(Map<String, dynamic> data, String id) =>
      NewDBHelper.update(table, data, where: 'id=?', whereArgs: [id]);

  static Future<int> deleteItem(String id) =>
      NewDBHelper.delete(table, where: 'id=?', whereArgs: [id]);
}
