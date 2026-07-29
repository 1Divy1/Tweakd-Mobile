import 'package:flutter/material.dart';

import 'package:car_social_media_app/features/garage/domain/entities/reference_data.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../utils/forum_format.dart';

/// A brand tile on the "By car" browse tab: two-letter monogram + name.
/// The thread count renders only when the backend starts providing one.
class ForumBrandCard extends StatelessWidget {
  final CarBrandEntity brand;
  final int? threadCount;
  final VoidCallback onTap;

  const ForumBrandCard({
    super.key,
    required this.brand,
    this.threadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final monogram = brand.name.length >= 2
        ? brand.name.substring(0, 2).toUpperCase()
        : brand.name.toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                monogram,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Spacer(),
            Text(
              brand.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (threadCount != null) ...[
              const SizedBox(height: 2),
              Text(
                l10n.forumsThreadsCount(threadCount!)
                    .replaceFirst('$threadCount', forumCompactCount(threadCount!)),
                style: const TextStyle(
                  color: AppColors.mute,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
