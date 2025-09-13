import 'package:easy_localization/easy_localization.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/staff/staff_dao.dart';
import 'package:starter_template/features/staff/staff_details_screen.dart';
import 'package:starter_template/features/staff/staff_model.dart';
import 'package:starter_template/features/staff/staff_provider.dart';
import 'package:starter_template/features/staff/summary_card.dart';

class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int activeTabIndex = 0;
  DateTime selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // 4 TABS NOW
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
            Tab(text: 'Payroll'), // NEW
          ],
        ),
      ),
      body: staffAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (staffList) => TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            DetailsTab(),
            AttendanceTab(),
            BonusFineTab(),
            PayrollTab(selectedMonth: selectedMonth), // NEW
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (activeTabIndex == 0) {
            _showAddEditStaffDialog(ref);
          } else if (activeTabIndex == 1) {
            _showAttendanceDialog(ref);
          } else if (activeTabIndex == 2) {
            _showBonusFineDialog(ref);
          } else {
            _showAddLoanDialog(ref); // NEW FAB BEHAVIOR
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

// ------------------- NEW LOAN DIALOG -------------------
  Future<void> _showAddLoanDialog(WidgetRef ref) async {
    // Load staff list from provider
    final staffListAsync = ref.read(staffListProvider);
    final staffList = staffListAsync.when(
      data: (list) => list,
      loading: () => [],
      error: (_, __) => [],
    );

    if (staffList.isEmpty) return; // No staff to select

    int? selectedStaffId;
    final amountCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Loan'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                isExpanded: true,
                hint: const Text('Select Staff'),
                value: selectedStaffId,
                items: staffList
                    .map((s) => DropdownMenuItem<int>(
                          value: s.id,
                          child: Text(s.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => selectedStaffId = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                decoration: const InputDecoration(
                  labelText: 'Loan Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: () async {
              if (selectedStaffId == null) return;

              final amt = double.tryParse(amountCtrl.text);
              if (amt == null || amt <= 0) {
                // Optionally show a toast/snackbar for invalid amount
                return;
              }

              // Add loan via StaffNotifier
              await ref.read(staffNotifierProvider).addLoan(
                    staffId: selectedStaffId!,
                    amount: amt,
                    reason: reasonCtrl.text.isEmpty ? null : reasonCtrl.text,
                  );

              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

// ------------------- ADD / EDIT STAFF DIALOG -------------------
  Future<void> _showAddEditStaffDialog(WidgetRef ref,
      [StaffModel? editing]) async {
    final formKey = GlobalKey<FormState>();

    // Initialize controllers with existing data or defaults
    final controllers = {
      'name': TextEditingController(text: editing?.name ?? ''),
      'email': TextEditingController(text: editing?.email ?? ''),
      'phone': TextEditingController(text: editing?.phone ?? ''),
      'salary': TextEditingController(
          text: editing?.salary != null
              ? editing!.salary.toStringAsFixed(0)
              : ''),
      'age': TextEditingController(text: editing?.age?.toString() ?? ''),
      'address': TextEditingController(text: editing?.address ?? ''),
    };

    bool isMale = (editing?.gender ?? 'male') == 'male';
    bool isActive = editing?.active ?? true;

    final roles = [
      'admin',
      'manager',
      'accountant',
      'cashier',
      'waiter',
      'chef',
      'assistant',
    ];
    String selectedRole = editing?.role ?? roles.first;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 250.0, vertical: 25),
          child: Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // --- Text Fields ---
                      ..._buildTextFields(controllers),

                      // --- Gender Switch ---
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
                                inactiveTrackColor: Colors.pink[200],
                              ),
                              const SizedBox(width: 8),
                              Text(isMale ? 'Male' : 'Female',
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // --- Active Switch ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Active', style: TextStyle(fontSize: 16)),
                          Switch(
                            value: isActive,
                            onChanged: (v) => setState(() => isActive = v),
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.grey,
                            inactiveTrackColor: Colors.grey[300],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // --- Role Dropdown ---
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: roles
                            .map((role) => DropdownMenuItem(
                                value: role, child: Text(role)))
                            .toList(),
                        onChanged: (v) => setState(() => selectedRole = v!),
                      ),
                      const SizedBox(height: 12),

                      // --- Actions ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel')),
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
                                role: selectedRole,
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

                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
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

// Helper function to generate text fields with consistent spacing
  List<Widget> _buildTextFields(
      Map<String, TextEditingController> controllers) {
    final fieldConfigs = [
      {
        'label': 'Name',
        'key': 'name',
        'keyboard': TextInputType.text,
        'validator': true
      },
      {
        'label': 'Email',
        'key': 'email',
        'keyboard': TextInputType.emailAddress
      },
      {'label': 'Phone', 'key': 'phone', 'keyboard': TextInputType.phone},
      {'label': 'Salary', 'key': 'salary', 'keyboard': TextInputType.number},
      {'label': 'Age', 'key': 'age', 'keyboard': TextInputType.number},
      {'label': 'Address', 'key': 'address', 'keyboard': TextInputType.text},
    ];

    return fieldConfigs.map((f) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: TextFormField(
          controller: controllers[f['key']]!,
          keyboardType: f['keyboard'] as TextInputType?,
          validator: f['validator'] == true
              ? (v) => v == null || v.isEmpty ? 'Required' : null
              : null,
          decoration: InputDecoration(
            labelText: f['label'] as String,
            border: const OutlineInputBorder(),
          ),
        ),
      );
    }).toList();
  }

// ---------------- REFACTORED ATTENDANCE DIALOG ----------------
  Future<void> _showAttendanceDialog(WidgetRef ref) async {
    final staffList = await ref.read(staffListProvider.future);
    final today = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(today);

    final notifier = ref.read(staffNotifierProvider);

    // Load today's attendance from DB for all staff
    final monthlyAttendance = await notifier.monthlyAttendance(
      year: today.year,
      month: today.month,
    );
    final todayAttendance =
        monthlyAttendance.where((a) => a.date == dateStr).toList();

    // Optimized status map: only store existing attendance or default to present
    final statusMap = {
      for (var staff in staffList)
        staff.id!: {
          for (var part in [1, 2])
            part: todayAttendance
                .firstWhere((a) => a.staffId == staff.id && a.part == part,
                    orElse: () => StaffAttendanceModel(
                          staffId: staff.id!,
                          date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          part: part,
                          status: AttendanceStatus.absent,
                        ))
                .status
        }
    };

    int selectedPart = 1;

    await showDialog(
      context: ref.context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('record_attendance'.tr()),
          content: SizedBox(
            width: 400.w,
            height: 500.h,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: Text('part_1'.tr()),
                      selected: selectedPart == 1,
                      onSelected: (_) => setState(() => selectedPart = 1),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('part_2'.tr()),
                      selected: selectedPart == 2,
                      onSelected: (_) => setState(() => selectedPart = 2),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (_, __) => const Divider(height: 12),
                    itemCount: staffList.length,
                    itemBuilder: (_, i) {
                      final staff = staffList[i];
                      final current = statusMap[staff.id!]![selectedPart]!;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              staff.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            children: AttendanceStatus.values.map((status) {
                              final selected = current == status;
                              return ChoiceChip(
                                label: Text(status.name.capitalize()),
                                selected: selected,
                                selectedColor: switch (status) {
                                  AttendanceStatus.present => Colors.green,
                                  AttendanceStatus.absent => Colors.red,
                                  AttendanceStatus.late => Colors.orange,
                                },
                                labelStyle: TextStyle(
                                    color:
                                        selected ? Colors.white : Colors.black),
                                onSelected: (_) => setState(() =>
                                    statusMap[staff.id!]![selectedPart] =
                                        status),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('cancel'.tr()),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: Text('save'.tr()),
              onPressed: () async {
                if (selectedPart == 1) {
                  final part1Map = {
                    for (var staff in staffList)
                      staff.id!: statusMap[staff.id!]![1]!
                  };
                  await notifier.recordAttendancePart(part1Map, 1);
                } else {
                  for (var part in [1, 2]) {
                    final partMap = {
                      for (var staff in staffList)
                        staff.id!: statusMap[staff.id!]![part]!
                    };
                    await notifier.recordAttendancePart(partMap, part);
                  }
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

// ---------------- REFACTORED BONUS / FINE DIALOG ----------------
  Future<void> _showBonusFineDialog(WidgetRef ref) async {
    final staffList = await ref.read(staffListProvider.future);

    int? selectedStaffId;
    final controllers = {
      'amount': TextEditingController(),
      'reason': TextEditingController(),
    };
    bool isBonus = true;

    await showDialog(
      context: ref.context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('add_bonus_fine'.tr()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Staff dropdown
                DropdownButton<int>(
                  isExpanded: true,
                  hint: Text('select_staff'.tr()),
                  value: selectedStaffId,
                  items: staffList
                      .map((s) =>
                          DropdownMenuItem(value: s.id, child: Text(s.name)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedStaffId = v),
                ),
                const SizedBox(height: 12),

                // Generate amount & reason fields dynamically
                ..._fineBounsTextField({
                  'Amount': controllers['amount']!,
                  'Reason': controllers['reason']!,
                }),
                const SizedBox(height: 16),

                // Bonus / Fine toggle
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => isBonus = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isBonus ? Colors.green.shade400 : null,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8)),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Text(
                            'bonus'.tr(),
                            style: TextStyle(
                                color: isBonus ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => isBonus = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: !isBonus ? Colors.red.shade400 : null,
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8)),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Text(
                            'fine'.tr(),
                            style: TextStyle(
                                color: !isBonus ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('cancel'.tr())),
            ElevatedButton(
              onPressed: () async {
                if (selectedStaffId == null) return;
                final amt = double.tryParse(controllers['amount']!.text) ?? 0;
                final notifier = ref.read(staffNotifierProvider);
                if (isBonus) {
                  await notifier.addBonus(
                      staffId: selectedStaffId!,
                      amount: amt,
                      reason: controllers['reason']!.text);
                } else {
                  await notifier.addFine(
                      staffId: selectedStaffId!,
                      amount: amt,
                      reason: controllers['reason']!.text,
                      type: 'manual');
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text('save'.tr()),
            ),
          ],
        ),
      ),
    );
  }

// ---------------- Helper function ----------------
  List<Widget> _fineBounsTextField(
      Map<String, TextEditingController> controllers) {
    return controllers.entries.map((e) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: TextFormField(
          controller: e.value,
          keyboardType:
              e.key == 'Amount' ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            labelText: e.key.tr(),
            border: const OutlineInputBorder(),
          ),
        ),
      );
    }).toList();
  }
}

extension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

// --------------------- Details TAB (Refactored with Providers) ---------------------
class DetailsTab extends ConsumerWidget {
  const DetailsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();

    final staffAsync = ref.watch(staffListProvider);

    return staffAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
      data: (staffList) {
        // Sort: active first
        final sortedStaff = [...staffList]..sort((a, b) {
            if (a.active && !b.active) return -1;
            if (!a.active && b.active) return 1;
            return a.name.compareTo(b.name);
          });

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 1400 ? 4 : 3,
            childAspectRatio: 1.45,
          ),
          itemCount: sortedStaff.length,
          itemBuilder: (_, i) {
            final staff = sortedStaff[i];

            // Watch monthly data for this staff
            // final monthlyDataAsync = ref.watch(staffMonthlyDataProvider({
            //   'staffId': staff.id!,
            //   'month': now,
            // }));
            final monthlyDataAsync = ref.watch(
              staffMonthlyDataProvider(
                StaffMonthlyParams(staffId: staff.id!, month: now),
              ),
            );

            return monthlyDataAsync.when(
              loading: () => Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (e, st) => Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Center(child: Text('Error: $e')),
              ),
              data: (data) {
                // final attendance = data['attendance'] as Map<String, int>;
                final monthBonus = data['bonus'] as double? ?? 0;
                final monthFine = data['fine'] as double? ?? 0;
                final totalSalary = staff.salary + monthBonus;
                final totalPayable = totalSalary - monthFine;

                final salaryPart =
                    totalSalary == 0 ? 0 : staff.salary / totalSalary * 100;
                final bonusPart =
                    totalSalary == 0 ? 0 : monthBonus / totalSalary * 100;
                final finePart =
                    totalSalary == 0 ? 0 : monthFine / totalSalary * 100;

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  color: staff.active ? clrWhite : Colors.grey[400],
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              StaffDetailsScreen(staffId: staff.id!),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  staff.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: staff.active
                                        ? Colors.black
                                        : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text('Role: ${staff.role}'),
                                Text(
                                    'Salary: ${staff.salary.toStringAsFixed(0)}'),
                                const SizedBox(height: 6),
                                Text('Bonus: ${monthBonus.toStringAsFixed(0)}',
                                    style:
                                        const TextStyle(color: Colors.green)),
                                Text('Fines: ${monthFine.toStringAsFixed(0)}',
                                    style: const TextStyle(color: Colors.red)),
                                Text(
                                    'Payable: ${totalPayable.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Stack(
                              children: [
                                Positioned(
                                  right: 0,
                                  child: TxtWidget(
                                    txt: staff.active ? "Active" : "Inactive",
                                    color: staff.active ? clrGreen : clrRed,
                                    fontWeight: FontWeight.bold,
                                    fontsize: 14,
                                  ),
                                ),
                                _buildPieChart(
                                  salaryPart.roundToDouble(),
                                  bonusPart.roundToDouble(),
                                  finePart.roundToDouble(),
                                  ['Salary', 'Bonus', 'Fine'],
                                  [clrBlue, clrGreen, clrRed],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPieChart(double salaryPct, double bonusPct, double finePct,
      List<String> labels, List<Color> colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 120,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                    value: salaryPct, color: colors[0], radius: 28),
                PieChartSectionData(
                    value: bonusPct, color: colors[1], radius: 24),
                PieChartSectionData(
                    value: finePct, color: colors[2], radius: 22),
              ],
              centerSpaceRadius: 20,
              sectionsSpace: 2,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < labels.length; i++)
                LegendItem(
                    color: colors[i],
                    text: '${labels[i]} ${[
                      salaryPct,
                      bonusPct,
                      finePct
                    ][i].toStringAsFixed(0)}%'),
            ],
          ),
        ),
      ],
    );
  }
}

// ----------------- PIE LEGEND WIDGET -----------------
class LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const LegendItem({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20.h,
      width: 80.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          gapW4,
          Container(width: 12.w, height: 12.w, color: color),
          SizedBox(width: 4.w),
          Text(text, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

// --------------------- BONUS/FINE TAB ---------------------
class BonusFineTab extends ConsumerStatefulWidget {
  const BonusFineTab({super.key});

  @override
  ConsumerState<BonusFineTab> createState() => _BonusFineTabState();
}

class _BonusFineTabState extends ConsumerState<BonusFineTab> {
  StaffModel? selectedStaff;
  final ScrollController _scrollController = ScrollController();

  void _onStaffSelected(StaffModel staff) {
    setState(() {
      selectedStaff = staff;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staffListAsync = ref.watch(staffListProvider);

    return staffListAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (staffList) {
        return Column(
          children: [
            gapH8,
            SizedBox(
              height: 150,
              child: _buildStaffSummaryList(staffList),
            ),
            const Divider(thickness: 1),
            Expanded(
              child: selectedStaff == null
                  ? Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 65, color: clrLightBlack),
                        TxtWidget(
                            txt: 'tap any staff card for details', fontsize: 20)
                      ],
                    ))
                  : _buildStaffDetails(selectedStaff!),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStaffSummaryList(List<StaffModel> staffList) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: staffList.length,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (ctx, i) {
        final staff = staffList[i];
        final monthlyDataAsync = ref.watch(staffMonthlyDataProvider(
            StaffMonthlyParams(staffId: staff.id!, month: DateTime.now())));

        return monthlyDataAsync.when(
          loading: () => _loadingCard(staff.name),
          error: (_, __) => _loadingCard(staff.name),
          data: (data) {
            final bonus = data['bonus'] ?? 0.0;
            final fine = data['fine'] ?? 0.0;
            final net = (staff.salary + bonus - fine);
            return InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => _onStaffSelected(staff),
              child: _summaryCard(
                staff.name,
                bonus.toDouble(),
                fine.toDouble(),
                net: net.toDouble(),
                isSelected: selectedStaff?.id == staff.id,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStaffDetails(StaffModel staff) {
    final detailsFuture = ref.watch(staffMonthlyDataProvider(
      StaffMonthlyParams(staffId: staff.id!, month: DateTime.now()),
    ).future);

    // staffMonthlyDataProvider({
    //   'staffId': staff.id!,
    //   'month': DateTime.now(),
    // }).future,

    return FutureBuilder<Map<String, dynamic>>(
      future: detailsFuture,
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snap.data!;
        final groupedRows = _generateGroupedRows(staff, data);

        final currentMonthKey =
            '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          child: ExpansionTileGroup(
            toggleType: ToggleType.expandOnlyCurrent,
            spaceBetweenItem: 8,
            children: groupedRows.entries.map((entry) {
              final monthKey = entry.key;
              final items = entry.value;
              final dt = DateFormat('yyyy-MM').parse(monthKey);
              final monthTitle = DateFormat.yMMM().format(dt);

              return ExpansionTileItem.outlined(
                initiallyExpanded: monthKey == currentMonthKey,
                title: Row(
                  children: [
                    Text(monthTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(items.first.description,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                expendedBorderColor: Colors.blue.shade100,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildMonthTable(items, monthKey, staff),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Map<String, List<StaffDetailItem>> _generateGroupedRows(
      StaffModel staff, Map<String, dynamic> data) {
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final items = <StaffDetailItem>[];

    // Bonuses
    for (final row in (data['bonusRows'] as List<Map<String, Object?>>)) {
      final createdAt = DateTime.parse(row['createdAt'] as String);
      items.add(
        StaffDetailItem(
          'Bonus',
          'Bonus on day ${createdAt.day}',
          amount: (row['amount'] as num).toDouble(),
          day: createdAt.day, // ✅ store day
        ),
      );
    }

    // Fines
    for (final row in (data['fineRows'] as List<Map<String, Object?>>)) {
      final createdAt = DateTime.parse(row['createdAt'] as String);
      items.add(
        StaffDetailItem(
          'Fine',
          'Fine on day ${createdAt.day}',
          amount: (row['amount'] as num).toDouble(),
          day: createdAt.day, // ✅ store day
        ),
      );
    }

    // Summary
    final bonus = (data['bonus'] as double);
    final fine = (data['fine'] as double);
    items.add(
      StaffDetailItem.summary(
        'Bonuses: ${bonus.round()} | Fines: ${fine.round()} | '
        'Net: ${(staff.salary + bonus - fine).round()}',
      ),
    );

    return {monthKey: items};
  }

  Widget _loadingCard(String name) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: SizedBox(
          width: 160,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                const CircularProgressIndicator(strokeWidth: 2),
              ],
            ),
          ),
        ),
      );

  Widget _summaryCard(String name, double bonus, double fine,
      {double? net, bool isSelected = false}) {
    return Card(
      elevation: isSelected ? 6 : 2,
      color: isSelected ? Colors.blue.shade50 : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SizedBox(
        width: 160,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Text('Bonus: ${bonus.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.green, fontSize: 13)),
              Text('Fine: ${fine.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
              const Divider(),
              Text('Net: ${net?.toStringAsFixed(0) ?? '-'}',
                  style: const TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthTable(
      List<StaffDetailItem> items, String monthKey, StaffModel staff) {
    final dt = DateFormat('yyyy-MM').parse(monthKey);
    final lastDay = DateTime(dt.year, dt.month + 1, 0);
    final days = List.generate(lastDay.day, (i) => i + 1);

    final bonusMap = <int, double>{};
    final fineMap = <int, double>{};

    for (final b in items.where((i) => i.type == 'Bonus')) {
      if (b.day != null) {
        bonusMap[b.day!] = (bonusMap[b.day!] ?? 0) + (b.amount ?? 0);
      }
    }

    for (final f in items.where((i) => i.type == 'Fine')) {
      if (f.day != null) {
        fineMap[f.day!] = (fineMap[f.day!] ?? 0) + (f.amount ?? 0);
      }
    }

    return DataTable(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnSpacing: 30,
      headingRowColor: WidgetStateProperty.all(Colors.blueGrey.shade50),
      columns: [
        const DataColumn(
            label: Text('Days', style: TextStyle(fontWeight: FontWeight.w600))),
        ...days.map((d) => DataColumn(label: Center(child: Text('$d')))),
      ],
      rows: [
        DataRow(cells: [
          const DataCell(
              Text('Bonus', style: TextStyle(fontWeight: FontWeight.w600))),
          ...days.map((d) => DataCell(
              Center(child: Text(bonusMap[d]?.toStringAsFixed(0) ?? '0')))),
        ]),
        DataRow(cells: [
          const DataCell(
              Text('Fines', style: TextStyle(fontWeight: FontWeight.w600))),
          ...days.map((d) => DataCell(
              Center(child: Text(fineMap[d]?.toStringAsFixed(0) ?? '0')))),
        ]),
      ],
    );
  }
}

/// ===================== Data Wrappers =====================
class StaffDetailItem {
  final String? type; // "Bonus" | "Fine" | null for summary
  final String description;
  final double? amount;
  final int? day; // <-- new: store the actual day
  final bool isSummary;

  StaffDetailItem(this.type, this.description, {this.amount, this.day})
      : isSummary = false;

  StaffDetailItem.summary(this.description)
      : type = null,
        amount = null,
        day = null,
        isSummary = true;
}

// --------------------- ATTENDANCE TAB (Optimized & Improved) ---------------------

class AttendanceTab extends ConsumerStatefulWidget {
  const AttendanceTab({super.key});

  @override
  ConsumerState<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends ConsumerState<AttendanceTab> {
  DateTime selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final normalizedMonth =
        DateTime(selectedMonth.year, selectedMonth.month, 1);

    final staffListAsync = ref.watch(staffListProvider);
    final attendanceAsync =
        ref.watch(monthlyAttendanceProvider(normalizedMonth));

    return staffListAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (staffList) {
        return attendanceAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (allAttendance) {
            final daysInMonth = DateUtils.getDaysInMonth(
                selectedMonth.year, selectedMonth.month);
            final attendanceMap = _groupMonthlyAttendance(allAttendance);
            final columns = _buildColumns(daysInMonth);
            final rows = _buildRows(staffList, attendanceMap, normalizedMonth);

            return Column(
              children: [
                SizedBox(
                  height: 170.h,
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: staffList.length,
                    itemBuilder: (ctx, i) {
                      final staff = staffList[i];
                      return SummaryCard(
                        staff: staff,
                        month: normalizedMonth,
                        records: attendanceMap[staff.id!] ?? [],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('yyyy - MMM').format(selectedMonth),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      tooltip: 'Select Month',
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () async {
                        final picked = await showMonthPicker(
                          context: context,
                          initialDate: selectedMonth,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => selectedMonth =
                              DateTime(picked.year, picked.month));
                        }
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: PlutoGrid(
                    columns: columns,
                    rows: rows,
                    configuration: PlutoGridConfiguration(
                      style: PlutoGridStyleConfig(
                        rowHeight: 70.h,
                        gridBackgroundColor: clrWhite,
                        columnTextStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ----------------- HELPERS -----------------
  Map<int, List<StaffAttendanceModel>> _groupMonthlyAttendance(
      List<StaffAttendanceModel> records) {
    final map = <int, List<StaffAttendanceModel>>{};
    for (final r in records) {
      map.putIfAbsent(r.staffId, () => []).add(r);
    }
    return map;
  }
}

List<PlutoColumn> _buildColumns(int daysInMonth) {
  PlutoColumn baseDayColumn(int day) => PlutoColumn(
        title: '$day',
        field: 'day$day',
        type: PlutoColumnType.text(),
        readOnly: true,
        width: 48.h,
        enableContextMenu: false,
        enableDropToResize: false,
        enableFilterMenuItem: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (ctx) => _attendanceDotRow(ctx.cell.value),
      );

  return [
    PlutoColumn(
      title: 'Staff Name',
      field: 'staff',
      type: PlutoColumnType.text(),
      frozen: PlutoColumnFrozen.start,
      readOnly: true,
      enableContextMenu: false,
      enableDropToResize: false,
      enableFilterMenuItem: false,
      width: 150.h,
    ),
    for (var d = 1; d <= daysInMonth; d++) baseDayColumn(d),
  ];
}

List<PlutoRow> _buildRows(List<StaffModel> staffList,
    Map<int, List<StaffAttendanceModel>> attendanceMap, DateTime month) {
  final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

  return staffList.map((staff) {
    final cells = <String, PlutoCell>{'staff': PlutoCell(value: staff.name)};

    final staffRecords = attendanceMap[staff.id!] ?? [];

    final recordsByDay = <int, List<StaffAttendanceModel>>{};
    for (final record in staffRecords) {
      final day = DateTime.parse(record.date).day;
      recordsByDay.putIfAbsent(day, () => []).add(record);
    }

    AttendanceStatus getAttendanceForPart(
        int day, int part, DateTime currentDate) {
      final dayRecords = recordsByDay[day] ?? [];
      final record = dayRecords.firstWhere(
        (r) => r.part == part,
        orElse: () => StaffAttendanceModel(
          staffId: staff.id!,
          date: DateFormat('yyyy-MM-dd').format(currentDate),
          part: part,
          status: AttendanceStatus.absent,
        ),
      );
      return record.status;
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final currentDate = DateTime(month.year, month.month, day);

      if (currentDate.isAfter(DateTime.now())) {
        cells['day$day'] = PlutoCell(value: []);
        continue;
      }

      final dayRecords = recordsByDay[day] ?? [];
      if (dayRecords.isEmpty) {
        cells['day$day'] = PlutoCell(value: []);
        continue;
      }

      cells['day$day'] = PlutoCell(
        value: [
          getAttendanceForPart(day, 1, currentDate),
          getAttendanceForPart(day, 2, currentDate),
        ],
      );
    }

    return PlutoRow(cells: cells);
  }).toList();
}

Widget _attendanceDotRow(List<dynamic> statuses) {
  if (statuses.isEmpty) return const SizedBox();
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: statuses.map((s) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Tooltip(
          message: s.toString().split('.').last,
          child: _buildAttendanceDot(s),
        ),
      );
    }).toList(),
  );
}

Widget _buildAttendanceDot(AttendanceStatus status) {
  final color = switch (status) {
    AttendanceStatus.present => clrGreen,
    AttendanceStatus.late => clrOrange,
    AttendanceStatus.absent => clrRed,
  };
  return Container(
    width: 11.h,
    height: 11.h,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.black12),
    ),
  );
}

class PayrollTab extends ConsumerWidget {
  final DateTime selectedMonth;
  const PayrollTab({super.key, required this.selectedMonth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(payrollReportProvider(selectedMonth));
    final totalAsync = ref.watch(payrollCostProvider(selectedMonth));

    return reportAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text("Error: $e")),
      data: (report) {
        if (report.isEmpty) {
          return const Center(child: Text("No payroll data available"));
        }

        return Column(
          children: [
            // ----------------- TOTAL HEADER -----------------
            totalAsync.when(
              data: (val) => Container(
                margin: const EdgeInsets.all(12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Payroll Cost",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      val.toStringAsFixed(0),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text("Error: $e"),
            ),

            // ----------------- PAYROLL LIST -----------------
            Expanded(
              child: ListView.builder(
                itemCount: report.length,
                itemBuilder: (context, i) {
                  final p = report[i];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(
                        "Staff #${p.staffId}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Base: ${p.baseSalary.toStringAsFixed(0)}"),
                          Text("Bonus: ${p.bonus.toStringAsFixed(0)}",
                              style: const TextStyle(color: Colors.green)),
                          Text("Fines: ${p.fines.toStringAsFixed(0)}",
                              style: const TextStyle(color: Colors.red)),
                          Text("Loans: ${p.loans.toStringAsFixed(0)}",
                              style: const TextStyle(color: Colors.orange)),
                        ],
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Net Payable",
                              style: TextStyle(fontSize: 12)),
                          Text(
                            p.netPayable.toStringAsFixed(0),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
