import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tweakd/core/shared/bloc/tag_picker/bloc.dart';
import 'package:tweakd/core/shared/bloc/tag_picker/event.dart';
import 'package:tweakd/core/shared/bloc/tag_picker/state.dart';
import 'package:tweakd/core/shared/entities/tag_selection.dart';
import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/features/garage/domain/entities/car_summary.dart';
import 'package:tweakd/l10n/app_localizations.dart';

import 'tag_avatar.dart';

/// Opens the two-step car picker: pick a garage (your own, or a mentioned
/// person's), then a car from it. Resolves to the picked car, or null when the
/// sheet is dismissed.
///
/// Must be called from a context that can read a [TagPickerBloc] — it is passed
/// down so the sheet reuses the composer's already-loaded garages.
Future<TaggedCar?> showCarPickerSheet(
  BuildContext context, {
  required List<TaggedPerson> people,
  required Set<String> takenCarIds,
}) {
  final bloc = context.read<TagPickerBloc>();
  return showModalBottomSheet<TaggedCar>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider<TagPickerBloc>.value(
      value: bloc,
      child: _CarPickerSheet(people: people, takenCarIds: takenCarIds),
    ),
  );
}

class _CarPickerSheet extends StatefulWidget {
  final List<TaggedPerson> people;
  final Set<String> takenCarIds;

  const _CarPickerSheet({required this.people, required this.takenCarIds});

  @override
  State<_CarPickerSheet> createState() => _CarPickerSheetState();
}

class _CarPickerSheetState extends State<_CarPickerSheet> {
  /// Null = the garage chooser; [_ownGarage] = the viewer's own garage;
  /// otherwise the mentioned person whose garage is open.
  TaggedPerson? _selected;
  bool _ownSelected = false;

  void _selectPerson(TaggedPerson person) {
    setState(() {
      _selected = person;
      _ownSelected = false;
    });
    context.read<TagPickerBloc>().add(OwnerCarsRequested(person.username));
  }

  void _selectOwnGarage() {
    setState(() {
      _selected = null;
      _ownSelected = true;
    });
    context.read<TagPickerBloc>().add(const MyCarsRequested());
  }

  void _back() => setState(() {
    _selected = null;
    _ownSelected = false;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final owner = _selected;
    final onGarage = _ownSelected || owner != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                if (onGarage)
                  GestureDetector(
                    onTap: _back,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    onGarage
                        ? l10n.forumsTagChooseCar
                        : l10n.forumsTagChoosePerson,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.line),
          Expanded(
            child: !onGarage
                ? _GarageChooser(
                    people: widget.people,
                    scrollController: scrollCtrl,
                    onSelectOwn: _selectOwnGarage,
                    onSelectPerson: _selectPerson,
                  )
                : _CarChooser(
                    owner: owner,
                    takenCarIds: widget.takenCarIds,
                    scrollController: scrollCtrl,
                    onPick: (car) => Navigator.of(context).pop(car),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Step one — "Your garage" plus every mentioned person.
class _GarageChooser extends StatelessWidget {
  final List<TaggedPerson> people;
  final ScrollController scrollController;
  final VoidCallback onSelectOwn;
  final ValueChanged<TaggedPerson> onSelectPerson;

  const _GarageChooser({
    required this.people,
    required this.scrollController,
    required this.onSelectOwn,
    required this.onSelectPerson,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.garage_rounded,
              size: 19,
              color: AppColors.accent,
            ),
          ),
          title: Text(
            l10n.forumsTagYourGarage,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.mute,
          ),
          onTap: onSelectOwn,
        ),
        if (people.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Text(
              l10n.forumsTagPersonFirst,
              style: const TextStyle(
                color: AppColors.mute,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          for (final person in people) ...[
            const Divider(
              height: 1,
              color: AppColors.line2,
              indent: 20,
              endIndent: 20,
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: TagAvatar(
                username: person.username,
                avatarUrl: person.avatarUrl,
                size: 36,
              ),
              title: Text(
                '@${person.username}',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.mute,
              ),
              onTap: () => onSelectPerson(person),
            ),
          ],
      ],
    );
  }
}

/// Step two — the chosen garage's cars. [owner] null means the viewer's own
/// garage, whose cars stay taggable without a matching person tag.
class _CarChooser extends StatelessWidget {
  final TaggedPerson? owner;
  final Set<String> takenCarIds;
  final ScrollController scrollController;
  final ValueChanged<TaggedCar> onPick;

  const _CarChooser({
    required this.owner,
    required this.takenCarIds,
    required this.scrollController,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final person = owner;

    return BlocBuilder<TagPickerBloc, TagPickerState>(
      builder: (context, state) {
        final status = person == null ? state.myCarsStatus : state.carsStatus;
        final stale = person != null && state.ownerUsername != person.username;

        if (status == TagLoadStatus.loading ||
            status == TagLoadStatus.idle ||
            stale) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }
        if (status == TagLoadStatus.failure) {
          return _CenteredMessage(l10n.forumsTagLoadError);
        }

        final source = person == null ? state.myCars : state.ownerCars;
        final cars = source
            .where((c) => !takenCarIds.contains(c.id))
            .toList(growable: false);
        if (cars.isEmpty) {
          return _CenteredMessage(
            person == null ? l10n.forumsTagNoOwnCars : l10n.forumsTagNoCars,
          );
        }

        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: cars.length,
          separatorBuilder: (_, _) => const Divider(
            height: 1,
            color: AppColors.line2,
            indent: 20,
            endIndent: 20,
          ),
          itemBuilder: (_, i) => _CarRow(
            car: cars[i],
            onTap: () => onPick(
              TaggedCar(
                id: cars[i].id,
                name: '${cars[i].brand} ${cars[i].model}'.trim(),
                ownerId: person?.id ?? cars[i].ownerId ?? '',
                ownerHandle:
                    person?.username ?? cars[i].ownerUsername ?? '',
                imageUrl: cars[i].coverImage?.url,
                isOwn: person == null,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CarRow extends StatelessWidget {
  final CarSummaryEntity car;
  final VoidCallback onTap;

  const _CarRow({required this.car, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final url = car.coverImage?.url;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(
          width: 44,
          height: 44,
          child: url != null
              ? CachedNetworkImage(imageUrl: url, fit: BoxFit.cover)
              : Container(
                  color: AppColors.bg,
                  child: const Icon(
                    Icons.directions_car_rounded,
                    color: AppColors.muteSoft,
                    size: 20,
                  ),
                ),
        ),
      ),
      title: Text(
        '${car.brand} ${car.model}'.trim(),
        style: const TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final String text;
  const _CenteredMessage(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.mute,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
