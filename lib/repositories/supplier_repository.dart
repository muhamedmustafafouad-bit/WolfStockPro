import '../database/database_helper.dart';
import '../models/supplier_model.dart';

class SupplierRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<SupplierModel>> getSuppliers() async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'suppliers',
      orderBy: 'name ASC',
    );

    return result
        .map((e) => SupplierModel.fromMap(e))
        .toList();
  }

  Future<int> addSupplier(
      SupplierModel supplier) async {
    final db = await _databaseHelper.database;

    return db.insert(
      'suppliers',
      supplier.toMap()..remove('id'),
    );
  }

  Future<int> updateSupplier(
      SupplierModel supplier) async {
    final db = await _databaseHelper.database;

    return db.update(
      'suppliers',
      supplier.toMap()..remove('id'),
      where: 'id=?',
      whereArgs: [supplier.id],
    );
  }

  Future<int> deleteSupplier(int id) async {
    final db = await _databaseHelper.database;

    return db.delete(
      'suppliers',
      where: 'id=?',
      whereArgs: [id],
    );
  }
}
