import 'package:flutter/material.dart';

import '../../../../../core/shared/widgets/app_shimmer.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// Skeleton cards shown while the first page loads.
class FeedbackFeedLoadingView extends StatelessWidget {
  const FeedbackFeedLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) => const _CardSkeleton(),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Bone(width: 36, height: 36, radius: 18),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bone(width: 110, height: 12),
                    SizedBox(height: 6),
                    _Bone(width: 60, height: 10),
                  ],
                ),
                Spacer(),
                _Bone(width: 70, height: 20, radius: 999),
              ],
            ),
            SizedBox(height: 14),
            _Bone(width: double.infinity, height: 12),
            SizedBox(height: 8),
            _Bone(width: 220, height: 12),
            SizedBox(height: 16),
            Row(
              children: [
                _Bone(width: 74, height: 38, radius: 12),
                SizedBox(width: 8),
                _Bone(width: 74, height: 38, radius: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _Bone({required this.width, required this.height, this.radius = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.line2,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Full-section error state with a retry action.
class FeedbackFeedErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const FeedbackFeedErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: AppColors.muteSoft,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mute,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: Text(l10n.feedbackFeedRetry),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state for both lists — the board and the completed screen pass their
/// own copy.
class FeedbackFeedEmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const FeedbackFeedEmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.muteSoft, size: 42),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mute,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The trailing loader under a paginated list.
class FeedbackFeedListFooter extends StatelessWidget {
  final bool isLoadingMore;

  const FeedbackFeedListFooter({super.key, required this.isLoadingMore});

  @override
  Widget build(BuildContext context) {
    if (!isLoadingMore) return const SizedBox(height: 8);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}
