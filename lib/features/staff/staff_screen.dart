// lib/features/staff/staff_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:starter_template/features/staff/staff_model.dart';
import 'package:starter_template/features/staff/staff_provider.dart';

class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => activeTabIndex = _tabController.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(staffListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Attendance'),
            Tab(text: 'Bonuses & Fines'),
          ],
        ),
      ),
      body: staffAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (staffList) => TabBarView(
          controller: _tabController,
          children: [
            _DetailsTab(staffList: staffList),
            _AttendanceTab(staffList: staffList),
            _BonusFineTab(staffList: staffList),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          if (activeTabIndex == 0) {
            _showAddEditStaffDialog();
          } else if (activeTabIndex == 1) {
            _showAttendanceDialog();
          } else {
            _showBonusFineDialog();
          }
        },
      ),
    );
  }

  void _showAddEditStaffDialog([StaffModel? editing]) {
    final name = TextEditingController(text: editing?.name ?? '');
    final email = TextEditingController(text: editing?.email ?? '');
    final phone = TextEditingController(text: editing?.phone ?? '');
    final role = TextEditingController(text: editing?.role ?? 'staff');
    final salary = TextEditingController(
        text: (editing?.salary ?? 0.0).toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(editing == null ? 'Add Staff' : 'Edit Staff'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Name')),
              TextField(
                  controller: email,
                  decoration: const InputDecoration(labelText: 'Email')),
              TextField(
                  controller: phone,
                  decoration: const InputDecoration(labelText: 'Phone')),
              TextField(
                  controller: role,
                  decoration: const InputDecoration(labelText: 'Role')),
              TextField(
                controller: salary,
                decoration: const InputDecoration(labelText: 'Salary'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final model = StaffModel(
                active: true,
                id: editing?.id,
                name: name.text.trim(),
                email: email.text.trim().isEmpty ? null : email.text.trim(),
                phone: phone.text.trim().isEmpty ? null : phone.text.trim(),
                role: role.text.trim().isEmpty ? 'staff' : role.text.trim(),
                permissions: editing?.permissions ?? [],
                salary: double.tryParse(salary.text) ?? 0.0,
                createdAt: editing?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );
              final notifier = ref.read(staffNotifierProvider);
              if (editing == null) {
                await notifier.addStaff(model);
              } else {
                await notifier.updateStaff(model);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAttendanceDialog() async {
    // existing attendance dialog logic...
  }

  Future<void> _showBonusFineDialog() async {
    // existing bonus/fine dialog logic...
  }
}

// --------------------- DETAILS TAB ---------------------
class _DetailsTab extends ConsumerWidget {
  final List<StaffModel> staffList;
  const _DetailsTab({required this.staffList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(staffNotifierProvider);

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
      ),
      itemCount: staffList.length,
      itemBuilder: (_, i) {
        final s = staffList[i];
        return Card(
          margin: const EdgeInsets.all(6),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Role: ${s.role}'),
                Text('Salary: ${s.salary.toStringAsFixed(0)}'),
                FutureBuilder<Map<String, double>>(
                  future: notifier.getSummaryForMonth(
                      s.id!, DateTime.now().year, DateTime.now().month),
                  builder: (ctx, snap) {
                    final data = snap.data ?? {'bonus': 0, 'fine': 0};
                    return Text(
                        'Bonus: ${data['bonus']} • Fines: ${data['fine']}');
                  },
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => {}, // reuse add/edit dialog
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await notifier.deleteStaff(s.id!);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --------------------- BONUS/FINE TAB ---------------------
class _BonusFineTab extends ConsumerWidget {
  final List<StaffModel> staffList;
  const _BonusFineTab({required this.staffList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(staffNotifierProvider);

    return Column(
      children: [
        // Summary grid
        Flexible(
          flex: 1,
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 1.3),
            itemCount: staffList.length,
            itemBuilder: (ctx, i) {
              final s = staffList[i];
              return FutureBuilder<Map<String, double>>(
                future: notifier.getSummaryForMonth(
                    s.id!, DateTime.now().year, DateTime.now().month),
                builder: (ctx, snap) {
                  final data = snap.data ?? {'bonus': 0, 'fine': 0};
                  return Card(
                    margin: const EdgeInsets.all(6),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(s.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Bonus: ${data['bonus']}'),
                          Text('Fine: ${data['fine']}'),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        // PlutoGrid
        Flexible(
          flex: 1,
          child: FutureBuilder(
            future: Future.wait(staffList.map((s) => Future.wait([
                  notifier.bonusesForStaff(s.id!),
                  notifier.finesForStaff(s.id!),
                ]))),
            builder: (ctx, AsyncSnapshot<List<List<dynamic>>> snap) {
              if (!snap.hasData)
                return const Center(child: CircularProgressIndicator());

              // Columns: Staff + months
              final columns = <PlutoColumn>[
                PlutoColumn(
                    title: 'Staff',
                    field: 'staff',
                    type: PlutoColumnType.text(),
                    frozen: PlutoColumnFrozen.start),
                ...List.generate(
                    12,
                    (i) => PlutoColumn(
                        title: '${i + 1}',
                        field: 'm${i + 1}',
                        type: PlutoColumnType.number(),
                        readOnly: true)),
              ];

              final rows = <PlutoRow>[];
              for (var idx = 0; idx < staffList.length; idx++) {
                final s = staffList[idx];
                final bonuses = snap.data![idx][0] as List<StaffBonusModel>;
                final fines = snap.data![idx][1] as List<StaffFineModel>;

                // One row for bonuses
                final bonusCells = <String, PlutoCell>{
                  'staff': PlutoCell(value: '${s.name} (Bonus)')
                };
                for (int m = 1; m <= 12; m++) {
                  final total = bonuses
                      .where((b) => b.createdAt.month == m)
                      .fold(0.0, (sum, b) => sum + b.amount);
                  bonusCells['m$m'] = PlutoCell(value: total);
                }
                rows.add(PlutoRow(cells: bonusCells));

                // One row for fines
                final fineCells = <String, PlutoCell>{
                  'staff': PlutoCell(value: '${s.name} (Fine)')
                };
                for (int m = 1; m <= 12; m++) {
                  final total = fines
                      .where((f) => f.createdAt.month == m)
                      .fold(0.0, (sum, f) => sum + f.amount);
                  fineCells['m$m'] = PlutoCell(value: total);
                }
                rows.add(PlutoRow(cells: fineCells));
              }

              return PlutoGrid(columns: columns, rows: rows);
            },
          ),
        ),
      ],
    );
  }
}

// --------------------- ATTENDANCE TAB ---------------------
class _AttendanceTab extends ConsumerStatefulWidget {
  final List<StaffModel> staffList;
  const _AttendanceTab({required this.staffList});

  @override
  ConsumerState<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends ConsumerState<_AttendanceTab> {
  DateTime selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(staffNotifierProvider);

    return Column(
      children: [
        Flexible(
          flex: 1,
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 1.2),
            itemCount: widget.staffList.length,
            itemBuilder: (ctx, i) {
              final s = widget.staffList[i];
              return FutureBuilder<List<StaffAttendanceModel>>(
                future: notifier.attendanceForStaff(s.id!,
                    date: DateFormat('yyyy-MM').format(selectedMonth)),
                builder: (ctx, snap) {
                  final att = snap.data ?? [];
                  final present = att.where((a) => a.present).length;
                  final absent = att.where((a) => !a.present).length;
                  final total = present + absent;
                  return Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                    value: present.toDouble(),
                                    color: Colors.green,
                                    title: 'P'),
                                PieChartSectionData(
                                    value: absent.toDouble(),
                                    color: Colors.red,
                                    title: 'A'),
                              ],
                              sectionsSpace: 0,
                              centerSpaceRadius: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        Flexible(
          flex: 1,
          child: Column(
            children: [
              Row(
                children: [
                  Text('Month: ${DateFormat('yyyy-MM').format(selectedMonth)}'),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final dt = await showDatePicker(
                        context: context,
                        initialDate: selectedMonth,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        selectableDayPredicate: (d) => d.day == 1,
                      );
                      if (dt != null) setState(() => selectedMonth = dt);
                    },
                  ),
                ],
              ),
              Expanded(
                child: FutureBuilder<List<List<StaffAttendanceModel>>>(
                  future: Future.wait(widget.staffList.map((s) =>
                      notifier.attendanceForStaff(s.id!,
                          date: DateFormat('yyyy-MM').format(selectedMonth)))),
                  builder: (ctx, snap) {
                    if (!snap.hasData)
                      return const Center(child: CircularProgressIndicator());

                    final daysInMonth = DateUtils.getDaysInMonth(
                        selectedMonth.year, selectedMonth.month);
                    final columns = <PlutoColumn>[
                      PlutoColumn(
                          title: 'Staff',
                          field: 'staff',
                          type: PlutoColumnType.text(),
                          frozen: PlutoColumnFrozen.start),
                      for (int d = 1; d <= daysInMonth; d++)
                        PlutoColumn(
                            title: '$d',
                            field: 'day$d',
                            type: PlutoColumnType.text(),
                            readOnly: true),
                    ];

                    final rows = <PlutoRow>[];
                    for (var i = 0; i < widget.staffList.length; i++) {
                      final s = widget.staffList[i];
                      final att = snap.data![i];
                      final cells = <String, PlutoCell>{
                        'staff': PlutoCell(value: s.name)
                      };

                      for (var day = 1; day <= daysInMonth; day++) {
                        final record = att.firstWhere(
                            (a) => DateTime.parse(a.date).day == day,
                            orElse: () => StaffAttendanceModel(
                                staffId: s.id!,
                                date: DateTime(selectedMonth.year,
                                        selectedMonth.month, day)
                                    .toIso8601String(),
                                part: 1,
                                present: false));
                        cells['day$day'] =
                            PlutoCell(value: record.present ? 'P' : 'A');
                      }

                      rows.add(PlutoRow(cells: cells));
                    }

                    return PlutoGrid(columns: columns, rows: rows);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
