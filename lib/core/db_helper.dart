import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:starter_template/features/logs/log_model.dart';
import 'package:starter_template/features/menu/cart/cart_model.dart';
import 'package:starter_template/features/orders_list/place_order/order_model.dart';

class DBHelper {
  static Database? _db;

  static Future<void> init() async {
    sqfliteFfiInit();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ResturantMNGMNT.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // --- CART ---
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

        // --- ORDERS ---
        await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orderType TEXT NOT NULL,
            orderStatus TEXT NOT NULL,
            paymentStatus TEXT NOT NULL,
            paymentType TEXT,
            paymentId TEXT,
            totalAmount REAL NOT NULL,
            totalItems INTEGER NOT NULL,
            transactionId TEXT,
            tableName TEXT,
            deliveryAddress TEXT,
            deliveryOwner TEXT,
            deliveryPhone TEXT,
            deliveryInstructions TEXT,
            createdAt TEXT NOT NULL,
            items TEXT NOT NULL
          )
        ''');

        // --- LOGS ---
        await db.execute('''
          CREATE TABLE logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            action TEXT NOT NULL,
            entity TEXT NOT NULL,
            entityId TEXT,
            details TEXT NOT NULL,
            userId TEXT NOT NULL,
            timestamp TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Database get db {
    if (_db == null) throw Exception('DB not initialized.');
    return _db!;
  }

  // ------------------- CART -------------------
  static Future<int> insertCartItem(CartItemModel item) =>
      db.insert('cart', item.toMap());

  static Future<List<CartItemModel>> getCartItems() async {
    final rows = await db.query('cart');
    return rows.map((m) => CartItemModel.fromMap(m)).toList();
  }

  static Future<int> updateCartItem(CartItemModel item) =>
      db.update('cart', item.toMap(), where: 'id = ?', whereArgs: [item.dbId]);

  static Future<int> deleteCartItem(int id) =>
      db.delete('cart', where: 'id = ?', whereArgs: [id]);

  static Future<int> clearCart() => db.delete('cart');

  // ------------------- ORDERS -------------------
  static Future<int> insertOrder(OrderModel order) =>
      db.insert('orders', order.toMap());

  static Future<int> updateOrder(OrderModel order) => db
      .update('orders', order.toMap(), where: 'id = ?', whereArgs: [order.id]);

  static Future<List<OrderModel>> getOrders({
    String? date,
    String? orderType,
    String? paymentType,
    String? orderStatus,
  }) async {
    String where = 'WHERE 1=1';
    final args = <dynamic>[];

    if (date != null) {
      where += ' AND DATE(createdAt) = ?';
      args.add(date);
    }
    if (orderType != null) {
      where += ' AND orderType = ?';
      args.add(orderType);
    }
    if (paymentType != null) {
      where += ' AND paymentType = ?';
      args.add(paymentType);
    }
    if (orderStatus != null) {
      where += ' AND orderStatus = ?';
      args.add(orderStatus);
    }

    final rows = await db.rawQuery(
        'SELECT * FROM orders $where ORDER BY createdAt DESC', args);
    return rows.map((m) => OrderModel.fromMap(m)).toList();
  }

  static Future<int> cancelOrder(int id) => db.update(
      'orders',
      {
        'orderStatus': OrderStatus.cancelled.name,
        'paymentType': OrderStatus.cancelled.name,
        'paymentStatus': OrderStatus.cancelled.name,
        'totalAmount': '0',
        'totalItems': '0'
      },
      where: 'id = ?',
      whereArgs: [id]);
  // ------------------- LOGS -------------------
  static Future<int> insertLog(LogModel log) => db.insert('logs', log.toMap());

  static Future<List<LogModel>> getLogs({
    String? action,
    String? entity,
    String? entityId,
    String? userId,
    String? date, // YYYY-MM-DD filtering
  }) async {
    String where = 'WHERE 1=1';
    final args = <dynamic>[];

    if (action != null) {
      where += ' AND action = ?';
      args.add(action);
    }
    if (entity != null) {
      where += ' AND entity = ?';
      args.add(entity);
    }
    if (entityId != null) {
      where += ' AND entityId = ?';
      args.add(entityId);
    }
    if (userId != null) {
      where += ' AND userId = ?';
      args.add(userId);
    }
    if (date != null) {
      where += ' AND DATE(timestamp) = ?';
      args.add(date);
    }

    final rows = await db.rawQuery(
        'SELECT * FROM logs $where ORDER BY timestamp DESC', args);
    return rows.map((m) => LogModel.fromMap(m)).toList();
  }

}
