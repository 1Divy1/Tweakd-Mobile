import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

class MyReportsEmptyView extends StatelessWidget {
  const MyReportsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, size: 48, color: AppColors.muteSoft),
            const SizedBox(height: 16),
            Text(
              l10n.myReportsEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mute,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
