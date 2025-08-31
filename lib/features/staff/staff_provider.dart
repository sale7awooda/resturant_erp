// lib/features/staff/provider/staff_provider.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_template/features/staff/stadd_dao.dart';
import 'package:starter_template/features/staff/staff_model.dart';

/// -------------------------
/// Providers
/// -------------------------

/// Staff list provider (auto-updates after invalidation).
final staffListProvider = FutureProvider<List<StaffModel>>((ref) async {
  return StaffDao.getAllStaff();
});

/// Main notifier provider for staff CRUD, attendance, bonuses, fines, salaries.
final staffNotifierProvider = Provider<StaffNotifier>((ref) {
  return StaffNotifier(ref);
});

/// -------------------------
/// Staff Notifier
/// -------------------------
class StaffNotifier {
  final Ref ref;
  StaffNotifier(this.ref);

  /// -------------------------
  /// CRUD OPERATIONS
  /// -------------------------
  Future<int> addStaff(StaffModel staff) async {
    final id = await StaffDao.insertStaff(staff);
    ref.invalidate(staffListProvider);
    return id;
  }

  Future<int> updateStaff(StaffModel staff) async {
    final res = await StaffDao.updateStaff(staff);
    ref.invalidate(staffListProvider);
    return res;
  }

  Future<int> deleteStaff(int id) async {
    final res = await StaffDao.deleteStaff(id);
    ref.invalidate(staffListProvider);
    return res;
  }

  /// -------------------------
  /// ATTENDANCE
  /// -------------------------

  Future<Map<String, double>> getSummaryForMonth(
      int staffId, int year, int month) async {
    final bonuses = await bonusesForStaff(staffId);
    final fines = await finesForStaff(staffId);

    final totalBonus = bonuses
        .where((b) => b.createdAt.year == year && b.createdAt.month == month)
        .fold(0.0, (sum, b) => sum + b.amount);
    final totalFines = fines
        .where((f) => f.createdAt.year == year && f.createdAt.month == month)
        .fold(0.0, (sum, f) => sum + f.amount);

    return {'bonus': totalBonus, 'fine': totalFines};
  }

  /// Get attendance records for a staff member on a given date.
  Future<List<StaffAttendanceModel>> attendanceForStaff(
    int staffId, {
    required String date,
  }) =>
      StaffDao.attendanceForStaff(staffId, date: date);

  /// Get attendance records by date for all staff.
  Future<List<StaffAttendanceModel>> attendanceByDate(String date) =>
      StaffDao.attendanceByDate(date);

  /// Record attendance for a specific part of the day.
  /// [presentMap] = staffId -> present (true/false)
  /// [part] = 1 (morning) or 2 (afternoon)
  Future<void> recordAttendancePart(
    Map<int, bool> presentMap,
    int part,
  ) async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final staffList = await StaffDao.getAllStaff();

    // Upsert each staff attendance row
    for (final staff in staffList) {
      final present = presentMap[staff.id!] ?? false;
      final att = StaffAttendanceModel(
        staffId: staff.id!,
        date: date,
        part: part,
        present: present,
      );
      await StaffDao.upsertAttendance(att);
    }

    // If this was part 2, evaluate absences and fines
    if (part == 2) {
      await _applyAutomaticAbsenceFines(staffList, date);
    }

    ref.invalidate(staffListProvider);
  }

  /// Internal helper: Apply automatic fines for absences.
  Future<void> _applyAutomaticAbsenceFines(
    List<StaffModel> staffList,
    String date,
  ) async {
    final attendanceRows = await StaffDao.attendanceByDate(date);

    // Group attendance by staffId
    final Map<int, List<StaffAttendanceModel>> grouped = {};
    for (final att in attendanceRows) {
      grouped.putIfAbsent(att.staffId, () => []).add(att);
    }

    for (final staff in staffList) {
      final entries = grouped[staff.id!] ?? [];

      final p1 = entries.firstWhere(
        (e) => e.part == 1,
        orElse: () => StaffAttendanceModel(
          staffId: staff.id!,
          date: date,
          part: 1,
          present: false,
        ),
      );

      final p2 = entries.firstWhere(
        (e) => e.part == 2,
        orElse: () => StaffAttendanceModel(
          staffId: staff.id!,
          date: date,
          part: 2,
          present: false,
        ),
      );

      // Salary calculations
      final dailySalary = staff.salary / 30.0;
      final halfDeduction = dailySalary / 2.0;

      if (!p1.present && !p2.present) {
        // Full-day absence
        await StaffDao.insertFine(
          StaffFineModel(
            staffId: staff.id!,
            amount: dailySalary,
            reason: 'Full day absent automatic deduction',
            createdAt: DateTime.now(),
          ),
        );
      } else if (!p1.present || !p2.present) {
        // Half-day absence
        await StaffDao.insertFine(
          StaffFineModel(
            staffId: staff.id!,
            amount: halfDeduction,
            reason: 'Half day absent automatic deduction',
            createdAt: DateTime.now(),
          ),
        );
      }
    }
  }

  /// -------------------------
  /// BONUSES & FINES
  /// -------------------------
  Future<int> addBonus({
    required int staffId,
    required double amount,
    String? reason,
  }) async {
    final bonus = StaffBonusModel(
      staffId: staffId,
      amount: amount,
      reason: reason,
      createdAt: DateTime.now(),
    );
    final id = await StaffDao.insertBonus(bonus);
    ref.invalidate(staffListProvider);
    return id;
  }

  Future<int> addFine({
    required int staffId,
    required double amount,
    String? reason,
  }) async {
    final fine = StaffFineModel(
      staffId: staffId,
      amount: amount,
      reason: reason,
      createdAt: DateTime.now(),
    );
    final id = await StaffDao.insertFine(fine);
    ref.invalidate(staffListProvider);
    return id;
  }

  Future<List<StaffBonusModel>> bonusesForStaff(int staffId) =>
      StaffDao.bonusesForStaff(staffId);

  Future<List<StaffFineModel>> finesForStaff(int staffId) =>
      StaffDao.finesForStaff(staffId);

  /// -------------------------
  /// SALARY CALCULATION
  /// -------------------------

  /// Compute net salary for a month:
  /// base salary + bonuses - fines
  Future<double> computeNetSalaryForMonth(
    int staffId,
    int year,
    int month,
    double baseSalary,
  ) async {
    final bonuses = await StaffDao.bonusesForStaff(staffId);
    final fines = await StaffDao.finesForStaff(staffId);

    // Filter bonuses and fines by year/month
    final totalBonuses = bonuses
        .where((b) => b.createdAt.year == year && b.createdAt.month == month)
        .fold<double>(0.0, (sum, b) => sum + b.amount);

    final totalFines = fines
        .where((f) => f.createdAt.year == year && f.createdAt.month == month)
        .fold<double>(0.0, (sum, f) => sum + f.amount);

    return baseSalary + totalBonuses - totalFines;
  }
}
