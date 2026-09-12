import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/shared/widgets/app_pill_button.dart';
import '../../../../../l10n/app_localizations.dart';

/// The megaphone in the leading slot of your own profile: one tap to the
/// community feedback board, where members suggest features, report bugs and
/// vote on each other's ideas.
class FeedbackButton extends StatelessWidget {
  const FeedbackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: AppLocalizations.of(context)!.profileFeedbackButton,
      child: AppPillButton(
        icon: Icons.campaign_outlined,
        onTap: () => context.push('/feedback-feed'),
      ),
    );
  }
}
