import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:starter_template/features/logs/logs_provider.dart';
import 'package:starter_template/features/logs/log_model.dart';

class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  String _fmtDate(DateTime d) => DateFormat('yyyy-MM-dd HH:mm:ss').format(d);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(logsAsyncProvider);
    final logsCount = ref.watch(logsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(logsAsyncProvider.notifier).reload(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('No logs found.'));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: ExpansionTileGroup(
                    toggleType: ToggleType.expandOnlyCurrent,
                    // expandOnlyCurrent: true,
                    children: logs.map((log) => _buildLogItem(log)).toList(),
                  ),
                ),
              ),
              _buildSummary(context, logsCount),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  ExpansionTileItem _buildLogItem(LogModel log) {
    return ExpansionTileItem(
      key: ValueKey(log.id),
      title:
          Text(log.action, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('User: ${log.userId} | ${_fmtDate(log.timestamp)}'),
      // content:
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(log.details),
        ),
      ],
    );
  }

  Widget _buildSummary(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      width: double.infinity,
      color: Theme.of(context).primaryColorLight.withValues(alpha: 0.1),
      child: Text(
        'Total logs: $count',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
