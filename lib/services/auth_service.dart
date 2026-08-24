import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../database/database_helper.dart';
import '../models/user_model.dart';

class AuthService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<UserModel?> login(
    String username,
    String password,
  ) async {
    final db = await _databaseHelper.database;

    final passwordHash = _hashPassword(password);

    final result = await db.query(
      'users',
      where: 'username = ? AND password_hash = ? AND active = 1',
      whereArgs: [
        username.trim(),
        passwordHash,
      ],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return UserModel.fromMap(result.first);
  }

  Future<bool> usernameExists(String username) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'users',
      columns: ['id'],
      where: 'username = ?',
      whereArgs: [username.trim()],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<void> changePassword(
    int userId,
    String newPassword,
  ) async {
    final db = await _databaseHelper.database;

    final passwordHash = _hashPassword(newPassword);

    await db.update(
      'users',
      {
        'password_hash': passwordHash,
        'must_change_password': 0,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
