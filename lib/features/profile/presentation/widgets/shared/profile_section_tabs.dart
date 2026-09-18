import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../l10n/app_localizations.dart';

/// The sections a profile body can show. Garage is the default (left) tab —
/// the cars are what a profile is for — then Posts, Reposts (other people's
/// posts this user put in front of their followers), Tags (everything this
/// user, or one of their cars, was tagged in elsewhere) and, on your own
/// profile only, Events.
enum ProfileSection { garage, posts, reposts, tags, events }

/// The section switcher shown between the profile header and the active
/// section. Only one section is visible at a time.
///
/// [showEvents] is false on someone else's profile: `GET /map-events/mine` is
/// scoped to the caller, so there is no such thing as another user's events
/// list to show.
class ProfileSectionTabs extends StatelessWidget {
  final ProfileSection active;
  final ValueChanged<ProfileSection> onChanged;
  final bool showEvents;

  const ProfileSectionTabs({
    super.key,
    required this.active,
    required this.onChanged,
    this.showEvents = false,
  });

  /// Past this the row stops growing with the user's text size. It lives in a
  /// pinned sliver of a fixed height, and beyond this cap the tabs would
  /// outgrow the band the header reserves for them.
  /// `ProfileTabsSliverHeader.heightFor` reads [heightFor], so the two can
  /// never disagree.
  static const maxTextScale = 1.3;

  /// Matches the 20pt inset every other profile widget uses, so the first tab
  /// lines up with the header above it.
  static const _inset = 20.0;

  static const _labelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
  );

  /// Kept tight on purpose: these three numbers are most of the budget that
  /// decides whether four labelled tabs still fit across a phone. See
  /// [_labelsFit].
  static const _iconLabelGap = 6.0;
  static const _labelPadding = 6.0;
  static const _minTabGap = 8.0;

  /// The skirt around a bare icon, so its underline still reads as a bar. Flat
  /// rather than a multiple of the icon: four icons that each grew their own
  /// padding with the text scale overflowed a 320pt row at 1.3x.
  static const _iconOnlyPadding = 16.0;

  /// Breathing room above and below the tab content, plus the active
  /// underline underneath it.
  static const _verticalPadding = 14.0;
  static const underlineWidth = 2.0;

  static double _scale(BuildContext context) {
    return math.min(MediaQuery.textScalerOf(context).scale(1), maxTextScale);
  }

  static double iconSizeFor(BuildContext context) => 18 * _scale(context);

  /// The tallest thing a tab draws: the icon, or the label's line box when the
  /// text is the taller of the two. Every tab is forced to exactly this, so the
  /// row's height is known before it is laid out.
  static double contentHeightFor(BuildContext context) {
    final scale = _scale(context);
    return math.max(18, _labelStyle.fontSize! * 1.35) * scale;
  }

  /// The band the whole row occupies, underline included.
  static double heightFor(BuildContext context) {
    return _verticalPadding * 2 + contentHeightFor(context) + underlineWidth;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = <_TabSpec>[
      _TabSpec(Icons.house, l10n.profileTabGarage, ProfileSection.garage),
      _TabSpec(
        Icons.grid_on_rounded,
        l10n.profileTabPosts,
        ProfileSection.posts,
      ),
      _TabSpec(AppIcons.repost, l10n.profileTabReposts, ProfileSection.reposts),
      _TabSpec(Icons.sell_rounded, l10n.profileTabTags, ProfileSection.tags),
      if (showEvents)
        _TabSpec(
          Icons.event_rounded,
          l10n.profileTabEvents,
          ProfileSection.events,
        ),
    ];

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: maxTextScale,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _inset),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final iconSize = iconSizeFor(context);
            final showLabels = _labelsFit(
              tabs,
              available: constraints.maxWidth,
              iconSize: iconSize,
              scaler: TextScaler.linear(_scale(context)),
            );
            return Row(
              // The tabs spread from inset to inset: the first one's underline
              // starts where the display name above it does, the last one's
              // ends at the opposite margin. Flexible, not Expanded — an equal
              // share centres its content and stretches the underline across a
              // third of the screen, which is not what an underline means.
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final tab in tabs)
                  Flexible(
                    child: _Tab(
                      icon: tab.icon,
                      label: tab.label,
                      iconSize: iconSize,
                      contentHeight: contentHeightFor(context),
                      showLabel: showLabels,
                      isActive: active == tab.section,
                      onTap: () => onChanged(tab.section),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Whether every label can be drawn in full, with a gap left between tabs.
  ///
  /// Measured rather than guessed: "Evenimente" is twice the length of
  /// "Events", and four labelled tabs are already snug on a small phone. When
  /// they don't fit, the row falls back to icons alone rather than ellipsising
  /// every label into a stump — the label survives as the icon's screen-reader
  /// name either way.
  static bool _labelsFit(
    List<_TabSpec> tabs, {
    required double available,
    required double iconSize,
    required TextScaler scaler,
  }) {
    var needed = _minTabGap * (tabs.length - 1);
    for (final tab in tabs) {
      final painter = TextPainter(
        text: TextSpan(text: tab.label, style: _labelStyle),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout();
      needed += painter.width + iconSize + _iconLabelGap + _labelPadding * 2;
      painter.dispose();
    }
    return needed <= available;
  }
}

class _TabSpec {
  final IconData icon;
  final String label;
  final ProfileSection section;

  const _TabSpec(this.icon, this.label, this.section);
}

class _Tab extends StatelessWidget {
  final IconData icon;

  /// Drawn beside the icon when [showLabel] is true; either way it is the
  /// tab's accessible name.
  final String label;
  final bool showLabel;
  final double iconSize;
  final double contentHeight;
  final bool isActive;
  final VoidCallback onTap;

  const _Tab({
    required this.icon,
    required this.label,
    required this.showLabel,
    required this.iconSize,
    required this.contentHeight,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.ink : AppColors.muteSoft;
    // The underlined box hugs the tab's own content — icon, gap, label — so
    // the underline reads as belonging to that tab rather than to a slice of
    // the row. Bottom-aligned, which lands it on the header's hairline.
    return Semantics(
      label: label,
      button: true,
      selected: isActive,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: ProfileSectionTabs._verticalPadding,
            // An icon-only tab gets a wider skirt, so its underline still
            // reads as a bar rather than a tick under an 18pt glyph.
            horizontal: showLabel
                ? ProfileSectionTabs._labelPadding
                : ProfileSectionTabs._iconOnlyPadding,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.ink : Colors.transparent,
                width: ProfileSectionTabs.underlineWidth,
              ),
            ),
          ),
          child: SizedBox(
            height: contentHeight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: iconSize, color: color),
                if (showLabel) ...[
                  const SizedBox(width: ProfileSectionTabs._iconLabelGap),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ProfileSectionTabs._labelStyle.copyWith(
                        color: color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
