import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reference_data.dart';
import 'register_car_fields.dart';

/// Power tab of the specs step — power, torque and weight figures. The step
/// title and the tab bar belong to [SpecsStep].
class PerformanceStep extends StatelessWidget {
  final TextEditingController hpCtrl;
  final TextEditingController torqueCtrl;
  final TextEditingController zeroToHundredCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController displacementCtrl;
  final TextEditingController engineCodeCtrl;
  final List<CarFuelTypeOptionEntity> fuelTypeOptions;
  final CarFuelTypeOptionEntity? selectedFuelType;
  final ValueChanged<CarFuelTypeOptionEntity> onSelectFuelType;

  const PerformanceStep({
    super.key,
    required this.hpCtrl,
    required this.torqueCtrl,
    required this.zeroToHundredCtrl,
    required this.weightCtrl,
    required this.displacementCtrl,
    required this.engineCodeCtrl,
    required this.fuelTypeOptions,
    required this.selectedFuelType,
    required this.onSelectFuelType,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RegisterLabeledField(
                label: l10n.garageFieldPower,
                controller: hpCtrl,
                hint: '503',
                unit: 'HP',
                isNumber: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RegisterLabeledField(
                label: l10n.garageFieldTorque,
                controller: torqueCtrl,
                hint: '650',
                unit: 'NM',
                isNumber: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RegisterLabeledField(
                label: '0–100',
                controller: zeroToHundredCtrl,
                hint: '3.9',
                unit: 'SEC',
                isDecimal: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RegisterLabeledField(
                label: l10n.garageFieldWeight,
                controller: weightCtrl,
                hint: '1650',
                unit: 'KG',
                isNumber: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RegisterLabeledField(
          label: l10n.garageFieldDisplacement,
          controller: displacementCtrl,
          hint: '3.0',
          unit: 'LITRE',
          isDecimal: true,
        ),
        const SizedBox(height: 16),
        RegisterFieldLabel(l10n.garageFieldEngineCode, optional: true),
        const SizedBox(height: 8),
        RegisterFormField(
            controller: engineCodeCtrl, hint: l10n.garageHintEngineCode),
        const SizedBox(height: 16),
        RegisterFieldLabel(l10n.garageFieldFuelType),
        const SizedBox(height: 8),
        RegisterSelectorTile(
          placeholder: l10n.garageHintFuelType,
          value: selectedFuelType?.name,
          onTap: () => showRegisterPicker<CarFuelTypeOptionEntity>(
            context: context,
            title: l10n.garagePickerFuelType,
            items: fuelTypeOptions,
            labelOf: (f) => f.name,
            onSelected: onSelectFuelType,
          ),
        ),
      ],
    );
  }
}
