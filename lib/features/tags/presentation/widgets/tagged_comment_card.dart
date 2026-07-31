import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:car_social_media_app/features/posts/domain/entities/post.dart';
import 'package:car_social_media_app/features/posts/domain/entities/post_comment.dart';
import 'package:car_social_media_app/features/posts/presentation/widgets/post_card/post_tags.dart';
import 'package:car_social_media_app/features/posts/presentation/widgets/post_detail/post_time.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import 'tag_static_counters.dart';

/// A tagged comment: a compact strip for the post it lives on (cover thumbnail
/// + author), then the comment itself in the same shape the comments sheet
/// uses. Display only — tapping anywhere opens the parent post.
class TaggedCommentCard extends StatelessWidget {
  final PostEntity post;
  final PostCommentEntity comment;

  const TaggedCommentCard({
    super.key,
    required this.post,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final coverUrl = post.images.isNotEmpty ? post.images.first.imageUrl : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Row(
            children: [
              _CoverThumb(url: coverUrl),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.tagsOnPostBy(post.author.username),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.mute,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
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
                  Flexible(
                    child: Text(
                      '@${comment.author.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '  ·  ${postTimeAgo(l10n, comment.createdAt)}',
                    style: const TextStyle(
                      color: AppColors.mute,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                comment.content ?? '',
                style: const TextStyle(
                  color: AppColors.ink2,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              if (comment.taggedPeople.isNotEmpty ||
                  comment.taggedCars.isNotEmpty) ...[
                const SizedBox(height: 10),
                PostTags(
                  people: comment.taggedPeople,
                  cars: comment.taggedCars,
                ),
              ],
              const SizedBox(height: 10),
              TagStaticCounters(
                dense: true,
                items: [
                  TagCounter(
                    icon: comment.viewerHasLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: comment.viewerHasLiked
                        ? AppColors.accent
                        : AppColors.mute,
                    label: '${comment.likeCount}',
                  ),
                  if (comment.replyCount > 0)
                    TagCounter(
                      icon: Icons.mode_comment_outlined,
                      color: AppColors.mute,
                      label: '${comment.replyCount}',
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverThumb extends StatelessWidget {
  final String? url;

  const _CoverThumb({required this.url});

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.line2,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.hardEdge,
      child: imageUrl == null
          ? const Icon(Icons.image_outlined, size: 18, color: AppColors.muteSoft)
          : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => const ColoredBox(color: AppColors.line2),
              errorWidget: (_, _, _) => const Icon(
                Icons.image_outlined,
                size: 18,
                color: AppColors.muteSoft,
              ),
            ),
    );
  }
}
