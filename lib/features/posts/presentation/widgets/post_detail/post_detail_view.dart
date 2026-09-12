import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/post.dart';
import '../post_card/post_author_header.dart';
import '../post_card/post_media_carousel.dart';
import '../post_card/post_participant_card_view.dart';
import '../post_card/post_tags.dart';
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
        PostAuthorHeader(author: post.author, createdAt: post.createdAt),
        if (post.participantCard != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: PostParticipantCardView(card: post.participantCard!),
          )
        else
          PostMediaCarousel(
            images: post.images,
            aspectRatio: 4 / 3,
            fit: BoxFit.contain,
            enableZoom: true,
          ),
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
            child: PostTags(people: post.taggedPeople, cars: post.taggedCars),
          ),
        if (post.commentsCountEnabled && post.commentsCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: GestureDetector(
              onTap: onOpenComments,
              child: Text(
                AppLocalizations.of(
                  context,
                )!.postViewAllComments(post.commentsCount),
                style: TextStyle(
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
            postTimeAgo(
              AppLocalizations.of(context)!,
              post.createdAt,
            ).toUpperCase(),
            style: TextStyle(
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
  final Color? color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.onTap,
    this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 24, color: color ?? AppColors.ink),
          if (label != null) ...[
            const SizedBox(width: 7),
            Text(
              label!,
              style: TextStyle(
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
        style: TextStyle(
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
        style: TextStyle(
          color: AppColors.ink2,
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(
            text: '${author.toLowerCase()} ',
            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
          ),
          TextSpan(text: caption),
        ],
      ),
    );
  }
}
