import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/shared/widgets/app_pill_button.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../bloc/home/bloc.dart';
import '../../bloc/home/event.dart';

/// The Forums segment's own actions, at the end of the home tab's segment
/// bar: browse every forum, and saved threads. Both re-sync the forums home on
/// return — a shortcut may have been pinned, a save undone.
class ForumsHomeActions extends StatelessWidget {
  const ForumsHomeActions({super.key});

  Future<void> _open(BuildContext context, String location) async {
    final bloc = context.read<ForumsHomeBloc>();
    await context.push(location);
    bloc.add(const RefreshForumsHome());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          container: true,
          button: true,
          label: l10n.forumsBrowseAction,
          child: AppPillButton(
            icon: Icons.explore_outlined,
            size: 36,
            iconSize: 19,
            onTap: () => _open(context, '/forums/browse'),
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          container: true,
          button: true,
          label: l10n.forumsSavedAction,
          child: AppPillButton(
            icon: Icons.bookmark_border_rounded,
            size: 36,
            iconSize: 19,
            onTap: () => _open(context, '/forums/saved'),
          ),
        ),
      ],
    );
  }
}
