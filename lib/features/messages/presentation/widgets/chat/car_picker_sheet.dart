import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../garage/domain/entities/car_summary.dart';
import '../../../../garage/presentation/widgets/car_image.dart';
import '../../../domain/entities/message.dart';
import '../../bloc/car_picker/cubit.dart';
import '../../bloc/car_picker/state.dart';

/// Maximum cars shareable in one message (backend rejects >10).
const int kMaxTaggedCars = 10;

DmTaggedCarEntity _toTagged(CarSummaryEntity car) => DmTaggedCarEntity(
      id: car.id,
      brand: car.brand,
      model: car.model,
      coverImageUrl: car.coverImage?.url,
    );

/// Opens the "Share cars" sheet listing the viewer's own garage cars for
/// multi-select (max [kMaxTaggedCars]). Resolves with the chosen cars, or null
/// if dismissed without confirming. [initialSelected] pre-checks the cars
/// already staged in the composer.
Future<List<DmTaggedCarEntity>?> showCarPickerSheet(
  BuildContext context, {
  required List<DmTaggedCarEntity> initialSelected,
}) {
  return showModalBottomSheet<List<DmTaggedCarEntity>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider<GarageCarsCubit>(
      create: (_) => getIt<GarageCarsCubit>()..load(),
      child: _CarPickerSheet(initialSelected: initialSelected),
    ),
  );
}

class _CarPickerSheet extends StatefulWidget {
  final List<DmTaggedCarEntity> initialSelected;

  const _CarPickerSheet({required this.initialSelected});

  @override
  State<_CarPickerSheet> createState() => _CarPickerSheetState();
}

class _CarPickerSheetState extends State<_CarPickerSheet> {
  /// Ordered selection (id → car). Insertion order is the share order.
  late final Map<String, DmTaggedCarEntity> _selected = {
    for (final car in widget.initialSelected) car.id: car,
  };

  bool get _atLimit => _selected.length >= kMaxTaggedCars;

  void _toggle(CarSummaryEntity car) {
    setState(() {
      if (_selected.containsKey(car.id)) {
        _selected.remove(car.id);
      } else if (!_atLimit) {
        _selected[car.id] = _toTagged(car);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.62,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.muteSoft,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.messagesShareCarsTitle,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _atLimit
                ? l10n.messagesShareCarsLimit(kMaxTaggedCars)
                : l10n.messagesShareCarsSubtitle,
            style: TextStyle(
              color: _atLimit ? AppColors.accent : AppColors.mute,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<GarageCarsCubit, GarageCarsState>(
              builder: (context, state) {
                switch (state.status) {
                  case GarageCarsStatus.loading:
                    return Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accent,
                        ),
                      ),
                    );
                  case GarageCarsStatus.error:
                    return _CenteredHint(text: l10n.messagesShareCarsError);
                  case GarageCarsStatus.loaded:
                    if (state.cars.isEmpty) {
                      return _CenteredHint(text: l10n.messagesShareCarsEmpty);
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 6, bottom: 12),
                      itemCount: state.cars.length,
                      itemBuilder: (context, index) {
                        final car = state.cars[index];
                        final selected = _selected.containsKey(car.id);
                        return _CarRow(
                          car: car,
                          selected: selected,
                          // Rows that would exceed the cap can't be selected,
                          // but already-selected rows stay tappable (to remove).
                          enabled: selected || !_atLimit,
                          onTap: () => _toggle(car),
                        );
                      },
                    );
                }
              },
            ),
          ),
          _ConfirmBar(
            count: _selected.length,
            // When the sheet opened with staged cars, confirming an empty
            // selection is a deliberate "clear all" — keep the button enabled.
            allowEmpty: widget.initialSelected.isNotEmpty,
            onConfirm: () =>
                Navigator.of(context).pop(_selected.values.toList()),
          ),
        ],
      ),
    );
  }
}

class _CenteredHint extends StatelessWidget {
  final String text;

  const _CenteredHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.mute,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CarRow extends StatelessWidget {
  final CarSummaryEntity car;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _CarRow({
    required this.car,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              CarImage(
                imageUrl: car.coverImage?.url,
                width: 66,
                height: 48,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.brand,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      car.model,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.mute,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _Checkmark(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _Checkmark extends StatelessWidget {
  final bool selected;

  const _Checkmark({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: selected ? AppColors.accent : Colors.transparent,
        shape: BoxShape.circle,
        border: selected ? null : Border.all(color: AppColors.muteSoft, width: 2),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
          : null,
    );
  }
}

/// Bottom confirm button — disabled until at least one car is picked.
class _ConfirmBar extends StatelessWidget {
  final int count;
  final bool allowEmpty;
  final VoidCallback onConfirm;

  const _ConfirmBar({
    required this.count,
    required this.allowEmpty,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final enabled = count > 0 || allowEmpty;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: enabled ? onConfirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              disabledBackgroundColor: AppColors.muteSoft,
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              enabled
                  ? l10n.messagesShareCarsConfirm(count)
                  : l10n.messagesShareCarsConfirmEmpty,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
