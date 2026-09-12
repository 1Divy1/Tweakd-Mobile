import 'package:flutter/material.dart';

import 'package:tweakd/features/forums/domain/entities/forum_reply.dart';
import 'package:tweakd/features/forums/domain/entities/forum_thread.dart';
import 'package:tweakd/features/forums/presentation/utils/forum_format.dart';
import 'package:tweakd/features/forums/presentation/widgets/shared/forum_avatar.dart';
import 'package:tweakd/features/forums/presentation/widgets/shared/forum_tag_row.dart';
import 'package:tweakd/features/posts/presentation/widgets/post_detail/post_time.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import 'tag_static_counters.dart';

/// A tagged forum reply: the thread it belongs to, then the reply in the same
/// shape [ReplyTile] uses. Display only — tapping opens the thread.
class TaggedReplyCard extends StatelessWidget {
  final ForumThreadEntity thread;
  final ForumReplyEntity reply;

  const TaggedReplyCard({
    super.key,
    required this.thread,
    required this.reply,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authorName = reply.author?.username;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.forum_outlined, size: 14, color: AppColors.mute),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  thread.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ForumAvatar(
                      username: authorName,
                      avatarUrl: reply.author?.avatarUrl,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        authorName != null
                            ? '@$authorName'
                            : l10n.forumsDeletedPlaceholder,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              authorName != null ? AppColors.ink : AppColors.mute,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '  ·  ${postTimeAgo(l10n, reply.createdAt)}',
                      style: TextStyle(
                        color: AppColors.mute,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  reply.content ?? '',
                  style: TextStyle(
                    color: AppColors.ink2,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                if (reply.taggedPeople.isNotEmpty ||
                    reply.taggedCars.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ForumTagRow(
                    people: reply.taggedPeople,
                    cars: reply.taggedCars,
                    dense: true,
                  ),
                ],
                const SizedBox(height: 10),
                TagStaticCounters(
                  dense: true,
                  items: [
                    TagCounter(
                      icon: reply.viewerHasLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color:
                          reply.viewerHasLiked ? AppColors.accent : AppColors.mute,
                      label: forumCompactCount(reply.likesCount),
                    ),
                    if (reply.replyCount > 0)
                      TagCounter(
                        icon: Icons.mode_comment_outlined,
                        color: AppColors.mute,
                        label: forumCompactCount(reply.replyCount),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
