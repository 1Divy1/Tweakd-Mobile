import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/onboarding reference/car_category_entity.dart';
import '../onboarding_fields.dart';
import '../onboarding_pickers.dart';

/// Minimum number of categories the user must pick to calibrate their feed.
const int kMinTasteCategories = 1;

/// Step 4 — the scenes/categories the user is into. Multi-select with a
/// soft minimum of [kMinTasteCategories].
class TasteStep extends StatelessWidget {
  final List<CarCategoryEntity> categories;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  const TasteStep({
    super.key,
    required this.categories,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final count = selectedIds.length;
    final enough = count >= kMinTasteCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingSectionHeader(
          label: '04 — TASTE',
          title: 'Categories you’re into',
          subtitle: 'Tap the scenes that get your pulse up. We’ll lead with '
              'these across your feed and the marketplace.',
        ),
        const SizedBox(height: 20),
        const OnboardingFieldLabel('CATEGORIES'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final category in categories)
              OnboardingChoicePill(
                label: category.name.toUpperCase(),
                selected: selectedIds.contains(category.id),
                onTap: () => onToggle(category.id),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: TextStyle(
              color: enough ? AppColors.mute : AppColors.accentHot,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(text: '$count selected'),
              const TextSpan(
                text: ' · pick at least 1 to calibrate your feed.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
