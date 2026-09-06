import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/shared/widgets/app_pill_button.dart';
import '../../../../../l10n/app_localizations.dart';
import 'create_picker_sheet.dart';

/// The "+" in the top-left of your own profile: the entry point for creating a
/// post, a car event or a garage car.
class CreateButton extends StatelessWidget {
  const CreateButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context)!.profileCreateButton,
      button: true,
      child: AppPillButton(
        icon: Icons.add_rounded,
        onTap: () => _openChooser(context),
      ),
    );
  }

  Future<void> _openChooser(BuildContext context) async {
    final action = await showCreatePickerSheet(context);
    if (action == null || !context.mounted) return;
    switch (action) {
      case CreateAction.post:
        context.push('/posts/create');
      case CreateAction.carEvent:
        context.push('/map-events/create');
      case CreateAction.car:
        context.push('/garage/cars/add');
    }
  }
}
