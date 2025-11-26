// =============================================================
// File: lib/screens/admin/admin_sales_report_screen.dart
// Purpose: Sales chart and CSV export.
// Endpoint: GET /api/admin/sales/report?startDate&endDate
// =============================================================
import 'package:flutter/material.dart';

class AdminSalesReportScreen extends StatelessWidget {
  const AdminSalesReportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final start = TextEditingController(text: '2025-08-01');
    final end = TextEditingController(text: '2025-08-31');
    return Scaffold(
      appBar: AppBar(title: const Text('Admin • Sales report')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 12, runSpacing: 12, children: [
            SizedBox(width: 160, child: TextField(controller: start, decoration: const InputDecoration(labelText: 'Start date'))),
            SizedBox(width: 160, child: TextField(controller: end, decoration: const InputDecoration(labelText: 'End date'))),
            FilledButton(onPressed: () {/* TODO: fetch report */}, child: const Text('Run report')),
            OutlinedButton(onPressed: () {/* TODO: export CSV */}, child: const Text('Export CSV')),
          ]),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Text('Chart placeholder', style: Theme.of(context).textTheme.bodyLarge),
            ),
          ),
        ]),
      ),
    );
  }
}