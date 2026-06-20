import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/onboarding reference/community_role_entity.dart';
import '../onboarding_fields.dart';
import '../onboarding_pickers.dart';

/// Step 3 — the community roles the user identifies with. Multi-select; at
/// least one is required (backend `role_ids` is non-empty).
class RoleStep extends StatelessWidget {
  final List<CommunityRoleEntity> roles;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  const RoleStep({
    super.key,
    required this.roles,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingSectionHeader(
          label: '03 — ROLE',
          title: 'Your role in the scene',
          subtitle: 'How do you show up in the community? Choose all that '
              'apply — it shapes who you meet.',
        ),
        const SizedBox(height: 20),
        const OnboardingFieldLabel('ROLES'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final role in roles)
              OnboardingChoicePill(
                label: role.name.toUpperCase(),
                selected: selectedIds.contains(role.id),
                onTap: () => onToggle(role.id),
              ),
          ],
        ),
      ],
    );
  }
}
