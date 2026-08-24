import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/product_model.dart';

class ProductRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<ProductModel>> getProducts({
    int? branchId,
  }) async {
    final db = await _databaseHelper.database;

    final branch = branchId ?? 1;

    final result = await db.rawQuery('''
      SELECT
        p.*,
        COALESCE(s.quantity, 0) AS quantity
      FROM products p
      LEFT JOIN stock s
        ON p.id = s.product_id
        AND s.branch_id = ?
      WHERE p.active = 1
      ORDER BY p.name COLLATE NOCASE ASC
    ''', [branch]);

    return result
        .map((map) => ProductModel.fromMap(map))
        .toList();
  }

  Future<ProductModel?> getProductById(int id) async {
    final db = await _databaseHelper.database;

    final result = await db.rawQuery('''
      SELECT
        p.*,
        COALESCE(
          (SELECT SUM(quantity)
           FROM stock
           WHERE product_id = p.id),
          0
        ) AS quantity
      FROM products p
      WHERE p.id = ?
      LIMIT 1
    ''', [id]);

    if (result.isEmpty) {
      return null;
    }

    return ProductModel.fromMap(result.first);
  }

  Future<int> addProduct(ProductModel product) async {
    final db = await _databaseHelper.database;

    return db.insert(
      'products',
      product.toMap()..remove('id'),
    );
  }

  Future<int> updateProduct(ProductModel product) async {
    if (product.id == null) {
      throw Exception('Product ID is required.');
    }

    final db = await _databaseHelper.database;

    final data = product.toMap();
    data.remove('id');

    return db.update(
      'products',
      data,
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await _databaseHelper.database;

    return db.update(
      'products',
      {'active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ProductModel>> searchProducts(
    String query, {
    int branchId = 1,
  }) async {
    final db = await _databaseHelper.database;

    final search = '%${query.trim()}%';

    final result = await db.rawQuery('''
      SELECT
        p.*,
        COALESCE(s.quantity, 0) AS quantity
      FROM products p
      LEFT JOIN stock s
        ON p.id = s.product_id
        AND s.branch_id = ?
      WHERE p.active = 1
        AND (
          p.name LIKE ?
          OR p.barcode LIKE ?
          OR p.sku LIKE ?
        )
      ORDER BY p.name COLLATE NOCASE ASC
    ''', [
      branchId,
      search,
      search,
      search,
    ]);

    return result
        .map((map) => ProductModel.fromMap(map))
        .toList();
        }
  
    Future<void> setInitialStock({
  required int productId,
  required int branchId,
  required double quantity,
}) async {
  final db = await _databaseHelper.database;

  final now = DateTime.now().toIso8601String();

  await db.insert(
    'stock',
    {
      'product_id': productId,
      'branch_id': branchId,
      'quantity': quantity,
      'updated_at': now,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  await db.insert(
    'stock_movements',
    {
      'product_id': productId,
      'branch_id': branchId,
      'user_id': null,
      'movement_type': 'INITIAL',
      'quantity': quantity,
      'reference_no': null,
      'notes': 'Initial stock',
      'created_at': now,
    },
  );
  }
}
