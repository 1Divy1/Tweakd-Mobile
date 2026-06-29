import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:car_social_media_app/core/shared/entities/search_result.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../bloc/tag_picker/bloc.dart';
import '../../bloc/tag_picker/event.dart';
import '../../bloc/tag_picker/state.dart';
import 'create_post_fields.dart';

/// A car linked to the post, surfaced as a chip on the tags step. [ownerId] is
/// the tagged person who owns it — kept so the car is removed when its owner is
/// untagged (the backend rejects a car whose owner isn't also tagged).
class TaggedCar {
  final String id;
  final String name;
  final String ownerId;
  final String ownerHandle;
  final String? imageUrl;

  const TaggedCar({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.ownerHandle,
    this.imageUrl,
  });
}

/// A person tagged in the post, surfaced as a chip on the tags step.
class TaggedPerson {
  final String id;
  final String username;
  final String? avatarUrl;

  const TaggedPerson({
    required this.id,
    required this.username,
    this.avatarUrl,
  });
}

/// Step 3 — tag people (live username search) and link cars from a tagged
/// person's garage. People are tagged first; a car can only be picked from a
/// person who is already tagged, which keeps the owner-must-be-tagged
/// constraint satisfied client-side.
class TagsStep extends StatelessWidget {
  final List<TaggedPerson> people;
  final List<TaggedCar> cars;
  final TextEditingController peopleSearchCtrl;
  final ValueChanged<TaggedPerson> onAddPerson;
  final ValueChanged<int> onRemovePerson;
  final ValueChanged<TaggedCar> onAddCar;
  final ValueChanged<int> onRemoveCar;

  const TagsStep({
    super.key,
    required this.people,
    required this.cars,
    required this.peopleSearchCtrl,
    required this.onAddPerson,
    required this.onRemovePerson,
    required this.onAddCar,
    required this.onRemoveCar,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostSectionHeader(
          label: '03 — ${l10n.postStepTags}',
          title: l10n.postTagsTitle,
          subtitle: l10n.postTagsSubtitle,
        ),
        const SizedBox(height: 24),

        // ── People ──────────────────────────────────────────────────────────
        PostFieldLabel(l10n.postTagsPeople, count: people.length),
        const SizedBox(height: 12),
        PostSearchField(
          hint: l10n.postTagsPeopleHint,
          controller: peopleSearchCtrl,
          onChanged: (q) =>
              context.read<TagPickerBloc>().add(PeopleQueryChanged(q)),
        ),
        _PeopleResults(
          taggedIds: people.map((p) => p.id).toSet(),
          onPick: (result) {
            onAddPerson(TaggedPerson(
              id: result.id,
              username: result.username,
              avatarUrl: result.avatarUrl,
            ));
            peopleSearchCtrl.clear();
            context.read<TagPickerBloc>().add(const PeopleResultsCleared());
          },
        ),
        if (people.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < people.length; i++)
                _PersonChip(
                  person: people[i],
                  onRemove: () => onRemovePerson(i),
                ),
            ],
          ),
        ],
        const SizedBox(height: 28),

        // ── Cars ────────────────────────────────────────────────────────────
        PostFieldLabel(l10n.postTagsCars, count: cars.length),
        const SizedBox(height: 12),
        _AddCarTile(
          onTap: () => _openCarPicker(context),
        ),
        if (cars.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < cars.length; i++)
                _CarChip(car: cars[i], onRemove: () => onRemoveCar(i)),
            ],
          ),
        ],
      ],
    );
  }

  void _openCarPicker(BuildContext context) {
    final taggedCarIds = cars.map((c) => c.id).toSet();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<TagPickerBloc>(),
        child: _CarPickerSheet(
          people: people,
          taggedCarIds: taggedCarIds,
          onPick: onAddCar,
        ),
      ),
    );
  }
}

/// The people typeahead results panel, shown under the search field while a
/// query is active. Already-tagged people are filtered out.
class _PeopleResults extends StatelessWidget {
  final Set<String> taggedIds;
  final ValueChanged<SearchResultEntity> onPick;

  const _PeopleResults({required this.taggedIds, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<TagPickerBloc, TagPickerState>(
      buildWhen: (a, b) =>
          a.peopleStatus != b.peopleStatus ||
          a.peopleResults != b.peopleResults,
      builder: (context, state) {
        if (state.peopleStatus == TagLoadStatus.idle) {
          return const SizedBox.shrink();
        }

        final results = state.peopleResults
            .where((r) => !taggedIds.contains(r.id))
            .toList();

        return Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: switch (state.peopleStatus) {
            TagLoadStatus.loading => const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.mute,
                    ),
                  ),
                ),
              ),
            TagLoadStatus.failure => _ResultMessage(l10n.postTagsLoadError),
            TagLoadStatus.success when results.isEmpty =>
              _ResultMessage(l10n.postTagsNoPeopleFound),
            _ => Column(
                children: [
                  for (var i = 0; i < results.length; i++) ...[
                    if (i > 0)
                      const Divider(
                          height: 1, color: AppColors.line2, indent: 14),
                    _PersonResultTile(
                      result: results[i],
                      onTap: () => onPick(results[i]),
                    ),
                  ],
                ],
              ),
          },
        );
      },
    );
  }
}

