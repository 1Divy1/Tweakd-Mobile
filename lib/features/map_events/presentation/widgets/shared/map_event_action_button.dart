import 'package:car_social_media_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Visual weight of a [MapEventActionButton].
enum MapEventButtonTone {
  /// Filled black — the active half of a toggle pair.
  active,

  /// Filled white with a hairline — the inactive half.
  idle,

  /// Filled orange — the one primary action on a screen.
  accent,

  /// Orange text on a soft orange fill — a state, not really a button
  /// (the "⏳ PENDING" participation state).
  accentSoft,

  /// Filled grey — a done state that can't be tapped further
  /// ("✓ PARTICIPATING").
  done,
}

/// The pill button the event UI is built from: RSVP toggles, the participation
/// button, the popup's CTA.
///
/// One widget rather than five near-identical ones, because the design uses the
/// same pill at five weights and they have to stay in step.
class MapEventActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final MapEventButtonTone tone;

  /// Null disables the button — greyed and inert, which is how a full entry
  /// list or a passed deadline is communicated.
  final VoidCallback? onTap;

  final bool isBusy;
  final bool isCompact;

  const MapEventActionButton({
    super.key,
    required this.label,
    this.icon,
    required this.tone,
    required this.onTap,
    this.isBusy = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !isBusy;
    final (background, foreground, border) = _palette(enabled);

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: isCompact ? 40 : 46,
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: border == null ? null : Border.all(color: border),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isBusy)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foreground,
                    ),
                  )
                else if (icon != null)
                  Icon(icon, size: 15, color: foreground),
                if (isBusy || icon != null) const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isCompact ? 11.5 : 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color, Color?) _palette(bool enabled) {
    if (!enabled) {
      // One disabled look for every tone: a greyed pill reads as "not now"
      // regardless of what it would have been.
      return (AppColors.line2, AppColors.muteSoft, null);
    }
    return switch (tone) {
      MapEventButtonTone.active => (AppColors.ink, Colors.white, null),
      MapEventButtonTone.idle => (AppColors.surface, AppColors.ink, AppColors.line),
      MapEventButtonTone.accent => (AppColors.accent, Colors.white, null),
      MapEventButtonTone.accentSoft => (
          AppColors.accentSoft,
          AppColors.accentHot,
          null
        ),
      MapEventButtonTone.done => (AppColors.mute, Colors.white, null),
    };
  }
}
