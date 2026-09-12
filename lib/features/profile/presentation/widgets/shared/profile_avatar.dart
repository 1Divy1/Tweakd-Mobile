import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// The circular profile picture with its accent ring and verified tick.
///
/// Alignment is the caller's business — the header lays this out at the start
/// of a row, next to the name and stats.
class ProfileAvatar extends StatelessWidget {
  final String avatarUrl;
  final bool isVerified;
  final double size;

  const ProfileAvatar({
    super.key,
    required this.avatarUrl,
    required this.isVerified,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned.fill(child: _AvatarImage(avatarUrl: avatarUrl)),
          if (isVerified)
            const Positioned(right: 0, bottom: 0, child: _VerifiedBadge()),
        ],
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  final String avatarUrl;

  const _AvatarImage({required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final hasUrl = avatarUrl.isNotEmpty;
    // A soft white collar, not an accent ring: in the profile design the only
    // orange on the avatar is the verified tick.
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: hasUrl
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _AvatarPlaceholder(),
              )
            : const _AvatarPlaceholder(),
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
      child: Icon(Icons.person, size: 40, color: AppColors.muteSoft),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 2),
      ),
      child: const Icon(Icons.check, size: 12, color: Colors.white),
    );
  }
}
