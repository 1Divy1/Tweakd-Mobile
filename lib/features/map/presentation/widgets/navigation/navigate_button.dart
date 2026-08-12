import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/geo_position.dart';
import 'navigation_app_sheet.dart';

/// Full-width "Navigate" action that hands [position] to the user's navigation
/// app of choice.
///
/// Takes a bare coordinate and label rather than a business, so a car meet —
/// or any other pin that lands on the map later — can drop it in unchanged.
class NavigateButton extends StatelessWidget {
  final GeoPosition position;

  /// Shown as the destination in the chooser sheet, e.g. the business name.
  final String label;

  const NavigateButton({
    super.key,
    required this.position,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => showNavigationAppSheet(
          context,
          lat: position.lat,
          lng: position.lng,
          destinationLabel: label,
        ),
        icon: const Icon(Icons.near_me_rounded, size: 18),
        label: Text(
          l10n.mapNavigate,
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
