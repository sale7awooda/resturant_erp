class UserModel {
  final int? id;
  final String name;
  final String email;
  final String role;
  final String? permissions;
  final String? password; // hashed

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    this.permissions,
    this.password,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'],
        name: map['name'],
        email: map['email'],
        role: map['role'],
        permissions: map['permissions'],
        password: map['password'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'permissions': permissions,
        'password': password,
      };
}

class RoleModel {
  final int? id;
  final String roleName;
  final String? permissions; // JSON string

  RoleModel({this.id, required this.roleName, this.permissions});

  factory RoleModel.fromMap(Map<String, dynamic> map) => RoleModel(
        id: map['id'],
        roleName: map['roleName'],
        permissions: map['permissions'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'roleName': roleName,
        'permissions': permissions,
      };
}
