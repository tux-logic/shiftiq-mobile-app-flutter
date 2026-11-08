import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite Database Manager for ShiftIQ Mobile
/// Follows easyrecipe-mobile-flutter-main clean pattern
class AppDatabase {
  static const String _dbName = 'shiftiq_mobile.db';
  static const int _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Settings & Key-Value storage (Tokens, active branch, preferences)
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // 2. Offline Cached Products
    await db.execute('''
      CREATE TABLE cached_products (
        id TEXT PRIMARY KEY,
        branch_id TEXT NOT NULL,
        sku TEXT NOT NULL,
        name TEXT NOT NULL,
        brand TEXT NOT NULL,
        stock INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        minimum_stock_threshold INTEGER NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 3. Offline Cached Appointments
    await db.execute('''
      CREATE TABLE cached_appointments (
        id TEXT PRIMARY KEY,
        branch_id TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        vehicle_plate TEXT NOT NULL,
        scheduled_at TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT
      )
    ''');

    // 4. Offline Cached Work Orders
    await db.execute('''
      CREATE TABLE cached_work_orders (
        id TEXT PRIMARY KEY,
        branch_id TEXT NOT NULL,
        vehicle_plate TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        status TEXT NOT NULL,
        total_amount REAL NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
