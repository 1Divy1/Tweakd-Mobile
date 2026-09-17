import 'package:flutter/material.dart';
import 'package:tweakd/core/theme/app_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../posts/domain/entities/post.dart';
import '../../../posts/presentation/widgets/post_card/post_author_header.dart';
import '../../../posts/presentation/widgets/post_card/post_media_carousel.dart';
import '../../../posts/presentation/widgets/post_card/post_participant_card_view.dart';
import '../../../posts/presentation/widgets/post_card/post_reposted_by.dart';
import '../../../posts/presentation/widgets/post_card/post_tags.dart';

/// A single post in the feed, styled after the Tweakd feed design: a "reposted
/// by" line when someone the viewer follows reposted it, an author header, a pinch-zoomable image carousel, the action row, an "x likes" line
/// (opens the likers list), the caption, tagged cars and people, and an inline
/// comment composer. The media can be zoomed in place; the comment icon opens
/// the comments sheet; the heart toggles the viewer's like inline. Tapping
/// empty space does nothing.
class FeedPostCard extends StatelessWidget {
  final PostEntity post;
  final VoidCallback onToggleLike;
  final VoidCallback onToggleSave;
  /// Null on the viewer's own post: the repost count still shows, but a post
  /// can't be reposted by its author.
  final VoidCallback? onToggleRepost;
  final VoidCallback onOpenComments;
  final VoidCallback onOpenLikers;
  final ValueChanged<String> onSubmitComment;
  final VoidCallback onMenu;

  const FeedPostCard({
    super.key,
    required this.post,
    required this.onToggleLike,
    required this.onToggleSave,
    this.onToggleRepost,
    required this.onOpenComments,
    required this.onOpenLikers,
    required this.onSubmitComment,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasCaption =
        post.description != null && post.description!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.repostedBy != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: PostRepostedBy(repostedBy: post.repostedBy!),
            ),
          PostAuthorHeader(
            author: post.author,
            createdAt: post.createdAt,
            onMenu: onMenu,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            // A participant-card post carries the card instead of images.
            child: post.participantCard != null
                ? PostParticipantCardView(card: post.participantCard!)
                : PostMediaCarousel(
                    images: post.images,
                    aspectRatio: 16 / 9,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(16),
                    peek: true,
                    enableZoom: true,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _Counter(
                  icon: post.viewerHasLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: post.viewerHasLiked ? AppColors.accent : AppColors.ink,
                  onTap: onToggleLike,
                ),
                const SizedBox(width: 20),
                _Counter(
                  icon: Icons.mode_comment_outlined,
                  color: AppColors.ink,
                  label:
                      post.commentsCountEnabled ? '${post.commentsCount}' : null,
                  onTap: onOpenComments,
                ),
                const SizedBox(width: 20),
                _Counter(
                  icon: AppIcons.repost,
                  color: post.viewerHasReposted
                      ? AppColors.accent
                      : onToggleRepost == null
                      ? AppColors.muteSoft
                      : AppColors.ink,
                  label: post.sharesCountEnabled ? '${post.sharesCount}' : null,
                  onTap: onToggleRepost,
                ),
                const Spacer(),
                _Counter(
                  icon: post.viewerHasSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: post.viewerHasSaved ? AppColors.accent : AppColors.ink,
                  label: post.savedCountEnabled ? '${post.savedCount}' : null,
                  onTap: onToggleSave,
                ),
              ],
            ),
          ),
          if (post.likesCountEnabled && post.likesCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onOpenLikers,
                child: Text(
                  l10n.postLikesCount(post.likesCount),
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          if (hasCaption)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _Caption(
                author: post.author.username,
                caption: post.description!.trim(),
              ),
            ),
          if (post.taggedCars.isNotEmpty || post.taggedPeople.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: PostTags(
                people: post.taggedPeople,
                cars: post.taggedCars,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 4),
            child: _CommentComposer(onSubmit: onSubmitComment),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? label;
  final VoidCallback? onTap;

  const _Counter({
    required this.icon,
    required this.color,
    required this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: color),
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

/// Instagram-style inline comment input: a "add a comment…" field whose send
/// button appears at the trailing edge only once at least one character is
/// typed. Submitting posts the comment and clears the field.
class _CommentComposer extends StatefulWidget {
  final ValueChanged<String> onSubmit;

  const _CommentComposer({required this.onSubmit});

  @override
  State<_CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<_CommentComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            cursorColor: AppColors.accent,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _submit(),
            minLines: 1,
            maxLines: 4,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: l10n.postCommentHint,
              hintStyle: TextStyle(
                color: AppColors.muteSoft,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
          ),
        ),
        // The send button only shows once there is something to send.
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (_, value, _) {
            if (value.text.trim().isEmpty) return const SizedBox(width: 4);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _submit,
              child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.arrow_upward_rounded,
                    color: AppColors.accent, size: 22),
              ),
            );
          },
        ),
      ],
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
            text: '@$author ',
            style: TextStyle(
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
