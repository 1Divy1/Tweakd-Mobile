import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../garage/presentation/bloc/bloc.dart';
import '../../../../garage/presentation/bloc/event.dart';
import '../../../../garage/presentation/bloc/state.dart';
import '../../../../garage/presentation/utils/garage_error_mapper.dart';
import '../../../../garage/presentation/widgets/add_car_button.dart';
import '../../../../garage/presentation/widgets/garage_car_card.dart';

class GarageSection extends StatelessWidget {
  final bool isOwner;

  const GarageSection({super.key, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GarageBloc, GarageState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: switch (state) {
            GarageLoading() => const _GarageLoadingView(),
            GarageLoaded(:final garage) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // No section heading: the Garage tab right above already
                // names the section, and the car count was noise.
                if (garage.cars.isEmpty)
                  _GarageEmptyView(isOwner: isOwner)
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: garage.cars.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final car = garage.cars[index];
                      return GarageCarCard(
                        car: car,
                        onTap: () => _openCar(context, car.id),
                      );
                    },
                  ),
                // Adding a car is rare, so it trails the garage as a quiet link
                // rather than leading it.
                if (isOwner) ...[
                  const SizedBox(height: 8),
                  AddCarButton(
                    label: AppLocalizations.of(context)!.garageAddNewCar,
                    onTap: () => _addCar(context),
                  ),
                ],
              ],
            ),
            GarageError(:final code) => _GarageErrorView(
              message: garageErrorMessage(AppLocalizations.of(context)!, code),
            ),
            _ => const SizedBox.shrink(),
          },
        );
      },
    );
  }

  /// Opens the car page; it pops `true` when the owner deleted the car there,
  /// and the car leaves the list without a refetch.
  Future<void> _openCar(BuildContext context, String carId) async {
    final bloc = context.read<GarageBloc>();
    final deleted =
        await context.push<bool>('/garage/cars/$carId', extra: isOwner);
    if (deleted == true) bloc.add(CarRemovedFromGarage(carId));
  }

  /// Opens the add-car wizard and reloads the garage on the way back, so a
  /// new car shows up straight away.
  Future<void> _addCar(BuildContext context) async {
    final bloc = context.read<GarageBloc>();
    await context.push('/garage/cars/add');
    bloc.add(const LoadMyGarage());
  }
}

class _GarageEmptyView extends StatelessWidget {
  final bool isOwner;

  const _GarageEmptyView({required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(Icons.directions_car_outlined, size: 36, color: AppColors.mute),
          const SizedBox(height: 10),
          Text(
            isOwner
                ? AppLocalizations.of(context)!.garageEmptyOwner
                : AppLocalizations.of(context)!.garageEmptyVisitor,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.mute,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _GarageLoadingView extends StatelessWidget {
  const _GarageLoadingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShimmerBox(width: double.infinity, height: 220, radius: 18),
        const SizedBox(height: 12),
        _ShimmerBox(width: double.infinity, height: 220, radius: 18),
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.line,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _GarageErrorView extends StatelessWidget {
  final String message;

  const _GarageErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.mute,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
