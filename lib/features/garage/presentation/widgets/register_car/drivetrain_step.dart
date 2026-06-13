import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/reference_data.dart';
import 'register_car_fields.dart';

/// Step 3 — drivetrain layout, paint colour and mileage unit.
class DrivetrainStep extends StatelessWidget {
  final List<CarDrivetrainEntity> drivetrains;
  final List<CarColorEntity> colors;
  final List<CarDistanceUnitEntity> distanceUnits;
  final CarDrivetrainEntity? selectedDrivetrain;
  final CarColorEntity? selectedColor;
  final CarDistanceUnitEntity? selectedDistanceUnit;
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
    required this.onSelectDrivetrain,
    required this.onSelectColor,
    required this.onSelectDistanceUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RegisterSectionHeader(
          label: '03 — CONFIGURATION',
          title: 'Configuration',
        ),
        const SizedBox(height: 20),
        const RegisterFieldLabel('DRIVETRAIN'),
        const SizedBox(height: 8),
        RegisterSelectorTile(
          placeholder: 'e.g. Rear-Wheel Drive',
          value: selectedDrivetrain?.name,
          onTap: () => showRegisterPicker<CarDrivetrainEntity>(
            context: context,
            title: 'Select Drivetrain',
            items: drivetrains,
            labelOf: (d) => d.name,
            onSelected: onSelectDrivetrain,
          ),
        ),
        const SizedBox(height: 16),
        const RegisterFieldLabel('COLOR'),
        const SizedBox(height: 8),
        RegisterSelectorTile(
          placeholder: 'e.g. Inka Orange',
          value: selectedColor?.name,
          leading: selectedColor != null
              ? _ColorSwatch(code: selectedColor!.colorCode)
              : null,
          onTap: () => showRegisterPicker<CarColorEntity>(
            context: context,
            title: 'Select Color',
            items: colors,
            labelOf: (c) => c.name,
            leadingOf: (c) => _ColorSwatch(code: c.colorCode),
            onSelected: onSelectColor,
          ),
        ),
        const SizedBox(height: 16),
        const RegisterFieldLabel('MILEAGE UNIT'),
        const SizedBox(height: 8),
        _MileageToggle(
          units: distanceUnits,
          selected: selectedDistanceUnit,
          onSelect: onSelectDistanceUnit,
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
        border: Border.all(color: AppColors.line),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
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
                    borderRadius: BorderRadius.circular(10),
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
