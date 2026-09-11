import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reference_data.dart';
import 'drivetrain_step.dart';
import 'identity_step.dart';
import 'performance_step.dart';
import 'register_car_fields.dart';

/// The three groups of technical detail that used to be three separate wizard
/// steps.
enum SpecsTab { basics, power, config }

/// First step — everything the car *is*, on one screen.
///
/// Make/model/year, engine figures and drivetrain are all the same kind of
/// answer — facts off the registration document — so pushing them through
/// three sequential screens made the flow feel longer than the work actually
/// is. They now share a screen and a tab bar, which also lets an owner jump
/// straight back to the one figure they mistyped instead of walking the wizard.
///
/// The active tab is owned by the page, not by this widget: a failed
/// validation has to be able to pull the user to the tab holding the missing
/// field.
class SpecsStep extends StatelessWidget {
  final SpecsTab tab;
  final ValueChanged<SpecsTab> onTabChanged;

  // Basics
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

  // Power
  final TextEditingController hpCtrl;
  final TextEditingController torqueCtrl;
  final TextEditingController zeroToHundredCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController displacementCtrl;
  final TextEditingController engineCodeCtrl;
  final List<CarFuelTypeOptionEntity> fuelTypeOptions;
  final CarFuelTypeOptionEntity? selectedFuelType;
  final ValueChanged<CarFuelTypeOptionEntity> onSelectFuelType;

  // Config
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

  const SpecsStep({
    super.key,
    required this.tab,
    required this.onTabChanged,
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
    required this.hpCtrl,
    required this.torqueCtrl,
    required this.zeroToHundredCtrl,
    required this.weightCtrl,
    required this.displacementCtrl,
    required this.engineCodeCtrl,
    required this.fuelTypeOptions,
    required this.selectedFuelType,
    required this.onSelectFuelType,
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
        RegisterSectionHeader(title: l10n.garageRegisterSpecsTitle),
        const SizedBox(height: 18),
        SpecsTabs(active: tab, onChanged: onTabChanged),
        const SizedBox(height: 24),
        switch (tab) {
          SpecsTab.basics => IdentityStep(
              selectedBrand: selectedBrand,
              selectedModel: selectedModel,
              brands: brands,
              models: models,
              modelsLoading: modelsLoading,
              yearCtrl: yearCtrl,
              chassisCodeCtrl: chassisCodeCtrl,
              modelCodeCtrl: modelCodeCtrl,
              onSelectBrand: onSelectBrand,
              onSelectModel: onSelectModel,
            ),
          SpecsTab.power => PerformanceStep(
              hpCtrl: hpCtrl,
              torqueCtrl: torqueCtrl,
              zeroToHundredCtrl: zeroToHundredCtrl,
              weightCtrl: weightCtrl,
              displacementCtrl: displacementCtrl,
              engineCodeCtrl: engineCodeCtrl,
              fuelTypeOptions: fuelTypeOptions,
              selectedFuelType: selectedFuelType,
              onSelectFuelType: onSelectFuelType,
            ),
          SpecsTab.config => DrivetrainStep(
              drivetrains: drivetrains,
              colors: colors,
              distanceUnits: distanceUnits,
              selectedDrivetrain: selectedDrivetrain,
              selectedColor: selectedColor,
              selectedDistanceUnit: selectedDistanceUnit,
              mileageCtrl: mileageCtrl,
              onSelectDrivetrain: onSelectDrivetrain,
              onSelectColor: onSelectColor,
              onSelectDistanceUnit: onSelectDistanceUnit,
            ),
        },
      ],
    );
  }
}

/// The Basics / Power / Config switcher.
///
/// A raised white pill on a recessed track — the segmented control the profile
/// and event pages already use, so the app keeps one idea of what switching
/// sections looks like. Deliberately *not* the inverted ink pill of the
/// mileage-unit toggle further down the config tab: that one sets a value,
/// this one moves you between screens, and on a screen showing both they must
/// not read as the same control.
class SpecsTabs extends StatelessWidget {
  final SpecsTab active;
  final ValueChanged<SpecsTab> onChanged;

  const SpecsTabs({super.key, required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.line,
        borderRadius: BorderRadius.circular(kRegisterRadius),
      ),
      child: Row(
        children: [
          for (final (tab, label) in <(SpecsTab, String)>[
            (SpecsTab.basics, l10n.garageSpecsTabBasics),
            (SpecsTab.power, l10n.garageSpecsTabPower),
            (SpecsTab.config, l10n.garageSpecsTabConfig),
          ])
            Expanded(
              child: _Segment(
                label: label,
                isActive: active == tab,
                onTap: () => onChanged(tab),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      child: GestureDetector(
        onTap: onTap,
        // Transparent segments still have to answer taps, or only the label's
        // own glyphs would be tappable.
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 44,
          decoration: BoxDecoration(
            color: isActive ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(kRegisterRadius - 4),
            boxShadow: isActive ? kRegisterSurfaceShadow : null,
          ),
          child: Center(
            // Three labels across a 320pt screen leaves no room to grow, so
            // they scale down rather than truncate.
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: RegisterFitted(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive ? AppColors.ink : AppColors.mute,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
