import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tweakd/core/theme/app_icons.dart';

import '../../../../../core/shared/widgets/app_avatar.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import 'create_post_fields.dart';
import 'post_photo.dart';
import 'visibility_step.dart';

/// Step 5 — a faithful preview of how the post lands in the feed, built from the
/// choices made on the earlier steps.
class ReviewStep extends StatelessWidget {
  final List<PostPhoto> photos;
  final String caption;
  final PostVisibility visibility;
  final String authorName;
  final String? authorAvatarUrl;

  const ReviewStep({
    super.key,
    required this.photos,
    required this.caption,
    required this.visibility,
    required this.authorName,
    this.authorAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostStepHeader(
          title: l10n.postReviewTitle,
          subtitle: l10n.postReviewSubtitle,
        ),
        const SizedBox(height: 24),
        _FeedPreviewCard(
          photos: photos,
          caption: caption,
          visibility: visibility,
          authorName: authorName,
          authorAvatarUrl: authorAvatarUrl,
        ),
      ],
    );
  }
}

class _FeedPreviewCard extends StatelessWidget {
  final List<PostPhoto> photos;
  final String caption;
  final PostVisibility visibility;
  final String authorName;
  final String? authorAvatarUrl;

  const _FeedPreviewCard({
    required this.photos,
    required this.caption,
    required this.visibility,
    required this.authorName,
    required this.authorAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(kPostRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowAlpha(12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            authorName: authorName,
            authorAvatarUrl: authorAvatarUrl,
            justNow: l10n.postReviewJustNow,
          ),
          _Media(photos: photos),
          _Actions(visibility: visibility),
          if (caption.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
              child: _Caption(author: authorName, caption: caption.trim()),
            )
          else
            const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String authorName;
  final String? authorAvatarUrl;
  final String justNow;

  const _Header({
    required this.authorName,
    required this.authorAvatarUrl,
    required this.justNow,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Row(
        children: [
          AppAvatar(size: 42, url: authorAvatarUrl, name: authorName),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      authorName,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  justNow,
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
          Icon(Icons.more_horiz_rounded, color: AppColors.mute),
        ],
      ),
    );
  }
}

class _Media extends StatefulWidget {
  final List<PostPhoto> photos;
  const _Media({required this.photos});

  @override
  State<_Media> createState() => _MediaState();
}

class _MediaState extends State<_Media> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _photo(PostPhoto photo) => switch (photo) {
        LocalPostPhoto(:final path) =>
          Image.file(File(path), fit: BoxFit.cover),
        RemotePostPhoto(:final url) =>
          CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
      };

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    if (photos.isEmpty) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          color: AppColors.bg,
          child: Center(
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
            itemCount: photos.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _photo(photos[i]),
          ),
          if (photos.length > 1)
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
                  '${_page + 1} / ${photos.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          if (photos.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: _PageDots(count: photos.length, active: _page),
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
    final shown = count.clamp(0, 5);
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
  final PostVisibility visibility;
  const _Actions({required this.visibility});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          _ActionItem(
            icon: Icons.favorite_border_rounded,
            // A brand-new post starts with zero engagement; the number is only
            // shown when its counter is set to visible.
            label: visibility.showLikes ? '0' : null,
          ),
          const SizedBox(width: 20),
          const _ActionItem(icon: Icons.mode_comment_outlined),
          const SizedBox(width: 20),
          _ActionItem(
            icon: AppIcons.repost,
            label: visibility.showShares ? '0' : null,
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String? label;

  const _ActionItem({required this.icon, this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: AppColors.ink),
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
