import 'package:flutter/material.dart';

import 'package:tweakd/features/garage/domain/entities/reference_data.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../bloc/composer/state.dart';
import 'reference_picker_sheet.dart';

/// Where the thread gets filed: a brand (required) and, once that is picked, a
/// model of it (optional). This is browsing metadata, not car tagging — tagging
/// other people's cars lives in the tag editor below.
///
/// Both fields open a bottom-sheet picker on tap; nothing pops open on its own.
class ThreadCategoryPicker extends StatelessWidget {
  final NewThreadState state;
  final ValueChanged<CarBrandEntity> onSelectBrand;
  final VoidCallback onClearBrand;
  final ValueChanged<CarModelEntity> onSelectModel;
  final VoidCallback onClearModel;

  const ThreadCategoryPicker({
    super.key,
    required this.state,
    required this.onSelectBrand,
    required this.onClearBrand,
    required this.onSelectModel,
    required this.onClearModel,
  });

  Future<void> _pickBrand(BuildContext context, AppLocalizations l10n) async {
    final picked = await showForumReferencePickerSheet<CarBrandEntity>(
      context,
      title: l10n.forumsChooseBrand,
      searchHint: l10n.forumsSearchBrandHint,
      noMatchesLabel: l10n.forumsNoBrandMatches,
      options: state.brands,
      labelOf: (brand) => brand.name,
    );
    if (picked != null) onSelectBrand(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final brand = state.selectedBrand;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepLabel(label: l10n.forumsBrandRequiredLabel),
        const SizedBox(height: 8),
        if (brand == null)
          _PickerField(
            hint: l10n.forumsSearchBrandHint,
            onTap: () => _pickBrand(context, l10n),
          )
        else ...[
          _SelectedChip(label: brand.name, onClear: onClearBrand),
          const SizedBox(height: 16),
          _StepLabel(label: l10n.forumsModelOptionalLabel),
          const SizedBox(height: 8),
          _ModelStep(
            state: state,
            l10n: l10n,
            onSelect: onSelectModel,
            onClear: onClearModel,
          ),
        ],
        const SizedBox(height: 10),
        Text(
          l10n.forumsTagCarHelper,
          style: TextStyle(
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

/// Model half of the picker: loading, the selected model, or the picker field.
class _ModelStep extends StatelessWidget {
  final NewThreadState state;
  final AppLocalizations l10n;
  final ValueChanged<CarModelEntity> onSelect;
  final VoidCallback onClear;

  const _ModelStep({
    required this.state,
    required this.l10n,
    required this.onSelect,
    required this.onClear,
  });

  Future<void> _pickModel(BuildContext context) async {
    final picked = await showForumReferencePickerSheet<CarModelEntity>(
      context,
      title: l10n.forumsChooseModel,
      searchHint: l10n.forumsSearchModelHint,
      noMatchesLabel: l10n.forumsNoModelMatches,
      options: state.models,
      labelOf: (model) => model.model,
    );
    if (picked != null) onSelect(picked);
  }

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingModels) {
      return Padding(
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

    return _PickerField(
      hint: l10n.forumsSearchModelHint,
      onTap: () => _pickModel(context),
    );
  }
}

/// Read-only field that opens a picker sheet — it holds no keyboard focus, so
/// no list can pop open before the user asks for one.
class _PickerField extends StatelessWidget {
  final String hint;
  final VoidCallback onTap;

  const _PickerField({required this.hint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 18, color: AppColors.mute),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hint,
                style: TextStyle(
                  color: AppColors.muteSoft,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.expand_more_rounded,
              size: 20,
              color: AppColors.mute,
            ),
          ],
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
        style: TextStyle(
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
      style: TextStyle(
        color: AppColors.mute,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
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
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close, size: 18, color: AppColors.mute),
          ),
        ],
      ),
    );
  }
}
