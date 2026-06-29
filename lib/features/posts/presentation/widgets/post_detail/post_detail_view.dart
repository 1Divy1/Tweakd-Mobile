import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/post.dart';
import '../../../domain/entities/post_image.dart';
import '../../../domain/entities/post_tagged_car.dart';
import '../../../domain/entities/post_user.dart';
import 'pinch_zoom.dart';
import 'post_time.dart';

/// A faithful, full rendering of a published post — the same card the create
/// wizard previews, made interactive. Engagement counters honour the author's
/// per-counter visibility flags.
class PostDetailView extends StatelessWidget {
  final PostEntity post;
  final VoidCallback onToggleLike;
  final VoidCallback onToggleSave;
  final VoidCallback onShare;
  final VoidCallback onOpenComments;
  final VoidCallback onOpenLikers;

  const PostDetailView({
    super.key,
    required this.post,
    required this.onToggleLike,
    required this.onToggleSave,
    required this.onShare,
    required this.onOpenComments,
    required this.onOpenLikers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(author: post.author, createdAt: post.createdAt),
        _Media(images: post.images),
        _Actions(
          post: post,
          onToggleLike: onToggleLike,
          onToggleSave: onToggleSave,
          onShare: onShare,
          onOpenComments: onOpenComments,
        ),
        if (post.likesCountEnabled && post.likesCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
            child: _LikesLine(count: post.likesCount, onTap: onOpenLikers),
          ),
        if (post.description != null && post.description!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: _Caption(
              author: post.author.username,
              caption: post.description!.trim(),
            ),
          ),
        if (post.taggedCars.isNotEmpty || post.taggedPeople.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: _Tags(
              people: post.taggedPeople,
              cars: post.taggedCars,
            ),
          ),
        if (post.commentsCountEnabled && post.commentsCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: GestureDetector(
              onTap: onOpenComments,
              child: Text(
                AppLocalizations.of(context)!
                    .postViewAllComments(post.commentsCount),
                style: const TextStyle(
                  color: AppColors.mute,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            postTimeAgo(AppLocalizations.of(context)!, post.createdAt)
                .toUpperCase(),
            style: const TextStyle(
              color: AppColors.muteSoft,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final PostUserEntity author;
  final DateTime createdAt;

  const _Header({required this.author, required this.createdAt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.push('/users/${author.username}', extra: author.id),
        child: Row(
          children: [
            _Avatar(username: author.username, avatarUrl: author.avatarUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    author.username,
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
    );
  }
}

class _Media extends StatefulWidget {
  final List<PostImageEntity> images;
  const _Media({required this.images});

  @override
  State<_Media> createState() => _MediaState();
}

class _MediaState extends State<_Media> {
  final _controller = PageController();
  int _page = 0;
  bool _zooming = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    if (images.isEmpty) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          color: AppColors.bg,
          child: const Center(
            child: Icon(Icons.image_outlined,
                color: AppColors.muteSoft, size: 40),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            physics: _zooming
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => PinchZoom(
              onZoomChanged: (z) => setState(() => _zooming = z),
              child: CachedNetworkImage(
                imageUrl: images[i].imageUrl,
                fit: BoxFit.contain,
                fadeInDuration: const Duration(milliseconds: 150),
                placeholder: (_, _) => const ColoredBox(color: AppColors.bg),
                errorWidget: (_, _, _) => const ColoredBox(
                  color: AppColors.bg,
                  child: Center(
                    child: Icon(Icons.broken_image_outlined,
                        color: AppColors.muteSoft, size: 36),
                  ),
                ),
              ),
            ),
          ),
          if (images.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(150),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_page + 1} / ${images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          if (images.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: _PageDots(count: images.length, active: _page),
            ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final int count;
  final int active;
  const _PageDots({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    final shown = count.clamp(0, 7);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < shown; i++)
          Container(
            width: i == active ? 16 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: i == active ? Colors.white : Colors.white.withAlpha(130),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  final PostEntity post;
  final VoidCallback onToggleLike;
  final VoidCallback onToggleSave;
  final VoidCallback onShare;
  final VoidCallback onOpenComments;

  const _Actions({
    required this.post,
    required this.onToggleLike,
    required this.onToggleSave,
    required this.onShare,
    required this.onOpenComments,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          _ActionItem(
            icon: post.viewerHasLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: post.viewerHasLiked ? AppColors.accent : AppColors.ink,
            label: post.likesCountEnabled ? '${post.likesCount}' : null,
            onTap: onToggleLike,
          ),
          const SizedBox(width: 20),
          _ActionItem(
            icon: Icons.mode_comment_outlined,
            label: post.commentsCountEnabled ? '${post.commentsCount}' : null,
            onTap: onOpenComments,
          ),
          const SizedBox(width: 20),
          _ActionItem(
            icon: Icons.ios_share_rounded,
            label: post.sharesCountEnabled ? '${post.sharesCount}' : null,
            onTap: onShare,
          ),
          const Spacer(),
          _ActionItem(
            icon: post.viewerHasSaved
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            color: post.viewerHasSaved ? AppColors.accent : AppColors.ink,
            onTap: onToggleSave,
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.onTap,
    this.label,
    this.color = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          if (label != null) ...[
            const SizedBox(width: 7),
            Text(
              label!,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LikesLine extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _LikesLine({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        AppLocalizations.of(context)!.postLikesCount(count),
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  final String author;
  final String caption;

  const _Caption({required this.author, required this.caption});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppColors.ink2,
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(
            text: '${author.toLowerCase()} ',
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: caption),
        ],
      ),
    );
  }
}

class _Tags extends StatelessWidget {
  final List<PostUserEntity> people;
  final List<PostTaggedCarEntity> cars;

  const _Tags({required this.people, required this.cars});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final car in cars)
          _TagChip(
            icon: Icons.directions_car_rounded,
            label: '${car.make} ${car.model}'.trim(),
          ),
        for (final person in people)
          _TagChip(
            icon: Icons.person_rounded,
            label: '@${person.username}',
            onTap: () => context.push(
              '/users/${person.username}',
              extra: person.id,
            ),
          ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _TagChip({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.accent),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String username;
  final String? avatarUrl;

  const _Avatar({required this.username, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final initial =
        username.isNotEmpty ? username.characters.first.toUpperCase() : '?';
    return CircleAvatar(
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
  }
}
