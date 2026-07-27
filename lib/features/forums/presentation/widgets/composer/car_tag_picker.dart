import 'package:flutter/material.dart';

import 'package:car_social_media_app/features/garage/domain/entities/car_summary.dart';
import 'package:car_social_media_app/features/garage/domain/entities/reference_data.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../bloc/composer/state.dart';
import '../shared/forum_section_label.dart';

/// "TAG A CAR" section of the composer: garage suggestions, then a searchable
/// brand list (required) and, once a brand is picked, a searchable model list
/// for that brand (optional).
class CarTagPicker extends StatelessWidget {
  final NewThreadState state;
  final TextEditingController brandSearchController;
  final TextEditingController modelSearchController;
  final ValueChanged<String> onBrandQueryChanged;
  final ValueChanged<CarBrandEntity> onSelectBrand;
  final VoidCallback onClearBrand;
  final ValueChanged<String> onModelQueryChanged;
  final ValueChanged<CarModelEntity> onSelectModel;
  final VoidCallback onClearModel;
  final ValueChanged<CarSummaryEntity> onSelectGarageCar;

  const CarTagPicker({
    super.key,
    required this.state,
    required this.brandSearchController,
    required this.modelSearchController,
    required this.onBrandQueryChanged,
    required this.onSelectBrand,
    required this.onClearBrand,
    required this.onModelQueryChanged,
    required this.onSelectModel,
    required this.onClearModel,
    required this.onSelectGarageCar,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final brand = state.selectedBrand;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ForumSectionLabel(label: l10n.forumsTagACar),
        const SizedBox(height: 10),
        _StepLabel(label: l10n.forumsBrandRequiredLabel),
        const SizedBox(height: 8),
        if (brand == null) ...[
          for (final car in state.garageCars) ...[
            _GarageCarChip(
              car: car,
              l10n: l10n,
              onTap: () => onSelectGarageCar(car),
            ),
            const SizedBox(height: 8),
          ],
          _SearchField(
            controller: brandSearchController,
            hint: l10n.forumsSearchBrandHint,
            onChanged: onBrandQueryChanged,
          ),
          const SizedBox(height: 6),
          _OptionList(
            maxHeight: 240,
            emptyLabel: state.filteredBrands.isEmpty
                ? l10n.forumsNoBrandMatches
                : null,
            children: [
              for (final option in state.filteredBrands)
                _OptionRow(
                  label: option.name,
                  onTap: () => onSelectBrand(option),
                ),
            ],
          ),
        ] else ...[
          _SelectedChip(label: brand.name, onClear: onClearBrand),
          const SizedBox(height: 16),
          _StepLabel(label: l10n.forumsModelOptionalLabel),
          const SizedBox(height: 8),
          _ModelStep(
            state: state,
            l10n: l10n,
            controller: modelSearchController,
            onQueryChanged: onModelQueryChanged,
            onSelect: onSelectModel,
            onClear: onClearModel,
          ),
        ],
        const SizedBox(height: 10),
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

/// Model half of the picker: loading, the selected model, or search + list.
class _ModelStep extends StatelessWidget {
  final NewThreadState state;
  final AppLocalizations l10n;
  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<CarModelEntity> onSelect;
  final VoidCallback onClear;

  const _ModelStep({
    required this.state,
    required this.l10n,
    required this.controller,
    required this.onQueryChanged,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingModels) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.accent,
          ),
        ),
      );
    }

    final model = state.selectedModel;
    if (model != null) {
      return _SelectedChip(label: model.model, onClear: onClear);
    }

    if (state.models.isEmpty) {
      return _EmptyNote(label: l10n.forumsNoModelsForBrand);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SearchField(
          controller: controller,
          hint: l10n.forumsSearchModelHint,
          onChanged: onQueryChanged,
        ),
        const SizedBox(height: 6),
        _OptionList(
          maxHeight: 200,
          emptyLabel: state.filteredModels.isEmpty
              ? l10n.forumsNoModelMatches
              : null,
          children: [
            for (final option in state.filteredModels)
              _OptionRow(label: option.model, onTap: () => onSelect(option)),
          ],
        ),
      ],
    );
  }
}

/// Bounded, scrollable result list. Renders [emptyLabel] instead when there is
/// nothing to show.
class _OptionList extends StatelessWidget {
  final double maxHeight;
  final String? emptyLabel;
  final List<Widget> children;

  const _OptionList({
    required this.maxHeight,
    required this.emptyLabel,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final label = emptyLabel;
    if (label != null) return _EmptyNote(label: label);

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: children,
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OptionRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  final String label;

  const _EmptyNote({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.muteSoft,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// "BRAND · REQUIRED" / "MODEL · OPTIONAL" step captions.
class _StepLabel extends StatelessWidget {
  final String label;

  const _StepLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.mute,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
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
            const Icon(
              Icons.directions_car_filled_outlined,
              size: 16,
              color: AppColors.accentHot,
            ),
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

class _SelectedChip extends StatelessWidget {
  final String label;
  final VoidCallback onClear;

  const _SelectedChip({required this.label, required this.onClear});

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
              label,
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
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.hint,
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
        ],
      ),
    );
  }
}
