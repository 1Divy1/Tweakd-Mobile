import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The app's layout measures — the only place a page width is decided.
///
/// Tweakd is a phone-first design. On anything wider (tablets, unfolded
/// foldables, iPad Split View, landscape) the same layout is shown as a centred
/// column; the page background still runs edge to edge. Phones are never
/// affected: every measure here is wider than a phone in portrait.
///
/// Two ways to apply a measure, depending on what's being centred:
/// - fixed content (top bars, input bars, action rows, non-scrolling pages):
///   wrap it in [ContentFrame];
/// - scrolling content: keep the scroll view full width and add
///   [AppLayout.inset] to its padding (or use [SliverContentFrame]). Wrapping a
///   scroll view in a frame instead would leave the side margins dead to
///   swipes.
abstract final class AppLayout {
  /// Below this the window is a phone in portrait.
  static const double compactMaxWidth = 600;

  /// Feeds, lists, profiles, detail pages, and the tab bar.
  static const double readingWidth = 640;

  /// Composers, wizards, auth and settings-style forms.
  static const double formWidth = 560;

  /// Small centred surfaces: empty/error states, confirmation content.
  static const double narrowWidth = 420;

  /// Whether [context]'s window is wider than a phone in portrait.
  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= compactMaxWidth;

  /// The horizontal padding that centres a column of [maxWidth] inside
  /// [availableWidth]. Zero whenever the column already fits.
  static double insetFor(
    double availableWidth, {
    double maxWidth = readingWidth,
  }) => math.max(0, (availableWidth - maxWidth) / 2);

  /// Symmetric horizontal padding that centres a column of [maxWidth] in the
  /// window. Add it to a full-width scroll view's own padding:
  ///
  /// ```dart
  /// ListView(padding: const EdgeInsets.all(16) + AppLayout.inset(context))
  /// ```
  static EdgeInsets inset(
    BuildContext context, {
    double maxWidth = readingWidth,
  }) => EdgeInsets.symmetric(
    horizontal: insetFor(MediaQuery.sizeOf(context).width, maxWidth: maxWidth),
  );

  /// Height for a bottom sheet that wants [fraction] of the screen, capped to
  /// what's actually free: below the status bar and above the keyboard.
  ///
  /// A bare `size.height * fraction` overflows as soon as the keyboard opens on
  /// a short window — a landscape phone, a flip phone's cover screen, a
  /// foldable's half.
  static double sheetHeight(BuildContext context, double fraction) {
    final media = MediaQuery.of(context);
    final free =
        media.size.height -
        media.viewInsets.bottom -
        media.padding.top -
        kSheetTopGap;
    return math.max(0, math.min(media.size.height * fraction, free));
  }

  /// Space left above a sheet at its tallest, so it never touches the status
  /// bar and still reads as a sheet.
  static const double kSheetTopGap = 24;
}

/// Centres [child] in a column no wider than [maxWidth], measured against the
/// space it is actually given (so it also behaves inside sheets and panes).
///
/// Implemented as padding rather than `Center` + `ConstrainedBox` so the child
/// keeps exactly the constraints it had on a phone — a `Column` still
/// stretches, an `Expanded` still fills — just narrower.
class ContentFrame extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ContentFrame({
    super.key,
    required this.child,
    this.maxWidth = AppLayout.readingWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final inset = constraints.hasBoundedWidth
            ? AppLayout.insetFor(constraints.maxWidth, maxWidth: maxWidth)
            : 0.0;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: inset),
          child: child,
        );
      },
    );
  }
}

/// [ContentFrame] for slivers: centres [sliver] inside a full-width
/// `CustomScrollView`, so the whole width still scrolls.
class SliverContentFrame extends StatelessWidget {
  final Widget sliver;
  final double maxWidth;

  const SliverContentFrame({
    super.key,
    required this.sliver,
    this.maxWidth = AppLayout.readingWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) => SliverPadding(
        padding: EdgeInsets.symmetric(
          horizontal: AppLayout.insetFor(
            constraints.crossAxisExtent,
            maxWidth: maxWidth,
          ),
        ),
        sliver: sliver,
      ),
    );
  }
}
