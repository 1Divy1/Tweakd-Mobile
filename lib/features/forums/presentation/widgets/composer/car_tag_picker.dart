import 'package:flutter/material.dart';

import 'package:car_social_media_app/features/garage/domain/entities/car_summary.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../bloc/composer/state.dart';
import '../shared/forum_section_label.dart';

/// "TAG A CAR" section of the composer: garage suggestions, the model search
/// with inline autocomplete, and the selected-car chip.
class CarTagPicker extends StatelessWidget {
  final NewThreadState state;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<ComposerCarOption> onSelect;
  final ValueChanged<CarSummaryEntity> onSelectGarageCar;
  final VoidCallback onClear;

  const CarTagPicker({
    super.key,
    required this.state,
    required this.searchController,
    required this.onQueryChanged,
    required this.onSelect,
    required this.onSelectGarageCar,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selected = state.selectedCar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ForumSectionLabel(label: l10n.forumsTagACar),
        const SizedBox(height: 10),
        if (selected != null)
          _SelectedCarChip(option: selected, onClear: onClear)
        else ...[
          for (final car in state.garageCars) ...[
            _GarageCarChip(
              car: car,
              l10n: l10n,
              onTap: () => onSelectGarageCar(car),
            ),
            const SizedBox(height: 8),
          ],
          _SearchField(
            controller: searchController,
            hint: l10n.forumsSearchCarHint,
            isSearching: state.isSearching,
            onChanged: onQueryChanged,
          ),
          if (state.suggestions.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                children: [
                  for (final option in state.suggestions)
                    InkWell(
                      onTap: () => onSelect(option),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option.label,
                                style: const TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              option.brand.name,
                              style: const TextStyle(
                                color: AppColors.mute,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
        const SizedBox(height: 8),
        Text(
          l10n.forumsTagCarHelper,
          style: const TextStyle(
            color: AppColors.muteSoft,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _GarageCarChip extends StatelessWidget {
  final CarSummaryEntity car;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _GarageCarChip({
    required this.car,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.accentSoft.withAlpha(120),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions_car_filled_outlined,
                size: 16, color: AppColors.accentHot),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.forumsFromYourGarage('${car.brand} ${car.model}'),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.accentHot,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedCarChip extends StatelessWidget {
  final ComposerCarOption option;
  final VoidCallback onClear;

  const _SelectedCarChip({required this.option, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              option.label,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, size: 18, color: AppColors.mute),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isSearching;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.hint,
    required this.isSearching,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: AppColors.mute),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: AppColors.accent,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(
                  color: AppColors.muteSoft,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (isSearching)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            ),
        ],
      ),
    );
  }
}
