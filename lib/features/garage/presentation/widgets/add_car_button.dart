import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// The owner's quiet "Add new car" link under their garage on the profile.
///
/// Deliberately low-key — no fill, muted ink: a car gets added once every few
/// years, so it shouldn't compete with the cars themselves. Still a full
/// 44pt-tall tap target.
class AddCarButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AddCarButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.mute,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
