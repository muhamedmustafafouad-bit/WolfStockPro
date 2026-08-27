import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/stock_movement_model.dart';

class StockRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> addMovement(StockMovementModel movement) async {
    final db = await _databaseHelper.database;

    return await db.transaction((txn) async {
      final movementId = await txn.insert(
        'stock_movements',
        movement.toMap()..remove('id'),
      );

      final existing = await txn.query(
        'stock',
        where: 'product_id=? AND branch_id=?',
        whereArgs: [
          movement.productId,
          movement.branchId,
        ],
      );

      double currentQty = 0;

      if (existing.isNotEmpty) {
        currentQty =
            (existing.first['quantity'] as num).toDouble();
      }

      double newQty = currentQty;

      switch (movement.movementType) {
        case 'IN':
          newQty += movement.quantity;
          break;

        case 'OUT':
          newQty -= movement.quantity;
          break;

        case 'INITIAL':
          newQty = movement.quantity;
          break;
      }

      if (existing.isEmpty) {
        await txn.insert(
          'stock',
          {
            'product_id': movement.productId,
            'branch_id': movement.branchId,
            'quantity': newQty,
            'updated_at':
                DateTime.now().toIso8601String(),
          },
        );
      } else {
        await txn.update(
          'stock',
          {
            'quantity': newQty,
            'updated_at':
                DateTime.now().toIso8601String(),
          },
          where: 'product_id=? AND branch_id=?',
          whereArgs: [
            movement.productId,
            movement.branchId,
          ],
        );
      }

      return movementId;
    });
  }

  Future<List<StockMovementModel>> getHistory() async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'stock_movements',
      orderBy: 'created_at DESC',
    );

    return result
        .map((e) => StockMovementModel.fromMap(e))
        .toList();
  }
}
