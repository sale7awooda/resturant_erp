// ignore_for_file: public_member_api_docs, sort_constructors_first
// lib/features/staff/models/staff_models.dart

class StaffModel {
  final int? id;
  final bool active; // true if not deleted
  final String name;
  final String? email;
  final String? phone;
  final String role;
  final List<String> permissions;
  final double salary;
  final DateTime createdAt;
  final DateTime? updatedAt;

  StaffModel({
    this.id,
    required this.active,
    required this.name,
    this.email,
    this.phone,
    required this.role,
    required this.permissions,
    required this.salary,
    required this.createdAt,
    this.updatedAt,
  });

  StaffModel copyWith({
    int? id,
    String? name,
    String? active,
    String? email,
    String? phone,
    String? role,
    List<String>? permissions,
    double? salary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StaffModel(
      id: id ?? this.id,
      active: active != null
          ? (active.toLowerCase() == 'true' || active == '1')
          : this.active,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      salary: salary ?? this.salary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory StaffModel.fromMap(Map<String, dynamic> m) {
    final perms = (m['permissions'] as String?) ?? '';
    final permsList = perms.isEmpty ? <String>[] : perms.split(',');
    return StaffModel(
      id: m['id'] as int?,
      active: (m['active'] as int? ?? 1) == 1,
      name: m['name'] as String,
      email: m['email'] as String?,
      phone: m['phone'] as String?,
      role: m['role'] as String? ?? 'staff',
      permissions: permsList,
      salary: (m['salary'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(m['createdAt'] as String),
      updatedAt: m['updatedAt'] != null
          ? DateTime.parse(m['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'active': active ? 1 : 0,
      'email': email,
      'phone': phone,
      'role': role,
      'permissions': permissions.join(','),
      'salary': salary,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class StaffAttendanceModel {
  final int? id;
  final int staffId;
  final String date; // yyyy-MM-dd
  final int part; // 1 or 2
  final bool present;
  final DateTime createdAt; // 👈 add this

  StaffAttendanceModel({
    this.id,
    required this.staffId,
    required this.date,
    required this.part,
    required this.present,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now(); // default now

  factory StaffAttendanceModel.fromMap(Map<String, dynamic> m) {
    return StaffAttendanceModel(
      id: m['id'] as int?,
      staffId: m['staffId'] as int,
      date: m['date'] as String,
      part: (m['part'] as num).toInt(),
      present: (m['present'] as num) == 1,
      createdAt: DateTime.parse(m['createdAt'] as String), // 👈 parse it
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'staffId': staffId,
        'date': date,
        'part': part,
        'present': present ? 1 : 0,
        'createdAt': createdAt.toIso8601String(), // 👈 save it
      };
}

class StaffBonusModel {
  final int? id;
  final int staffId;
  final double amount;
  final String? reason;
  final DateTime createdAt;

  StaffBonusModel({
    this.id,
    required this.staffId,
    required this.amount,
    this.reason,
    required this.createdAt,
  });

  factory StaffBonusModel.fromMap(Map<String, dynamic> m) => StaffBonusModel(
        id: m['id'] as int?,
        staffId: m['staffId'] as int,
        amount: (m['amount'] as num).toDouble(),
        reason: m['reason'] as String?,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'staffId': staffId,
        'amount': amount,
        'reason': reason,
        'createdAt': createdAt.toIso8601String(),
      };
}

class StaffFineModel {
  final int? id;
  final int staffId;
  final double amount;
  final String? reason;
  final DateTime createdAt;

  StaffFineModel({
    this.id,
    required this.staffId,
    required this.amount,
    this.reason,
    required this.createdAt,
  });

  factory StaffFineModel.fromMap(Map<String, dynamic> m) => StaffFineModel(
        id: m['id'] as int?,
        staffId: m['staffId'] as int,
        amount: (m['amount'] as num).toDouble(),
        reason: m['reason'] as String?,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'staffId': staffId,
        'amount': amount,
        'reason': reason,
        'createdAt': createdAt.toIso8601String(),
      };
}
