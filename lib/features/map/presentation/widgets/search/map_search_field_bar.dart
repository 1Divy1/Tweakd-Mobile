import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tweakd/l10n/app_localizations.dart';

import '../../../../../core/shared/widgets/app_pill_button.dart';
import '../../../../../core/shared/widgets/search_input.dart';

/// Back button and the search field, in one row across the top of the search
/// screen. The field takes focus on open: the user came here to type.
class MapSearchFieldBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const MapSearchFieldBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        AppPillButton(
          icon: Icons.chevron_left_rounded,
          onTap: () => context.pop(),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SearchInput(
            controller: controller,
            onChanged: onChanged,
            onClear: onClear,
            hintText: l10n.mapSearchHint,
          ),
        ),
      ],
    );
  }
}
