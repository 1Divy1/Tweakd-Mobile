import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/my_report.dart';
import 'my_report_status_chip.dart';

/// One row on the "My reports" screen: what was reported, the reason (if any),
/// when it was filed, and the current moderation status.
class MyReportTile extends StatelessWidget {
  final MyReportEntity report;

  const MyReportTile({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (icon, typeLabel) = switch (report.targetType) {
      ReportTargetType.post => (Icons.image_outlined, l10n.reportTargetPost),
      ReportTargetType.comment => (
          Icons.mode_comment_outlined,
          l10n.reportTargetComment,
        ),
      ReportTargetType.profile => (
          Icons.person_outline,
          l10n.reportTargetProfile,
        ),
      ReportTargetType.forumThread => (
          Icons.forum_outlined,
          l10n.reportTargetForumThread,
        ),
      ReportTargetType.forumReply => (
          Icons.mode_comment_outlined,
          l10n.reportTargetForumReply,
        ),
    };
    final date = MaterialLocalizations.of(context).formatMediumDate(
      report.createdAt,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.mute, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeLabel,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  report.reason ?? l10n.reportNoReason,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: report.reason != null
                        ? AppColors.ink2
                        : AppColors.muteSoft,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontStyle: report.reason != null
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  date,
                  style: const TextStyle(
                    color: AppColors.muteSoft,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          MyReportStatusChip(status: report.status),
        ],
      ),
    );
  }
}
