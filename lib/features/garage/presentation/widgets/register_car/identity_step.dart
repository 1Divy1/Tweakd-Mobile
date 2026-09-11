import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reference_data.dart';
import 'register_car_fields.dart';

/// Basics tab of the specs step — the car's make/model/year details. The
/// cover photo used to live here; it now sits with the rest of the imagery on
/// the gallery step.
///
/// The step title and the tab bar belong to [SpecsStep], so this body starts
/// straight at its first field.
class IdentityStep extends StatelessWidget {
  final CarBrandEntity? selectedBrand;
  final CarModelEntity? selectedModel;
  final List<CarBrandEntity> brands;
  final List<CarModelEntity> models;
  final bool modelsLoading;
  final TextEditingController yearCtrl;
  final TextEditingController chassisCodeCtrl;
  final TextEditingController modelCodeCtrl;
  final ValueChanged<CarBrandEntity> onSelectBrand;
  final ValueChanged<CarModelEntity> onSelectModel;

  const IdentityStep({
    super.key,
    required this.selectedBrand,
    required this.selectedModel,
    required this.brands,
    required this.models,
    required this.modelsLoading,
    required this.yearCtrl,
    required this.chassisCodeCtrl,
    required this.modelCodeCtrl,
    required this.onSelectBrand,
    required this.onSelectModel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegisterFieldLabel(l10n.garageFieldMake),
        const SizedBox(height: 8),
        RegisterSelectorTile(
          placeholder: l10n.garageHintMake,
          value: selectedBrand?.name,
          onTap: () => showRegisterPicker<CarBrandEntity>(
            context: context,
            title: l10n.garagePickerMake,
            items: brands,
            labelOf: (b) => b.name,
            onSelected: onSelectBrand,
            searchable: true,
          ),
        ),
        const SizedBox(height: 16),
        RegisterFieldLabel(l10n.garageFieldModel),
        const SizedBox(height: 8),
        RegisterSelectorTile(
          placeholder: selectedBrand == null
              ? l10n.garageHintModelPickMakeFirst
              : l10n.garageHintModel,
          value: selectedModel?.model,
          loading: modelsLoading,
          enabled: selectedBrand != null,
          onTap: selectedBrand == null || modelsLoading
              ? null
              : () => showRegisterPicker<CarModelEntity>(
                    context: context,
                    title: l10n.garagePickerModel,
                    items: models,
                    labelOf: (m) => m.model,
                    onSelected: onSelectModel,
                    searchable: true,
                  ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RegisterLabeledField(
                label: l10n.garageFieldYear,
                controller: yearCtrl,
                hint: '2024',
                isNumber: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RegisterFieldLabel(l10n.garageFieldChassisCode,
                      optional: true),
                  const SizedBox(height: 8),
                  RegisterFormField(
                    controller: chassisCodeCtrl,
                    hint: '',
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(12),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RegisterFieldLabel(l10n.garageFieldModelCode, optional: true),
        const SizedBox(height: 8),
        RegisterFormField(
          controller: modelCodeCtrl,
          hint: l10n.garageHintModelCode,
          inputFormatters: [
            LengthLimitingTextInputFormatter(12),
          ],
        ),
      ],
    );
  }
}
