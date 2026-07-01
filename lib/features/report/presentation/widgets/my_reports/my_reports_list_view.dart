import 'package:flutter/material.dart';

import '../../../domain/entities/my_report.dart';
import 'my_report_tile.dart';

/// The loaded list of the user's submitted reports.
class MyReportsListView extends StatelessWidget {
  final List<MyReportEntity> reports;

  const MyReportsListView({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: reports.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) => MyReportTile(report: reports[i]),
    );
  }
}
