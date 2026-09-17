import 'package:flutter/material.dart';

import 'package:tweakd/l10n/app_localizations.dart';

import '../../theme/app_colors.dart';
import '../layout/app_layout.dart';

class SearchTopBar extends StatelessWidget {
  const SearchTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(16, 8, 16, 12) + AppLayout.inset(context),
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Center(
        child: Text(
          AppLocalizations.of(context)!.searchTitle,
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
