
import 'package:starter_template/core/new_db_helper.dart';

class AuthDAO {
  // --- USERS ---
  static Future<int> createUser(Map<String, dynamic> userData) async {
    return NewDBHelper.insert('staff', userData);
  }

  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final users = await NewDBHelper.query(
      'staff',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (users.isNotEmpty) return users.first;
    return null;
  }

  static Future<Map<String, dynamic>?> getUserById(int id) async {
    final users = await NewDBHelper.query(
      'staff',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (users.isNotEmpty) return users.first;
    return null;
  }

  // --- ROLES ---
  static Future<int> createRole(Map<String, dynamic> roleData) async {
    return NewDBHelper.insert('roles', roleData);
  }

  static Future<Map<String, dynamic>?> getRoleByName(String roleName) async {
    final roles = await NewDBHelper.query(
      'roles',
      where: 'roleName = ?',
      whereArgs: [roleName],
    );
    if (roles.isNotEmpty) return roles.first;
    return null;
  }

  // --- AUTH CHECK ---
  static Future<bool> validateLogin(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user == null) return false;
    // Assuming you store hashed passwords
    return user['password'] == password;
  }
}
