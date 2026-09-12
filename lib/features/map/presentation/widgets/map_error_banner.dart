import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../utils/map_error_mapper.dart';

/// A dismissible banner floating over the map.
///
/// A map error never replaces the page: whatever pins are already rendered stay
/// usable, and this just explains why nothing new arrived.
class MapErrorBanner extends StatelessWidget {
  final MapErrorCode code;
  final VoidCallback onDismiss;

  const MapErrorBanner({
    super.key,
    required this.code,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowAlpha(0x1A),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.mute,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mapErrorMessage(l10n, code),
              style: TextStyle(fontSize: 13, color: AppColors.ink2),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.close_rounded,
              size: 18,
              color: AppColors.muteSoft,
            ),
          ),
        ],
      ),
    );
  }
}
