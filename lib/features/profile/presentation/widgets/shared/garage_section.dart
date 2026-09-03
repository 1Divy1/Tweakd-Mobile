import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../garage/presentation/bloc/bloc.dart';
import '../../../../garage/presentation/bloc/state.dart';
import '../../../../garage/presentation/utils/garage_error_mapper.dart';
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
                // names the section, and the car count was noise. All the
                // owner needs here is the way to add one.
                if (isOwner) ...[
                  const _AddCarButton(),
                  const SizedBox(height: 14),
                ],
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
                        onTap: () => context.push(
                          '/garage/cars/${car.id}',
                          extra: isOwner,
                        ),
                      );
                    },
                  ),
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
}

/// Owner-only: the way to add a car, sitting above the cards. A visitor sees
/// the cars on their own, directly under the Garage tab.
class _AddCarButton extends StatelessWidget {
  const _AddCarButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => context.push('/garage/cars/add'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            AppLocalizations.of(context)!.garageAddButton,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
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
          const Icon(
            Icons.directions_car_outlined,
            size: 36,
            color: AppColors.mute,
          ),
          const SizedBox(height: 10),
          Text(
            isOwner
                ? AppLocalizations.of(context)!.garageEmptyOwner
                : AppLocalizations.of(context)!.garageEmptyVisitor,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
        style: const TextStyle(
          color: AppColors.mute,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
