import 'package:flutter/material.dart';

import 'package:car_social_media_app/core/shared/entities/tag_selection.dart';

import '../../../../../core/theme/app_colors.dart';

/// Compact, horizontally scrolling strip of the tags attached to a reply that
/// is being composed. Sits above the reply input bar; each chip removes itself.
class ForumTagStrip extends StatelessWidget {
  final List<TaggedPerson> people;
  final List<TaggedCar> cars;
  final ValueChanged<String> onRemovePerson;
  final ValueChanged<String> onRemoveCar;

  const ForumTagStrip({
    super.key,
    required this.people,
    required this.cars,
    required this.onRemovePerson,
    required this.onRemoveCar,
  });

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty && cars.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: 6),
        children: [
          for (final car in cars)
            _StripChip(
              icon: Icons.directions_car_rounded,
              label: car.name,
              onRemove: () => onRemoveCar(car.id),
            ),
          for (final person in people)
            _StripChip(
              icon: Icons.person_rounded,
              label: '@${person.username}',
              onRemove: () => onRemovePerson(person.id),
            ),
        ],
      ),
    );
  }
}

class _StripChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onRemove;

  const _StripChip({
    required this.icon,
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.fromLTRB(9, 4, 5, 4),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.accent),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.mute,
            ),
          ),
        ],
      ),
    );
  }
}
