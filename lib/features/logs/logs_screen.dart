import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:starter_template/common/widgets/txt_widget.dart';
import 'package:starter_template/core/constants.dart';
import 'package:starter_template/features/logs/logs_provider.dart';

class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  DateTime? _selectedDate;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      ref.read(logsProvider.notifier).loadLogs(
            date: DateFormat('yyyy-MM-dd').format(picked),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final logsState = ref.watch(logsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('System Logs'),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.h, vertical: 5.h),
            child: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _pickDate(context),
            ),
          ),
        ],
      ),
      body: logsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (logs) {
          if (logs.isEmpty) {
            return Center(
              child: TxtWidget(
                txt: 'No logs available.',
                fontWeight: FontWeight.w500,
                fontsize: 20.sp,
              ),
            );
          }

          final columns = <PlutoColumn>[
            PlutoColumn(
                title: 'ID',
                field: 'id',
                type: PlutoColumnType.number(),
                width: 60.w,
                minWidth: 60.w,
                readOnly: true,
                enableHideColumnMenuItem: false,
                textAlign: PlutoColumnTextAlign.center,
                titleTextAlign: PlutoColumnTextAlign.center,
                enableColumnDrag: false,
                enableContextMenu: false,
                enableRowDrag: false),
            PlutoColumn(
                title: 'Action',
                field: 'action',
                type: PlutoColumnType.text(),
                width: 130.w,
                minWidth: 130.w,
                readOnly: true,
                enableHideColumnMenuItem: false,
                textAlign: PlutoColumnTextAlign.center,
                titleTextAlign: PlutoColumnTextAlign.center,
                enableColumnDrag: false,
                enableContextMenu: false,
                enableRowDrag: false),
            PlutoColumn(
                title: 'Entity',
                field: 'entity',
                type: PlutoColumnType.text(),
                width: 90.w,
                minWidth: 90.w,
                readOnly: true,
                enableHideColumnMenuItem: false,
                textAlign: PlutoColumnTextAlign.center,
                titleTextAlign: PlutoColumnTextAlign.center,
                enableColumnDrag: false,
                enableContextMenu: false,
                enableRowDrag: false),
            // PlutoColumn(
            //     title: 'Entity ID',
            //     field: 'entityId',
            //     type: PlutoColumnType.text(),
            //     width: 100.w),
            PlutoColumn(
                title: 'Details',
                field: 'details',
                type: PlutoColumnType.text(),
                width: 350.w,
                minWidth: 350.w,
                readOnly: true,
                enableHideColumnMenuItem: false,
                textAlign: PlutoColumnTextAlign.center,
                titleTextAlign: PlutoColumnTextAlign.center,
                enableColumnDrag: false,
                enableContextMenu: false,
                enableRowDrag: false),
            PlutoColumn(
                title: 'User ID',
                field: 'userId',
                type: PlutoColumnType.text(),
                width: 100.w,
                minWidth: 100.w,
                readOnly: true,
                enableHideColumnMenuItem: false,
                textAlign: PlutoColumnTextAlign.center,
                titleTextAlign: PlutoColumnTextAlign.center,
                enableColumnDrag: false,
                enableContextMenu: false,
                enableRowDrag: false),
            PlutoColumn(
                title: 'Date',
                field: 'date',
                type: PlutoColumnType.text(),
                width: 170.w,
                minWidth: 170.w,
                readOnly: true,
                enableHideColumnMenuItem: false,
                textAlign: PlutoColumnTextAlign.center,
                titleTextAlign: PlutoColumnTextAlign.center,
                enableColumnDrag: false,
                enableContextMenu: false,
                enableRowDrag: false),
          ];

          final rows = logs.map((log) {
            return PlutoRow(cells: {
              'id': PlutoCell(value: log.id ?? 0),
              'action': PlutoCell(value: log.action),
              'entity': PlutoCell(value: log.entity),
              // 'entityId': PlutoCell(value: log.entityId ?? '-'),
              'userId': PlutoCell(value: log.userId),
              'details': PlutoCell(value: log.details),
              'date': PlutoCell(
                value: DateFormat('yyyy/MM/dd HH:mm').format(log.timestamp),
              ),
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
        },
      ),
    );
  }
}

class _LogsSummaryFooter extends StatelessWidget {
  final int totalLogs;
  final List<dynamic> logs;

  const _LogsSummaryFooter({required this.totalLogs, required this.logs});

  @override
  Widget build(BuildContext context) {
    // Group logs by action type for summary
    final Map<String, int> actionCounts = {};
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
              children: actionCounts.entries.map((e) {
                return TxtWidget(
                    txt: "${e.key}: ${e.value}", fontWeight: FontWeight.w500);
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
