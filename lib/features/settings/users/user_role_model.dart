class UserRole {
  final int? id;
  final String name;
  final String? permissions;
  UserRole({this.id, required this.name, this.permissions});
  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'permissions': permissions};
  factory UserRole.fromMap(Map<String, dynamic> m) => UserRole(id: m['id'], name: m['name'], permissions: m['permissions']);
}
