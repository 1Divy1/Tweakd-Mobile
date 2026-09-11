import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/app_pill_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/badge.dart';
import '../widgets/badge_art.dart';

/// Arguments for the `/badge` route: the badge to show.
///
/// The badge entity travels whole (like `FullscreenImageArgs` carries its
/// image list): the catalogue is already in memory wherever this screen is
/// opened from, so there is nothing to fetch.
class BadgeDetailArgs {
  final BadgeEntity badge;

  const BadgeDetailArgs({required this.badge});
}

/// A single badge on its own screen: the artwork blown up, its title, and the
/// "how you get it" copy. Opened by tapping a badge in the profile strip or a
/// row in the all-badges sheet.
///
/// Deliberately bare — no bloc, no scroll chrome beyond an overflow guard. The
/// badge is decorative; this is the "look at it up close" view.
class BadgeDetailPage extends StatelessWidget {
  final BadgeEntity badge;

  const BadgeDetailPage({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: AppPillButton(
                  icon: Icons.close_rounded,
                  onTap: () => context.pop(),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 88, 32, 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Big, but never so big it crowds the copy on a small
                      // phone or at a large text scale.
                      final art = math.min(constraints.maxWidth * 0.5, 184.0);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BadgeArt(badge: badge, size: art),
                          const SizedBox(height: 32),
                          Text(
                            badge.title.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              height: 1.15,
                            ),
                          ),
                          if (badge.description != null) ...[
                            const SizedBox(height: 14),
                            Text(
                              badge.description!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.mute,
                                fontSize: 16,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      );
                    },
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
