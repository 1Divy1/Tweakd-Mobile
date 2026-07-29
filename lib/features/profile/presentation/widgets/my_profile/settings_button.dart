import 'package:flutter/material.dart';

import '../../../../../core/shared/widgets/app_pill_button.dart';

class SettingsButton extends StatelessWidget {
  final VoidCallback onTap;

  const SettingsButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppPillButton(icon: Icons.settings_outlined, onTap: onTap);
  }
}
