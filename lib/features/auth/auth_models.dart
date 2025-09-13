// lib/features/auth/models/user_model.dart
class UserModel {
  final int? id;
  final String username;
  final String? email;
  final String passwordHash;
  final String salt;
  final int? roleId;
  final int? staffId;
  final bool active;
  final String createdAt;
  final String? updatedAt;

  UserModel({
    this.id,
    required this.username,
    this.email,
    required this.passwordHash,
    required this.salt,
    this.roleId,
    this.staffId,
    this.active = true,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'username': username,
        'email': email,
        'passwordHash': passwordHash,
        'salt': salt,
        'roleId': roleId,
        'staffId': staffId,
        'active': active ? 1 : 0,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
        id: m['id'] as int?,
        username: m['username'] as String,
        email: m['email'] as String?,
        passwordHash: m['passwordHash'] as String,
        salt: m['salt'] as String,
        roleId: m['roleId'] as int?,
        staffId: m['staffId'] as int?,
        active: (m['active'] as int? ?? 1) == 1,
        createdAt: m['createdAt'] as String,
        updatedAt: m['updatedAt'] as String?,
      );
}

// lib/features/auth/models/role_model.dart
class RoleModel {
  final int? id;
  final String roleName;
  final String? permissions; // JSON string or comma-separated list

  RoleModel({this.id, required this.roleName, this.permissions});

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'roleName': roleName,
        'permissions': permissions,
      };

  factory RoleModel.fromMap(Map<String, dynamic> m) => RoleModel(
        id: m['id'] as int?,
        roleName: m['roleName'] as String,
        permissions: m['permissions'] as String?,
      );
}
