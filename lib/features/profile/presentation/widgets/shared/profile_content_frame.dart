import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Paints the profile background edge to edge and centres the page content
/// within a readable measure.
///
/// Without a ceiling the header, bio and car cards stretch the full width of a
/// tablet or a landscape phone, which leaves a 900pt-wide line of bio text and
/// a car card taller than the screen. The background stays full-bleed so the
/// letterboxing isn't visible as a colour change.
class ProfileContentFrame extends StatelessWidget {
  final Widget child;

  /// Wider than any phone in portrait, so phones are unaffected; narrow enough
  /// that a tablet gets a column rather than a stretched page.
  static const maxContentWidth = 640.0;

  const ProfileContentFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bg,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: child,
        ),
      ),
    );
  }
}
