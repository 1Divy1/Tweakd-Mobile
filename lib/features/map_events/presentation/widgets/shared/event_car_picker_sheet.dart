import 'package:tweakd/core/di/injection.dart';
import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/features/garage/domain/entities/car_summary.dart';
import 'package:tweakd/features/garage/presentation/bloc/bloc.dart';
import 'package:tweakd/features/garage/presentation/bloc/event.dart';
import 'package:tweakd/features/garage/presentation/bloc/state.dart';
import 'package:tweakd/features/garage/presentation/widgets/car_image.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Asks which of the viewer's own cars to register for an event — any number
/// of them, from one up to the whole garage (or up to [remainingSpots] when
/// the event has a capacity left).
///
/// Deliberately **not** `core/shared/widgets/tagging/car_picker_sheet.dart`:
/// that one picks *someone else's* car for a tag. This one is the viewer's own
/// garage, loaded through [GarageBloc] with `LoadMyGarage`.
///
/// [excludedCarIds] are cars the viewer already has a live (pending/accepted)
/// entry for in this event — shown but not selectable, so resubmitting can't
/// create a second row for the same car.
///
/// Returns the selected car ids, or null if the sheet was dismissed without
/// registering anything.
Future<List<String>?> showEventCarPickerSheet(
  BuildContext context, {
  int? remainingSpots,
  Set<String> excludedCarIds = const {},
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider<GarageBloc>(
      create: (_) => getIt<GarageBloc>()..add(const LoadMyGarage()),
      child: _EventCarPickerSheet(
        remainingSpots: remainingSpots,
        excludedCarIds: excludedCarIds,
      ),
    ),
  );
}

class _EventCarPickerSheet extends StatefulWidget {
  final int? remainingSpots;
  final Set<String> excludedCarIds;

  const _EventCarPickerSheet({
    required this.remainingSpots,
    required this.excludedCarIds,
  });

  @override
  State<_EventCarPickerSheet> createState() => _EventCarPickerSheetState();
}

class _EventCarPickerSheetState extends State<_EventCarPickerSheet> {
  final Set<String> _selected = {};

  bool get _atSelectionLimit {
    final limit = widget.remainingSpots;
    return limit != null && _selected.length >= limit;
  }

  void _toggle(String carId) {
    setState(() {
      if (_selected.contains(carId)) {
        _selected.remove(carId);
      } else if (!_atSelectionLimit) {
        _selected.add(carId);
      }
    });
  }

  void _selectAll(List<CarSummaryEntity> cars) {
    final limit = widget.remainingSpots;
    final eligible = cars
        .where((c) => !widget.excludedCarIds.contains(c.id))
        .map((c) => c.id);
    setState(() {
      _selected
        ..clear()
        ..addAll(limit == null ? eligible : eligible.take(limit));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final full = widget.remainingSpots == 0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      decoration: BoxDecoration(
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
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Text(
              l10n.mapEventsPickCarTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              full
                  ? l10n.mapEventsPickCarFull
                  : widget.remainingSpots != null
                      ? l10n.mapEventsPickCarSpotsLeft(widget.remainingSpots!)
                      : l10n.mapEventsPickCarSubtitle,
              style: TextStyle(fontSize: 12.5, color: AppColors.mute),
            ),
          ),
          Flexible(
            child: BlocBuilder<GarageBloc, GarageState>(
              builder: (context, state) => switch (state) {
                GarageLoaded(:final garage) => garage.cars.isEmpty
                    ? const _EmptyGarage()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!full)
                            _SelectAllRow(
                              cars: garage.cars,
                              excludedCarIds: widget.excludedCarIds,
                              selectedCount: _selected.length,
                              onSelectAll: () => _selectAll(garage.cars),
                              onClear: () => setState(_selected.clear),
                            ),
                          Flexible(
                            child: _CarList(
                              cars: garage.cars,
                              selected: _selected,
                              excludedCarIds: widget.excludedCarIds,
                              atSelectionLimit: _atSelectionLimit,
                              onToggle: _toggle,
                            ),
                          ),
                        ],
                      ),
                GarageError() => const _LoadFailed(),
                _ => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: FilledButton(
              onPressed: _selected.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(_selected.toList()),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                disabledBackgroundColor: AppColors.line2,
                disabledForegroundColor: AppColors.muteSoft,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
              child: Text(l10n.mapEventsPickCarRegisterCta(_selected.length)),
            ),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }
}

class _SelectAllRow extends StatelessWidget {
  final List<CarSummaryEntity> cars;
  final Set<String> excludedCarIds;
  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;

  const _SelectAllRow({
    required this.cars,
    required this.excludedCarIds,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final eligibleCount =
        cars.where((c) => !excludedCarIds.contains(c.id)).length;
    if (eligibleCount <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: selectedCount == 0 ? null : onClear,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.mute,
              visualDensity: VisualDensity.compact,
              textStyle: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            child: Text(l10n.mapEventsPickCarClearAll),
          ),
          TextButton(
            onPressed: onSelectAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              visualDensity: VisualDensity.compact,
              textStyle: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            child: Text(l10n.mapEventsPickCarSelectAll),
          ),
        ],
      ),
    );
  }
}

class _CarList extends StatelessWidget {
  final List<CarSummaryEntity> cars;
  final Set<String> selected;
  final Set<String> excludedCarIds;
  final bool atSelectionLimit;
  final ValueChanged<String> onToggle;

  const _CarList({
    required this.cars,
    required this.selected,
    required this.excludedCarIds,
    required this.atSelectionLimit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      itemCount: cars.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final car = cars[index];
        final isExcluded = excludedCarIds.contains(car.id);
        final isSelected = selected.contains(car.id);
        final isDisabled = isExcluded || (!isSelected && atSelectionLimit);

        return Material(
          color: isSelected ? AppColors.accentSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: isDisabled ? null : () => onToggle(car.id),
            borderRadius: BorderRadius.circular(16),
            child: Opacity(
              opacity: isExcluded ? 0.5 : 1,
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
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isExcluded
                                ? l10n.mapEventsPickCarAlreadyIn
                                : (car.status?.type ?? ''),
                            style: TextStyle(
                              fontSize: 12,
                              color: isExcluded
                                  ? AppColors.accent
                                  : AppColors.mute,
                            ),
                          ),
                        ],
                      ),
                    ),
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
          Icon(
            Icons.garage_outlined,
            size: 34,
            color: AppColors.muteSoft,
          ),
          const SizedBox(height: 14),
          Text(
            l10n.mapEventsPickCarEmptyTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.mapEventsPickCarEmptyBody,
            textAlign: TextAlign.center,
            style: TextStyle(
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
          Icon(
            Icons.error_outline_rounded,
            size: 28,
            color: AppColors.muteSoft,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.mapEventsErrorGeneric,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: AppColors.ink2),
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
