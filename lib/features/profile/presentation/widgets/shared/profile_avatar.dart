import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String avatarUrl;
  final bool isVerified;
  final double size;

  const ProfileAvatar({
    super.key,
    required this.avatarUrl,
    required this.isVerified,
    this.size = 124,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Positioned.fill(child: _AvatarImage(avatarUrl: avatarUrl)),
            if (isVerified)
              const Positioned(
                right: 0,
                bottom: 0,
                child: _VerifiedBadge(),
              ),
          ],
        ),
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
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent, width: 3),
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
      child: const Icon(Icons.person, size: 56, color: AppColors.muteSoft),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.bg, width: 2),
      ),
      child: const Icon(Icons.check, size: 16, color: Colors.white),
    );
  }
}
