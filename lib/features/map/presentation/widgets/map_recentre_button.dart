import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Floating "find me" control. Re-asks for a fix and reloads the businesses
/// around it — which is also how a user who denied location the first time can
/// change their mind.
class MapRecentreButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const MapRecentreButton({
    super.key,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      button: true,
      label: l10n.mapRecentre,
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(),
        elevation: 3,
        shadowColor: const Color(0x33000000),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(
              isActive ? Icons.my_location_rounded : Icons.location_searching,
              size: 21,
              color: isActive ? AppColors.accent : AppColors.ink2,
            ),
          ),
        ),
      ),
    );
  }
}
