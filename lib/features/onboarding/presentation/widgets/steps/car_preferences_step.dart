import 'package:car_social_media_app/features/garage/domain/entities/reference_data.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../onboarding_fields.dart';
import '../onboarding_pickers.dart';

/// One dream-car row in the Garage step: a brand plus an optional set of
/// models. On submit each row expands to one dream car per selected model (or
/// a single brand-only entry when no models are picked).
class DreamCarRow {
  CarBrandEntity? brand;
  List<CarModelEntity> models;

  DreamCarRow({this.brand, List<CarModelEntity>? models})
      : models = models ?? [];
}

/// Step 2 — pick the marques (and exact models) the user is into. Everything
/// here is optional; the feed simply tunes around whatever is chosen.
class GarageStep extends StatelessWidget {
  final List<DreamCarRow> rows;
  final List<CarBrandEntity> brands;
  final Map<String, List<CarModelEntity>> modelsByBrand;
  final Set<String> loadingModelsFor;
  final VoidCallback onAddRow;
  final ValueChanged<int> onRemoveRow;
  final void Function(int index, CarBrandEntity brand) onSelectBrand;
  final void Function(int index, CarModelEntity model) onToggleModel;

  const GarageStep({
    super.key,
    required this.rows,
    required this.brands,
    required this.modelsByBrand,
    required this.loadingModelsFor,
    required this.onAddRow,
    required this.onRemoveRow,
    required this.onSelectBrand,
    required this.onToggleModel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingSectionHeader(
          label: l10n.onboardingGarageLabel,
          title: l10n.onboardingGarageTitle,
          subtitle: l10n.onboardingGarageSubtitle,
        ),
        const SizedBox(height: 20),
        OnboardingFieldLabel(l10n.onboardingFieldYourPicks, optional: true),
        const SizedBox(height: 12),
        for (var i = 0; i < rows.length; i++) ...[
          _DreamCarCard(
            row: rows[i],
            brands: brands,
            models: rows[i].brand == null
                ? const []
                : (modelsByBrand[rows[i].brand!.id] ?? const []),
            modelsLoading: rows[i].brand != null &&
                loadingModelsFor.contains(rows[i].brand!.id),
            onSelectBrand: (brand) => onSelectBrand(i, brand),
            onToggleModel: (model) => onToggleModel(i, model),
            onRemove: () => onRemoveRow(i),
          ),
          const SizedBox(height: 14),
        ],
        _AddBrandButton(onTap: onAddRow),
      ],
    );
  }
}

class _DreamCarCard extends StatelessWidget {
  final DreamCarRow row;
  final List<CarBrandEntity> brands;
  final List<CarModelEntity> models;
  final bool modelsLoading;
  final ValueChanged<CarBrandEntity> onSelectBrand;
  final ValueChanged<CarModelEntity> onToggleModel;
  final VoidCallback onRemove;

  const _DreamCarCard({
    required this.row,
    required this.brands,
    required this.models,
    required this.modelsLoading,
    required this.onSelectBrand,
    required this.onToggleModel,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final brand = row.brand;
    final modelsLabel =
        row.models.isEmpty ? null : row.models.map((m) => m.model).join(' · ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _BrandBadge(letter: brand == null ? null : _initial(brand.name)),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => showOnboardingPicker<CarBrandEntity>(
                    context: context,
                    title: l10n.onboardingSelectBrand,
                    items: brands,
                    labelOf: (b) => b.name,
                    onSelected: onSelectBrand,
                    searchable: true,
                  ),
                  child: _InlineSelectorText(
                    value: brand?.name,
                    placeholder: l10n.onboardingSelectBrand,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _RemoveButton(onTap: onRemove),
            ],
          ),
          if (brand != null) ...[
            const SizedBox(height: 14),
            OnboardingFieldLabel(l10n.onboardingFieldModels, optional: true),
            const SizedBox(height: 8),
            OnboardingSelectorTile(
              placeholder: l10n.onboardingAddModels,
              value: modelsLabel,
              loading: modelsLoading,
              enabled: models.isNotEmpty,
              onTap: models.isEmpty
                  ? null
                  : () => showOnboardingMultiPicker<CarModelEntity>(
                        context: context,
                        title: l10n.onboardingBrandModels(brand.name),
                        items: models,
                        labelOf: (m) => m.model,
                        isSelected: (m) =>
                            row.models.any((sel) => sel.id == m.id),
                        onToggle: onToggleModel,
                        searchable: true,
                      ),
            ),
          ],
        ],
      ),
    );
  }

  static String _initial(String name) =>
      name.isEmpty ? '?' : name.characters.first.toUpperCase();
}

class _BrandBadge extends StatelessWidget {
  final String? letter;
  const _BrandBadge({this.letter});

  @override
  Widget build(BuildContext context) {
    final hasBrand = letter != null;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: hasBrand ? AppColors.ink : AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: hasBrand ? null : Border.all(color: AppColors.line),
      ),
      child: Center(
        child: hasBrand
            ? Text(
                letter!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              )
            : const Icon(Icons.directions_car_filled_outlined,
                size: 18, color: AppColors.muteSoft),
      ),
    );
  }
}

class _InlineSelectorText extends StatelessWidget {
  final String? value;
  final String placeholder;

  const _InlineSelectorText({required this.value, required this.placeholder});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value ?? placeholder,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: value != null ? AppColors.ink : AppColors.muteSoft,
                fontSize: 15,
                fontWeight: value != null ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.expand_more_rounded,
              color: AppColors.mute, size: 20),
        ],
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RemoveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.line),
        ),
        child: const Icon(Icons.close_rounded, size: 18, color: AppColors.mute),
      ),
    );
  }
}

class _AddBrandButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddBrandButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.accent.withAlpha(120)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, size: 20, color: AppColors.accent),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.onboardingAddBrand,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
