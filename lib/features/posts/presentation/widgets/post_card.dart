import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/post.dart';

/// A single tile in a posts grid (the profile Posts tab, the Saved Posts page):
/// the post's cover image cropped to fill a square cell, edge to edge with no
/// border or rounded corners. A stacked-squares glyph sits in the top-right
/// corner when the post holds more than one image, or a trophy when it shares a
/// participant card (whose car cover stands in for the missing image). Tapping
/// opens the post.
class PostCard extends StatelessWidget {
  final PostEntity post;
  final VoidCallback onTap;

  const PostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // A participant-card post carries no images; its car's cover stands in.
    final card = post.participantCard;
    final coverUrl = post.images.isNotEmpty
        ? post.images.first.imageUrl
        : card?.car.coverImage?.url;

    return GestureDetector(
      onTap: onTap,
      child: ColoredBox(
        color: AppColors.bg,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (coverUrl != null)
              CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => const ColoredBox(color: AppColors.bg),
                errorWidget: (_, _, _) => const _PlaceholderTile(),
              )
            else
              const _PlaceholderTile(),
            if (card != null)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 16,
                  shadows: [
                    Shadow(color: Colors.black45, blurRadius: 4),
                  ],
                ),
              )
            else if (post.images.length > 1)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.filter_none,
                  color: Colors.white,
                  size: 16,
                  shadows: [
                    Shadow(color: Colors.black45, blurRadius: 4),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTile extends StatelessWidget {
  const _PlaceholderTile();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.bg,
      child: Center(
        child: Icon(Icons.image_outlined, color: AppColors.muteSoft, size: 32),
      ),
    );
  }
}
