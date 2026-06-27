import 'dart:io';

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
        PostSectionHeader(
          label: '01 — ${l10n.postStepPhotos}',
          title: l10n.postPhotosTitle,
          subtitle: l10n.postPhotosSubtitle,
        ),
        const SizedBox(height: 20),
        const PostFieldLabel('SELECTED'),
        const SizedBox(height: 12),
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
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.postPhotosCount(photos.length, postMaxPhotos),
              style: const TextStyle(
                color: AppColors.mute,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
            Text(
              l10n.postPhotosVideosSoon,
              style: const TextStyle(
                color: AppColors.muteSoft,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
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
          borderRadius: BorderRadius.circular(16),
          child: switch (photo) {
            LocalPostPhoto(:final path) =>
              Image.file(File(path), fit: BoxFit.cover),
            RemotePostPhoto(:final url) =>
              Image.network(url, fit: BoxFit.cover),
          },
        ),
        // Drag handle affordance (top-left).
        Positioned(
          top: 6,
          left: 6,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(120),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.drag_indicator_rounded,
                size: 16, color: Colors.white),
          ),
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
              child: const Icon(Icons.close_rounded,
                  size: 16, color: Colors.white),
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
                    color: AppColors.accent,
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
    return GestureDetector(
      onTap: onTap,
      child: _DashedBox(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.photo_camera_rounded,
                    color: AppColors.accent, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.postPhotosAdd,
                style: const TextStyle(
                  color: AppColors.mute,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints a dashed rounded border around the add tile.
class _DashedBox extends StatelessWidget {
  final Widget child;
  const _DashedBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.muteSoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(16),
    );
    final path = Path()..addRRect(rrect);

    const dash = 7.0;
    const gap = 5.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
