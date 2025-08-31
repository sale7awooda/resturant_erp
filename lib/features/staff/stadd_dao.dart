// lib/features/staff/dao/staff_dao.dart
import 'package:starter_template/core/new_db_helper.dart';
import 'package:starter_template/features/staff/staff_model.dart';

class StaffDao {
  static const staffTable = 'staff';
  static const attendanceTable = 'staffAttendance';
  static const bonusTable = 'staffBonus';
  static const fineTable = 'staffFines';

  // STAFF
  static Future<int> insertStaff(StaffModel s) =>
      NewDBHelper.insert(staffTable, s.toMap());

  static Future<int> updateStaff(StaffModel s) => NewDBHelper.update(
        staffTable,
        s.toMap(),
        where: 'id=?',
        whereArgs: [s.id],
      );
  static Future<int> deleteStaff(int id) => NewDBHelper.update(
        staffTable,
        {'active': 0},
        where: 'id=?',
        whereArgs: [id],
      );

  // static Future<List<StaffModel>> getAllStaff() async {
  //   final rows = await NewDBHelper.query(staffTable, orderBy: 'name ASC');
  //   return rows.map((r) => StaffModel.fromMap(r)).toList();
  // }
  static Future<List<StaffModel>> getAllStaff({bool includeInactive = false}) async {
  final where = includeInactive ? null : 'active=1';
  final rows = await NewDBHelper.query(staffTable, where: where, orderBy: 'name ASC');
  return rows.map((r) => StaffModel.fromMap(r)).toList();
}


  // ATTENDANCE
  static Future<int> upsertAttendance(StaffAttendanceModel a) async {
    // Try update first (by staffId/date/part)
    final existing = await NewDBHelper.query(
      attendanceTable,
      where: 'staffId=? AND date=? AND part=?',
      whereArgs: [a.staffId, a.date, a.part],
    );
    if (existing.isNotEmpty) {
      return NewDBHelper.update(
        attendanceTable,
        a.toMap(),
        where: 'staffId=? AND date=? AND part=?',
        whereArgs: [a.staffId, a.date, a.part],
      );
    } else {
      return NewDBHelper.insert(attendanceTable, a.toMap());
    }
  }

  static Future<List<StaffAttendanceModel>> attendanceForStaff(int staffId,
      {required String date}) async {
    final rows = await NewDBHelper.query(
      attendanceTable,
      where: 'staffId=? AND date=?',
      whereArgs: [staffId, date],
      orderBy: 'part ASC',
    );
    return rows.map((r) => StaffAttendanceModel.fromMap(r)).toList();
  }

  static Future<List<StaffAttendanceModel>> attendanceByDate(
      String date) async {
    final rows = await NewDBHelper.query(
      attendanceTable,
      where: 'date=?',
      whereArgs: [date],
      orderBy: 'staffId ASC, part ASC',
    );
    return rows.map((r) => StaffAttendanceModel.fromMap(r)).toList();
  }

  // BONUS / FINES
  static Future<int> insertBonus(StaffBonusModel b) =>
      NewDBHelper.insert(bonusTable, b.toMap());

  static Future<List<StaffBonusModel>> bonusesForStaff(int staffId) async {
    final rows = await NewDBHelper.query(bonusTable,
        where: 'staffId=?', whereArgs: [staffId], orderBy: 'createdAt DESC');
    return rows.map((r) => StaffBonusModel.fromMap(r)).toList();
  }

  static Future<int> insertFine(StaffFineModel f) =>
      NewDBHelper.insert(fineTable, f.toMap());

  static Future<List<StaffFineModel>> finesForStaff(int staffId) async {
    final rows = await NewDBHelper.query(fineTable,
        where: 'staffId=?', whereArgs: [staffId], orderBy: 'createdAt DESC');
    return rows.map((r) => StaffFineModel.fromMap(r)).toList();
  }
}
