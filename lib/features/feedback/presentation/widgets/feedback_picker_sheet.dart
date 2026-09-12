import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Shared scaffolding for a picker bottom sheet: grab handle, title, then a
/// scrollable column of rows.
class FeedbackPickerSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const FeedbackPickerSheet({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: children),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
