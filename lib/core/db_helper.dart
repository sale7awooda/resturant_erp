import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:starter_template/features/menu/cart/cart_model.dart';

class DBHelper {
  static Database? _db;

  static Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_cart.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cart (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            itemId TEXT NOT NULL,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            selectedOption TEXT,
            quantity INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  static Database get db {
    if (_db == null) {
      throw Exception('DB not initialized. Call DBHelper.init() first.');
    }
    return _db!;
  }

  // CRUD for cart items
  static Future<int> insertCartItem(CartItemModel item) async {
    final id = await db.insert('cart', item.toMap());
    return id;
  }

  static Future<List<CartItemModel>> getCartItems() async {
    final rows = await db.query('cart');
    return rows.map((r) => CartItemModel.fromMap(r)).toList();
  }

  static Future<int> updateCartItem(CartItemModel item) async {
    if (item.dbId == null) return 0;
    return await db
        .update('cart', item.toMap(), where: 'id = ?', whereArgs: [item.dbId]);
  }

  static Future<int> deleteCartItem(int id) async {
    return await db.delete('cart', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> clearCart() async {
    return await db.delete('cart');
  }
}
