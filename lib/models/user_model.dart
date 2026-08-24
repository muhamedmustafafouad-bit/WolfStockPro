
class UserModel {
  final int? id;
  final String username;
  final String password;
  final String fullName;
  final String role;
  final int? branchId;

  UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.fullName,
    required this.role,
    this.branchId,
  });

  // Convert database record → UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      fullName: map['fullname'] ?? '',
      role: map['role'] ?? 'EMPLOYEE',
      branchId: map['branch_id'] as int?,
    );
  }

  // Convert UserModel → database record
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'fullname': fullName,
      'role': role,
      'branch_id': branchId,
    };
  }

  bool get isAdmin => role.toUpperCase() == 'ADMIN';

  bool get isManager => role.toUpperCase() == 'MANAGER';

  bool get isEmployee => role.toUpperCase() == 'EMPLOYEE';
}
