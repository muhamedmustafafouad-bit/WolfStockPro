import '../database/database_helper.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<CategoryModel>> getCategories() async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'categories',
      orderBy: 'name ASC',
    );

    return result
        .map((e) => CategoryModel.fromMap(e))
        .toList();
  }

  Future<int> addCategory(CategoryModel category) async {
    final db = await _databaseHelper.database;

    return db.insert(
      'categories',
      category.toMap()..remove('id'),
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await _databaseHelper.database;

    return db.delete(
      'categories',
      where: 'id=?',
      whereArgs: [id],
    );
  }
}
