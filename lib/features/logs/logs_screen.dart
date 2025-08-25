// lib/features/logs/logs_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:starter_template/features/logs/logs_provider.dart';

class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsState = ref.watch(logsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("System Logs")),
      body: logsState.when(
        data: (logs) {
          final rows = logs
              .map((log) => PlutoRow(cells: {
                    'id': PlutoCell(value: log.id),
                    'type': PlutoCell(value: log.action),
                    'message': PlutoCell(value: log.entity),
                    'details': PlutoCell(value: log.details),
                    'date': PlutoCell(value: log.timestamp.toString()),
                  }))
              .toList();

          return PlutoGrid(
            columns: [
              PlutoColumn(
                  title: 'ID', field: 'id', type: PlutoColumnType.number()),
              PlutoColumn(
                  title: 'Type', field: 'type', type: PlutoColumnType.text()),
              PlutoColumn(
                  title: 'Message',
                  field: 'message',
                  type: PlutoColumnType.text()),
              PlutoColumn(
                  title: 'Details',
                  field: 'details',
                  type: PlutoColumnType.text()),
              PlutoColumn(
                  title: 'Date', field: 'date', type: PlutoColumnType.text()),
            ],
            rows: rows,
            onLoaded: (event) {},
            onChanged: (event) {},
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text("Error: $err")),
      ),
    );
  }
}
