import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_template/core/new_db_helper.dart';
import 'package:starter_template/features/staff/staff_dao.dart';
import 'package:starter_template/features/staff/staff_model.dart';

/// ======================================================
/// STAFF
/// ======================================================

final staffListProvider = FutureProvider.autoDispose<List<StaffModel>>((ref) {
  return StaffDao.getAllStaff();
});

final staffNotifierProvider = Provider<StaffNotifier>((ref) {
  return StaffNotifier(ref);
});

/// ======================================================
/// ATTENDANCE
/// ======================================================

/// All attendance records for a month (all staff)
final monthlyAttendanceProvider =
    FutureProvider.family.autoDispose<List<StaffAttendanceModel>, DateTime>(
  (ref, month) async {
    final normalized = DateTime(month.year, month.month, 1);
    final notifier = ref.read(staffNotifierProvider);
    return notifier.monthlyAttendance(
      year: normalized.year,
      month: normalized.month,
    );
  },
);

/// Staff attendance + bonus/fine for one month (used in detail screen)

final staffMonthlyDataProvider = FutureProvider.family
    .autoDispose<Map<String, dynamic>, StaffMonthlyParams>((ref, params) async {
  final notifier = ref.read(staffNotifierProvider);
  return notifier.staffMonthlyData(
    staffId: params.staffId,
    month: DateTime(params.month.year, params.month.month, 1),
  );
});

/// ======================================================
/// LOANS
/// ======================================================

final staffLoansProvider =
    FutureProvider.family<List<StaffLoanModel>, int>((ref, staffId) {
  return StaffDao.loansForStaff(staffId);
});

/// ======================================================
/// PAYROLL
/// ======================================================

/// Single staff payroll for a given month
final staffPayrollProvider = FutureProvider.family
    .autoDispose<StaffPayrollModel, Map<String, dynamic>>((ref, params) async {
  final staff = params['staff'] as StaffModel;
  final month = params['month'] as DateTime;
  return StaffDao.calculatePayroll(staff, month);
});

/// Salary sheet (all staff payroll for a month)
final payrollReportProvider =
    FutureProvider.family<List<StaffPayrollModel>, DateTime>((ref, month) {
  return StaffDao.payrollReport(month);
});

/// Total payroll cost in a month
final payrollCostProvider =
    FutureProvider.family<double, DateTime>((ref, month) {
  return StaffDao.totalPayrollCost(month);
});

/// ======================================================
/// STAFF NOTIFIER
/// ======================================================

class StaffNotifier {
  final Ref ref;
  StaffNotifier(this.ref);

  // -------------------------
  // STAFF CRUD
  // -------------------------
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

  // -------------------------
  // ATTENDANCE
  // -------------------------
  Future<List<StaffAttendanceModel>> monthlyAttendance({
    required int year,
    required int month,
  }) async {
    final datePrefix = '$year-${month.toString().padLeft(2, '0')}%';
    final rows = await NewDBHelper.query(
      'staffAttendance',
      where: 'date LIKE ?',
      whereArgs: [datePrefix],
      orderBy: 'staffId ASC, part ASC',
    );

    return rows.map((r) => StaffAttendanceModel.fromMap(r)).toList();
  }

  Future<Map<String, dynamic>> staffMonthlyData({
    required int staffId,
    required DateTime month,
  }) async {
    final year = month.year;
    final m = month.month;
    final monthPrefix = '$year-${m.toString().padLeft(2, '0')}%';
    final db = await NewDBHelper.db;

    // Attendance (already handled)
    final attendanceRows = await db.query(
      'staffAttendance',
      where: 'staffId=? AND date LIKE ?',
      whereArgs: [staffId, monthPrefix],
    );
    final attendanceRecords =
        attendanceRows.map((r) => StaffAttendanceModel.fromMap(r)).toList();

    int present = 0, late = 0, absent = 0;
    final grouped = <String, List<StaffAttendanceModel>>{};
    for (final r in attendanceRecords) {
      grouped.putIfAbsent(r.date, () => []).add(r);
    }
    for (final entry in grouped.values) {
      final presentCount =
          entry.where((r) => r.status == AttendanceStatus.present).length;
      if (presentCount == 2) {
        present++;
      } else if (presentCount == 1) {
        late++;
      } else {
        absent++;
      }
    }

    // Bonuses (fetch all rows, not just totals)
    final bonusRows = await db.query(
      'staffBonus',
      where: 'staffId=? AND strftime("%Y-%m", createdAt)=?',
      whereArgs: [staffId, "$year-${m.toString().padLeft(2, '0')}"],
    );

    // Fines
    final fineRows = await db.query(
      'staffFines',
      where: 'staffId=? AND strftime("%Y-%m", createdAt)=?',
      whereArgs: [staffId, "$year-${m.toString().padLeft(2, '0')}"],
    );

    return {
      'attendance': {'present': present, 'late': late, 'absent': absent},
      'bonus': bonusRows.fold<double>(
          0, (sum, r) => sum + (r['amount'] as num).toDouble()),
      'fine': fineRows.fold<double>(
          0, (sum, r) => sum + (r['amount'] as num).toDouble()),
      'bonusRows': bonusRows,
      'fineRows': fineRows,
    };
  }

  Future<void> recordAttendancePart(
    Map<int, AttendanceStatus> statusMap,
    int part,
  ) async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // final db = await NewDBHelper.db;

    // Convert the map to attendance models
    final list = statusMap.entries.map((entry) {
      return StaffAttendanceModel(
        staffId: entry.key,
        date: date,
        part: part,
        status: entry.value,
        createdAt: DateTime.now(),
      );
    }).toList();

    // Save and recalc fines for this day only
    await StaffDao.upsertAttendanceBatch(list);

    ref.invalidate(staffListProvider);
    ref.invalidate(monthlyAttendanceProvider);
    ref.invalidate(payrollReportProvider);
    ref.invalidate(payrollCostProvider);
  }

  // -------------------------
  // BONUSES & FINES
  // -------------------------
  Future<int> addBonus({
    required int staffId,
    required double amount,
    String? reason,
  }) async {
    final id = await StaffDao.insertBonus(
      StaffBonusModel(
        staffId: staffId,
        amount: amount,
        reason: reason,
        createdAt: DateTime.now(),
      ),
    );
    ref.invalidate(payrollReportProvider);
    ref.invalidate(payrollCostProvider);
    return id;
  }

  Future<int> addFine({
    required int staffId,
    required double amount,
    String? reason,
    String type = 'manual',
  }) async {
    final id = await StaffDao.upsertFine(
      StaffFineModel(
        staffId: staffId,
        amount: amount,
        reason: reason,
        type: type,
        createdAt: DateTime.now(),
      ),
    );
    ref.invalidate(payrollReportProvider);
    ref.invalidate(payrollCostProvider);
    return id;
  }

  // -------------------------
  // LOANS
  // -------------------------
  Future<int> addLoan({
    required int staffId,
    required double amount,
    String? reason,
  }) async {
    final id = await StaffDao.insertLoan(
      StaffLoanModel(
        staffId: staffId,
        amount: amount,
        reason: reason,
        createdAt: DateTime.now(),
      ),
    );

    ref.invalidate(staffLoansProvider(staffId));
    ref.invalidate(payrollReportProvider);
    ref.invalidate(payrollCostProvider);

    return id;
  }
}
