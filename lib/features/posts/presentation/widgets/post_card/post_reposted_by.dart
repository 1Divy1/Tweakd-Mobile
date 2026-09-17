import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/post_reposted_by.dart';

/// The line above a feed card that says why the post is there: "@andrei
/// reposted", "@andrei and @mihai reposted", "@andrei and 3 others reposted".
/// Tapping it opens the most recent reposter's profile.
class PostRepostedBy extends StatelessWidget {
  final RepostedByEntity repostedBy;

  const PostRepostedBy({super.key, required this.repostedBy});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final users = repostedBy.users;
    if (users.isEmpty) return const SizedBox.shrink();
    final first = users.first;
    final total = repostedBy.totalCount;

    final text = switch (total) {
      <= 1 => l10n.postRepostedByOne(first.username),
      2 when users.length > 1 =>
        l10n.postRepostedByTwo(first.username, users[1].username),
      _ => l10n.postRepostedByMany(total - 1, first.username),
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/users/${first.username}', extra: first.id),
      child: Row(
        children: [
          Icon(AppIcons.repost, size: 16, color: AppColors.mute),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.mute,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
