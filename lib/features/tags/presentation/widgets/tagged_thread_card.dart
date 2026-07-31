import 'package:flutter/material.dart';

import 'package:car_social_media_app/features/forums/domain/entities/forum_thread.dart';
import 'package:car_social_media_app/features/forums/presentation/utils/forum_format.dart';
import 'package:car_social_media_app/features/forums/presentation/widgets/shared/forum_avatar.dart';
import 'package:car_social_media_app/features/forums/presentation/widgets/shared/forum_chips.dart';
import 'package:car_social_media_app/features/forums/presentation/widgets/shared/forum_tag_row.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import 'tag_static_counters.dart';

/// A tagged forum thread, laid out like [ForumThreadCard] but without the
/// card's own container (the tags feed supplies the frame) and without the
/// bookmark toggle — tapping opens the real thread.
class TaggedThreadCard extends StatelessWidget {
  final ForumThreadEntity thread;

  const TaggedThreadCard({super.key, required this.thread});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authorName = thread.author?.username;

    final chips = <Widget>[
      if (thread.brand != null)
        ForumTagChip(label: thread.brand!.name, showDot: false),
      if (thread.model != null)
        ForumTagChip(label: thread.model!.model, showDot: false),
      for (final topic in thread.topics) ForumTagChip(label: topic.name),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (thread.pinned || thread.locked) ...[
            _StatusRow(
              icon: thread.pinned ? Icons.push_pin : Icons.lock_outline,
              label: thread.pinned ? l10n.forumsPinned : l10n.forumsLocked,
              color: thread.pinned ? AppColors.accent : AppColors.mute,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            thread.title,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ForumAvatar(
                username: authorName,
                avatarUrl: thread.author?.avatarUrl,
                size: 18,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  authorName != null
                      ? '@$authorName'
                      : l10n.forumsDeletedPlaceholder,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: authorName != null ? AppColors.ink : AppColors.mute,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '     ${forumActiveAgo(l10n, thread.lastActivityAt)}',
                style: const TextStyle(
                  color: AppColors.mute,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: chips),
          ],
          if (thread.taggedPeople.isNotEmpty ||
              thread.taggedCars.isNotEmpty) ...[
            const SizedBox(height: 8),
            ForumTagRow(
              people: thread.taggedPeople,
              cars: thread.taggedCars,
              dense: true,
            ),
          ],
          const SizedBox(height: 12),
          TagStaticCounters(
            dense: true,
            items: [
              TagCounter(
                icon: Icons.mode_comment_outlined,
                color: AppColors.mute,
                label: forumCompactCount(thread.replyCount),
              ),
              TagCounter(
                icon: Icons.favorite_border_rounded,
                color: AppColors.mute,
                label: forumCompactCount(thread.likesCount),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
