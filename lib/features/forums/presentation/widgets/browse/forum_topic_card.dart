import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/forum_topic.dart';
import '../../utils/forum_format.dart';

/// A topic tile on the "By topic" browse tab. The thread count renders only
/// when the backend starts providing one.
class ForumTopicCard extends StatelessWidget {
  final ForumTopicEntity topic;
  final VoidCallback onTap;

  const ForumTopicCard({super.key, required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final count = topic.threadCount;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              topic.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            if (count != null) ...[
              const SizedBox(height: 3),
              Text(
                l10n.forumsThreadsCount(count)
                    .replaceFirst('$count', forumCompactCount(count)),
                style: const TextStyle(
                  color: AppColors.mute,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
