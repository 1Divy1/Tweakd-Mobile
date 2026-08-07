import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/business_detail_entity.dart';
import 'business_hours_list.dart';

/// The loaded body of the business popup.
class BusinessPopupContent extends StatelessWidget {
  final BusinessDetailEntity business;

  /// Straight-line distance from the map's query centre, carried over from the
  /// pin — `GET /businesses/{id}` doesn't return one.
  final double? distanceKm;

  const BusinessPopupContent({
    super.key,
    required this.business,
    this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Header(business: business),
        const SizedBox(height: 14),
        _StatsRow(business: business, distanceKm: distanceKm),
        if (business.description.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            business.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.ink2,
            ),
          ),
        ],
        const SizedBox(height: 16),
        const Divider(color: AppColors.line2, height: 1),
        const SizedBox(height: 14),
        _IconRow(
          icon: Icons.place_outlined,
          // city_name, never city_id — that's the `cluj-napoca` slug.
          text: [business.address, business.cityName]
              .where((s) => s.isNotEmpty)
              .join(', '),
        ),
        if (business.followerCount > 0) ...[
          const SizedBox(height: 10),
          _IconRow(
            icon: Icons.people_outline,
            text: l10n.mapFollowerCount(business.followerCount),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          l10n.mapHoursTitle,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: AppColors.mute,
          ),
        ),
        const SizedBox(height: 8),
        BusinessHoursList(business: business),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final BusinessDetailEntity business;

  const _Header({required this.business});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BusinessLogo(logoUrl: business.logoUrl, size: 54),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      business.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  if (business.isVerified) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified_rounded,
                      size: 17,
                      color: AppColors.accent,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Text(
                business.typeLabel,
                style: const TextStyle(fontSize: 13, color: AppColors.mute),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Circular business logo, matching the map marker's look.
class BusinessLogo extends StatelessWidget {
  final String logoUrl;
  final double size;

  const BusinessLogo({super.key, required this.logoUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.accentSoft,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: logoUrl.isEmpty
          ? Icon(
              Icons.storefront_rounded,
              size: size * 0.5,
              color: AppColors.accent,
            )
          : CachedNetworkImage(
              imageUrl: logoUrl,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => Icon(
                Icons.storefront_rounded,
                size: size * 0.5,
                color: AppColors.accent,
              ),
            ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final BusinessDetailEntity business;
  final double? distanceKm;

  const _StatsRow({required this.business, required this.distanceKm});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final distance = distanceKm;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Pill(
          icon: business.isOpenNow
              ? Icons.check_circle_outline
              : Icons.schedule_rounded,
          label: business.isOpenNow ? l10n.mapOpenNow : l10n.mapClosedNow,
          tone: business.isOpenNow ? _PillTone.accent : _PillTone.neutral,
        ),
        _Pill(
          icon: Icons.star_rounded,
          label: business.hasRating
              ? '${business.averageRating.toStringAsFixed(1)} · '
                  '${l10n.mapReviewCount(business.reviewCount)}'
              : l10n.mapNoReviews,
          tone: _PillTone.neutral,
        ),
        if (distance != null)
          _Pill(
            icon: Icons.near_me_outlined,
            label: l10n.mapDistanceKm(distance.toStringAsFixed(1)),
            tone: _PillTone.neutral,
          ),
      ],
    );
  }
}

enum _PillTone { neutral, accent }

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final _PillTone tone;

  const _Pill({required this.icon, required this.label, required this.tone});

  @override
  Widget build(BuildContext context) {
    final isAccent = tone == _PillTone.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isAccent ? AppColors.accentSoft : AppColors.bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isAccent ? AppColors.accent : AppColors.mute),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isAccent ? AppColors.accentHot : AppColors.ink2,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IconRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.mute),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13.5, color: AppColors.ink2),
          ),
        ),
      ],
    );
  }
}
