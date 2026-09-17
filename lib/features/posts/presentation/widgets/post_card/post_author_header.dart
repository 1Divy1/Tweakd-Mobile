import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/shared/widgets/app_avatar.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/post_user.dart';
import '../post_detail/post_time.dart';

/// Shared post identity row: author avatar, `@username` and relative time.
/// Used by the feed card and the post detail view so a post looks the same
/// everywhere. Tapping the avatar/username opens the author's profile.
///
/// [onMenu], when non-null, adds the trailing "⋯" button.
class PostAuthorHeader extends StatelessWidget {
  final PostUserEntity author;
  final DateTime createdAt;
  final VoidCallback? onMenu;

  const PostAuthorHeader({
    super.key,
    required this.author,
    required this.createdAt,
    this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () =>
                  context.push('/users/${author.username}', extra: author.id),
              child: Row(
                children: [
                  _Avatar(
                    username: author.username,
                    avatarUrl: author.avatarUrl,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '@${author.username}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          postTimeAgo(AppLocalizations.of(context)!, createdAt),
                          style: TextStyle(
                            color: AppColors.mute,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (onMenu != null)
            IconButton(
              onPressed: onMenu,
              icon: Icon(Icons.more_horiz, color: AppColors.mute),
              splashRadius: 20,
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String username;
  final String? avatarUrl;

  const _Avatar({
    required this.username,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AppAvatar(size: 42, url: avatarUrl, name: username);
  }
}
