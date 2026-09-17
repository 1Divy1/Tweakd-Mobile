import 'package:flutter/material.dart';
import 'package:tweakd/core/theme/app_icons.dart';

import 'package:tweakd/features/posts/domain/entities/post.dart';
import 'package:tweakd/features/posts/presentation/widgets/post_card/post_author_header.dart';
import 'package:tweakd/features/posts/presentation/widgets/post_card/post_media_carousel.dart';
import 'package:tweakd/features/posts/presentation/widgets/post_card/post_participant_card_view.dart';
import 'package:tweakd/features/posts/presentation/widgets/post_card/post_tags.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import 'tag_static_counters.dart';

/// A tagged post, rendered with the feed card's layout but **display only** —
/// the like / comment / repost / save row is a static preview and the media
/// doesn't zoom, so the whole card stays a single tap target that opens the
/// real post.
class TaggedPostCard extends StatelessWidget {
  final PostEntity post;

  const TaggedPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final caption = post.description?.trim();
    final hasCaption = caption != null && caption.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostAuthorHeader(
          author: post.author,
          createdAt: post.createdAt,
        ),
        if (post.participantCard != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: IgnorePointer(
              child: PostParticipantCardView(
                card: post.participantCard!,
                interactive: false,
              ),
            ),
          )
        else if (post.images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: IgnorePointer(
              child: PostMediaCarousel(
                images: post.images,
                aspectRatio: 16 / 9,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(16),
                peek: true,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TagStaticCounters(
            items: [
              TagCounter(
                icon: post.viewerHasLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: post.viewerHasLiked ? AppColors.accent : AppColors.ink,
                label: post.likesCountEnabled ? '${post.likesCount}' : null,
              ),
              TagCounter(
                icon: Icons.mode_comment_outlined,
                label:
                    post.commentsCountEnabled ? '${post.commentsCount}' : null,
              ),
              TagCounter(
                icon: AppIcons.repost,
                color: post.viewerHasReposted ? AppColors.accent : AppColors.ink,
                label: post.sharesCountEnabled ? '${post.sharesCount}' : null,
              ),
            ],
            trailing: TagCounter(
              icon: post.viewerHasSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: post.viewerHasSaved ? AppColors.accent : AppColors.ink,
              label: post.savedCountEnabled ? '${post.savedCount}' : null,
            ),
          ),
        ),
        if (post.likesCountEnabled && post.likesCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              l10n.postLikesCount(post.likesCount),
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        if (hasCaption)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  color: AppColors.ink2,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: '@${post.author.username} ',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: caption),
                ],
              ),
            ),
          ),
        if (post.taggedCars.isNotEmpty || post.taggedPeople.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: PostTags(people: post.taggedPeople, cars: post.taggedCars),
          ),
        const SizedBox(height: 14),
      ],
    );
  }
}
