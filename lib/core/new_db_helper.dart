import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class NewDBHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    await init();
    return _db!;
  }

  static Future<void> init() async {
    sqfliteFfiInit();
    final dbPath = await databaseFactoryFfi.getDatabasesPath();
    final path = join(dbPath, 'restaurant.db');

    _db = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
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
              hasOption BOOL,
              selectedTable TEXT,
              orderType TEXT NOT NULL,
              imageUrl TEXT,
              quantity INTEGER NOT NULL,
              source TEXT DEFAULT 'normal'
            )
          ''');

          // --- ORDERS ---
          await db.execute('''
            CREATE TABLE orders (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              orderType TEXT NOT NULL,
              orderStatus TEXT NOT NULL,
              paymentStatus TEXT NOT NULL,
              paymentMethod TEXT,
              paymentId TEXT,
              totalAmount REAL NOT NULL,
              totalItems INTEGER NOT NULL,
              deliveryFee INTEGER DEFAULT 0,
              tableName TEXT,
              deliveryAddress TEXT,
              deliveryOwner TEXT,
              deliveryPhone TEXT,
              deliveryInstructions TEXT,
              createdAt TEXT NOT NULL,
              specialOrderId TEXT
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

          // --- MENU ITEMS ---
          await db.execute('''
            CREATE TABLE menuItems (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              price REAL NOT NULL,
              options TEXT,
              hasOption BOOL NOT NULL,
              category TEXT,
              imageUrl TEXT
            )
          ''');

          // --- ORDER ITEMS ---
          await db.execute('''
            CREATE TABLE orderItems (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              orderId INTEGER NOT NULL,
              menuItemId TEXT NOT NULL,
              itemName TEXT NOT NULL,
              quantity INTEGER NOT NULL,
              selectedOption TEXT,
              price REAL NOT NULL,
              FOREIGN KEY(orderId) REFERENCES orders(id) ON DELETE CASCADE,
              FOREIGN KEY(menuItemId) REFERENCES menuItems(id) ON DELETE CASCADE
            )
          ''');

          // --- CATEGORIES ---
          await db.execute('''
            CREATE TABLE categories (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL
            )
          ''');

          // --- TABLES ---
          await db.execute('''
            CREATE TABLE tables (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL
            )
          ''');
        },
      ),
    );
  }

  /// --- GENERIC CRUD ---
  static Future<int> insert(String table, Map<String, dynamic> data) async =>
      (await db).insert(table, data);

  static Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
    required List whereArgs,
  }) async =>
      (await db).update(table, data, where: where, whereArgs: whereArgs);

  static Future<int> delete(
    String table, {
    required String where,
    required List whereArgs,
  }) async =>
      (await db).delete(table, where: where, whereArgs: whereArgs);

  static Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List? whereArgs,
    String? orderBy,
  }) async =>
      (await db)
          .query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);

  /// --- BACKUP / RESTORE ---
  static Future<String> exportDB() async {
    final dbPath = await databaseFactoryFfi.getDatabasesPath();
    final path = join(dbPath, 'restaurant.db');
    final backupPath = join(dbPath, 'restaurant_backup.db');
    return File(path).copy(backupPath).then((file) => file.path);
  }

  static Future<void> importDB(String backupPath) async {
    final dbPath = await databaseFactoryFfi.getDatabasesPath();
    final path = join(dbPath, 'restaurant.db');
    await File(backupPath).copy(path);
    _db = null;
    await init();
  }

  static Future<void> resetDB() async {
    final dbPath = await databaseFactoryFfi.getDatabasesPath();
    final path = join(dbPath, 'restaurant.db');
    await databaseFactoryFfi.deleteDatabase(path);
    _db = null;
    await init();
  }
}
