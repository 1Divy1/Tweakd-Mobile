import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// The display name, shown beside the avatar. The `@username` is not repeated
/// here — the profile top bar carries it.
class ProfileIdentity extends StatelessWidget {
  final String name;

  const ProfileIdentity({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name.isEmpty ? '—' : name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
