import 'package:car_social_media_app/core/theme/app_colors.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/geocode_candidate.dart';

/// The candidates returned by a search, best match first.
///
/// Each row carries a precision badge rather than just the address string:
/// Mapbox regularly returns several hits whose `place_name` is character-for-
/// character identical (a rooftop hit and a street-level one for the same
/// road), and without the badge the user would be choosing between rows that
/// look the same. The badge also sets the right expectation for the pin they
/// then have to drop — an "approximate" hit means the camera lands on the
/// street, not the driveway.
class GeocodeResultList extends StatelessWidget {
  final List<GeocodeCandidateEntity> candidates;
  final ValueChanged<GeocodeCandidateEntity> onSelected;
  final VoidCallback onEditSearch;

  const GeocodeResultList({
    super.key,
    required this.candidates,
    required this.onSelected,
    required this.onEditSearch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.mapEventsLocationResultsTitle,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l10n.mapEventsLocationResultsSubtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: AppColors.mute,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: onEditSearch,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
                textStyle: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              child: Text(l10n.mapEventsLocationEditSearch),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: candidates.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _ResultRow(
              candidate: candidates[index],
              onTap: () => onSelected(candidates[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  final GeocodeCandidateEntity candidate;
  final VoidCallback onTap;

  const _ResultRow({required this.candidate, required this.onTap});

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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              const Icon(
                Icons.place_outlined,
                size: 19,
                color: AppColors.accent,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      candidate.placeName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _precisionLabel(l10n, candidate),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: candidate.accuracy.isExact
                            ? AppColors.accent
                            : AppColors.mute,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.muteSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// How precise this hit is, in words the user can act on.
///
/// `accuracy` is only populated for address-level hits, so anything coarser
/// falls back to describing the [GeocodeFeatureType] instead.
String _precisionLabel(AppLocalizations l10n, GeocodeCandidateEntity c) {
  return switch (c.accuracy) {
    GeocodeAccuracy.rooftop ||
    GeocodeAccuracy.parcel =>
      l10n.mapEventsLocationPrecisionExact,
    GeocodeAccuracy.point => l10n.mapEventsLocationPrecisionPoint,
    GeocodeAccuracy.intersection =>
      l10n.mapEventsLocationPrecisionIntersection,
    GeocodeAccuracy.interpolated ||
    GeocodeAccuracy.approximate =>
      l10n.mapEventsLocationPrecisionApproximate,
    GeocodeAccuracy.none => switch (c.featureType) {
        GeocodeFeatureType.street => l10n.mapEventsLocationPrecisionStreet,
        GeocodeFeatureType.address => l10n.mapEventsLocationPrecisionAddress,
        GeocodeFeatureType.postcode => l10n.mapEventsLocationPrecisionPostcode,
        GeocodeFeatureType.place ||
        GeocodeFeatureType.region ||
        GeocodeFeatureType.country =>
          l10n.mapEventsLocationPrecisionArea,
        GeocodeFeatureType.other => l10n.mapEventsLocationPrecisionArea,
      },
  };
}