class _ResultMessage extends StatelessWidget {
  final String text;
  const _ResultMessage(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.muteSoft,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PersonResultTile extends StatelessWidget {
  final SearchResultEntity result;
  final VoidCallback onTap;

  const _PersonResultTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            _Avatar(username: result.username, avatarUrl: result.avatarUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '@${result.username}',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.add_rounded, color: AppColors.accent, size: 22),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet that walks the user from a tagged person to one of their cars.
class _CarPickerSheet extends StatefulWidget {
  final List<TaggedPerson> people;
  final Set<String> taggedCarIds;
  final ValueChanged<TaggedCar> onPick;

  const _CarPickerSheet({
    required this.people,
    required this.taggedCarIds,
    required this.onPick,
  });

  @override
  State<_CarPickerSheet> createState() => _CarPickerSheetState();
}

class _CarPickerSheetState extends State<_CarPickerSheet> {
  TaggedPerson? _selected;

  void _selectPerson(TaggedPerson person) {
    setState(() => _selected = person);
    context.read<TagPickerBloc>().add(OwnerCarsRequested(person.username));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selected = _selected;

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
                if (selected != null)
                  GestureDetector(
                    onTap: () => setState(() => _selected = null),
                    child: const Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Icon(Icons.arrow_back_rounded,
                          size: 20, color: AppColors.ink),
                    ),
                  ),
                Expanded(
                  child: Text(
                    selected == null
                        ? l10n.postTagsChoosePerson
                        : l10n.postTagsChooseCar,
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
            child: selected == null
                ? _PersonChooser(
                    people: widget.people,
                    scrollController: scrollCtrl,
                    onSelect: _selectPerson,
                  )
                : _CarChooser(
                    owner: selected,
                    taggedCarIds: widget.taggedCarIds,
                    scrollController: scrollCtrl,
                    onPick: (car) {
                      widget.onPick(car);
                      Navigator.of(context).pop();
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PersonChooser extends StatelessWidget {
  final List<TaggedPerson> people;
  final ScrollController scrollController;
  final ValueChanged<TaggedPerson> onSelect;

  const _PersonChooser({
    required this.people,
    required this.scrollController,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (people.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l10n.postTagsTagPersonFirst,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.mute,
              fontSize: 15,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: people.length,
      separatorBuilder: (_, _) => const Divider(
          height: 1, color: AppColors.line2, indent: 20, endIndent: 20),
      itemBuilder: (_, i) {
        final person = people[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          leading: _Avatar(
              username: person.username, avatarUrl: person.avatarUrl),
          title: Text(
            '@${person.username}',
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: AppColors.mute),
          onTap: () => onSelect(person),
        );
      },
    );
  }
}

class _CarChooser extends StatelessWidget {
  final TaggedPerson owner;
  final Set<String> taggedCarIds;
  final ScrollController scrollController;
  final ValueChanged<TaggedCar> onPick;

  const _CarChooser({
    required this.owner,
    required this.taggedCarIds,
    required this.scrollController,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<TagPickerBloc, TagPickerState>(
      builder: (context, state) {
        if (state.carsStatus == TagLoadStatus.loading ||
            state.ownerUsername != owner.username) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }
        if (state.carsStatus == TagLoadStatus.failure) {
          return _CenteredMessage(l10n.postTagsLoadError);
        }
        final cars = state.ownerCars
            .where((c) => !taggedCarIds.contains(c.id))
            .toList();
        if (cars.isEmpty) {
          return _CenteredMessage(l10n.postTagsNoCars);
        }
        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: cars.length,
          separatorBuilder: (_, _) => const Divider(
              height: 1, color: AppColors.line2, indent: 20, endIndent: 20),
          itemBuilder: (_, i) {
            final car = cars[i];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: car.coverImage != null
                      ? CachedNetworkImage(
                          imageUrl: car.coverImage!.url, fit: BoxFit.cover)
                      : Container(
                          color: AppColors.bg,
                          child: const Icon(Icons.directions_car_rounded,
                              color: AppColors.muteSoft, size: 20),
                        ),
                ),
              ),
              title: Text(
                '${car.brand} ${car.model}',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              onTap: () => onPick(TaggedCar(
                id: car.id,
                name: '${car.brand} ${car.model}',
                ownerId: owner.id,
                ownerHandle: owner.username,
                imageUrl: car.coverImage?.url,
              )),
            );
          },
        );
      },
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

class _AddCarTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddCarTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.accent, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.postTagsAddCar,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String username;
  final String? avatarUrl;

  const _Avatar({required this.username, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final initial =
        username.isNotEmpty ? username.characters.first.toUpperCase() : '?';
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.accentSoft,
      backgroundImage:
          avatarUrl != null ? CachedNetworkImageProvider(avatarUrl!) : null,
      child: avatarUrl == null
          ? Text(
              initial,
              style: const TextStyle(
                color: AppColors.accentHot,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            )
          : null,
    );
  }
}

class _CarChip extends StatelessWidget {
  final TaggedCar car;
  final VoidCallback onRemove;

  const _CarChip({required this.car, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: SizedBox(
              width: 38,
              height: 38,
              child: car.imageUrl != null
                  ? CachedNetworkImage(imageUrl: car.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.bg,
                      child: const Icon(Icons.directions_car_rounded,
                          color: AppColors.muteSoft, size: 20),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                car.name,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (car.ownerHandle.isNotEmpty)
                Text(
                  '@${car.ownerHandle}',
                  style: const TextStyle(
                    color: AppColors.mute,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          _RemoveButton(onTap: onRemove),
        ],
      ),
    );
  }
}

class _PersonChip extends StatelessWidget {
  final TaggedPerson person;
  final VoidCallback onRemove;

  const _PersonChip({required this.person, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Avatar(username: person.username, avatarUrl: person.avatarUrl),
          const SizedBox(width: 10),
          Text(
            '@${person.username}',
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10),
          _RemoveButton(onTap: onRemove),
        ],
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RemoveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: AppColors.line),
        ),
        child: const Icon(Icons.close_rounded, size: 14, color: AppColors.mute),
      ),
    );
  }
}
