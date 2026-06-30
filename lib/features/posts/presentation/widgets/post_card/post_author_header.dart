import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/post_user.dart';
import '../post_detail/post_time.dart';

/// Shared post identity row: author avatar, `@username` and relative time.
/// Used by the feed card and the post detail view so a post looks the same
/// everywhere. Tapping the avatar/username opens the author's profile.
///
/// [showRing] draws the accent gradient ring from the feed design; [onMenu],
/// when non-null, adds the trailing "⋯" button.
class PostAuthorHeader extends StatelessWidget {
  final PostUserEntity author;
  final DateTime createdAt;
  final bool showRing;
  final VoidCallback? onMenu;

  const PostAuthorHeader({
    super.key,
    required this.author,
    required this.createdAt,
    this.showRing = false,
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
                    showRing: showRing,
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
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          postTimeAgo(AppLocalizations.of(context)!, createdAt),
                          style: const TextStyle(
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
              icon: const Icon(Icons.more_horiz, color: AppColors.mute),
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
  final bool showRing;

  const _Avatar({
    required this.username,
    required this.showRing,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final initial =
        username.isNotEmpty ? username.characters.first.toUpperCase() : '?';
    final avatar = CircleAvatar(
      radius: 21,
      backgroundColor: AppColors.accentSoft,
      backgroundImage:
          avatarUrl != null ? CachedNetworkImageProvider(avatarUrl!) : null,
      child: avatarUrl == null
          ? Text(
              initial,
              style: const TextStyle(
                color: AppColors.accentHot,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            )
          : null,
    );

    if (!showRing) return avatar;

    // Accent gradient ring with a thin surface gap, matching the feed design.
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accent, AppColors.accentHot],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
        ),
        child: avatar,
      ),
    );
  }
}
