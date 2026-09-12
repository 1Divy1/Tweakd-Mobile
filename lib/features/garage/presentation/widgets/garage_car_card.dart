import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/car_summary.dart';
import 'car_image.dart';

/// A car in the garage list: cover image, then the identity row (name +
/// chevron), then a divider'd row of headline specs — power, torque, year.
///
/// Every spec below the image is nullable — see [CarSummaryEntity]. The card
/// drops whichever parts are missing instead of showing dashes, so it still
/// reads correctly against a payload that doesn't carry them.
class GarageCarCard extends StatelessWidget {
  final CarSummaryEntity car;
  final VoidCallback onTap;

  const GarageCarCard({super.key, required this.car, required this.onTap});

  /// Ceiling for the spec row's text scaling. Three numeric cells share one
  /// line; past this the figures shrink to ellipses and stop being specs.
  static const _maxSpecTextScale = 1.5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = _stats(l10n);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CarImage(imageUrl: car.coverImage?.url, status: car.status?.type),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${car.brand} ${car.model}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: AppColors.muteSoft,
                  ),
                ],
              ),
            ),
            if (stats.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Divider(height: 1, color: AppColors.line),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: MediaQuery.withClampedTextScaling(
                  maxScaleFactor: _maxSpecTextScale,
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < stats.length; i++) ...[
                          if (i > 0)
                            VerticalDivider(
                              width: 1,
                              thickness: 1,
                              color: AppColors.line,
                            ),
                          Expanded(
                            child: Padding(
                              // The first cell sits flush with the card's
                              // padding; the rest clear the divider.
                              padding: EdgeInsets.only(left: i == 0 ? 0 : 14),
                              child: stats[i],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ] else
              const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  List<Widget> _stats(AppLocalizations l10n) {
    return [
      if (car.horsepower != null)
        _CarStat(
          value: '${car.horsepower}',
          unit: l10n.garageCarUnitPower,
          label: l10n.garageCarStatPower,
        ),
      if (car.torque != null)
        _CarStat(
          value: '${car.torque}',
          unit: l10n.garageCarUnitTorque,
          label: l10n.garageCarStatTorque,
        ),
      if (car.year != null)
        _CarStat(value: '${car.year}', label: l10n.garageCarStatYear),
    ];
  }
}

/// One cell of the spec row: a big number with an optional inline unit, over a
/// small uppercase caption.
///
/// Value and unit are both [Flexible] — the cell is a third of the card, and a
/// long localized unit next to a four-digit figure has to truncate rather than
/// overflow.
class _CarStat extends StatelessWidget {
  final String value;
  final String? unit;
  final String label;

  const _CarStat({required this.value, required this.label, this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (unit != null) ...[
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  unit!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.mute,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.muteSoft,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class _CarImage extends StatelessWidget {
  final String? imageUrl;
  final String? status;

  const _CarImage({this.imageUrl, this.status});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CarImage(imageUrl: imageUrl, fit: BoxFit.cover),
          if (status != null)
            Positioned(top: 10, left: 10, child: _StatusBadge(status: status!)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        status.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.surface,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
