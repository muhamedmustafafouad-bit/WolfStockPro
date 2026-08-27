import '../../repositories/dashboard_repository.dart';

import '../database/database_helper.dart';

class DashboardRepository {

  final DashboardRepository _repository =
    DashboardRepository();

int products = 0;
int suppliers = 0;
int categories = 0;
int movements = 0;
  
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> totalProducts() async {
    final db = await _databaseHelper.database;

    final result =
        await db.rawQuery("SELECT COUNT(*) total FROM products");

    return result.first["total"] as int;
  }

  Future<int> totalCategories() async {
    final db = await _databaseHelper.database;

    final result =
        await db.rawQuery("SELECT COUNT(*) total FROM categories");

    return result.first["total"] as int;
  }

  Future<int> totalSuppliers() async {
    final db = await _databaseHelper.database;

    final result =
        await db.rawQuery("SELECT COUNT(*) total FROM suppliers");

    return result.first["total"] as int;
  }

  Future<int> totalMovements() async {
    final db = await _databaseHelper.database;

    final result = await db.rawQuery(
        "SELECT COUNT(*) total FROM stock_movements");

    return result.first["total"] as int;
  }
}
