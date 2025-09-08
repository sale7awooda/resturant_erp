import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/core/new_db_helper.dart';
import 'package:starter_template/features/staff/staff_model.dart';
import 'package:starter_template/features/staff/staff_provider.dart';

class StaffDetailsScreen extends ConsumerStatefulWidget {
  final int staffId;
  const StaffDetailsScreen({super.key, required this.staffId});

  @override
  ConsumerState<StaffDetailsScreen> createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends ConsumerState<StaffDetailsScreen> {
  late Future<StaffDetailsData> _detailsFuture;
  final ScrollController _scrollController = ScrollController(); // 🔹 add this

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() {
    final notifier = ref.read(staffNotifierProvider);
    _detailsFuture = _fetchStaffDetails(notifier);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<StaffDetailsData> _fetchStaffDetails(StaffNotifier notifier) async {
    final staffList = await ref.read(staffListProvider.future);
    final staff = staffList.firstWhere((s) => s.id == widget.staffId);

    final attRows = await NewDBHelper.query(
      'staffAttendance',
      where: 'staffId = ?',
      whereArgs: [staff.id],
      orderBy: 'date ASC, part ASC',
    );
    final staffAttendance =
        attRows.map((r) => StaffAttendanceModel.fromMap(r)).toList();

    final bonusRows = await NewDBHelper.query(
      'staffBonus',
      where: 'staffId = ?',
      whereArgs: [staff.id],
      orderBy: 'createdAt ASC',
    );
    final bonuses = bonusRows.map((r) => StaffBonusModel.fromMap(r)).toList();

    final fineRows = await NewDBHelper.query(
      'staffFines',
      where: 'staffId = ?',
      whereArgs: [staff.id],
      orderBy: 'createdAt ASC',
    );
    final fines = fineRows.map((r) => StaffFineModel.fromMap(r)).toList();

    final allMonths = <String>{};
    for (final a in staffAttendance) {
      allMonths.add(a.date.substring(0, 7));
    }
    for (final b in bonuses) {
      allMonths.add(
          '${b.createdAt.year}-${b.createdAt.month.toString().padLeft(2, '0')}');
    }
    for (final f in fines) {
      allMonths.add(
          '${f.createdAt.year}-${f.createdAt.month.toString().padLeft(2, '0')}');
    }

    final sortedMonths = allMonths.toList()..sort();

    final Map<String, List<StaffDetailItem>> grouped = {};
    for (final monthKey in sortedMonths) {
      final monthAttendance =
          staffAttendance.where((a) => a.date.startsWith(monthKey)).toList();
      final monthBonuses = bonuses
          .where((b) =>
              '${b.createdAt.year}-${b.createdAt.month.toString().padLeft(2, '0')}' ==
              monthKey)
          .toList();
      final monthFines = fines
          .where((f) =>
              '${f.createdAt.year}-${f.createdAt.month.toString().padLeft(2, '0')}' ==
              monthKey)
          .toList();

      if (monthAttendance.isEmpty &&
          monthBonuses.isEmpty &&
          monthFines.isEmpty) {
        continue;
      }

      final totalParts = monthAttendance.length;
      final presentParts = monthAttendance
          .where((a) => a.status == AttendanceStatus.present)
          .length;
      final lateParts = monthAttendance
          .where((a) => a.status == AttendanceStatus.late)
          .length;
      final absentParts = monthAttendance
          .where((a) => a.status == AttendanceStatus.absent)
          .length;

      final presentPct =
          totalParts == 0 ? 0 : (presentParts / totalParts * 100).round();
      final latePct =
          totalParts == 0 ? 0 : (lateParts / totalParts * 100).round();
      final absentPct =
          totalParts == 0 ? 0 : (absentParts / totalParts * 100).round();

      final totalBonus =
          monthBonuses.fold<double>(0, (sum, b) => sum + b.amount);
      final totalFines = monthFines.fold<double>(0, (sum, f) => sum + f.amount);

      final List<StaffDetailItem> items = [];

      items.add(StaffDetailItem.summary(
        'Attendance: (Present: $presentPct% Late: $latePct% Absent: $absentPct% ) | '
        'Bonuses: ${totalBonus.round()} | Fines: ${totalFines.round()} | '
        'Net: ${(staff.salary + totalBonus - totalFines).round()}',
      ));

      for (final att in monthAttendance) {
        final day = DateTime.parse(att.date).day;
        items.add(
            StaffDetailItem('Attendance', 'Day $day | ${att.status.name}'));
      }
      for (final b in monthBonuses) {
        items.add(StaffDetailItem(
            'Bonus', 'Day ${b.createdAt.day} - ${b.reason ?? ''}',
            amount: b.amount.roundToDouble()));
      }
      for (final f in monthFines) {
        items.add(StaffDetailItem(
            'Fine', 'Day ${f.createdAt.day} - ${f.reason ?? ''}',
            amount: f.amount.roundToDouble()));
      }

      grouped[monthKey] = items;
    }

    return StaffDetailsData(staff: staff, groupedRows: grouped);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Details')),
      body: FutureBuilder<StaffDetailsData>(
        future: _detailsFuture,
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!;
          final staff = data.staff;
          if (snap.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final currentMonthKey =
                  '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

              final index =
                  data.groupedRows.keys.toList().indexOf(currentMonthKey);
              if (index != -1) {
                final offset =
                    (index * 80.0); // 🔹 estimate height per tile header
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    offset,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              }
            });
          }

          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopCard(staff),
                const SizedBox(height: 16),

                // 🔹 All months grouped in one ExpansionTileGroup
                ExpansionTileGroup(
                  toggleType: ToggleType.expandOnlyCurrent,
                  spaceBetweenItem: 4,
                  children: data.groupedRows.entries.map((entry) {
                    final monthKey = entry.key;
                    final items = entry.value;

                    final dt = DateFormat('yyyy-MM').parse(monthKey);
                    final monthTitle = DateFormat.yMMM().format(dt);
                    final summary = items.first.description;

                    // 👉 current month key
                    final currentMonthKey =
                        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

                    return ExpansionTileItem.outlined(
                      initiallyExpanded: monthKey ==
                          currentMonthKey, // 🔥 auto-expand current month
                      title: Row(
                        children: [
                          TxtWidget(
                              txt: monthTitle, fontWeight: FontWeight.bold),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              summary,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      expendedBorderColor: Colors.blueGrey.shade100,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: _buildMonthTable(items, monthKey, staff),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopCard(StaffModel staff) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: staff.active ? Colors.green : Colors.red,
              child: Text(
                staff.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 35, color: Colors.white),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TxtWidget(
                        txt: staff.role,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontsize: 16,
                      ),
                      gapW12,
                      Text(
                        staff.name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Salary: ${staff.salary.toStringAsFixed(0)}'),
                      Text('Age: ${staff.age ?? '-'}'),
                      Text('Gender: ${staff.gender}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (staff.phone != null) Text('📞 ${staff.phone}'),
                      if (staff.email != null) Text('✉️ ${staff.email}'),
                      if (staff.address != null) Text('🏠 ${staff.address}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () => _showAddEditStaffDialog(staff),
                  child: const Text('Update'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final notifier = ref.read(staffNotifierProvider);
                    await notifier
                        .updateStaff(staff.copyWith(active: !staff.active));
                    _loadDetails();
                    setState(() {});
                  },
                  child: TxtWidget(
                    txt: staff.active ? 'Deactivate' : 'Activate',
                    color: staff.active ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w600,
                    fontsize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
Widget _buildMonthTable(
    List<StaffDetailItem> items, String monthKey, StaffModel staff) {
  final dt = DateFormat('yyyy-MM').parse(monthKey);
  final lastDay = DateTime(dt.year, dt.month + 1, 0);
  final days = List.generate(lastDay.day, (i) => i + 1);

  final attendanceMap = <int, List<String>>{};
  final bonusMap = <int, double>{};
  final fineMap = <int, double>{};

  // Populate attendance
  for (final att in items.where((i) => i.type == 'Attendance')) {
    final match = RegExp(r'Day (\d+)').firstMatch(att.description);
    if (match != null) {
      final day = int.parse(match.group(1)!);
      attendanceMap
          .putIfAbsent(day, () => [])
          .add(att.description.split('|').last.trim());
    }
  }

  // Populate bonus
  for (final b in items.where((i) => i.type == 'Bonus')) {
    final match = RegExp(r'Day (\d+)').firstMatch(b.description);
    if (match != null) {
      final day = int.parse(match.group(1)!);
      bonusMap[day] = (bonusMap[day] ?? 0) + (b.amount ?? 0);
    }
  }

  // Populate fines
  for (final f in items.where((i) => i.type == 'Fine')) {
    final match = RegExp(r'Day (\d+)').firstMatch(f.description);
    if (match != null) {
      final day = int.parse(match.group(1)!);
      fineMap[day] = (fineMap[day] ?? 0) + (f.amount ?? 0);
    }
  }

  return DataTable(
    border: TableBorder.all(color: Colors.grey.shade300),
    columnSpacing: 30,
    headingRowColor: WidgetStateProperty.all(Colors.blueGrey.shade50),
    columns: [
      const DataColumn(
        label: TxtWidget(
          txt: 'Days',
          fontsize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      ...days.map(
        (d) => DataColumn(
          label: Center(
            child: TxtWidget(
              txt: '$d',
              fontsize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ],
    rows: [
      // Attendance row
      DataRow(
        cells: [
          const DataCell(
            TxtWidget(txt: 'Attendance', fontsize: 14, fontWeight: FontWeight.w600),
          ),
          ...days.map(
            (d) => DataCell(
              Center(
                child: Text(attendanceMap[d]?.join('\n') ?? '-', textAlign: TextAlign.center),
              ),
            ),
          ),
        ],
      ),
      // Bonus row
      DataRow(
        cells: [
          const DataCell(
            TxtWidget(txt: 'Bonus', fontsize: 14, fontWeight: FontWeight.w600),
          ),
          ...days.map(
            (d) => DataCell(
              Center(
                child: Text(bonusMap[d]?.toStringAsFixed(0) ?? '0', style: const TextStyle(color: Colors.green)),
              ),
            ),
          ),
        ],
      ),
      // Fine row
      DataRow(
        cells: [
          const DataCell(
            TxtWidget(txt: 'Fines', fontsize: 14, fontWeight: FontWeight.w600),
          ),
          ...days.map(
            (d) => DataCell(
              Center(
                child: Text(fineMap[d]?.toStringAsFixed(0) ?? '0', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

  void _showAddEditStaffDialog([StaffModel? editing]) {
    final controllers = _initStaffControllers(editing);
    bool isMale = (editing?.gender ?? 'male') == 'male';
    bool isActive = editing?.active ?? true;
    final formKey = GlobalKey<FormState>();

    final roles = [
      'admin',
      'manager',
      'accountant',
      'cashier',
      'waiter',
      'chef',
      'assistant'
    ];
    String selectedRole = editing?.role ?? roles.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 250.0, vertical: 25),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        editing == null ? 'Add Staff' : 'Edit Staff',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ✅ Form fields (name, email, etc.)
                      ..._buildStaffFormFields(
                        controllers,
                        setState,
                        isMale,
                        isActive,
                        roles,
                        selectedRole,
                      ),

                      const SizedBox(height: 12),

                      // ✅ Role dropdown fixed
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: roles
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(r),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedRole = val; // 🔥 updates state
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;

                              final model = StaffModel(
                                id: editing?.id,
                                active: isActive,
                                name: controllers['name']!.text.trim(),
                                email: controllers['email']!.text.trim().isEmpty
                                    ? null
                                    : controllers['email']!.text.trim(),
                                phone: controllers['phone']!.text.trim().isEmpty
                                    ? null
                                    : controllers['phone']!.text.trim(),
                                role: selectedRole, // ✅ now updates correctly
                                permissions: editing?.permissions ?? [],
                                salary: double.tryParse(
                                        controllers['salary']!.text) ??
                                    0,
                                age: int.tryParse(controllers['age']!.text),
                                address:
                                    controllers['address']!.text.trim().isEmpty
                                        ? null
                                        : controllers['address']!.text.trim(),
                                gender: isMale ? 'male' : 'female',
                                createdAt: editing?.createdAt ?? DateTime.now(),
                                updatedAt: DateTime.now(),
                              );

                              final notifier = ref.read(staffNotifierProvider);
                              if (editing == null) {
                                await notifier.addStaff(model);
                              } else {
                                await notifier.updateStaff(model);
                              }
                              ref.invalidate(staffNotifierProvider);
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, TextEditingController> _initStaffControllers(
      [StaffModel? editing]) {
    return {
      'name': TextEditingController(text: editing?.name ?? ''),
      'email': TextEditingController(text: editing?.email ?? ''),
      'phone': TextEditingController(text: editing?.phone ?? ''),
      'role': TextEditingController(text: editing?.role ?? 'staff'),
      'salary': TextEditingController(
          text: (editing?.salary ?? 0).toStringAsFixed(0)),
      'age': TextEditingController(text: editing?.age?.toString() ?? ''),
      'address': TextEditingController(text: editing?.address ?? ''),
    };
  }

  List<Widget> _buildStaffFormFields(
      Map<String, TextEditingController> controllers,
      void Function(void Function()) setState,
      bool isMale,
      bool isActive,
      List<String> roles,
      String selectedRole) {
    return [
      _buildTextField('Name', controllers['name']!,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null),
      _buildTextField('Email', controllers['email']!,
          keyboardType: TextInputType.emailAddress),
      _buildTextField('Phone', controllers['phone']!,
          keyboardType: TextInputType.phone),
      _buildTextField('Salary', controllers['salary']!,
          keyboardType: TextInputType.number),
      _buildTextField('Age', controllers['age']!,
          keyboardType: TextInputType.number),
      _buildTextField('Address', controllers['address']!),
      const SizedBox(height: 8),
      // Gender
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Gender', style: TextStyle(fontSize: 16)),
          Row(
            children: [
              Switch(
                  value: isMale,
                  onChanged: (v) => setState(() => isMale = v),
                  activeColor: Colors.blue,
                  inactiveThumbColor: Colors.pink,
                  inactiveTrackColor: Colors.pink[200]),
              const SizedBox(width: 8),
              Text(isMale ? 'Male' : 'Female',
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
      const SizedBox(height: 8),
      // Active
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Active', style: TextStyle(fontSize: 16)),
          Switch(
              value: isActive,
              onChanged: (v) => setState(() => isActive = v),
              activeColor: Colors.green),
        ],
      ),
      const SizedBox(height: 8),
      // Role Dropdown
      // DropdownButtonFormField<String>(
      //   value: selectedRole,
      //   decoration: const InputDecoration(
      //     labelText: 'Role',
      //     border: OutlineInputBorder(),
      //     contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      //   ),
      //   items: roles
      //       .map((role) => DropdownMenuItem(value: role, child: Text(role)))
      //       .toList(),
      //   onChanged: (v) => setState(() => selectedRole = v!),
      // ),
      const SizedBox(height: 12),
    ];
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType, String? Function(dynamic v)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }
}

// ===================== Data Wrapper =====================
class StaffDetailsData {
  final StaffModel staff;
  final Map<String, List<StaffDetailItem>> groupedRows;
  StaffDetailsData({required this.staff, required this.groupedRows});
}

// ===================== Item Model =====================
class StaffDetailItem {
  final String? type;
  final String description;
  final double? amount;
  final bool isSummary;

  StaffDetailItem(this.type, this.description, {this.amount})
      : isSummary = false;

  StaffDetailItem.summary(this.description)
      : type = null,
        amount = null,
        isSummary = true;
}
