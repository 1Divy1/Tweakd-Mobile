import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../shared/profile_action_button.dart';

/// "Share profile", sharing the action row with Edit profile on your own
/// profile.
///
/// UI only for now — there is no share target yet. Sharing needs a public URL
/// for a profile, which means a web route and a backend deep-link contract;
/// neither exists. Wire [_share] up once they do.
class ShareProfileButton extends StatelessWidget {
  const ShareProfileButton({super.key});

  void _share(BuildContext context) {
    // TODO(share): open the system share sheet with the profile's public link
    // once the backend exposes one.
  }

  @override
  Widget build(BuildContext context) {
    return ProfileActionButton(
      icon: Icons.ios_share,
      label: AppLocalizations.of(context)!.profileShareButton,
      onTap: () => _share(context),
    );
  }
}
