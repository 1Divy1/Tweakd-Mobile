import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/car_summary.dart';
import '../car_image.dart';
import '../register_car/register_car_fields.dart';

/// Step 1 of the add-modification flow — which of the viewer's cars the work
/// went into. Only shown when the garage holds more than one car.
class AddModCarStep extends StatelessWidget {
  final List<CarSummaryEntity> cars;
  final String? selectedCarId;
  final ValueChanged<String> onSelect;

  const AddModCarStep({
    super.key,
    required this.cars,
    required this.selectedCarId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegisterSectionHeader(
          title: l10n.garageAddModCarTitle,
          subtitle: l10n.garageAddModCarSubtitle,
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < cars.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _CarOption(
            car: cars[i],
            isSelected: cars[i].id == selectedCarId,
            onTap: () => onSelect(cars[i].id),
          ),
        ],
      ],
    );
  }
}

class _CarOption extends StatelessWidget {
  final CarSummaryEntity car;
  final bool isSelected;
  final VoidCallback onTap;

  const _CarOption({
    required this.car,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = '${car.brand} ${car.model}';

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(kRegisterRadius),
            boxShadow: kRegisterSurfaceShadow,
          ),
          child: Row(
            children: [
              CarImage(
                imageUrl: car.coverImage?.url,
                width: 76,
                height: 56,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (car.year != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        car.year.toString(),
                        style: TextStyle(
                          color: AppColors.mute,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: isSelected ? AppColors.accent : AppColors.muteSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What the add-modification flow shows when the garage is empty: there is
/// nothing to log work against, so it points at adding a car first.
class AddModNoCarsView extends StatelessWidget {
  final VoidCallback onAddCar;

  const AddModNoCarsView({super.key, required this.onAddCar});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.garage_outlined,
                size: 40,
                color: AppColors.muteSoft,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.garageAddModNoCarsTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.garageAddModNoCarsBody,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.mute,
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: onAddCar,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(kRegisterRadius),
                  ),
                  child: Text(
                    l10n.garageAddModAddCar,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
