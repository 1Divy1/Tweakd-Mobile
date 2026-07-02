import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class FeedbackLoadingView extends StatelessWidget {
  const FeedbackLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.accent),
    );
  }
}
