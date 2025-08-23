// lib/core/db_helper.dart

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:starter_template/features/logs/log_model.dart';
import 'package:starter_template/features/menu/cart/cart_model.dart';
import 'package:starter_template/features/orders_list/place_order/order_model.dart';

// lib/core/db_helper.dart

// ... unchanged imports

class DBHelper {
  static Database? _db;

  static Future<void> init() async {
    sqfliteFfiInit();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ResturantMNGMNT.db');

    _db = await openDatabase(
      path,
      version: 2, // bumped because schema change
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cart (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            itemId TEXT NOT NULL,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            selectedOption TEXT,
            selectedTable TEXT,
            orderType TEXT NOT NULL,
            imageUrl TEXT,
            quantity INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orderType TEXT NOT NULL,
            paymentType TEXT,
            totalAmount REAL NOT NULL,
            totalItems INTEGER NOT NULL,
            transactionId TEXT,
            tableName TEXT,
            deliveryAddress TEXT,
            createdAt TEXT NOT NULL,
            items TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'placed'
          )
        ''');

        await db.execute('''
          CREATE TABLE logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            action TEXT NOT NULL,
            details TEXT NOT NULL,
            userId TEXT NOT NULL,
            timestamp TEXT NOT NULL
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

  // --- Cart methods (unchanged except clearCart covers dinein tables) ---
  static Future<int> insertCartItem(CartItemModel item) async =>
      await db.insert('cart', item.toMap());

  static Future<List<CartItemModel>> getCartItems({
    String? selectedTable,
    required String orderType,
  }) async {
    String where = 'WHERE orderType = ?';
    final args = [orderType];

    if (orderType == 'dinein' &&
        selectedTable != null &&
        selectedTable.isNotEmpty) {
      where += ' AND selectedTable = ?';
      args.add(selectedTable);
    }

    final rows = await db.rawQuery('SELECT * FROM cart $where', args);
    return rows.map((m) => CartItemModel.fromMap(m)).toList();
  }

  static Future<int> updateCartItem(CartItemModel item) async => await db
      .update('cart', item.toMap(), where: 'id = ?', whereArgs: [item.dbId]);

  static Future<int> deleteCartItem(int id) async =>
      await db.delete('cart', where: 'id = ?', whereArgs: [id]);

  static Future<int> clearCart(
      {required String orderType, String? selectedTable}) async {
    String where = 'orderType = ?';
    final args = [orderType];

    if (orderType == 'dinein' &&
        selectedTable != null &&
        selectedTable.isNotEmpty) {
      where += ' AND selectedTable = ?';
      args.add(selectedTable);
    }

    return await db.delete('cart', where: where, whereArgs: args);
  }

  // --- Orders ---
  static Future<int> insertOrder(OrderModel order) async =>
      await db.insert('orders', order.toMap());

  static Future<List<OrderModel>> getOrders({
    String? date,
    String? orderType,
    String? paymentType,
  }) async {
    String where = 'WHERE 1=1';
    final args = <dynamic>[];

    if (date != null && date.isNotEmpty) {
      where += ' AND DATE(createdAt) = ?';
      args.add(date);
    }
    if (orderType != null && orderType.isNotEmpty) {
      where += ' AND orderType = ?';
      args.add(orderType);
    }
    if (paymentType != null && paymentType.isNotEmpty) {
      where += ' AND paymentType = ?';
      args.add(paymentType);
    }

    final rows = await db.rawQuery(
        'SELECT * FROM orders $where ORDER BY createdAt DESC', args);
    return rows.map((m) => OrderModel.fromMap(m)).toList();
  }

  static Future<int> updateOrder(OrderModel order) async {
    if (order.id == null) return 0;
    return await db.update('orders', order.toMap(),
        where: 'id = ?', whereArgs: [order.id]);
  }

  static Future<int> updateOrderStatus(
          {required int id, required String status}) async =>
      await db.update('orders', {'status': status},
          where: 'id = ?', whereArgs: [id]);

  // ------------------- LOGS -------------------
  static Future<int> insertLog(LogModel log) async {
    return await db.insert('logs', log.toMap());
  }

  static Future<List<LogModel>> getLogs(
      {String? action, String? userId}) async {
    String where = 'WHERE 1=1';
    final args = <dynamic>[];

    if (action != null) {
      where += ' AND action = ?';
      args.add(action);
    }
    if (userId != null) {
      where += ' AND userId = ?';
      args.add(userId);
    }

    final rows = await db.rawQuery(
        'SELECT * FROM logs $where ORDER BY timestamp DESC', args);
    return rows.map((m) => LogModel.fromMap(m)).toList();
  }
}
