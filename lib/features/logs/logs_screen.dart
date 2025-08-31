import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/logs/log_model.dart';
import 'package:starter_template/features/logs/logs_provider.dart';

class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final pickedStart = await showDatePicker(
      context: context,
      helpText: 'pick starting date',
      initialDate: _selectedStartDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (pickedStart == null) return;

    final pickedEnd = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? pickedStart,
      firstDate: pickedStart,
      lastDate: now,
    );
    if (pickedEnd == null) return;

    setState(() {
      _selectedStartDate = pickedStart;
      _selectedEndDate = pickedEnd;
    });

    ref.read(logsProvider.notifier).loadLogs(
          startDate: pickedStart,
          endDate: pickedEnd,
        );
  }

  @override
  Widget build(BuildContext context) {
    final logsState = ref.watch(logsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('System Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _pickDateRange(context),
          ),
        ],
      ),
      body: logsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (logs) => logs.isEmpty
            ? Center(
                child: TxtWidget(
                  txt: 'No logs available.',
                  fontWeight: FontWeight.w500,
                  fontsize: 20.sp,
                ),
              )
            : _buildLogsGrid(logs),
      ),
    );
  }

  Widget _buildLogsGrid(List<LogModel> logs) {
    final columns = <PlutoColumn>[
      PlutoColumn(
        title: 'ID',
        field: 'id',
        type: PlutoColumnType.number(),
        width: 60.w,
        readOnly: true,
        enableEditingMode: false,
        enableContextMenu: false,
        enableDropToResize: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Action',
        field: 'action',
        type: PlutoColumnType.text(),
        width: 130.w,
        readOnly: true,
        enableEditingMode: false,
        enableContextMenu: false,
        enableDropToResize: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Entity',
        field: 'entity',
        type: PlutoColumnType.text(),
        width: 110.w,
        readOnly: true,
        enableEditingMode: false,
        enableContextMenu: false,
        enableDropToResize: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Details',
        field: 'details',
        type: PlutoColumnType.text(),
        width: 350.w,
        readOnly: true,
        enableEditingMode: false,
        enableContextMenu: false,
        enableDropToResize: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'User ID',
        field: 'userId',
        type: PlutoColumnType.text(),
        width: 100.w,
        readOnly: true,
        enableEditingMode: false,
        enableContextMenu: false,
        enableDropToResize: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Date',
        field: 'date',
        type: PlutoColumnType.text(),
        width: 170.w,
        readOnly: true,
        enableEditingMode: false,
        enableContextMenu: false,
        enableDropToResize: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
    ];

    final rows = logs.map((log) {
      return PlutoRow(cells: {
        'id': PlutoCell(value: log.id ?? 0),
        'action': PlutoCell(value: log.action),
        'entity': PlutoCell(value: log.entity),
        'details': PlutoCell(value: log.details),
        'userId': PlutoCell(value: log.userId),
        'date': PlutoCell(
            value: DateFormat('yyyy/MM/dd HH:mm').format(log.timestamp)),
      });
    }).toList();

    return Column(
      children: [
        Expanded(
          child: PlutoGrid(
            columns: columns,
            rows: rows,
            configuration: PlutoGridConfiguration(
              style: PlutoGridStyleConfig(
                rowColor: Colors.white,
                oddRowColor: Colors.blue.shade50,
                activatedColor: clrMainAppClrLight,
                gridBorderColor: Colors.grey.shade200,
                gridBorderRadius: BorderRadius.circular(12.r),
                rowHeight: 40.h,
                columnHeight: 55.h,
              ),
            ),
          ),
        ),
        _LogsSummaryFooter(totalLogs: logs.length, logs: logs),
      ],
    );
  }
}

class _LogsSummaryFooter extends StatelessWidget {
  final int totalLogs;
  final List<LogModel> logs;

  const _LogsSummaryFooter({required this.totalLogs, required this.logs});

  @override
  Widget build(BuildContext context) {
    final actionCounts = <String, int>{};
    for (var log in logs) {
      actionCounts[log.action] = (actionCounts[log.action] ?? 0) + 1;
    }

    return Card(
      margin: EdgeInsets.all(8.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.all(15.h),
        child: Row(
          children: [
            TxtWidget(
              txt: 'Total Logs: $totalLogs',
              fontWeight: FontWeight.w700,
              fontsize: 14.sp,
            ),
            gapW16,
            Wrap(
              spacing: 25.w,
              children: actionCounts.entries
                  .map((e) => TxtWidget(
                      txt: "${e.key}: ${e.value}", fontWeight: FontWeight.w500))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
