// lib/features/staff/models/staff_models.dart
// ignore_for_file: public_member_api_docs, sort_constructors_first

/// -------------------------
/// STAFF MODEL
/// -------------------------
class StaffModel {
  final int? id;
  final bool active;
  final String name;
  final String? email;
  final String? phone;
  final String role;
  final List<String> permissions;
  final double salary;
  final int? age;
  final String? address;
  final String gender; // male/female
  final DateTime createdAt;
  final DateTime? updatedAt;

  const StaffModel({
    this.id,
    required this.active,
    required this.name,
    this.email,
    this.phone,
    required this.role,
    required this.permissions,
    required this.salary,
    this.age,
    this.address,
    this.gender = 'male',
    required this.createdAt,
    this.updatedAt,
  });

  factory StaffModel.fromMap(Map<String, dynamic> m) {
    final perms = (m['permissions'] as String?) ?? '';
    return StaffModel(
      id: m['id'] as int?,
      active: (m['active'] as int? ?? 1) == 1,
      name: m['name'] as String,
      email: m['email'] as String?,
      phone: m['phone'] as String?,
      role: m['role'] as String? ?? 'staff',
      permissions: perms.isEmpty ? <String>[] : perms.split(','),
      salary: (m['salary'] as num?)?.toDouble() ?? 0.0,
      age: (m['age'] as num?)?.toInt(),
      address: m['address'] as String?,
      gender: (m['gender'] as String?) ?? 'male',
      createdAt:
          DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: (m['updatedAt'] != null)
          ? DateTime.tryParse(m['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'active': active ? 1 : 0,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'permissions': permissions.join(','),
        'salary': salary,
        'age': age,
        'address': address,
        'gender': gender,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  StaffModel copyWith({
    int? id,
    bool? active,
    String? name,
    String? email,
    String? phone,
    String? role,
    List<String>? permissions,
    double? salary,
    int? age,
    String? address,
    String? gender,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StaffModel(
      id: id ?? this.id,
      active: active ?? this.active,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      salary: salary ?? this.salary,
      age: age ?? this.age,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// -------------------------
/// ATTENDANCE MODEL
/// -------------------------
enum AttendanceStatus { absent, present, late }

class StaffAttendanceModel {
  final int? id;
  final int staffId;
  final String date; // yyyy-MM-dd
  final int part; // 1 or 2
  final AttendanceStatus status;
  final DateTime createdAt;

  StaffAttendanceModel({
    this.id,
    required this.staffId,
    required this.date,
    required this.part,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory StaffAttendanceModel.fromMap(Map<String, dynamic> m) {
    final statusValue = (m['status'] as num?)?.toInt() ?? 0;
    final status = AttendanceStatus.values[statusValue];
    return StaffAttendanceModel(
      id: m['id'] as int?,
      staffId: m['staffId'] as int,
      date: m['date'] as String,
      part: (m['part'] as num).toInt(),
      status: status,
      createdAt:
          DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'staffId': staffId,
        'date': date,
        'part': part,
        'status': status.index, // 0 absent, 1 present, 2 late
        'createdAt': createdAt.toIso8601String(),
      };
}

/// -------------------------
/// BONUS MODEL
/// -------------------------
class StaffBonusModel {
  final int? id;
  final int staffId;
  final double amount;
  final String? reason;
  final DateTime createdAt;

  const StaffBonusModel({
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
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'staffId': staffId,
        'amount': amount,
        'reason': reason,
        'createdAt': createdAt.toIso8601String(),
      };
}

/// -------------------------
/// FINE MODEL
/// -------------------------
class StaffFineModel {
  final int? id;
  final int staffId;
  final double amount;
  final String? reason;
  final String type; // automatic or manual
  final DateTime createdAt;

  const StaffFineModel({
    this.id,
    required this.staffId,
    required this.amount,
    this.reason,
    this.type = 'automatic',
    required this.createdAt,
  });

  factory StaffFineModel.fromMap(Map<String, dynamic> m) => StaffFineModel(
        id: m['id'] as int?,
        staffId: m['staffId'] as int,
        amount: (m['amount'] as num).toDouble(),
        reason: m['reason'] as String?,
        type: m['type'] as String? ?? 'automatic',
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'staffId': staffId,
        'amount': amount,
        'reason': reason,
        'type': type,
        'createdAt': createdAt.toIso8601String(),
      };
}

/// -------------------------
/// LOAN MODEL
/// -------------------------
class StaffLoanModel {
  final int? id;
  final int staffId;
  final double amount;
  final String? reason;
  final bool repaid;
  final DateTime createdAt;

  const StaffLoanModel({
    this.id,
    required this.staffId,
    required this.amount,
    this.reason,
    this.repaid = false,
    required this.createdAt,
  });

  factory StaffLoanModel.fromMap(Map<String, dynamic> m) => StaffLoanModel(
        id: m['id'] as int?,
        staffId: m['staffId'] as int,
        amount: (m['amount'] as num).toDouble(),
        reason: m['reason'] as String?,
        repaid: (m['repaid'] as int? ?? 0) == 1,
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'staffId': staffId,
        'amount': amount,
        'reason': reason,
        'repaid': repaid ? 1 : 0,
        'createdAt': createdAt.toIso8601String(),
      };
}

/// -------------------------
/// PAYROLL MODEL
/// -------------------------
class StaffPayrollModel {
  final int? id;
  final int staffId;
  final String month; // yyyy-MM
  final double baseSalary;
  final double bonus;
  final double fines;
  final double loans;
  final double netPayable;
  final DateTime? createdAt;

  const StaffPayrollModel({
    this.id,
    required this.staffId,
    required this.month,
    required this.baseSalary,
    this.bonus = 0,
    this.fines = 0,
    this.loans = 0,
    required this.netPayable,
    this.createdAt,
  });

  factory StaffPayrollModel.fromMap(Map<String, dynamic> m) =>
      StaffPayrollModel(
        id: m['id'] as int?,
        staffId: m['staffId'] as int,
        month: m['month'] as String,
        baseSalary: (m['baseSalary'] as num).toDouble(),
        bonus: (m['bonus'] as num?)?.toDouble() ?? 0,
        fines: (m['fines'] as num?)?.toDouble() ?? 0,
        loans: (m['loans'] as num?)?.toDouble() ?? 0,
        netPayable: (m['netPayable'] as num).toDouble(),
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'staffId': staffId,
        'month': month,
        'baseSalary': baseSalary,
        'bonus': bonus,
        'fines': fines,
        'loans': loans,
        'netPayable': netPayable,
        'createdAt': createdAt?.toIso8601String(),
      };
}
class StaffMonthlyParams {
  final int staffId;
  final DateTime month;

  StaffMonthlyParams({required this.staffId, required this.month});

  // 👇 Implement equality & hashCode so Riverpod can cache properly
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaffMonthlyParams &&
          runtimeType == other.runtimeType &&
          staffId == other.staffId &&
          month.year == other.month.year &&
          month.month == other.month.month;

  @override
  int get hashCode => staffId.hashCode ^ month.year.hashCode ^ month.month.hashCode;
}
