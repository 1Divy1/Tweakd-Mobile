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
/// to render. Shows at most [_maxVisible] of them plus a trailing slot that
/// opens the full sheet, so the strip is always the same width and never wraps.
class BadgeStrip extends StatelessWidget {
  /// Earned badges, newest unlock first — straight off `ProfileEntity.badges`.
  final List<UserBadgeEntity> badges;

  /// True on your own profile. Only there does the sheet have a locked
  /// section: the backend has no public equivalent of `/badges/me/locked`.
  final bool isOwner;

  const BadgeStrip({super.key, required this.badges, required this.isOwner});

  /// Four badges + the "all" slot fills the row edge to edge on a small phone.
  static const _maxVisible = 4;

  /// Slots the row is laid out for, visible or not, so a profile with two
  /// badges draws them at the same size as one with nine.
  static const _slots = _maxVisible + 1;

  /// Widest a slot is allowed to get. On a tablet the row would otherwise
  /// spread five circles across 600pt, leaving them stranded in white space;
  /// capped, the strip stays a group aligned with the header above it. Kept a
  /// gutter above the diameter ceiling so the circles never touch.
  static const _maxSlot = 92.0;

  @override
  Widget build(BuildContext context) {
    // A visitor with nothing to show gets no strip. The owner keeps the "all"
    // slot even at zero, so a new account can still see what's out there.
    if (badges.isEmpty && !isOwner) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slot = math.min(constraints.maxWidth / _slots, _maxSlot);
          final diameter = (slot - 8).clamp(40.0, 72.0);
          final visible = badges.take(_maxVisible).toList();

          void openSheet() =>
              showAllBadgesSheet(context, earned: badges, isOwner: isOwner);

          void openBadge(UserBadgeEntity entry) => context.push(
            '/badge',
            extra: BadgeDetailArgs(badge: entry.badge),
          );

          return Row(
            children: [
              for (final entry in visible)
                SizedBox(
                  width: slot,
                  child: Center(
                    child: BadgeCircle(
                      badge: entry.badge,
                      diameter: diameter,
                      onTap: () => openBadge(entry),
                    ),
                  ),
                ),
              SizedBox(
                width: slot,
                child: Center(
                  child: BadgeOverflowCircle(
                    hiddenCount: badges.length - visible.length,
                    diameter: diameter,
                    label: AppLocalizations.of(context)!.profileBadgesAll,
                    onTap: openSheet,
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
