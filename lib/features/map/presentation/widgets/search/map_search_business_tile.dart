import 'package:flutter/material.dart';
import 'package:tweakd/l10n/app_localizations.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/business_pin_entity.dart';
import '../businesses/business_popup_content.dart';

/// One business in the search results: logo, name, type, and whether it's
/// open right now (computed by the backend in the business's own timezone).
class MapSearchBusinessTile extends StatelessWidget {
  final BusinessPinEntity business;
  final VoidCallback onTap;

  const MapSearchBusinessTile({
    super.key,
    required this.business,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              BusinessLogo(logoUrl: business.logoUrl, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: business.typeLabel),
                          const TextSpan(text: ' · '),
                          TextSpan(
                            text: business.isOpenNow
                                ? l10n.mapOpenNow
                                : l10n.mapClosedNow,
                            style: TextStyle(
                              color: business.isOpenNow
                                  ? AppColors.accent
                                  : AppColors.muteSoft,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ink2,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: AppColors.muteSoft, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
