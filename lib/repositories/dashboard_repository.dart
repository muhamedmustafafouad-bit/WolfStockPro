import '../database/database_helper.dart';

class DashboardRepository {
  final DatabaseHelper _databaseHelper =
      DatabaseHelper.instance;

  Future<int> totalProducts() async {
    final db = await _databaseHelper.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM products',
    );

    return (result.first['total'] as int?) ?? 0;
  }

  Future<int> totalCategories() async {
    final db = await _databaseHelper.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM categories',
    );

    return (result.first['total'] as int?) ?? 0;
  }

  Future<int> totalSuppliers() async {
    final db = await _databaseHelper.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM suppliers',
    );

    return (result.first['total'] as int?) ?? 0;
  }

  Future<int> totalMovements() async {
    final db = await _databaseHelper.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM stock_movements',
    );

    return (result.first['total'] as int?) ?? 0;
  }
}
