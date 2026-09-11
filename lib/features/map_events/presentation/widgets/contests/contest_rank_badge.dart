import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/contest_enums.dart';
import '../../utils/contest_formatting.dart';
import 'contest_category_icon.dart';

/// A podium place as a badge: a rounded plate in the house language — accent
/// for a win, ink for a placing — with the category glyph and a rank pill.
/// Drawn locally from the placement, so a car's badges need no artwork.
class ContestRankBadge extends StatelessWidget {
  final ContestCategoryIcon icon;
  final int rank;
  final double size;

  /// A short caption under the plate (the category's short name).
  final String? label;

  const ContestRankBadge({
    super.key,
    required this.icon,
    required this.rank,
    this.size = 56,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final win = rank == 1;
    final plate = win ? AppColors.accent : AppColors.ink;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size + 8,
          height: size + 8,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: plate,
                  borderRadius: BorderRadius.circular(size * 0.3),
                  boxShadow: [
                    BoxShadow(
                      color: plate.withValues(alpha: win ? 0.28 : 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: ContestCategoryGlyph(
                  icon: icon,
                  color: Colors.white,
                  size: size * 0.42,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x290A0A0A),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    ContestFormat.rank(l10n, rank),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: win ? AppColors.accent : AppColors.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: size + 22,
            child: Text(
              label!.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                height: 1.3,
                color: AppColors.mute,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
