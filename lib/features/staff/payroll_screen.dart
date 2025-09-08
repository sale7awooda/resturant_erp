import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_template/features/staff/staff_provider.dart';

class PayrollReportScreen extends ConsumerWidget {
  final DateTime month;
  const PayrollReportScreen({super.key, required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(payrollReportProvider(month));
    final total = ref.watch(payrollCostProvider(month));

    return Scaffold(
      appBar:
          AppBar(title: Text("Payroll Report ${month.year}-${month.month}")),
      body: report.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text("No payroll data for this month"));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final p = list[i];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text("Staff #${p.staffId}"),
                        subtitle: Text(
                          "Base: ${p.baseSalary.toStringAsFixed(0)} | "
                          "Bonus: ${p.bonus.toStringAsFixed(0)} | "
                          "Fines: ${p.fines.toStringAsFixed(0)} | "
                          "Loans: ${p.loans.toStringAsFixed(0)}",
                        ),
                        trailing: Text(
                          "Net: ${p.netPayable.toStringAsFixed(0)}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ),
                    );
                  },
                ),
              ),
              total.when(
                data: (val) => Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "TOTAL PAYROLL COST: ${val.toStringAsFixed(0)}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text("Error: $e"),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
