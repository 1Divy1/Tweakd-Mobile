import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../garage/presentation/bloc/bloc.dart';
import '../../../../garage/presentation/bloc/state.dart';
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
                  _GarageHeader(
                    count: garage.cars.length,
                    isOwner: isOwner,
                  ),
                  const SizedBox(height: 14),
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
            GarageError(:final message) => _GarageErrorView(message: message),
            _ => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}

class _GarageHeader extends StatelessWidget {
  final int count;
  final bool isOwner;

  const _GarageHeader({required this.count, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'THE GARAGE',
          style: TextStyle(
            color: AppColors.mute,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                '$count ${count == 1 ? 'Machine' : 'Machines'}',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (isOwner)
              GestureDetector(
                onTap: () => context.push('/garage/cars/add'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: const Text(
                    '+ ADD',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
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
            isOwner ? 'Your garage is empty. Add your first machine.' : 'No machines yet.',
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
        _ShimmerBox(width: 100, height: 13, radius: 4),
        const SizedBox(height: 8),
        _ShimmerBox(width: 160, height: 24, radius: 4),
        const SizedBox(height: 14),
        _ShimmerBox(width: double.infinity, height: 220, radius: 12),
        const SizedBox(height: 12),
        _ShimmerBox(width: double.infinity, height: 220, radius: 12),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
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
