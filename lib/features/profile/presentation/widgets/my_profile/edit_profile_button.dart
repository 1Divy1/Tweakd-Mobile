import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../shared/profile_action_button.dart';

/// The "Edit profile" pill on the own-profile page. Shares the action row with
/// [ShareProfileButton], in the same slot where the public profile shows
/// Follow / Message.
class EditProfileButton extends StatelessWidget {
  final VoidCallback onTap;

  const EditProfileButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ProfileActionButton(
      icon: Icons.edit_outlined,
      label: AppLocalizations.of(context)!.profileEditButton,
      onTap: onTap,
    );
  }
}
