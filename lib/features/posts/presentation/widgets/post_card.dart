import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/post.dart';

/// A single tile in the profile Posts grid: the post's cover image with a
/// multi-image indicator when the post is a carousel. Tapping opens the post.
class PostCard extends StatelessWidget {
  final PostEntity post;
  final VoidCallback onTap;

  const PostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final coverUrl = post.images.isNotEmpty ? post.images.first.imageUrl : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        clipBehavior: Clip.hardEdge,
        child: AspectRatio(
          aspectRatio: 4 / 5,
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
              if (post.images.length > 1)
                const Positioned(
                  top: 10,
                  right: 10,
                  child: Icon(
                    Icons.collections_rounded,
                    color: Colors.white,
                    size: 20,
                    shadows: [
                      Shadow(color: Colors.black54, blurRadius: 6),
                    ],
                  ),
                ),
            ],
          ),
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
