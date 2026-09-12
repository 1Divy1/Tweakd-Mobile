import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class MyFeedbackLoadingView extends StatelessWidget {
  const MyFeedbackLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: AppColors.accent),
    );
  }
}
