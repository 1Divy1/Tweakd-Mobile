import 'package:tweakd/features/garage/domain/entities/reference_data.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../onboarding_fields.dart';
import '../onboarding_pickers.dart';

/// One dream-car row in the Preferences step: a brand plus an optional set of
/// models. On submit each row expands to one dream car per selected model (or
/// a single brand-only entry when no models are picked).
class DreamCarRow {
  CarBrandEntity? brand;
  List<CarModelEntity> models;

  DreamCarRow({this.brand, List<CarModelEntity>? models})
      : models = models ?? [];
}

/// Step 2 — brands & models the user is into (at least one brand is
/// required; models stay optional).
class PreferencesStep extends StatelessWidget {
  final List<DreamCarRow> rows;
  final List<CarBrandEntity> brands;
  final Map<String, List<CarModelEntity>> modelsByBrand;
  final Set<String> loadingModelsFor;
  final VoidCallback onAddRow;
  final ValueChanged<int> onRemoveRow;
  final void Function(int index, CarBrandEntity brand) onSelectBrand;
  final void Function(int index, CarModelEntity model) onToggleModel;

  const PreferencesStep({
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
          title: l10n.onboardingGarageTitle,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                OnboardingFieldLabel(l10n.onboardingFieldYourPicks),
                const SizedBox(height: 12),
                for (var i = 0; i < rows.length; i++) ...[
                  _DreamCarCard(
                    row: rows[i],
                    brands: _availableBrands(i),
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
            ),
          ),
        ),
      ],
    );
  }

  /// Brands already picked by other rows are hidden from row [index]'s
  /// picker so the same brand can't be added twice.
  List<CarBrandEntity> _availableBrands(int index) {
    final usedElsewhere = {
      for (var i = 0; i < rows.length; i++)
        if (i != index && rows[i].brand != null) rows[i].brand!.id,
    };
    return brands.where((b) => !usedElsewhere.contains(b.id)).toList();
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
            OnboardingFieldLabel(l10n.onboardingFieldModels),
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
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.onboardingAddBrand,
              style: const TextStyle(
                color: Colors.white,
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
