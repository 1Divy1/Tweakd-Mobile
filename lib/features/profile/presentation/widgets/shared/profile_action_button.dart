import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// One of the white pill actions under the profile header — Edit profile,
/// Share profile, Message. They always come in pairs sharing a row, so they
/// carry no width of their own: the caller wraps each in an `Expanded`.
///
/// The label stays on one line and ellipsizes rather than wrapping: two of
/// these on a 320pt screen leave about 130pt each, which "Distribuie profilul"
/// comfortably exceeds. The height is a minimum, not a fixed value, so a large
/// system text size grows the button instead of clipping the label.
class ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ProfileActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: Icon(icon, color: AppColors.ink, size: 19),
        // No Flexible here: OutlinedButton.icon already wraps the label in one,
        // and a second competing ParentDataWidget is an error.
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
