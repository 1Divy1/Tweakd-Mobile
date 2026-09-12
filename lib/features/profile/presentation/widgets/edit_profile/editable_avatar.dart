import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// Circular avatar with a "change photo" affordance. Shows an instant local
/// preview ([localPreviewPath]) while the picked image uploads, with a spinner
/// overlay during [isUploading].
class EditableAvatar extends StatelessWidget {
  final String avatarUrl;
  final String? localPreviewPath;
  final bool isUploading;
  final VoidCallback onTap;
  final double size;

  const EditableAvatar({
    super.key,
    required this.avatarUrl,
    required this.onTap,
    this.localPreviewPath,
    this.isUploading = false,
    this.size = 124,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                Positioned.fill(child: _image()),
                if (isUploading)
                  Positioned.fill(child: _uploadingOverlay()),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _CameraBadge(onTap: isUploading ? null : onTap),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: isUploading ? null : onTap,
          child: Text(
            l10n.editProfileChangePhoto,
            style: TextStyle(
              color: isUploading ? AppColors.muteSoft : AppColors.accent,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _image() {
    final Widget child;
    if (localPreviewPath != null) {
      child = Image.file(
        File(localPreviewPath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => const _AvatarPlaceholder(),
      );
    } else if (avatarUrl.isNotEmpty) {
      child = Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => const _AvatarPlaceholder(),
      );
    } else {
      child = const _AvatarPlaceholder();
    }

    return ClipOval(child: child);
  }

  Widget _uploadingOverlay() {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(90),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _CameraBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const _CameraBadge({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.bg, width: 3),
        ),
        child: const Icon(Icons.camera_alt_rounded, size: 17, color: Colors.white),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.line2,
      child: Icon(Icons.person, size: 56, color: AppColors.muteSoft),
    );
  }
}
