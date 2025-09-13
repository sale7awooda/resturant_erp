import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:starter_template/core/new_db_helper.dart';
import 'auth_models.dart';

/// Main authentication DAO for user, roles, and permissions.
class AuthDao {
  // ---------------- PASSWORD HASHING ----------------
  static String _generateSalt([int length = 16]) {
    final rnd = Random.secure();
    final bytes = List<int>.generate(length, (_) => rnd.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String _hashPassword(String password, String salt,
      {int iterations = 100000, int keyLength = 32}) {
    final saltBytes = utf8.encode(salt);
    final passwordBytes = utf8.encode(password);
    final hmac = Hmac(sha256, passwordBytes);

    int hashLen = 32; // sha256 output length
    int blocks = (keyLength / hashLen).ceil();
    final out = <int>[];

    for (var block = 1; block <= blocks; block++) {
      final blockBytes = <int>[...saltBytes, ..._int32(block)];
      List<int> u = hmac.convert(blockBytes).bytes;
      List<int> t = List<int>.from(u);
      for (var i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < t.length; j++) {
          t[j] ^= u[j];
        }
      }
      out.addAll(t);
    }

    return base64Url.encode(out.sublist(0, keyLength));
  }

  static List<int> _int32(int i) =>
      [(i >> 24) & 0xff, (i >> 16) & 0xff, (i >> 8) & 0xff, i & 0xff];

  static Map<String, String> generateSaltedHash(String password) {
    final salt = _generateSalt();
    final hash = _hashPassword(password, salt);
    return {'salt': salt, 'hash': hash};
  }

  static bool verifyPassword(String password, String salt, String hash) {
    return _hashPassword(password, salt) == hash;
  }

  // ---------------- USER MANAGEMENT ----------------
  static Future<int> registerUser({
    required String username,
    String? email,
    required String password,
    int? roleId,
    int? staffId,
  }) async {
    final now = DateTime.now().toIso8601String();
    final sh = generateSaltedHash(password);

    final data = {
      'username': username,
      'email': email,
      'passwordHash': sh['hash'],
      'salt': sh['salt'],
      'roleId': roleId,
      'staffId': staffId,
      'active': 1,
      'createdAt': now,
      'updatedAt': null,
    };

    return await NewDBHelper.insert('users', data);
  }

  static Future<UserModel?> getUserByUsername(String username) async {
    final rows = await NewDBHelper.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'id DESC',
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  static Future<UserModel?> getUserById(int id) async {
    final rows = await NewDBHelper.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  static Future<bool> authenticate(String username, String password) async {
    final user = await getUserByUsername(username);
    if (user == null || !user.active) return false;
    return verifyPassword(password, user.salt, user.passwordHash);
  }

  static Future<void> changePassword({
    required int userId,
    required String newPassword,
  }) async {
    final sh = generateSaltedHash(newPassword);
    await NewDBHelper.update(
      'users',
      {
        'passwordHash': sh['hash'],
        'salt': sh['salt'],
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  static Future<void> assignRole({
    required int userId,
    required int roleId,
  }) async {
    await NewDBHelper.update(
      'users',
      {
        'roleId': roleId,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // ---------------- ROLE & PERMISSIONS ----------------
  static Future<int> createRole(RoleModel role) async {
    return NewDBHelper.insert('roles', role.toMap());
  }

  static Future<RoleModel?> getRoleById(int id) async {
    final rows =
        await NewDBHelper.query('roles', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return RoleModel.fromMap(rows.first);
  }

  static Future<RoleModel?> getRoleByName(String name) async {
    final rows = await NewDBHelper.query(
      'roles',
      where: 'roleName = ?',
      whereArgs: [name],
      orderBy: 'id DESC',
    );
    if (rows.isEmpty) return null;
    return RoleModel.fromMap(rows.first);
  }

  static Future<List<RoleModel>> getAllRoles() async {
    final rows = await NewDBHelper.query('roles', orderBy: 'id ASC');
    return rows.map((r) => RoleModel.fromMap(r)).toList();
  }

  // ---------------- PERMISSIONS ----------------
  static Future<bool> checkPermission(int userId, String permissionKey) async {
    final user = await getUserById(userId);
    if (user == null || user.roleId == null) return false;

    final role = await getRoleById(user.roleId!);
    if (role == null) return false;

    final perms = parsePermissions(role.permissions ?? '');
    return perms.contains(permissionKey);
  }

  /// Public helper to parse permissions string
  static List<String> parsePermissions(String raw) {
    try {
      if (raw.isEmpty) return [];
      final decoded = json.decode(raw) as List;
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return raw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
  }
}
