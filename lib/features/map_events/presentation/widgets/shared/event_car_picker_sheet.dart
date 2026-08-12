import 'package:car_social_media_app/core/di/injection.dart';
import 'package:car_social_media_app/core/theme/app_colors.dart';
import 'package:car_social_media_app/features/garage/domain/entities/car_summary.dart';
import 'package:car_social_media_app/features/garage/presentation/bloc/bloc.dart';
import 'package:car_social_media_app/features/garage/presentation/bloc/event.dart';
import 'package:car_social_media_app/features/garage/presentation/bloc/state.dart';
import 'package:car_social_media_app/features/garage/presentation/widgets/car_image.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Asks which of the viewer's own cars to register for an event.
///
/// Deliberately **not** `core/shared/widgets/tagging/car_picker_sheet.dart`:
/// that one picks *someone else's* car for a tag. This one is the viewer's own
/// garage, loaded through [GarageBloc] with `LoadMyGarage`.
///
/// Returns the chosen car's id, or null if the sheet was dismissed.
Future<String?> showEventCarPickerSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider<GarageBloc>(
      create: (_) => getIt<GarageBloc>()..add(const LoadMyGarage()),
      child: const _EventCarPickerSheet(),
    ),
  );
}

class _EventCarPickerSheet extends StatelessWidget {
  const _EventCarPickerSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Text(
              l10n.mapEventsPickCarTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
          Flexible(
            child: BlocBuilder<GarageBloc, GarageState>(
              builder: (context, state) => switch (state) {
                GarageLoaded(:final garage) => garage.cars.isEmpty
                    ? const _EmptyGarage()
                    : _CarList(cars: garage.cars),
                GarageError() => const _LoadFailed(),
                _ => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              },
            ),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 12),
        ],
      ),
    );
  }
}

class _CarList extends StatelessWidget {
  final List<CarSummaryEntity> cars;

  const _CarList({required this.cars});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      itemCount: cars.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final car = cars[index];
        return Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => Navigator.of(context).pop(car.id),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(10),
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
                          '${car.brand} ${car.model}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        if (car.status?.type case final status?
                            when status.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            status,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.mute,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.muteSoft,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyGarage extends StatelessWidget {
  const _EmptyGarage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.garage_outlined,
            size: 34,
            color: AppColors.muteSoft,
          ),
          const SizedBox(height: 14),
          Text(
            l10n.mapEventsPickCarEmptyTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.mapEventsPickCarEmptyBody,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: AppColors.ink2,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/garage/cars/add');
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            child: Text(l10n.mapEventsPickCarAdd),
          ),
        ],
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 28,
            color: AppColors.muteSoft,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.mapEventsErrorGeneric,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, color: AppColors.ink2),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () =>
                context.read<GarageBloc>().add(const LoadMyGarage()),
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            child: Text(l10n.mapEventsRetry),
          ),
        ],
      ),
    );
  }
}
