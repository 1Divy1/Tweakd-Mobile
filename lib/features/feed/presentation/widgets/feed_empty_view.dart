import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// The feed with nothing in it. On a young network that is likely the first
/// thing a new member sees, so rather than "check back soon" it asks them to
/// be the one who posts.
class FeedEmptyView extends StatelessWidget {
  final VoidCallback onCreatePost;

  const FeedEmptyView({super.key, required this.onCreatePost});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.dynamic_feed_outlined,
                color: AppColors.muteSoft, size: 48),
            const SizedBox(height: 16),
            Text(
              l10n.feedEmptyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.feedEmptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mute,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Semantics(
              button: true,
              child: GestureDetector(
                onTap: onCreatePost,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    l10n.feedEmptyCta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
