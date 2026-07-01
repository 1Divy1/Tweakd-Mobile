import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/my_report.dart';

/// A small pill showing a report's moderation status, colour-coded by state.
class MyReportStatusChip extends StatelessWidget {
  final MyReportStatus status;

  const MyReportStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (color, label) = switch (status) {
      MyReportStatus.pending => (
          const Color(0xFFB8860B),
          l10n.reportStatusPending,
        ),
      MyReportStatus.inProgress => (
          const Color(0xFF1E6FD9),
          l10n.reportStatusInProgress,
        ),
      MyReportStatus.resolved => (
          const Color(0xFF1F9254),
          l10n.reportStatusResolved,
        ),
      MyReportStatus.dismissed => (
          const Color(0xFF8A8680),
          l10n.reportStatusDismissed,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
