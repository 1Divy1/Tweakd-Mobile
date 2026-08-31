import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tweakd/features/garage/domain/entities/car_summary.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/forum_author.dart';

/// The tagged cars and people of a thread or reply, as tappable chips. Cars
/// open read-only in their owner's garage; people open their profile.
/// Renders nothing when both lists are empty.
class ForumTagRow extends StatelessWidget {
  final List<ForumAuthorEntity> people;
  final List<CarSummaryEntity> cars;

  /// Tighter type/padding for thread cards in lists.
  final bool dense;

  const ForumTagRow({
    super.key,
    required this.people,
    required this.cars,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty && cars.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: dense ? 6 : 8,
      runSpacing: dense ? 6 : 8,
      children: [
        for (final car in cars)
          _TagChip(
            icon: Icons.directions_car_rounded,
            label: '${car.brand} ${car.model}'.trim(),
            dense: dense,
            // The car belongs to someone else's garage, so it opens read-only.
            onTap: () => context.push('/garage/cars/${car.id}', extra: false),
          ),
        for (final person in people)
          _TagChip(
            icon: Icons.person_rounded,
            label: '@${person.username}',
            dense: dense,
            onTap: () =>
                context.push('/users/${person.username}', extra: person.id),
          ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool dense;
  final VoidCallback onTap;

  const _TagChip({
    required this.icon,
    required this.label,
    required this.dense,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? 8 : 10,
          vertical: dense ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.line2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: dense ? 12 : 14, color: AppColors.ink),
            SizedBox(width: dense ? 4 : 6),
            Text(
              label,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: dense ? 11 : 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
