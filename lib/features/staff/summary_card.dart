import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/staff/staff_model.dart';

class SummaryCard extends StatelessWidget {
  final StaffModel staff;
  final DateTime month;
  final List<StaffAttendanceModel> records;
  final double bonus;
  final double fine;

  const SummaryCard({
    super.key,
    required this.staff,
    required this.month,
    required this.records,
    this.bonus = 0.0,
    this.fine = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final summary = _attendanceSummary(records);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            staff.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          _AttendanceChartWithLegend(
            present: summary['present']!,
            late: summary['late']!,
            absent: summary['absent']!,
          )
        ],
      ),
    );
  }

  Map<String, int> _attendanceSummary(List<StaffAttendanceModel> records) {
    int present = 0, late = 0, absent = 0;

    for (final r in records) {
      switch (r.status) {
        case AttendanceStatus.present:
          present++;
          break;
        case AttendanceStatus.late:
          late++;
          break;
        case AttendanceStatus.absent:
          absent++;
          break;
      }
    }

    return {'present': present, 'late': late, 'absent': absent};
  }
}

/// Pie chart with legend for attendance summary
class _AttendanceChartWithLegend extends StatelessWidget {
  final int present;
  final int late;
  final int absent;

  const _AttendanceChartWithLegend({
    required this.present,
    required this.late,
    required this.absent,
  });

  @override
  Widget build(BuildContext context) {
    final total = present + late + absent;
    final presentPct = total == 0 ? 0 : (present / total) * 100;
    final latePct = total == 0 ? 0 : (late / total) * 100;
    final absentPct = total == 0 ? 0 : (absent / total) * 100;

    return Row(
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: presentPct.roundToDouble(),
                  color: clrGreen,
                  radius: 28,
                ),
                PieChartSectionData(
                  value: latePct.roundToDouble(),
                  color: clrOrange,
                  radius: 26,
                ),
                PieChartSectionData(
                  value: absentPct.roundToDouble(),
                  color: clrRed,
                  radius: 24,
                ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 18,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Attendance",
                style: TextStyle(fontWeight: FontWeight.bold)),
            _LegendItem(
                color: clrGreen,
                text: "Present ${presentPct.toStringAsFixed(0)}%"),
            _LegendItem(
                color: clrOrange, text: "Late ${latePct.toStringAsFixed(0)}%"),
            _LegendItem(
                color: clrRed, text: "Absent ${absentPct.toStringAsFixed(0)}%"),
          ],
        ),
      ],
    );
  }
}

/// Legend item row
class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          color: color,
          margin: const EdgeInsets.only(right: 4),
        ),
        Text(text),
      ],
    );
  }
}
