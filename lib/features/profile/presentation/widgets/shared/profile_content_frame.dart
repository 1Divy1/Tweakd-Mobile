import 'package:flutter/material.dart';

import '../../../../../core/shared/layout/app_layout.dart';
import '../../../../../core/theme/app_colors.dart';

/// Paints the profile background edge to edge. The page content inside is
/// centred in a reading column: the top bar pads itself with
/// [AppLayout.inset], and the scroll view wraps its slivers in a
/// [SliverContentFrame].
///
/// It used to centre the whole page in a `ConstrainedBox`. That left the side
/// margins on a tablet outside the scroll view, dead to swipes; centring inside
/// the full-width scroll view keeps the whole screen scrollable.
class ProfileContentFrame extends StatelessWidget {
  final Widget child;

  /// Wider than any phone in portrait, so phones are unaffected; narrow enough
  /// that a tablet gets a column rather than a stretched page.
  static const maxContentWidth = AppLayout.readingWidth;

  const ProfileContentFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: AppColors.bg, child: child);
  }
}
