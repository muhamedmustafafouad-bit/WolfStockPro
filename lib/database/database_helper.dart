import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance =
      DatabaseHelper._privateConstructor();

  static const String _databaseName = 'wolfstock.db';
  static const int _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // =========================
    // BRANCHES
    // =========================
    await db.execute('''
      CREATE TABLE branches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT,
        phone TEXT,
        manager_name TEXT,
        active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // =========================
    // USERS
    // =========================
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        full_name TEXT NOT NULL,
        role TEXT NOT NULL,
        branch_id INTEGER,
        active INTEGER NOT NULL DEFAULT 1,
        must_change_password INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (branch_id) REFERENCES branches(id)
      )
    ''');

    // =========================
    // CATEGORIES
    // =========================
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        description TEXT,
        active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // =========================
    // SUPPLIERS
    // =========================
    await db.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company_name TEXT NOT NULL,
        contact_name TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        notes TEXT,
        active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // =========================
    // PRODUCTS
    // =========================
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode TEXT UNIQUE,
        sku TEXT UNIQUE,
        name TEXT NOT NULL,
        description TEXT,
        category_id INTEGER,
        supplier_id INTEGER,
        unit TEXT NOT NULL DEFAULT 'pcs',
        cost_price REAL NOT NULL DEFAULT 0,
        selling_price REAL NOT NULL DEFAULT 0,
        minimum_stock REAL NOT NULL DEFAULT 0,
        image_path TEXT,
        active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id),
        FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
      )
    ''');

    // =========================
    // STOCK
    // =========================
    await db.execute('''
      CREATE TABLE stock (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        branch_id INTEGER NOT NULL,
        quantity REAL NOT NULL DEFAULT 0,
        updated_at TEXT NOT NULL,
        UNIQUE(product_id, branch_id),
        FOREIGN KEY (product_id) REFERENCES products(id),
        FOREIGN KEY (branch_id) REFERENCES branches(id)
      )
    ''');

    // =========================
    // STOCK MOVEMENTS
    // =========================
    await db.execute('''
      CREATE TABLE stock_movements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        branch_id INTEGER NOT NULL,
        user_id INTEGER,
        movement_type TEXT NOT NULL,
        quantity REAL NOT NULL,
        reference_no TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products(id),
        FOREIGN KEY (branch_id) REFERENCES branches(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // =========================
    // TRANSFERS
    // =========================
    await db.execute('''
      CREATE TABLE transfers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        from_branch_id INTEGER NOT NULL,
        to_branch_id INTEGER NOT NULL,
        quantity REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'PENDING',
        user_id INTEGER,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products(id),
        FOREIGN KEY (from_branch_id) REFERENCES branches(id),
        FOREIGN KEY (to_branch_id) REFERENCES branches(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // =========================
    // AUDIT LOG
    // =========================
    await db.execute('''
      CREATE TABLE audit_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        action TEXT NOT NULL,
        entity_type TEXT,
        entity_id INTEGER,
        details TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // =========================
    // SETTINGS
    // =========================
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        setting_key TEXT NOT NULL UNIQUE,
        setting_value TEXT
      )
    ''');

    // =========================
    // DEFAULT BRANCH
    // =========================
    final now = DateTime.now().toIso8601String();

    final branchId = await db.insert('branches', {
      'name': 'Main Branch',
      'address': '',
      'phone': '',
      'manager_name': '',
      'active': 1,
      'created_at': now,
    });

    // =========================
    // DEFAULT ADMIN
    // =========================
    final passwordHash = _hashPassword('admin123');

    await db.insert('users', {
      'username': 'admin',
      'password_hash': passwordHash,
      'full_name': 'Administrator',
      'role': 'ADMIN',
      'branch_id': branchId,
      'active': 1,
      'must_change_password': 1,
      'created_at': now,
    });

    // =========================
    // DEFAULT CATEGORIES
    // =========================
    await db.insert('categories', {
      'name': 'General',
      'description': 'Default category',
      'active': 1,
      'created_at': now,
    });

    // =========================
    // DEFAULT SETTINGS
    // =========================
    await db.insert('settings', {
      'setting_key': 'app_name',
      'setting_value': 'WolfStock Pro',
    });

    await db.insert('settings', {
      'setting_key': 'currency',
      'setting_value': 'EGP',
    });

    await db.insert('settings', {
      'setting_key': 'default_branch_id',
      'setting_value': branchId.toString(),
    });
  }

  static String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<String> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, _databaseName);
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
