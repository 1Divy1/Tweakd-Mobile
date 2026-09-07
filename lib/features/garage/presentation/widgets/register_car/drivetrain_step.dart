import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reference_data.dart';
import 'register_car_fields.dart';

/// Config tab of the specs step — drivetrain layout, paint colour and mileage
/// unit. The step title and the tab bar belong to [SpecsStep].
class DrivetrainStep extends StatelessWidget {
  final List<CarDrivetrainEntity> drivetrains;
  final List<CarColorEntity> colors;
  final List<CarDistanceUnitEntity> distanceUnits;
  final CarDrivetrainEntity? selectedDrivetrain;
  final CarColorEntity? selectedColor;
  final CarDistanceUnitEntity? selectedDistanceUnit;
  final TextEditingController mileageCtrl;
  final ValueChanged<CarDrivetrainEntity> onSelectDrivetrain;
  final ValueChanged<CarColorEntity> onSelectColor;
  final ValueChanged<CarDistanceUnitEntity> onSelectDistanceUnit;

  const DrivetrainStep({
    super.key,
    required this.drivetrains,
    required this.colors,
    required this.distanceUnits,
    required this.selectedDrivetrain,
    required this.selectedColor,
    required this.selectedDistanceUnit,
    required this.mileageCtrl,
    required this.onSelectDrivetrain,
    required this.onSelectColor,
    required this.onSelectDistanceUnit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegisterFieldLabel(l10n.garageFieldDrivetrain),
        const SizedBox(height: 8),
        RegisterSelectorTile(
          placeholder: l10n.garageHintDrivetrain,
          value: selectedDrivetrain?.name,
          onTap: () => showRegisterPicker<CarDrivetrainEntity>(
            context: context,
            title: l10n.garagePickerDrivetrain,
            items: drivetrains,
            labelOf: (d) => d.name,
            onSelected: onSelectDrivetrain,
          ),
        ),
        const SizedBox(height: 16),
        RegisterFieldLabel(l10n.garageFieldColor),
        const SizedBox(height: 8),
        RegisterSelectorTile(
          placeholder: l10n.garageHintColor,
          value: selectedColor?.name,
          leading: selectedColor != null
              ? _ColorSwatch(code: selectedColor!.colorCode)
              : null,
          onTap: () => showRegisterPicker<CarColorEntity>(
            context: context,
            title: l10n.garagePickerColor,
            items: colors,
            labelOf: (c) => c.name,
            leadingOf: (c) => _ColorSwatch(code: c.colorCode),
            onSelected: onSelectColor,
          ),
        ),
        const SizedBox(height: 16),
        RegisterFieldLabel(l10n.garageFieldMileageUnit),
        const SizedBox(height: 8),
        _MileageToggle(
          units: distanceUnits,
          selected: selectedDistanceUnit,
          onSelect: onSelectDistanceUnit,
        ),
        const SizedBox(height: 16),
        RegisterFieldLabel(l10n.garageFieldMileage, optional: true),
        const SizedBox(height: 8),
        RegisterFormField(
          controller: mileageCtrl,
          hint: l10n.garageHintMileage,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          unit: selectedDistanceUnit?.name,
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final String code;
  const _ColorSwatch({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: parseColorCode(code),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

/// Segmented control for the mileage unit (e.g. Kilometers / Miles).
class _MileageToggle extends StatelessWidget {
  final List<CarDistanceUnitEntity> units;
  final CarDistanceUnitEntity? selected;
  final ValueChanged<CarDistanceUnitEntity> onSelect;

  const _MileageToggle({
    required this.units,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(kRegisterRadius),
        boxShadow: kRegisterSurfaceShadow,
      ),
      child: Row(
        children: [
          for (final unit in units)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(unit),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected?.id == unit.id
                        ? AppColors.ink
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(kRegisterRadius - 5),
                  ),
                  child: Center(
                    child: Text(
                      unit.name.toUpperCase(),
                      style: TextStyle(
                        color: selected?.id == unit.id
                            ? Colors.white
                            : AppColors.mute,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
