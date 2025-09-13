import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:starter_template/core/new_db_helper.dart';
import 'package:starter_template/features/staff/staff_model.dart';

class StaffDao {
  static const staffTable = 'staff';
  static const attendanceTable = 'staffAttendance';
  static const bonusTable = 'staffBonus';
  static const fineTable = 'staffFines';
  static const loanTable = 'staffLoans';
  static const payrollTable = 'staffPayroll';

  // -------------------------
  // STAFF CRUD
  // -------------------------
  static Future<int> insertStaff(StaffModel s) async {
    final db = await NewDBHelper.db;
    return await db.insert(
      staffTable,
      s.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateStaff(StaffModel s) async {
    final db = await NewDBHelper.db;
    return await db.update(
      staffTable,
      s.toMap(),
      where: 'id=?',
      whereArgs: [s.id],
    );
  }

  /// Soft delete: marks staff as inactive
  static Future<int> deleteStaff(int id) async {
    final db = await NewDBHelper.db;
    return await db.update(
      staffTable,
      {'active': 0},
      where: 'id=?',
      whereArgs: [id],
    );
  }

  static Future<List<StaffModel>> getAllStaff(
      {bool includeInactive = true}) async {
    final rows = await NewDBHelper.query(
      staffTable,
      where: includeInactive ? null : 'active=1',
      orderBy: 'name ASC',
    );
    return rows.map((r) => StaffModel.fromMap(r)).toList();
  }

  // -------------------------
  // ATTENDANCE
  // -------------------------
  static Future<int> upsertAttendance(StaffAttendanceModel a) async {
    final db = await NewDBHelper.db;
    return await db.transaction((txn) async {
      final res = await txn.insert(
        attendanceTable,
        a.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 🔥 After updating attendance → recalc fines inside txn
      await _recalculateFineForDayTxn(txn, a.staffId, a.date);
      return res;
    });
  }

  static Future<void> upsertAttendanceBatch(
      List<StaffAttendanceModel> list) async {
    final db = await NewDBHelper.db;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (var a in list) {
        batch.insert(
          attendanceTable,
          a.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);

      // 🔥 Recalculate fines for each unique staff+date in same txn
      final uniqueDates = {
        for (var a in list) '${a.staffId}-${a.date}': [a.staffId, a.date]
      }.values;

      for (final entry in uniqueDates) {
        await _recalculateFineForDayTxn(
            txn, entry[0] as int, entry[1] as String);
      }
    });
  }

  // -------------------------
  // FINES
  // -------------------------
  static Future<int> upsertFine(StaffFineModel f) async {
    final db = await NewDBHelper.db;
    return await db.insert(
      fineTable,
      f.toMap(),
      conflictAlgorithm: f.type == 'automatic'
          ? ConflictAlgorithm.replace
          : ConflictAlgorithm.abort,
    );
  }

  static Future<void> recalculateFineForDay(int staffId, String date) async {
    final db = await NewDBHelper.db;
    await db.transaction((txn) async {
      await _recalculateFineForDayTxn(txn, staffId, date);
    });
  }

  /// Internal helper: recalc fine inside an existing txn
  static Future<void> _recalculateFineForDayTxn(
      Transaction txn, int staffId, String date) async {
    // Get staff
    final staffList = await getAllStaff();
    final staff = staffList.firstWhere((s) => s.id == staffId);

    // Get both parts of attendance
    final rows = await txn.query(
      attendanceTable,
      where: 'staffId=? AND date=?',
      whereArgs: [staffId, date],
    );

    final records = rows.map((r) => StaffAttendanceModel.fromMap(r)).toList();
    final p1 = records.firstWhere((r) => r.part == 1,
        orElse: () => StaffAttendanceModel(
              staffId: staffId,
              date: date,
              part: 1,
              status: AttendanceStatus.absent,
            ));
    final p2 = records.firstWhere((r) => r.part == 2,
        orElse: () => StaffAttendanceModel(
              staffId: staffId,
              date: date,
              part: 2,
              status: AttendanceStatus.absent,
            ));

    final dailySalary = staff.salary / 30.0;
    double fineAmount = 0;
    String reason = '';

    if (p1.status == AttendanceStatus.absent &&
        p2.status == AttendanceStatus.absent) {
      fineAmount = dailySalary;
      reason = 'Full day absent automatic deduction';
    } else if (p1.status == AttendanceStatus.absent ||
        p2.status == AttendanceStatus.absent ||
        (p1.status == AttendanceStatus.late &&
            p2.status == AttendanceStatus.late)) {
      fineAmount = dailySalary / 2.0;
      reason = 'Half day absence/late automatic deduction';
    }

    if (fineAmount > 0) {
      await txn.insert(
        fineTable,
        {
          'staffId': staffId,
          'amount': fineAmount,
          'reason': reason,
          'type': 'automatic',
          'createdAt': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      // ✅ Remove auto fine if no longer needed
      await txn.delete(
        fineTable,
        where: 'staffId=? AND type=? AND reason LIKE ?',
        whereArgs: [staffId, 'automatic', '%deduction%'],
      );
    }
  }

  static Future<void> upsertFinesBatch(List<StaffFineModel> list) async {
    final db = await NewDBHelper.db;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (var f in list) {
        batch.insert(
          fineTable,
          f.toMap(),
          conflictAlgorithm: f.type == 'automatic'
              ? ConflictAlgorithm.replace
              : ConflictAlgorithm.abort,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  static Future<List<StaffFineModel>> finesForStaff(int staffId,
      {String? type}) async {
    String? where;
    List whereArgs = [staffId];

    if (type != null) {
      where = 'staffId=? AND type=?';
      whereArgs = [staffId, type];
    } else {
      where = 'staffId=?';
    }

    final rows = await NewDBHelper.query(
      fineTable,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'createdAt DESC',
    );
    return rows.map((r) => StaffFineModel.fromMap(r)).toList();
  }

  // -------------------------
  // BONUS
  // -------------------------
  static Future<int> insertBonus(StaffBonusModel b) async {
    final db = await NewDBHelper.db;
    return await db.insert(
      bonusTable,
      b.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<StaffBonusModel>> bonusesForStaff(int staffId) async {
    final rows = await NewDBHelper.query(
      bonusTable,
      where: 'staffId=?',
      whereArgs: [staffId],
      orderBy: 'createdAt DESC',
    );
    return rows.map((r) => StaffBonusModel.fromMap(r)).toList();
  }

  // -------------------------
  // LOANS
  // -------------------------
  static Future<int> insertLoan(StaffLoanModel l) async {
    final db = await NewDBHelper.db;
    return await db.insert(
      loanTable,
      l.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<StaffLoanModel>> loansForStaff(int staffId) async {
    final db = await NewDBHelper.db;
    final rows = await db.query(
      loanTable,
      where: 'staffId=?',
      whereArgs: [staffId],
      orderBy: 'createdAt DESC',
    );
    return rows.map((r) => StaffLoanModel.fromMap(r)).toList();
  }

  static Future<void> markLoanRepaid(int loanId) async {
    final db = await NewDBHelper.db;
    await db.update(
      loanTable,
      {'repaid': 1},
      where: 'id=?',
      whereArgs: [loanId],
    );
  }

  // -------------------------
  // PAYROLL
  // -------------------------
  static Future<int> insertPayroll(StaffPayrollModel p) async {
    final db = await NewDBHelper.db;
    return db.insert(
      payrollTable,
      p.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<StaffPayrollModel> calculatePayroll(
      StaffModel staff, DateTime month) async {
    final db = await NewDBHelper.db;
    final yearMonth = "${month.year}-${month.month.toString().padLeft(2, '0')}";

    return await db.transaction((txn) async {
      // Bonuses
      final bonusRows = await txn.query(
        bonusTable,
        where: 'staffId=? AND strftime("%Y-%m", createdAt)=?',
        whereArgs: [staff.id, yearMonth],
      );
      final totalBonus = bonusRows.fold<double>(
          0, (sum, r) => sum + (r['amount'] as num).toDouble());

      // Fines
      final fineRows = await txn.query(
        fineTable,
        where: 'staffId=? AND strftime("%Y-%m", createdAt)=?',
        whereArgs: [staff.id, yearMonth],
      );
      final totalFine = fineRows.fold<double>(
          0, (sum, r) => sum + (r['amount'] as num).toDouble());

      // Loan deduction
      final loanRows = await txn.query(
        loanTable,
        where: 'staffId=? AND repaid=0',
        whereArgs: [staff.id],
        orderBy: 'createdAt ASC',
      );
      double loanDeduction = 0;
      if (loanRows.isNotEmpty) {
        final loan = StaffLoanModel.fromMap(loanRows.first);
        loanDeduction = loan.amount;
        await txn.update(
          loanTable,
          {'repaid': 1},
          where: 'id=?',
          whereArgs: [loan.id],
        );
      }

      final net = staff.salary + totalBonus - totalFine - loanDeduction;

      final payroll = StaffPayrollModel(
        staffId: staff.id!,
        month: yearMonth,
        baseSalary: staff.salary,
        bonus: totalBonus,
        fines: totalFine,
        loans: loanDeduction,
        netPayable: net,
        createdAt: DateTime.now(),
      );

      await txn.insert(
        payrollTable,
        payroll.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return payroll;
    });
  }

  static Future<List<StaffPayrollModel>> payrollForStaff(int staffId) async {
    final rows = await NewDBHelper.query(
      payrollTable,
      where: 'staffId=?',
      whereArgs: [staffId],
      orderBy: 'month DESC',
    );
    return rows.map((r) => StaffPayrollModel.fromMap(r)).toList();
  }

  static Future<List<StaffPayrollModel>> payrollReport(DateTime month) async {
    final yearMonth = "${month.year}-${month.month.toString().padLeft(2, '0')}";
    final rows = await NewDBHelper.query(
      payrollTable,
      where: 'month=?',
      whereArgs: [yearMonth],
      orderBy: 'staffId ASC',
    );
    return rows.map((r) => StaffPayrollModel.fromMap(r)).toList();
  }

  static Future<double> totalPayrollCost(DateTime month) async {
    final yearMonth = "${month.year}-${month.month.toString().padLeft(2, '0')}";
    final db = await NewDBHelper.db;
    final result = await db.rawQuery(
        'SELECT SUM(netPayable) as total FROM $payrollTable WHERE month=?',
        [yearMonth]);
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
