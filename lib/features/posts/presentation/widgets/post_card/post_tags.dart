import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/post_tagged_car.dart';
import '../../../domain/entities/post_user.dart';

/// Shared row of a post's tagged cars and people, rendered as pill chips.
/// Reused by the feed card and the post detail view. Tapping a person opens
/// their profile; tapping a car opens that car in its owner's garage.
class PostTags extends StatelessWidget {
  final List<PostUserEntity> people;
  final List<PostTaggedCarEntity> cars;

  const PostTags({super.key, required this.people, required this.cars});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final car in cars)
          _TagChip(
            icon: Icons.directions_car_rounded,
            label: '${car.make} ${car.model}'.trim(),
            // The tagged car belongs to another user, so it opens read-only.
            onTap: () => context.push('/garage/cars/${car.id}', extra: false),
          ),
        for (final person in people)
          _TagChip(
            icon: Icons.person_rounded,
            label: '@${person.username}',
            onTap: () => context.push(
              '/users/${person.username}',
              extra: person.id,
            ),
          ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _TagChip({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.accent),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
