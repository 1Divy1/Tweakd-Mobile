import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:car_social_media_app/core/shared/bloc/tag_picker/bloc.dart';
import 'package:car_social_media_app/core/shared/bloc/tag_picker/event.dart';
import 'package:car_social_media_app/core/shared/bloc/tag_picker/state.dart';
import 'package:car_social_media_app/core/shared/entities/search_result.dart';
import 'package:car_social_media_app/core/shared/entities/tag_selection.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../utils/forum_tags.dart';
import '../shared/forum_avatar.dart';
import '../shared/forum_section_label.dart';
import 'forum_car_picker_sheet.dart';

/// "Tag people & cars" block, shared by the thread composer, the reply tag
/// sheet and the edit sheet. It is fully controlled — the caller owns the
/// selection and decides where it lives (bloc state or local state).
///
/// People are mentioned first; cars are then picked from a mentioned person's
/// garage (or the viewer's own), which keeps the backend's
/// owner-must-be-tagged rule satisfied by construction.
class ForumTagEditor extends StatelessWidget {
  final List<TaggedPerson> people;
  final List<TaggedCar> cars;
  final TextEditingController peopleSearchController;
  final ValueChanged<TaggedPerson> onAddPerson;
  final ValueChanged<String> onRemovePerson;
  final ValueChanged<TaggedCar> onAddCar;
  final ValueChanged<String> onRemoveCar;

  /// Shows the uppercase section header + helper text. Off inside the compact
  /// sheets, which carry their own title.
  final bool showHeader;

  const ForumTagEditor({
    super.key,
    required this.people,
    required this.cars,
    required this.peopleSearchController,
    required this.onAddPerson,
    required this.onRemovePerson,
    required this.onAddCar,
    required this.onRemoveCar,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          ForumSectionLabel(label: l10n.forumsTagPeopleAndCars),
          const SizedBox(height: 6),
          Text(
            l10n.forumsTagHelper,
            style: const TextStyle(
              color: AppColors.muteSoft,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
        ],
        _MiniLabel('${l10n.forumsTagPeople} · ${people.length}'),
        const SizedBox(height: 8),
        if (people.length >= kForumTagLimit)
          _ResultMessage(l10n.forumsTagLimitReached(kForumTagLimit))
        else ...[
          _PeopleSearchField(
            controller: peopleSearchController,
            hint: l10n.forumsTagPeopleHint,
          ),
          _PeopleResults(
            taggedIds: {for (final p in people) p.id},
            onPick: (result) {
              onAddPerson(
                TaggedPerson(
                  id: result.id,
                  username: result.username,
                  avatarUrl: result.avatarUrl,
                ),
              );
              peopleSearchController.clear();
              context.read<TagPickerBloc>().add(const PeopleResultsCleared());
            },
          ),
        ],
        if (people.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final person in people)
                _PersonChip(
                  person: person,
                  onRemove: () => onRemovePerson(person.id),
                ),
            ],
          ),
        ],
        const SizedBox(height: 18),
        _MiniLabel('${l10n.forumsTagCars} · ${cars.length}'),
        const SizedBox(height: 8),
        if (cars.length >= kForumTagLimit)
          _ResultMessage(l10n.forumsTagLimitReached(kForumTagLimit))
        else
          _AddCarTile(
            label: l10n.forumsTagAddCar,
            onTap: () async {
              final car = await showForumCarPickerSheet(
                context,
                people: people,
                takenCarIds: {for (final c in cars) c.id},
              );
              if (car != null) onAddCar(car);
            },
          ),
        if (cars.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final car in cars)
                _CarChip(car: car, onRemove: () => onRemoveCar(car.id)),
            ],
          ),
        ],
      ],
    );
  }
}

/// The username typeahead. Already-tagged profiles are filtered out.
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
            .toList(growable: false);

        return Container(
          margin: const EdgeInsets.only(top: 8),
          constraints: const BoxConstraints(maxHeight: 220),
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
            TagLoadStatus.failure => _ResultMessage(l10n.forumsTagLoadError),
            TagLoadStatus.success when results.isEmpty => _ResultMessage(
              l10n.forumsTagNoPeopleFound,
            ),
            _ => ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: results.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.line2, indent: 14),
              itemBuilder: (_, i) => _PersonResultRow(
                result: results[i],
                onTap: () => onPick(results[i]),
              ),
            ),
          },
        );
      },
    );
  }
}

class _PersonResultRow extends StatelessWidget {
  final SearchResultEntity result;
  final VoidCallback onTap;

  const _PersonResultRow({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            ForumAvatar(
              username: result.username,
              avatarUrl: result.avatarUrl,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '@${result.username}',
                overflow: TextOverflow.ellipsis,
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

class _PeopleSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _PeopleSearchField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.bgSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 18, color: AppColors.mute),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              cursorColor: AppColors.accent,
              onChanged: (q) =>
                  context.read<TagPickerBloc>().add(PeopleQueryChanged(q)),
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
                hintText: hint,
                hintStyle: const TextStyle(
                  color: AppColors.muteSoft,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniLabel extends StatelessWidget {
  final String text;
  const _MiniLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.mute,
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
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

class _AddCarTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddCarTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.accent,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.fromLTRB(5, 5, 9, 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ForumAvatar(
            username: person.username,
            avatarUrl: person.avatarUrl,
            size: 26,
          ),
          const SizedBox(width: 8),
          Text(
            '@${person.username}',
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          _RemoveButton(onTap: onRemove),
        ],
      ),
    );
  }
}

class _CarChip extends StatelessWidget {
  final TaggedCar car;
  final VoidCallback onRemove;

  const _CarChip({required this.car, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final url = car.imageUrl;
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 9, 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 34,
              height: 34,
              child: url != null
                  ? CachedNetworkImage(imageUrl: url, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.bg,
                      child: const Icon(
                        Icons.directions_car_rounded,
                        color: AppColors.muteSoft,
                        size: 18,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 9),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                car.name,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (car.ownerHandle.isNotEmpty)
                Text(
                  '@${car.ownerHandle}',
                  style: const TextStyle(
                    color: AppColors.mute,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 9),
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
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.line),
        ),
        child: const Icon(Icons.close_rounded, size: 13, color: AppColors.mute),
      ),
    );
  }
}
