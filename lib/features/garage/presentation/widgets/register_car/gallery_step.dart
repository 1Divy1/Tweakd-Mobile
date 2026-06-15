import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import 'editable_image.dart';
import 'register_car_fields.dart';

/// Maximum number of gallery photos surfaced in the UI.
const _maxGalleryPhotos = 8;

/// Step 5 — an optional gallery of supporting shots, laid out as a square grid
/// with an add tile and per-tile remove affordance. The first photo is flagged
/// as the cover that leads the chassis card. Each item is either an existing
/// remote photo or a freshly picked local one ([SlotImage]).
class GalleryStep extends StatelessWidget {
  final List<SlotImage> images;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const GalleryStep({
    super.key,
    required this.images,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final canAddMore = images.length < _maxGalleryPhotos;
    final tileCount = images.length + (canAddMore ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RegisterSectionHeader(
          label: '05 — GALLERY',
          title: 'Show it off',
        ),
        const SizedBox(height: 20),
        const RegisterFieldLabel('PHOTOS', optional: true),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tileCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, i) {
            if (i == images.length) return _AddTile(onTap: onAdd);
            return _GalleryTile(
              image: images[i],
              isCover: i == 0,
              onRemove: () => onRemove(i),
            );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Up to 8 photos. The cover leads your chassis card — drag to reorder.',
          style: TextStyle(
            color: AppColors.mute,
            fontSize: 14,
            height: 1.35,
            fontWeight: FontWeight.w500,
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
      child: DashedRoundedBorder(
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
              const Text(
                'ADD',
                style: TextStyle(
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

class _GalleryTile extends StatelessWidget {
  final SlotImage image;
  final bool isCover;
  final VoidCallback onRemove;

  const _GalleryTile({
    required this.image,
    required this.isCover,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final img = image;
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: switch (img) {
            LocalSlotImage() =>
              Image.file(File(img.image.path), fit: BoxFit.cover),
            RemoteSlotImage() => Image.network(img.url, fit: BoxFit.cover),
          },
        ),
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
        if (isCover)
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'COVER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
