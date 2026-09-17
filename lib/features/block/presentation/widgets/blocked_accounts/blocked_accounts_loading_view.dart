import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class BlockedAccountsLoadingView extends StatelessWidget {
  const BlockedAccountsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: AppColors.accent),
    );
  }
}
