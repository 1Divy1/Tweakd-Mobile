import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import 'editable_image.dart';
import 'register_car_fields.dart';
import 'reorderable_photo_tile.dart';

/// Maximum number of gallery photos the wizard accepts.
const maxGalleryPhotos = 15;

/// Final step — all of the car's imagery in one place: the cover photo that
/// leads the chassis card, and the showcase gallery.
///
/// The cover is picked explicitly here; gallery photos are *only* gallery
/// photos and never get promoted to cover on their own. Tiles can be dragged
/// onto one another to reorder them once there is more than one.
class GalleryStep extends StatelessWidget {
  final List<SlotImage> images;

  /// A freshly picked local cover, if any. Takes precedence over
  /// [coverNetworkUrl].
  final String? coverFilePath;

  /// In edit mode, the URL of the existing cover.
  final String? coverNetworkUrl;

  final VoidCallback onPickCover;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  /// Moves the photo at `oldIndex` to `newIndex`.
  final void Function(int oldIndex, int newIndex) onReorder;

  const GalleryStep({
    super.key,
    required this.images,
    required this.coverFilePath,
    required this.coverNetworkUrl,
    required this.onPickCover,
    required this.onAdd,
    required this.onRemove,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canAddMore = images.length < maxGalleryPhotos;
    final tileCount = images.length + (canAddMore ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegisterSectionHeader(title: l10n.garageRegisterGalleryTitle),
        const SizedBox(height: 20),
        // The card is self-evidently the cover — it's the hero image at the
        // top of the step — so it carries no caption.
        _CoverCard(
          filePath: coverFilePath,
          networkUrl: coverNetworkUrl,
          onTap: onPickCover,
        ),
        const SizedBox(height: 24),
        RegisterFieldLabel(l10n.garageFieldGallery),
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
            return ReorderablePhotoTile(
              index: i,
              // Dragging a lone photo has nowhere to go.
              enabled: images.length > 1,
              onReorder: onReorder,
              feedback: SizedBox(
                width: 96,
                height: 106,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(kRegisterRadius),
                  child: slotImageWidget(images[i]),
                ),
              ),
              child: _GalleryTile(
                image: images[i],
                onRemove: () => onRemove(i),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          l10n.garageGalleryHint,
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

/// The hero cover card. Doubles as the picker affordance whether or not a
/// photo has been chosen yet.
class _CoverCard extends StatelessWidget {
  final String? filePath;
  final String? networkUrl;
  final VoidCallback onTap;

  const _CoverCard({
    required this.filePath,
    required this.networkUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // A freshly picked local file always wins over an existing remote cover.
    final ImageProvider? image = filePath != null
        ? FileImage(File(filePath!))
        : (networkUrl != null ? NetworkImage(networkUrl!) : null);
    final hasImage = image != null;

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(kRegisterRadius),
            image: hasImage
                ? DecorationImage(image: image, fit: BoxFit.cover)
                : null,
            boxShadow: hasImage
                ? [
                    BoxShadow(
                      color: AppColors.shadowAlpha(28),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : kRegisterSurfaceShadow,
          ),
          child: hasImage ? _replaceAffordance() : _emptyPrompt(context),
        ),
      ),
    );
  }

  Widget _replaceAffordance() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(235),
            borderRadius: BorderRadius.circular(kRegisterRadius),
          ),
          child: Icon(Icons.photo_camera_rounded,
              color: AppColors.onLight, size: 20),
        ),
      ),
    );
  }

  Widget _emptyPrompt(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // The card is a fixed 16:10 box, so the prompt scales down rather than
    // spilling out of it once text scaling is turned up.
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: RegisterFitted(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(kRegisterRadius),
                ),
                child: Icon(Icons.add_a_photo_rounded,
                    color: AppColors.accent, size: 26),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.garageAddCoverPhoto,
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.garagePickFromGallery,
                style: TextStyle(color: AppColors.mute, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return RegisterAddSurface(
      onTap: onTap,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: RegisterFitted(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(kRegisterRadius),
                  ),
                  child: Icon(Icons.photo_camera_rounded,
                      color: AppColors.accent, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.garageGalleryAdd,
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
      ),
    );
  }
}

/// Renders either kind of [SlotImage] — a freshly picked local file or an
/// existing remote photo.
Widget slotImageWidget(SlotImage image) => switch (image) {
      LocalSlotImage() => Image.file(File(image.image.path), fit: BoxFit.cover),
      RemoteSlotImage() => Image.network(image.url, fit: BoxFit.cover),
    };

class _GalleryTile extends StatelessWidget {
  final SlotImage image;
  final VoidCallback onRemove;

  const _GalleryTile({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(kRegisterRadius),
          child: slotImageWidget(image),
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
                borderRadius: BorderRadius.circular(kRegisterRadius),
              ),
              child: const Icon(Icons.close_rounded,
                  size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
