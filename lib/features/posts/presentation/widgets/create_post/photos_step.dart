import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import 'create_post_fields.dart';
import 'post_photo.dart';

/// Maximum number of photos a single post can carry.
const postMaxPhotos = 10;

/// Step 1 — pick and order the post's photos. Laid out as a square grid with an
/// add tile; the first photo leads the post as the cover. Tiles can be
/// long-press dragged onto one another to reorder.
class PhotosStep extends StatelessWidget {
  final List<PostPhoto> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;

  const PhotosStep({
    super.key,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canAddMore = photos.length < postMaxPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostStepHeader(
          title: l10n.postPhotosTitle,
          subtitle: l10n.postPhotosSubtitle,
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 12.0;
            final tileSize = (constraints.maxWidth - spacing * 2) / 3;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (var i = 0; i < photos.length; i++)
                  SizedBox(
                    width: tileSize,
                    height: tileSize,
                    child: _DraggablePhotoTile(
                      index: i,
                      photo: photos[i],
                      isCover: i == 0,
                      onRemove: () => onRemove(i),
                      onReorder: onReorder,
                    ),
                  ),
                if (canAddMore)
                  SizedBox(
                    width: tileSize,
                    height: tileSize,
                    child: _AddTile(onTap: onAdd),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        // A Wrap, so the two notes stack rather than collide on a narrow
        // screen or at a large text scale.
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          runSpacing: 4,
          children: [
            Text(
              l10n.postPhotosCount(photos.length, postMaxPhotos),
              style: TextStyle(
                color: AppColors.mute,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              l10n.postPhotosVideosSoon,
              style: TextStyle(
                color: AppColors.muteSoft,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A photo tile that is both a drag source (carrying its index) and a drop
/// target (reordering when another tile lands on it).
class _DraggablePhotoTile extends StatelessWidget {
  final int index;
  final PostPhoto photo;
  final bool isCover;
  final VoidCallback onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;

  const _DraggablePhotoTile({
    required this.index,
    required this.photo,
    required this.isCover,
    required this.onRemove,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final tile = _PhotoTile(
      photo: photo,
      isCover: isCover,
      position: index + 1,
      onRemove: onRemove,
    );

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != index,
      onAcceptWithDetails: (details) => onReorder(details.data, index),
      builder: (context, candidate, rejected) {
        return LongPressDraggable<int>(
          data: index,
          feedback: Material(
            color: Colors.transparent,
            child: Opacity(
              opacity: 0.9,
              child: SizedBox.square(
                dimension: _tileDimension(context),
                child: tile,
              ),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: tile),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 120),
            scale: candidate.isNotEmpty ? 1.05 : 1,
            child: tile,
          ),
        );
      },
    );
  }

  /// The dragged feedback needs an explicit size since it floats outside the
  /// grid's layout. Falls back to the parent's width.
  double _tileDimension(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    return box?.size.width ?? 100;
  }
}

class _PhotoTile extends StatelessWidget {
  final PostPhoto photo;
  final bool isCover;
  final int position;
  final VoidCallback onRemove;

  const _PhotoTile({
    required this.photo,
    required this.isCover,
    required this.position,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(kPostRadius),
          child: switch (photo) {
            LocalPostPhoto(:final path) =>
              Image.file(File(path), fit: BoxFit.cover),
            RemotePostPhoto(:final url) =>
              CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
          },
        ),
        // Remove (top-right).
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(140),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // Cover badge / position number (bottom-left).
        Positioned(
          left: 8,
          bottom: 8,
          child: isCover
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(140),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.postPhotosCover,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                )
              : Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(140),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      position.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PostAddSurface(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          // The tile is a third of the screen wide; at a large text scale the
          // label shrinks to fit rather than spilling out of it.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_photo_alternate_rounded,
                  color: AppColors.muteSoft,
                  size: 26,
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context)!.postPhotosAdd,
                  style: TextStyle(
                    color: AppColors.mute,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
