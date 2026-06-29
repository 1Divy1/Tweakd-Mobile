import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reference_data.dart';
import 'register_car_fields.dart';

/// Step 2 — power, torque and weight figures, with a live power-to-weight
/// readout derived locally from the entered horsepower and weight.
class PerformanceStep extends StatefulWidget {
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
  State<PerformanceStep> createState() => _PerformanceStepState();
}

class _PerformanceStepState extends State<PerformanceStep> {
  @override
  void initState() {
    super.initState();
    widget.hpCtrl.addListener(_onChange);
    widget.weightCtrl.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.hpCtrl.removeListener(_onChange);
    widget.weightCtrl.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  /// Horsepower per metric tonne, or null until both inputs are valid.
  int? get _powerToWeight {
    final hp = int.tryParse(widget.hpCtrl.text.trim());
    final kg = int.tryParse(widget.weightCtrl.text.trim());
    if (hp == null || kg == null || kg <= 0) return null;
    return (hp / (kg / 1000)).round();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegisterSectionHeader(
          label: l10n.garageRegisterPerformanceLabel,
          title: l10n.garageRegisterPerformanceTitle,
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RegisterLabeledField(
                label: l10n.garageFieldPower,
                controller: widget.hpCtrl,
                hint: '503',
                unit: 'HP',
                isNumber: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RegisterLabeledField(
                label: l10n.garageFieldTorque,
                controller: widget.torqueCtrl,
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
                controller: widget.zeroToHundredCtrl,
                hint: '3.9',
                unit: 'SEC',
                isDecimal: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RegisterLabeledField(
                label: l10n.garageFieldWeight,
                controller: widget.weightCtrl,
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
          controller: widget.displacementCtrl,
          hint: '3.0',
          unit: 'LITRE',
          isDecimal: true,
        ),
        const SizedBox(height: 16),
        RegisterFieldLabel(l10n.garageFieldEngineCode, optional: true),
        const SizedBox(height: 8),
        RegisterFormField(
            controller: widget.engineCodeCtrl, hint: l10n.garageHintEngineCode),
        const SizedBox(height: 16),
        RegisterFieldLabel(l10n.garageFieldFuelType),
        const SizedBox(height: 8),
        RegisterSelectorTile(
          placeholder: l10n.garageHintFuelType,
          value: widget.selectedFuelType?.name,
          onTap: () => showRegisterPicker<CarFuelTypeOptionEntity>(
            context: context,
            title: l10n.garagePickerFuelType,
            items: widget.fuelTypeOptions,
            labelOf: (f) => f.name,
            onSelected: widget.onSelectFuelType,
          ),
        ),
        const SizedBox(height: 20),
        _PowerToWeightCard(value: _powerToWeight),
      ],
    );
  }
}

class _PowerToWeightCard extends StatelessWidget {
  final int? value;
  const _PowerToWeightCard({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.garagePowerToWeight,
                  style: TextStyle(
                    color: Colors.white.withAlpha(140),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value?.toString() ?? '—',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'HP / T',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(38),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.bolt_rounded,
                color: AppColors.accent, size: 26),
          ),
        ],
      ),
    );
  }
}
