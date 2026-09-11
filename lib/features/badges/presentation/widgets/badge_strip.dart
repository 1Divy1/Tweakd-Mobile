import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user_badge.dart';
import '../pages/badge_detail_page.dart';
import 'all_badges_sheet.dart';
import 'badge_circle.dart';

/// The row of achievement badges under the profile actions.
///
/// The badges come embedded in the profile payload, so this widget is handed a
/// list rather than watching a bloc — there is no loading or error state for it
/// to render. The row is laid out for [_slots] circles: up to that many badges
/// are drawn outright, and only a collection that doesn't fit gives up the last
/// slot to an "all" button opening the full sheet.
class BadgeStrip extends StatelessWidget {
  /// Earned badges, newest unlock first — straight off `ProfileEntity.badges`.
  final List<UserBadgeEntity> badges;

  const BadgeStrip({super.key, required this.badges});

  /// Slots the row is laid out for, filled or not, so a profile with two
  /// badges draws them at the same size as one with nine. Five circles fill
  /// the row edge to edge on a small phone.
  static const _slots = 5;

  /// Widest a slot is allowed to get. On a tablet the row would otherwise
  /// spread five circles across 600pt, leaving them stranded in white space;
  /// capped, the strip stays a group aligned with the header above it. Kept a
  /// gutter above the diameter ceiling so the circles never touch.
  static const _maxSlot = 92.0;

  @override
  Widget build(BuildContext context) {
    // Nothing earned, nothing to show. There is no locked catalogue to browse,
    // so an empty strip has nothing to offer even on your own profile.
    if (badges.isEmpty) return const SizedBox.shrink();

    // Everything fits, or the last slot becomes the "all" button.
    final overflowing = badges.length > _slots;
    final visible = badges.take(overflowing ? _slots - 1 : _slots).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slot = math.min(constraints.maxWidth / _slots, _maxSlot);
          final diameter = (slot - 8).clamp(40.0, 72.0);

          return Row(
            children: [
              for (final entry in visible)
                SizedBox(
                  width: slot,
                  child: Center(
                    child: BadgeCircle(
                      badge: entry.badge,
                      diameter: diameter,
                      onTap: () => context.push(
                        '/badge',
                        extra: BadgeDetailArgs(badge: entry.badge),
                      ),
                    ),
                  ),
                ),
              if (overflowing)
                SizedBox(
                  width: slot,
                  child: Center(
                    child: BadgeOverflowCircle(
                      hiddenCount: badges.length - visible.length,
                      diameter: diameter,
                      label: AppLocalizations.of(context)!.profileBadgesAll,
                      onTap: () => showAllBadgesSheet(context, earned: badges),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
